# Verificación móvil y diagnóstico XMI — 5 de septiembre de 2026

La web local actualizada en `http://localhost:8080` pasa los seis recorridos
táctiles de esta revisión. Se corrigieron desbordamientos, distribución del
editor y desplazamientos al navegar. Es una verificación mediante Chromium
con emulación móvil; no certifica Safari ni dispositivos físicos.

El estado general y los faltantes funcionales y de operación están en la
[auditoría consolidada](auditoria-2026-09-05.md). Este informe amplía su apartado
móvil con comprobaciones de altura del lienzo y visibilidad inicial de la cabecera.

## Correcciones

- Formularios y tarjetas caben desde 320 px, incluso con nombres largos.
- En teléfonos y orientación horizontal de poca altura, las herramientas se
  distribuyen encima del lienzo y los paneles usan el ancho completo debajo.
- La cuadrícula reserva altura explícita para el lienzo. Se verifican al menos
  240 px; una versión intermedia podía dejarlo con altura cero.
- Los campos, controles táctiles, atributos, mensajes de validación e importación
  ajustan su distribución sin desbordar el documento. El botón de crear clase
  alcanza al menos 44 px de altura en teléfono y horizontal.
- La navegación comienza arriba al cambiar de ruta.
- El asistente deja de ejecutar `scrollIntoView` al abrir una conversación vacía.
  Ese efecto desplazaba toda la página y ocultaba la cabecera a 320 px y en
  horizontal. Las conversaciones con mensajes conservan su desplazamiento.
- Se mantienen los botones para ocultar paneles y dedicar el ancho al diagrama.

Archivos: `frontend/src/styles.css`, `frontend/src/App.tsx`,
`frontend/src/features/assistant/AssistantPanel.tsx` y `e2e/specs/movil.spec.ts`.

## Resultados finales

| Comprobación | Resultado |
|---|---|
| Chromium táctil, 320×568 | Pasa |
| Chromium táctil, 360×800 | Pasa |
| Chromium táctil, 390×844 | Pasa |
| Chromium táctil, 430×932 | Pasa |
| Chromium táctil, 768×1024 | Pasa |
| Chromium táctil horizontal, 844×390 | Pasa |
| Navegador contra Vite, móviles y regresiones de escritorio | 20/20, aproximadamente 60 s |
| Repetición móvil contra Nginx local actualizado, puerto 8080 | 6/6, 20,2 s |
| `npm test` | 352 pruebas pasan; la muestra real de Architect se procesa con avisos explícitos para construcciones no soportadas |
| Compilación de la imagen web | Correcta |
| Contenedores web, API, colaboración y PostgreSQL | Saludables |

Cada recorrido táctil registra una cuenta de prueba, cambia su nombre, crea un
proyecto y una invitación, abre una pizarra, crea una clase con atributo, cambia
entre importar/generar/asistente, oculta y muestra paneles y cierra sesión.
Comprueba el ancho del documento, controles fuera de pantalla, cabecera visible,
altura del lienzo y ancho al ocultar paneles. Se inspeccionaron capturas de
320 px y horizontal además de las aserciones.

Las regresiones de escritorio incluyen perfil, recuperación, generación y
descarga de ZIP, selección y movimiento por teclado y colaboración. Esta pasada
no vuelve a certificar todos los recorridos de IA ni el banco Spring completo:
sus resultados previos están en la auditoría general.

Evidencia local, excluida de Git:

- `reports/movil-2026-09-05/antes/`: fallos iniciales y capturas.
- `reports/movil-2026-09-05/verificado/`: 20 recorridos finales contra Vite.
- `reports/movil-2026-09-05/desplegado/`: seis recorridos finales en 8080.

Se actualizó únicamente el contenedor web en esta continuación. El servidor
Vite temporal se apagó al terminar. Quedan pendientes pruebas físicas Android/iOS,
Safari, teclado virtual, cambios de orientación durante una sesión, gestos de
arrastre/pellizco y cámara/micrófono reales.

## Tipos de atributo al importar XMI en Enterprise Architect

La captura aportada muestra atributos sin su tipo, pero no permite determinar
si el campo está vacío en el modelo importado o está oculto en el diagrama.

1. Abrir las propiedades del diagrama, sección **Features**, y seleccionar
   **Show Attribute Detail → Name and Type**. Esta opción controla si se
   presenta solamente el nombre o también el tipo, según la
   [documentación oficial de Sparx](https://www.sparxsystems.com/enterprise_architect_user_guide/17.1/modeling_fundamentals/appearance_options_feat.html).
2. Abrir los atributos de una clase y revisar su campo **Type/Tipo**.
   Si tiene el valor esperado, el tipo se importó y el problema es de presentación.
3. Si está vacío, descargar un XMI nuevo desde la plataforma actual e importarlo
   en un paquete de prueba. La API actual emite referencias UML a tipos
   primitivos y una extensión `Enterprise Architect` con
   `<properties type="string" .../>` para cada atributo. También incluye el
   paquete de primitivos, conectores y un diagrama `Logical` con posiciones y
   tamaños, siguiendo la muestra real proporcionada. La integración desplegada
   fue reconstruida y verificada.
4. Si persiste, conservar el XMI exacto importado y la versión de EA. Hace falta
   comparar ese archivo con lo que EA importó para corregir la incompatibilidad
   concreta. El parser ya tiene una prueba contra el archivo real de Architect;
   la apertura del archivo generado en EA sigue siendo la validación final.

La multiplicidad `[0..1]` indica un atributo opcional y no sustituye al tipo.
La distribución gráfica de las clases tampoco demuestra pérdida de tipos:
el exportador transmite el modelo semántico, sin un diagrama gráfico nativo de EA.
