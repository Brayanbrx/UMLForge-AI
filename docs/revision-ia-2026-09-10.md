# Revisión del asistente de texto y voz

Fecha: 10 de septiembre de 2026. Actualiza la [revisión del 6 de septiembre](revision-ia-2026-09-06.md).

## Cambios implementados

- Prompt común de instrucciones reorganizado por intención, contexto, referencias, tipos, restricciones y relaciones. Explicita autocorrecciones parciales, negaciones, cardinalidades dictadas y opciones ordinales. No permite representar funciones no soportadas mediante cambios inventados ni afirmar que una propuesta ya se aplicó.
- Las propiedades `required:false` y `unique:false` se explican expresamente. Un nombre `id` no autoriza por sí solo a añadir una clave primaria. Las multiplicidades exactas fuera del vocabulario, como `2..5`, requieren aclaración en vez de una aproximación silenciosa.
- Prompt de consulta: diferencia datos existentes de sugerencias y evita equiparar ausencia de hallazgos del validador con proyecto completo, desplegado o probado.
- Contexto y hallazgos serializados como JSON para separar el texto de los datos de los encabezados. Esto reduce ambigüedad de formato; no sustituye la validación ni garantiza inmunidad a instrucciones incrustadas.
- Las opciones de una aclaración se muestran y envían con la misma numeración, sin ocultar la novena en adelante. Si el contexto excede el contrato, se recupera completo para revisión, sin truncarlo.
- Al rechazar una propuesta desactualizada, se recuperan la instrucción y sus aclaraciones originales; antes solo se recuperaba la última respuesta, como «la primera».
- Inferencia determinista corregida: `numeroTelefono`, `numeroDocumento` y `codigoPostal` son texto; `Madrid` y `Android` no se convierten en enteros por terminar en `id`. Se reconocen `clienteID`, `IDCliente` y `UUIDCliente`. Un tipo explícito conserva prioridad.
- Si el dictado falla sin reconocer palabras, el borrador anterior permanece intacto, incluidos espacios y preámbulos. Se mantiene Dictar → Parar → revisar → Enviar, sin llamadas LLM por resultados parciales ni una llamada adicional para limpiar el dictado.
- Botón **Cancelar solicitud** para instrucciones y consultas. Recupera el texto, ignora respuestas tardías y cancela HTTP. El cambio de pizarra o desmontaje del panel también cancela. La API propaga la desconexión a los puertos de instrucciones, consultas y transcripción; la cadena existente respeta esa señal. Cancelar no revierte tokens ya procesados.

## Verificación

- **527/527 pruebas unitarias**, en 33 archivos. Evidencia: `reports/revision-ia-2026-09-10/unitarias.xml`.
- **13/13 pruebas de integración** de las rutas del asistente con PostgreSQL temporal y proveedores simulados. Evidencia: `integracion.xml` en el mismo directorio.
- **7/7 pruebas de Chromium** contra Docker: voz, pausas, cancelación, permisos del micrófono, contexto largo, opciones y recuperación de una propuesta desactualizada tras edición de otro usuario. Reconocimiento y respuestas LLM simulados; cuentas y colaboración reales del entorno local. Evidencia: `navegador.xml`.
- Después del ajuste de legibilidad de la conversación, **13/13 pruebas finales de Chromium**: las siete anteriores y seis tamaños móviles, de 320 × 568 a 844 × 390. Evidencia: `navegador-final.xml`.
- TypeScript y ESLint aprobados. API y web compiladas y actualizadas en Docker.
- Comprobación final de formato y `git diff --check` aprobada. Los cuatro contenedores quedaron saludables; se conservaron la base de datos y los volúmenes.
- Prueba HTTP con servidor real: recibir un POST completo no cancela la inferencia; abortar la conexión mientras se espera la respuesta sí lo hace. La respuesta normal libera los listeners sin marcar cancelación. Se siguió la distinción entre finalización y cierre prematuro de [ServerResponse en Node.js](https://nodejs.org/api/http.html#event-close_2).

La primera ejecución unitaria falló únicamente en una expectativa que exigía el formato anterior `Usuario: ...`; se actualizó para comprobar los turnos JSON completos y la suite volvió a pasar. No se interpreta este cambio de formato como pérdida de contexto.

## Evaluación del proveedor real

Se preparó [un banco optativo de ocho casos](../scripts/verify-ai-prompts.ts): negación/autocorrección, cardinalidades habladas, restricciones negativas, herencia, acciones dependientes, aclaración ordinal, teléfono y límite no representable. Utiliza diagramas sintéticos, el principal configurado, ningún respaldo, cero reintentos y 45 segundos por llamada. No lee ni modifica pizarras del usuario.

La revisión automática bloqueó el primer intento por límite de uso de Codex, antes de ejecutar la llamada. Después de que el usuario pidió continuar, la ejecución fue autorizada. El primer caso con `gemini / gemini-3.7-flash` terminó con `ProviderUnavailableError` (plazo configurado: 45 segundos); el banco se detuvo. El registro conserva el tipo de error, no acredita su causa remota exacta. **No hay casos reales aprobados ni evidencia suficiente para afirmar mejora de exactitud, ahorro monetario o disponibilidad de todos los proveedores.** El resultado está en `reports/revision-ia-2026-09-10/proveedor-real.json`. El fallo del principal aislado no demuestra que fallen los respaldos de la aplicación.

El prompt de instrucciones tiene 3.822 caracteres, el de consulta 755 y el bloque de esquema 1.751. Son caracteres, no tokens. Se priorizaron reglas que evitan cambios incorrectos y solicitudes repetidas; no se acredita una reducción del tamaño total del prompt ni del costo.

## Límites pendientes

- Repetir el banco cuando el principal responda y comparar exactitud por proveedor. Las pruebas simuladas acreditan contratos y flujo, no comprensión del lenguaje natural.
- Micrófono físico y reconocimiento en distintos navegadores y teléfonos. Se conserva el servicio del navegador; los adaptadores de transcripción del servidor aún no están conectados mediante MediaRecorder como alternativa desde el botón Dictar. Los resultados provisionales pueden cambiar o desaparecer según [Web Speech](https://developer.mozilla.org/en-US/docs/Web/API/SpeechRecognitionEvent/results); el flujo mantiene la revisión manual.
- Límites de consumo y concurrencia por usuario/proyecto y registro privado y persistente de intentos, incluidos fallos. El registro actual de uso sigue siendo agregado en memoria.
- Cancelación y reutilización de extracciones en el panel de importación visual. Esta revisión conecta la cancelación del asistente, no la de todas las operaciones de importación.
- La consulta es sobre la pizarra actual y no tiene una conversación propia de seguimiento; las aclaraciones conservadas pertenecen a Instruir.

Las operaciones propuestas siguen pasando por el contrato, la resolución de referencias y las precondiciones colaborativas antes de aplicarse por decisión de la persona.
