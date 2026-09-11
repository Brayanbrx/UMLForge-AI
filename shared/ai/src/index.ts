/**
 * @uml/ai
 *
 * Capa de IA desacoplada (plan maestro 6).
 *
 * Ningun modulo del dominio conoce un proveedor concreto (RA-14). Se consume a
 * traves de tres puertos, y cada proveedor es un adaptador intercambiable por
 * configuracion.
 *
 * Dos reglas que gobiernan todo lo demas:
 *
 *   - **El modelo nunca toca el estado.** Devuelve una propuesta; el sistema la
 *     resuelve, la valida y la aplica.
 *   - **El modelo nunca resuelve identificadores.** Devuelve nombres, y el
 *     resolver los busca contra el modelo real.
 */
export * from './ports.js';
export * from './proposal.js';
export * from './resolver.js';
export * from './registry.js';
export {
  SUPPORTED_AUDIO_TYPES,
  SUPPORTED_IMAGE_TYPES,
  describir,
  inferirTipoAtributo,
  interpretarPropuesta,
} from './prompt.js';
export { MockLlmPort, MockSpeechPort, MockVisionPort, nombreDeClase } from './adapters/mock.js';
export { AnthropicLlmPort, type AnthropicAdapterOptions } from './adapters/anthropic.js';
export { AnthropicVisionPort, type AnthropicVisionOptions } from './adapters/anthropic-vision.js';
export { GeminiLlmPort, GeminiVisionPort, type GeminiAdapterOptions } from './adapters/gemini.js';
export {
  OpenRouterLlmPort,
  OpenRouterVisionPort,
  type OpenRouterAdapterOptions,
} from './adapters/openrouter.js';
export { GroqSpeechPort, type GroqSpeechOptions } from './adapters/groq.js';
export { CloudflareSpeechPort, type CloudflareSpeechOptions } from './adapters/cloudflare.js';
