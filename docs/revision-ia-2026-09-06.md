# Revisión del prompt y uso de IA

Fecha: 6 de septiembre de 2026. Alcance: instrucciones, consultas, extracción visual, resolución de operaciones, contexto de aclaraciones y consumo de proveedores.

## Estado

El flujo tiene mejores reglas y validaciones, y ya evita algunas llamadas innecesarias. **Todavía falta controlar el gasto por usuario, cancelar solicitudes abandonadas y medir calidad con proveedores reales.** Añadir respaldos aumenta disponibilidad; no establece un presupuesto ni garantiza mejores respuestas.

## Correcciones realizadas en esta revisión

- Instrucciones de texto: una respuesta incompleta ya no se rescata como si fuera una propuesta completa. Se rechazan operaciones con campos desconocidos y actualizaciones sin ningún cambio indicado. La recuperación parcial de visión permanece explícita y con aviso.
- Se comprueba el motivo de finalización del proveedor: un JSON aparentemente válido no basta si el proveedor informa truncamiento. Se conserva la recuperación visual explícita de Gemini cuando corresponde.
- El resolver procesa una vista temporal actualizada tras cada operación. Crear, renombrar, añadir atributos y volver a usar el nombre nuevo dentro de un mismo pedido ya no depende del estado anterior a la solicitud.
- Corregida la asignación de multiplicidades cuando el pedido menciona los extremos de una relación en orden inverso. Los roles ahora permiten desambiguar relaciones paralelas al modificarlas o eliminarlas.
- El prompt especifica dependencias, reutilización de entidades, negaciones, autocorrecciones, roles y límites de campos. Las aclaraciones solicitan una respuesta concreta y no mezclan preguntas con operaciones para aplicar. Los nombres se serializan como datos; esto no sustituye la validación ni garantiza inmunidad a instrucciones maliciosas dentro de los datos.
- La conversación conserva el pedido y las aclaraciones. Cuando excede el contexto permitido, se ofrece recuperar la solicitud completa para editarla; no se elimina silenciosamente el inicio del pedido.
- Las consultas exactas admitidas sobre cantidad de clases, cantidad de relaciones y lista de clases se responden localmente, sin llamar a un proveedor. Otras preguntas mantienen el flujo LLM.
- Los errores de configuración de Anthropic ya no se tratan como caídas que disparen respaldos innecesarios. Se muestra la explicación breve de la propuesta cuando existe.

Implementación principal: [prompt](../shared/ai/src/prompt.ts), [contrato](../shared/ai/src/proposal.ts), [resolver](../shared/ai/src/resolver.ts), [respuestas locales](../shared/ai/src/local-answer.ts) y [panel del asistente](../frontend/src/features/assistant/AssistantPanel.tsx).

## Pendientes por prioridad

| Prioridad | Falta | Evidencia e impacto | Criterio de cierre |
| --- | --- | --- | --- |
| Alta | Cancelación de extremo a extremo | El panel ignora respuestas al cambiar de pizarra, pero el cliente HTTP y las rutas no propagan una cancelación a los puertos. La inferencia puede continuar hasta su plazo máximo. | Conectar la cancelación de la interfaz, HTTP y proveedor; comprobar desconexión, cambio de pizarra y cancelación manual. Cancelar puede evitar trabajo restante, pero no revierte tokens ya procesados. |
| Alta | Límites de consumo y concurrencia | Hay bloqueo de doble envío en el panel y un plazo por cadena, pero no presupuesto por usuario/proyecto ni deduplicación de solicitudes simultáneas en el servidor. | Limitar solicitudes concurrentes y frecuencia, establecer presupuestos configurables y reconocer solicitudes idénticas en curso sin cobrar dos llamadas. |
| Alta | Contabilidad completa y privada | La cadena conserva hasta 200 usos exitosos en memoria. Los intentos fallidos o truncados pueden consumir tokens sin quedar registrados. `/assistant/usage` muestra datos agregados del proceso a cualquier usuario autenticado. | Registrar intentos, resultados y uso disponible por usuario/proyecto/proveedor; persistirlos y restringir su consulta. Incluir tokens de razonamiento/caché cuando el proveedor los reporte, sin inventar valores ausentes. |
| Alta | Propuestas vinculadas al estado revisado | Se valida contra el modelo enviado; al aplicar después, la pizarra colaborativa puede haber cambiado. Las precondiciones de comandos no detectan todo cambio de significado. | Vincular la propuesta a una revisión o huella semántica y revisar los cambios antes de aplicarla sobre otro estado. |
| Alta | Distinguir errores semánticos nuevos | El dominio permite estados incompletos durante la edición. Que un lote sea aplicable no garantiza que deje un modelo válido para generar código. | Comparar los hallazgos anteriores y posteriores; mostrar o impedir nuevos errores relevantes sin bloquear la reparación de modelos ya incompletos. |
| Media | Reutilizar la extracción de imágenes | Cambiar de importación a «Reemplazar» vuelve a enviar la imagen y ejecuta otra extracción visual. | Conservar una extracción validada, acotada y asociada al usuario; recalcular localmente el candidato según modo y pizarra. No reutilizar comandos con identificadores o permisos de otra solicitud. |
| Media | Contrato estructurado por operación y proveedor | El esquema JSON común exige `op`, pero muchos campos siguen siendo opcionales en ese esquema. El prompt y Zod completan la protección; el modelo aún puede producir una combinación inválida. | Mantener una fuente de verdad y adaptar esquemas según las capacidades verificadas de cada proveedor. Probar campos requeridos, prohibidos y condiciones por operación. |
| Media | Presupuesto de contexto y salida por tarea | Los límites de salida son distintos entre adaptadores y amplios para consultas breves. Los turnos de aclaración tienen límite de caracteres, no un presupuesto conjunto de tokens. | Separar consulta, edición y visión; medir antes de ajustar límites. Conservar información necesaria y detectar truncamiento, sin recortar operaciones para ahorrar. |
| Media | Aclaraciones referidas a opciones | El contexto conserva la pregunta, pero no incorpora las opciones que el resolver devuelve por separado. Una respuesta como «la primera» puede perder su referente. | Enviar opciones identificables con la aclaración o exigir una selección explícita que conserve su significado. |
| Media | Calidad comprobada con APIs reales | Las regresiones verifican lógica y contratos mediante respuestas simuladas. No permiten ordenar los proveedores de mejor a peor. | Ejecutar un banco pequeño con presupuesto acordado: negaciones, correcciones, acciones encadenadas, roles, herencia, intermedias y fotos. Medir exactitud, aclaraciones, fallos, tokens y latencia por modelo. |

