import { describe, expect, it } from 'vitest';
import { fixture } from '@uml/fixtures';
import { buildGenerationIr } from '@uml/generation-ir';
import { generateMobileProject } from '@uml/generator-backend';

describe('paquete Android del diagrama', () => {
  it('incluye backend protegido y cliente offline del mismo contrato, sin secretos ni pesos', async () => {
    const ir = buildGenerationIr({
      projectName: 'Ventas',
      snapshotVersion: 1,
      model: fixture('T01').model,
    });
    const first = await generateMobileProject(ir);
    const second = await generateMobileProject(ir);
    expect(first.zip.equals(second.zip)).toBe(true);
    const content = (path: string) => first.files.find((f) => f.path.endsWith(path))!.content;
    expect(content('mobile/assets/contract.json')).toBe(content('backend/docs/dto-contract.json'));
    expect(content('backend/src/main/resources/mobile-contract.json')).toBe(
      content('mobile/assets/contract.json'),
    );
    expect(content('MobileContractController.java')).toContain('@GetMapping("/mobile-contract")');
    expect(content('mobile/tool/start_backend.dart')).toContain('Random.secure()');
    expect(content('MobileSecurity.java')).toContain('anyRequest().authenticated()');
    expect(content('MobileSyncController.java')).toContain('UUID.fromString(node.asText())');
    expect(content('MobileSyncController.java')).not.toContain('__HANDLERS__');
    expect(content('mobile/pubspec.yaml')).toContain('llama_flutter_android: 0.2.6');
    expect(content('backend/.env.example')).toContain('AUTH_TOKEN_SECRET=\n');
    expect(first.files.some((f) => f.path.endsWith('.gguf'))).toBe(false);
    expect(first.files.some((f) => f.path.endsWith('.litertlm') || f.path.endsWith('.bin'))).toBe(
      false,
    );
    for (const path of [
      'mobile/lib/data/model_library.dart',
      'mobile/lib/data/local_speech.dart',
      'mobile/lib/domain/assistant_prompt.dart',
      'mobile/lib/ui/local_model_settings.dart',
      'mobile/docs/local-models.md',
    ])
      expect(content(path)).toBeTruthy();
  });
});
