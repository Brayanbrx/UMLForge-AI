import { afterEach, expect, it, vi } from 'vitest';
import {
  createAiPorts,
  describeAiChains,
  loadAiConfig,
  ProviderContractError,
} from '../src/index.js';

afterEach(() => {
  vi.unstubAllGlobals();
  vi.useRealTimers();
});
const snapshot = { classes: [], relationships: [] };
const question = { question: 'Explica el diseno actual', snapshot };
const base = {
  AI_LLM_PROVIDER: 'openrouter',
  AI_LLM_MODEL: 'primary',
  OPENROUTER_API_KEY: 'secret',
  AI_MAX_RETRIES: '0',
};
const reply = () =>
  new Response(
    JSON.stringify({
      choices: [{ message: { content: 'respuesta' } }],
      usage: { prompt_tokens: 100, completion_tokens: 5 },
    }),
  );
const entry = (model: string) => ({ provider: 'openrouter', model });

it('recorre principal y siete respaldos en orden, termina en el primero exitoso', async () => {
  const calls: string[] = [];
  vi.stubGlobal(
    'fetch',
    vi.fn(async (_url: string, init: RequestInit) => {
      const body = JSON.parse(String(init.body)) as { model: string };
      calls.push(body.model);
      return calls.length === 8 ? reply() : new Response('{}', { status: 429 });
    }),
  );
  const ports = createAiPorts(
    loadAiConfig({
      ...base,
      AI_LLM_FALLBACKS: JSON.stringify(Array.from({ length: 7 }, (_, i) => entry(`f${i}`))),
    }),
  );
  expect((await ports.llm.answer(question)).text).toBe('respuesta');
  expect(calls).toEqual(['primary', 'f0', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6']);
  expect(ports.usageLog).toHaveLength(1);
});

it('legacy es el primer respaldo y el array continua despues', async () => {
  const config = loadAiConfig({
    ...base,
    AI_LLM_FALLBACK_PROVIDER: 'openrouter',
    AI_LLM_FALLBACK_MODEL: 'legacy',
    AI_LLM_FALLBACKS: JSON.stringify([entry('third')]),
  });
  expect(describeAiChains(config)).toContain(
    'openrouter/primary → openrouter/legacy → openrouter/third',
  );
});

it.each([
  { AI_LLM_FALLBACKS: '{mal' },
  { AI_LLM_FALLBACKS: JSON.stringify(Array.from({ length: 8 }, (_, i) => entry(`f${i}`))) },
  {
    AI_LLM_FALLBACK_PROVIDER: 'openrouter',
    AI_LLM_FALLBACK_MODEL: 'legacy',
    AI_LLM_FALLBACKS: JSON.stringify(Array.from({ length: 7 }, (_, i) => entry(`f${i}`))),
  },
  { AI_LLM_FALLBACKS: JSON.stringify([entry('primary')]) },
  { AI_LLM_FALLBACKS: '[{"provider":"mistral"}]' },
  { AI_SPEECH_FALLBACKS: '[{"provider":"zai","model":"glm-4.7-flash"}]' },
  { AI_VISION_PROVIDER: 'zai', AI_VISION_MODEL: 'glm-4.7-flash' },
  { AI_LLM_FALLBACKS: '[{"provider":"mistral","model":"x","enable":false}]' },
  { MISTRAL_BASE_URL: 'http://example.invalid/v1' },
])('rechaza cadenas invalidas sin llamar a ninguna API: %j', (extra) => {
  expect(() => loadAiConfig({ ...base, ...extra })).toThrow();
});

it('una plantilla desactivada no exige clave; al activarla falla antes de arrancar', () => {
  expect(() =>
    createAiPorts(
      loadAiConfig({
        ...base,
        AI_LLM_FALLBACKS: '[{"provider":"mistral","model":"mistral-small-latest","enabled":false}]',
      }),
    ),
  ).not.toThrow();
  expect(() =>
    createAiPorts(
      loadAiConfig({
        ...base,
        AI_LLM_FALLBACKS: '[{"provider":"mistral","model":"mistral-small-latest"}]',
      }),
    ),
  ).toThrow(/MISTRAL_API_KEY/);
});

it.each([402, 429])(
  'HTTP %i salta sin reintentar y respeta Retry-After entre solicitudes',
  async (status) => {
    vi.useFakeTimers({ toFake: ['Date'] });
    const calls = vi
      .fn()
      .mockResolvedValueOnce(new Response('{}', { status, headers: { 'Retry-After': '120' } }))
      .mockImplementation(reply);
    vi.stubGlobal('fetch', calls);
    const ports = createAiPorts(
      loadAiConfig({
        ...base,
        AI_MAX_RETRIES: '3',
        AI_LLM_FALLBACKS: JSON.stringify([entry('backup')]),
      }),
    );
    await ports.llm.answer(question);
    await ports.llm.answer(question);
    expect(calls).toHaveBeenCalledTimes(3);
    const model = (i: number) =>
      (JSON.parse(String((calls.mock.calls[i]?.[1] as RequestInit).body)) as { model: string })
        .model;
    expect([model(0), model(1), model(2)]).toEqual(['primary', 'backup', 'backup']);
    vi.setSystemTime(Date.now() + 120001);
    await ports.llm.answer(question);
    expect(model(3)).toBe('primary');
  },
);

it.each([400, 401, 403, 404])(
  'HTTP %i no desperdicia una segunda llamada por configuracion incorrecta',
  async (status) => {
    const calls = vi.fn(async () => new Response('{}', { status }));
    vi.stubGlobal('fetch', calls);
    const ports = createAiPorts(
      loadAiConfig({ ...base, AI_LLM_FALLBACKS: JSON.stringify([entry('backup')]) }),
    );
    await expect(ports.llm.answer(question)).rejects.toBeInstanceOf(ProviderContractError);
    expect(calls).toHaveBeenCalledTimes(1);
  },
);

it('una respuesta incompleta no se presenta como propuesta valida ni se reenvia', async () => {
  const calls = vi.fn(
    async () =>
      new Response(
        JSON.stringify({
          choices: [{ finish_reason: 'length', message: { content: '{"operations":[]}' } }],
        }),
      ),
  );
  vi.stubGlobal('fetch', calls);
  const ports = createAiPorts(
    loadAiConfig({ ...base, AI_LLM_FALLBACKS: JSON.stringify([entry('backup')]) }),
  );
  await expect(
    ports.llm.proposeCommands({ instruction: 'crea Cliente', snapshot }),
  ).rejects.toThrow(/limite de salida/);
  expect(calls).toHaveBeenCalledTimes(1);
});

it('detecta cuota dentro de una respuesta HTTP 200', async () => {
  const calls = vi
    .fn()
    .mockResolvedValueOnce(new Response('{"error":{"code":429}}'))
    .mockImplementation(reply);
  vi.stubGlobal('fetch', calls);
  const ports = createAiPorts(
    loadAiConfig({ ...base, AI_LLM_FALLBACKS: JSON.stringify([entry('backup')]) }),
  );
  await expect(ports.llm.answer(question)).resolves.toMatchObject({ text: 'respuesta' });
  expect(calls).toHaveBeenCalledTimes(2);
});

it.each(['cancel', 'deadline'])(
  'la cadena se detiene por %s sin iniciar otro proveedor',
  async (mode) => {
    const controller = new AbortController();
    const calls = vi.fn(
      (_url: string, init: RequestInit) =>
        new Promise<Response>((_resolve, reject) => {
          init.signal?.addEventListener('abort', () => reject(new Error('abortado')), {
            once: true,
          });
          if (mode === 'cancel') controller.abort();
        }),
    );
    vi.stubGlobal('fetch', calls);
    const ports = createAiPorts(
      loadAiConfig({
        ...base,
        AI_CHAIN_TIMEOUT_MS: '10',
        AI_LLM_FALLBACKS: JSON.stringify([entry('backup')]),
      }),
    );
    await expect(ports.llm.answer({ ...question, signal: controller.signal })).rejects.toThrow();
    expect(calls).toHaveBeenCalledTimes(1);
  },
);

it.each([
  ['mistral', 'mistral-small-latest', 'MISTRAL_API_KEY', 'api.mistral.ai'],
  ['zai', 'glm-4.6v-flash', 'ZAI_API_KEY', 'api.z.ai'],
  ['moonshot', 'kimi-k2.6', 'MOONSHOT_API_KEY', 'api.moonshot.ai'],
  ['moonshot', 'kimi-k3', 'MOONSHOT_API_KEY', 'api.moonshot.ai'],
  ['sambanova', 'Meta-Llama-3.3-70B-Instruct', 'SAMBANOVA_API_KEY', 'api.sambanova.ai'],
  ['groq', 'llama-3.3-70b-versatile', 'GROQ_API_KEY', 'api.groq.com'],
])(
  '%s/%s manda texto e imagen al endpoint y registra el proveedor correcto',
  async (provider, model, key, host) => {
    const calls = vi.fn(
      async () =>
        new Response(JSON.stringify({ choices: [{ message: { content: '{"operations":[]}' } }] })),
    );
    vi.stubGlobal('fetch', calls);
    const ports = createAiPorts(
      loadAiConfig({
        AI_LLM_PROVIDER: provider,
        AI_LLM_MODEL: model,
        AI_VISION_PROVIDER: provider,
        AI_VISION_MODEL: model,
        [key!]: 'secret',
      }),
    );
    await ports.llm.proposeCommands({ instruction: 'crea Cliente', snapshot });
    await ports.vision.extractModel({ image: new Uint8Array([1, 2]), mediaType: 'image/png' });
    const [url, init] = calls.mock.calls[1] as unknown as [string, RequestInit];
    expect(new URL(url).hostname).toBe(host);
    expect(url).toContain('/chat/completions');
    expect(init.headers).toMatchObject({ authorization: 'Bearer secret' });
    const body = JSON.parse(String(init.body)) as Record<string, unknown>;
    expect(JSON.stringify(body.messages)).toContain('data:image/png;base64,');
    if (provider === 'moonshot') {
      expect(body.temperature).toBeUndefined();
      if (model === 'kimi-k3') {
        expect(body.reasoning_effort).toBe('low');
        expect(body.thinking).toBeUndefined();
      } else expect(body.thinking).toEqual({ type: 'disabled' });
    }
    expect(ports.usageLog.map((u) => u.provider)).toEqual([provider, provider]);
  },
);

it('Mistral transcribe con Voxtral y formulario, sin parametros exclusivos de Groq', async () => {
  const calls = vi.fn(async () => new Response('{"text":"Crea Cliente"}'));
  vi.stubGlobal('fetch', calls);
  const ports = createAiPorts(
    loadAiConfig({
      AI_SPEECH_PROVIDER: 'mistral',
      AI_SPEECH_MODEL: 'voxtral-mini-latest',
      MISTRAL_API_KEY: 'secret',
    }),
  );
  await expect(
    ports.speech.transcribe({ audio: new Uint8Array([1]), mediaType: 'audio/webm' }),
  ).resolves.toMatchObject({ text: 'Crea Cliente', usage: { provider: 'mistral' } });
  const [url, init] = calls.mock.calls[0] as unknown as [string, RequestInit];
  expect(url).toBe('https://api.mistral.ai/v1/audio/transcriptions');
  expect((init.body as FormData).get('model')).toBe('voxtral-mini-latest');
  expect((init.body as FormData).has('temperature')).toBe(false);
});