Referencias de código para consumo y cancelación: [rutas IA](../backend/api/src/modules/ai/routes.ts), [cliente HTTP](../frontend/src/lib/api.ts), [cadena de respaldos](../shared/ai/src/fallback-chain.ts), [importación visual](../backend/api/src/modules/import/routes.ts) y [panel de importación](../frontend/src/features/import/ImportPanel.tsx).

## Otros límites que siguen vigentes

- La pausa por cuota vive en cada proceso; varias instancias no comparten ese estado. Los reintentos internos de SDK también deben armonizarse con el tratamiento HTTP de cuotas y `Retry-After` si se habilitan.
- Conviene preparar imágenes con recorte o ajuste de tamaño conservando legibilidad y revisión del usuario. La ruta actual envía la imagen original.
- El dictado sigue usando reconocimiento del navegador. Los adaptadores de transcripción del servidor existen, pero falta conectarlos mediante grabación de audio cuando el navegador no ofrece reconocimiento. Sigue pendiente probar micrófono, teclado virtual y suspensión en teléfonos reales.
- La limpieza del dictado es local y conservadora. No se hace una llamada extra de resumen antes de la llamada de instrucciones; la interpretación de intención ocurre en esa misma respuesta.
- Completar claves en `.env` no resuelve estos pendientes de implementación. Tampoco es posible garantizar disponibilidad por tener siete respaldos: dependen de sus cuentas, cuotas y modelos habilitados.

## Verificación realizada

- **442 pruebas unitarias y de regresión aprobadas, en 26 archivos.** Incluyen casos de secuencias de operaciones, roles, respuestas truncadas, errores de proveedores, consultas locales y conservación de contexto.
- **5 pruebas de navegador del flujo de voz y aclaraciones aprobadas.** El reconocimiento y las respuestas de IA son simulados; el entorno de aplicación es local.
- TypeScript, ESLint y formato aprobados. API y web compiladas y reconstruidas en Docker; la API alcanzó estado saludable y la web arrancó correctamente.
- Medición local del resolver con 170 operaciones: mediana de aproximadamente 30 ms en diez ejecuciones medidas, tras calentamiento. No incluye inferencia remota ni representa rendimiento de producción.
- No se consumieron cuotas reales de IA en estas verificaciones. No se acredita todavía calidad comparada, disponibilidad real de todas las cuentas ni ahorro monetario medido.

La medición anterior de longitud del prompt en [voz y consumo](voz-y-consumo-ia.md) corresponde a una etapa previa. Esta revisión añadió reglas necesarias para corregir errores; menos caracteres no es por sí solo una mejora si aumenta los reintentos o pierde intención.

Para interpretar terminaciones se consultaron las referencias oficiales de [Gemini](https://ai.google.dev/api/generate-content) y [Anthropic](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons). La disponibilidad de [salidas estructuradas de Anthropic](https://platform.claude.com/docs/en/build-with-claude/structured-outputs) no sustituye la validación semántica local.

El siguiente incremento recomendado es **cancelación + límites por usuario + registro de todos los intentos**, seguido de reutilización de visión y evaluación comparada. Son las mejoras con mayor relación directa con el control de gasto pendiente.
