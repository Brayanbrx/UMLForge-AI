# Apariencia y temas — 10 de septiembre

Se revisaron acceso, proyectos, editor, propiedades y observaciones. La presentación usa tipografías IBM Plex servidas localmente con sus licencias, jerarquía tipográfica, listas de proyectos y menos recuadros decorativos. Las observaciones ajustan sus líneas sin desplazamiento horizontal.

## Modos de apariencia

- **Claro:** superficies cálidas y acento verde sobrio.
- **Oscuro:** grises neutros inspirados en Dark de VS Code, lienzo `#1e1e1e`, paneles `#252526` y acento azul. Sustituye la primera propuesta de oscuro verdoso tras la revisión del usuario.
- **Sistema:** sigue `prefers-color-scheme`, incluidos los cambios con la aplicación abierta.

El menú de apariencia está disponible en acceso, proyectos, cuenta y editor. Usa iconos y una marca de selección; admite flechas, Inicio/Fin, Enter y Escape. Cierra al pulsar fuera o abandonar el control con Tab. La preferencia se guarda en `localStorage`, se sincroniza entre pestañas y funciona en la pestaña actual aunque el navegador restrinja el almacenamiento. Un script previo al renderizado evita el destello del tema opuesto.

El cambio de tema no remonta la pizarra ni altera el documento colaborativo. Los colores del lienzo, controles, relaciones y clases siguen la apariencia elegida. Los formatos de exportación conservan su comportamiento.

## Comprobación

TypeScript, ESLint, formato y compilación web aprobados. La suite completa inicial obtuvo 92 aprobaciones y detectó un fallo de tamaño táctil en móvil horizontal: el botón medía 36 px. Se corrigió a 44 px en ese tamaño y se volvieron a aprobar las seis resoluciones móviles.

Las pruebas de apariencia cubren persistencia, cambios del sistema, sincronización entre pestañas, almacenamiento restringido, teclado del menú, ausencia de desbordamiento y conservación del diagrama. **20/20 pruebas finales en Docker aprobadas**, incluyendo apariencia, seis tamaños móviles y regresiones de colaboración/XMI. Capturas y resultados locales en `reports/apariencia/`, ignorados por Git; resultado final en `docker-final.xml`.

Se reconstruyó y actualizó únicamente el servicio web. API, colaboración, base de datos y volúmenes se conservan.
