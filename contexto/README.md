# contexto/

Generadores de volcados en Markdown del codigo del proyecto, para leer o pegar
todo el contexto de una carpeta en un solo archivo.

**No forma parte del repositorio.** `contexto/` esta en `.gitignore`.

## Uso

```bash
python contexto/todo.py          # los siete documentos + indice.md
python contexto/shared.py        # solo uno
```

Los `.md` se escriben en `contexto/salida/`.

## Documentos

| Script | Salida | Cubre |
| --- | --- | --- |
| `shared.py` | `shared.md` | `shared/*` --- contracts, domain-core, generation-ir, generator-backend, yjs-adapter, xmi, ai |
| `backend.py` | `backend.md` | `backend/api`, `backend/collab`, `backend/prisma`, `prisma.config.ts` |
| `frontend.py` | `frontend.md` | `frontend/src`, `frontend/public`, configuracion de Vite |
| `plantillas.py` | `plantillas.md` | `templates/*` --- Spring, Flutter, backend movil, empaquetado |
| `fixtures.py` | `fixtures.md` | `fixtures/*` --- banco T01 a T08 y XMI de referencia |
| `herramientas.py` | `herramientas.md` | `scripts/` y `e2e/` |
| `infraestructura.py` | `infraestructura.md` | `infra/`, `.github/`, `config/` y la configuracion de la raiz |
| `documentacion.py` | `documentacion.md` | `docs/` --- ADR, arquitectura, requisitos, plan maestro |
| `todo.py` | todos + `indice.md` | --- |

`nucleo.py` es el motor compartido; los demas solo declaran que incluir.

`docs/` esta borrada en el arbol de trabajo, asi que `documentacion.py` se omite
solo y avisa. Con `git restore docs` vuelve a producir su documento.

## Comprobar que no falta nada

```bash
python contexto/cobertura.py            # huecos, si los hay
python contexto/cobertura.py --detalle  # aporte de cada documento
```

Recorre el repositorio entero y resta lo que ya recogen los generadores. Sale con
codigo 1 si algun archivo no aparece en ningun documento, asi que sirve tal cual
en una comprobacion encadenada. Ejecutalo despues de anadir carpetas al proyecto.

## Opciones

| Opcion | Efecto |
| --- | --- |
| `--salida RUTA` | Carpeta de destino (por defecto `contexto/salida`) |
| `--con-pruebas` | Incluye carpetas `tests/` y archivos `.test` / `.spec` |
| `--max-kib N` | Trunca los archivos por encima de N KiB (por defecto 160) |

`plantillas.py` y `herramientas.py` ya incluyen sus pruebas sin pedirlo: en esas
carpetas las pruebas son parte del contenido.

Un `Objetivo` con `recursivo=False` toma solo los archivos sueltos de la carpeta,
sin bajar a las subcarpetas; asi una carpeta contenedora no repite lo que ya
recogen las secciones de sus hijas.

## Que queda fuera

Siempre: `node_modules/`, `dist/`, `coverage/`, `.git/`, informes de pruebas,
`package-lock.json` y los archivos de bloqueo, `.tsbuildinfo`, registros.

Los binarios (tipografias, imagenes, certificados) se **listan** en el arbol y se
nombran bajo cada seccion, pero no se vuelcan.

Los `.env` reales nunca aparecen: `.gitignore` los excluye del repositorio y aqui
solo se recogen los `.example`. Aun asi, revisa `infraestructura.md` antes de
compartirlo con nadie.

## Ajustes

Para anadir una carpeta, copia uno de los scripts y cambia el `Documento`. Los
filtros por extension, los lenguajes de resaltado y las carpetas ignoradas estan
todos en la cabecera de `nucleo.py`.

Si un documento sale demasiado grande para pegarlo entero, `--max-kib 20` recorta
los archivos largos conservando la estructura y el inicio de cada uno.
