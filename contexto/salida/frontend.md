# Frontend

Aplicacion web en React con Vite. `src/features/` agrupa por pantalla: autenticacion, proyectos, editor de la pizarra, asistente de IA, importacion, panel de generacion y ayuda. `src/components/` son piezas globales y `src/lib/` el cliente HTTP y la descarga de archivos.

> Generado el 2026-09-21 00:48 por `contexto/frontend.py`.
> 66 archivos, 15,822 lineas, 483.0 KiB de codigo.
> Pruebas: excluidas. Dependencias, compilados y binarios: siempre excluidos.

> Sin archivos con los filtros actuales: `frontend/tests`. Probar con `--con-pruebas`.

## Contenido

- [Codigo de la aplicacion](#codigo-de-la-aplicacion) --- 50 archivos
- [Recursos publicos](#recursos-publicos) --- 9 archivos
- [Modo sin conexion](#modo-sin-conexion) --- 2 archivos
- [Uso, requisitos y limites del editor sin conexion](#uso-requisitos-y-limites-del-editor-sin-conexion) --- 1 archivo
- [Punto de entrada HTML](#punto-de-entrada-html) --- 1 archivo
- [Configuracion de Vite](#configuracion-de-vite) --- 1 archivo
- [Dependencias del paquete web](#dependencias-del-paquete-web) --- 1 archivo
- [TypeScript del paquete web](#typescript-del-paquete-web) --- 1 archivo

---

## Codigo de la aplicacion

`styles.css` es la hoja principal y es grande; si estorba, ejecutar con `--max-kib 20` para recortarla.

### Estructura

```text
frontend/src/
|-- components/
|   |-- AppBar.tsx
|   |-- icons.tsx
|   `-- ThemeProvider.tsx
|-- features/
|   |-- assistant/
|   |   |-- AssistantLearningGuide.tsx
|   |   |-- AssistantPanel.tsx
|   |   |-- conversation-context.ts
|   |   |-- learning-guide.ts
|   |   |-- prepare-dictation.ts
|   |   |-- speech-session.ts
|   |   `-- useSpeech.ts
|   |-- auth/
|   |   |-- LoginPage.tsx
|   |   |-- ProfilePage.tsx
|   |   |-- ResetPage.tsx
|   |   |-- session.tsx
|   |   `-- VerificationPage.tsx
|   |-- editor/
|   |   |-- AsociacionEdge.tsx
|   |   |-- board-drafts.ts
|   |   |-- BoardCanvas.tsx
|   |   |-- BoardPage.tsx
|   |   |-- ClassNode.tsx
|   |   |-- commands.ts
|   |   |-- editor-tools.ts
|   |   |-- EditorToolbox.tsx
|   |   |-- export-image.ts
|   |   |-- Inspector.tsx
|   |   |-- OfflineBoardsPage.tsx
|   |   |-- useBoardDocument.ts
|   |   `-- ValidationPanel.tsx
|   |-- generation/
|   |   `-- GenerationPanel.tsx
|   |-- help/
|   |   |-- InteractiveTour.tsx
|   |   |-- software-lessons.ts
|   |   |-- SoftwareGuide.tsx
|   |   |-- tour-steps.ts
|   |   |-- TourCoach.tsx
|   |   `-- use-tour-target.ts
|   |-- import/
|   |   |-- candidate.ts
|   |   |-- CandidateEditor.tsx
|   |   |-- CapturaCamara.tsx
|   |   |-- ExportImage.tsx
|   |   `-- ImportPanel.tsx
|   `-- projects/
|       |-- ProjectMembers.tsx
|       `-- ProjectsPage.tsx
|-- lib/
|   |-- api.ts
|   |-- guardar-archivo.ts
|   `-- offline.ts
|-- App.tsx
|-- design.css
|-- main.tsx
|-- styles.css
`-- vite-env.d.ts
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/src/App.tsx` | 96 |
| `frontend/src/design.css` | 820 |
| `frontend/src/main.tsx` | 28 |
| `frontend/src/styles.css` | 4001 |
| `frontend/src/vite-env.d.ts` | 2 |
| `frontend/src/components/AppBar.tsx` | 205 |
| `frontend/src/components/ThemeProvider.tsx` | 238 |
| `frontend/src/components/icons.tsx` | 161 |
| `frontend/src/features/assistant/AssistantLearningGuide.tsx` | 163 |
| `frontend/src/features/assistant/AssistantPanel.tsx` | 512 |
| `frontend/src/features/assistant/conversation-context.ts` | 41 |
| `frontend/src/features/assistant/learning-guide.ts` | 40 |
| `frontend/src/features/assistant/prepare-dictation.ts` | 17 |
| `frontend/src/features/assistant/speech-session.ts` | 147 |
| `frontend/src/features/assistant/useSpeech.ts` | 63 |
| `frontend/src/features/auth/LoginPage.tsx` | 272 |
| `frontend/src/features/auth/ProfilePage.tsx` | 424 |
| `frontend/src/features/auth/ResetPage.tsx` | 131 |
| `frontend/src/features/auth/VerificationPage.tsx` | 104 |
| `frontend/src/features/auth/session.tsx` | 234 |
| `frontend/src/features/editor/AsociacionEdge.tsx` | 283 |
| `frontend/src/features/editor/BoardCanvas.tsx` | 466 |
| `frontend/src/features/editor/BoardPage.tsx` | 704 |
| `frontend/src/features/editor/ClassNode.tsx` | 186 |
| `frontend/src/features/editor/EditorToolbox.tsx` | 216 |
| `frontend/src/features/editor/Inspector.tsx` | 499 |
| `frontend/src/features/editor/OfflineBoardsPage.tsx` | 44 |
| `frontend/src/features/editor/ValidationPanel.tsx` | 63 |
| `frontend/src/features/editor/board-drafts.ts` | 117 |
| `frontend/src/features/editor/commands.ts` | 150 |
| `frontend/src/features/editor/editor-tools.ts` | 58 |
| `frontend/src/features/editor/export-image.ts` | 70 |
| `frontend/src/features/editor/useBoardDocument.ts` | 642 |
| `frontend/src/features/generation/GenerationPanel.tsx` | 314 |
| `frontend/src/features/help/InteractiveTour.tsx` | 74 |
| `frontend/src/features/help/SoftwareGuide.tsx` | 224 |
| `frontend/src/features/help/TourCoach.tsx` | 209 |
| `frontend/src/features/help/software-lessons.ts` | 242 |
| `frontend/src/features/help/tour-steps.ts` | 199 |
| `frontend/src/features/help/use-tour-target.ts` | 111 |
| `frontend/src/features/import/CandidateEditor.tsx` | 317 |
| `frontend/src/features/import/CapturaCamara.tsx` | 162 |
| `frontend/src/features/import/ExportImage.tsx` | 104 |
| `frontend/src/features/import/ImportPanel.tsx` | 594 |
| `frontend/src/features/import/candidate.ts` | 23 |
| `frontend/src/features/projects/ProjectMembers.tsx` | 264 |
| `frontend/src/features/projects/ProjectsPage.tsx` | 459 |
| `frontend/src/lib/api.ts` | 702 |
| `frontend/src/lib/guardar-archivo.ts` | 36 |
| `frontend/src/lib/offline.ts` | 133 |

---

### `frontend/src/App.tsx`

```tsx
import { BrowserRouter, Link, Navigate, Route, Routes, useLocation } from 'react-router';
import { lazy, Suspense, useLayoutEffect } from 'react';
import { LoginPage } from './features/auth/LoginPage.js';
import { ProfilePage } from './features/auth/ProfilePage.js';
import { ResetPage } from './features/auth/ResetPage.js';
import { VerificationPage } from './features/auth/VerificationPage.js';
import { SessionProvider, useSession } from './features/auth/session.js';
import { ProjectPage, ProjectsPage } from './features/projects/ProjectsPage.js';
import { InteractiveTourProvider } from './features/help/InteractiveTour.js';
import { OfflineBoardsPage } from './features/editor/OfflineBoardsPage.js';

const BoardPage = lazy(async () => {
  const { BoardPage } = await import('./features/editor/BoardPage.js');
  return { default: BoardPage };
});

export function App(): React.JSX.Element {
  return (
    <SessionProvider>
      <BrowserRouter>
        <InteractiveTourProvider>
          <Suspense
            fallback={
              <main className="centrado" role="status">
                Cargando la aplicación…
              </main>
            }
          >
            <Rutas />
          </Suspense>
        </InteractiveTourProvider>
      </BrowserRouter>
    </SessionProvider>
  );
}

function Rutas(): React.JSX.Element {
  const { user, loading, offline } = useSession();
  const { pathname } = useLocation();

  useLayoutEffect(() => {
    // Cada pantalla comienza por su cabecera, aunque la anterior estuviera
    // desplazada (por ejemplo al abrir una pizarra desde un teléfono).
    window.scrollTo({ top: 0, left: 0, behavior: 'instant' });
  }, [pathname]);

  // Sin esta espera, una recarga con sesion viva mandaria al usuario al login
  // durante el instante que tarda la renovacion, y perderia la ruta que tenia.
  if (loading) {
    return (
      <main className="centrado">
        {/* `role="status"` para que un lector de pantalla anuncie la espera:
            de otro modo la pagina se queda muda hasta que aparece algo. */}
        <div className="estado-ruta" role="status">
          <div className="girando" aria-hidden="true" />
          <p>Restaurando tu sesión…</p>
        </div>
      </main>
    );
  }

  if (user === null) {
    return (
      <Routes>
        <Route path="/entrar" element={<LoginPage />} />
        <Route path="/activar" element={<VerificationPage />} />
        {/* Restablecer se llega desde el correo, sin sesion: tiene que existir
            tambien para quien no ha entrado. */}
        <Route path="/restablecer" element={<ResetPage />} />
        <Route path="*" element={<Navigate to="/entrar" replace />} />
      </Routes>
    );
  }

  return (
    <>
      {offline && !pathname.startsWith('/pizarras/') && pathname !== '/sin-conexion' && (
        <p className="advertencia banda" role="status" data-testid="aviso-sin-conexion">
          Sin conexión. Conservamos lo que estás escribiendo; espera a reconectar para enviarlo.{' '}
          <Link to="/sin-conexion">Ver pizarras guardadas</Link>
        </p>
      )}
      <Routes>
        <Route path="/proyectos" element={<ProjectsPage />} />
        <Route path="/cuenta" element={<ProfilePage />} />
        <Route path="/activar" element={<VerificationPage />} />
        <Route path="/restablecer" element={<ResetPage />} />
        <Route path="/proyectos/:projectId" element={<ProjectPage />} />
        <Route path="/pizarras/:boardId" element={<BoardPage />} />
        <Route path="/sin-conexion" element={<OfflineBoardsPage />} />
        <Route path="*" element={<Navigate to="/proyectos" replace />} />
      </Routes>
    </>
  );
}
```

---

### `frontend/src/design.css`

```css
/* Paleta mineral. La notación UML conserva su geometría en los tres modos. */
@font-face {
  font-family: 'Plex Sans';
  src: url('/fonts/plex-sans-regular.ttf') format('truetype');
  font-style: normal;
  font-weight: 400;
  font-display: swap;
}
@font-face {
  font-family: 'Plex Sans';
  src: url('/fonts/plex-sans-semibold.ttf') format('truetype');
  font-style: normal;
  font-weight: 500 700;
  font-display: swap;
}
@font-face {
  font-family: 'Plex Serif';
  src: url('/fonts/plex-serif-medium.ttf') format('truetype');
  font-style: normal;
  font-weight: 500;
  font-display: swap;
}

:root {
  font-family: 'Plex Sans', 'Segoe UI', sans-serif;
  color-scheme: light;
  --fondo: #f5f4f0;
  --superficie: #fffefa;
  --superficie-2: #eeeee8;
  --superficie-3: #e7e9e2;
  --fondo-panel: var(--superficie);
  --suave: rgb(33 47 40 / 4%);
  --suave-fuerte: rgb(33 47 40 / 8%);
  --texto: #252d29;
  --texto-suave: #59635c;
  --texto-tenue: #657069;
  --borde: #dedfd7;
  --borde-fuerte: #a9b4aa;
  --acento: #35634c;
  --acento-vivo: #284f3c;
  --acento-texto: #2f6047;
  --acento-suave: #e6eee6;
  --error: #b44339;
  --error-texto: #a23731;
  --error-suave: #f8e9e5;
  --aviso: #a17627;
  --aviso-texto: #805d1c;
  --aviso-suave: #f5efdf;
  --ok: #3d7855;
  --ok-texto: #316648;
  --ok-suave: #e8f0e7;
  --sombra-1: 0 1px 2px rgb(29 42 33 / 5%);
  --sombra-2: 0 12px 32px rgb(29 42 33 / 12%);
  --r-md: 0.375rem;
  --r-lg: 0.5rem;
  --r-xl: 0.5rem;
  --alto-control: 2.25rem;
  --editorial: 'Plex Serif', Georgia, serif;
  --diagrama-fondo: #f5f4ee;
  --diagrama-punto: #d4d8ce;
  --diagrama-linea: #566659;
  --clase-borde: #9baa9a;
  --clase-cabecera: #e8eee2;
  --clase-cuerpo: #fffef8;
  --clase-texto: #28352b;
  --clase-tenue: #5d6a5e;
  --clase-seleccion: #397253;
  --minimapa-mascara: rgb(60 73 60 / 10%);
}

:root[data-theme='dark'] {
  color-scheme: dark;
  --fondo: #1e1e1e;
  --superficie: #252526;
  --superficie-2: #2d2d30;
  --superficie-3: #333333;
  --suave: rgb(255 255 255 / 4%);
  --suave-fuerte: rgb(255 255 255 / 8%);
  --texto: #d4d4d4;
  --texto-suave: #b5b5b5;
  --texto-tenue: #a0a0a0;
  --borde: #3c3c3c;
  --borde-fuerte: #606060;
  --acento: #0e639c;
  --acento-vivo: #1177bb;
  --acento-texto: #9cdcfe;
  --acento-suave: #263b4d;
  --error: #f48771;
  --error-texto: #f4a395;
  --error-suave: #3d2927;
  --aviso: #cca700;
  --aviso-texto: #d7ba7d;
  --aviso-suave: #363225;
  --ok: #89b678;
  --ok-texto: #a5c895;
  --ok-suave: #29352a;
  --sombra-1: 0 1px 2px rgb(0 0 0 / 14%);
  --sombra-2: 0 12px 32px rgb(0 0 0 / 24%);
  --diagrama-fondo: #1e1e1e;
  --diagrama-punto: #363636;
  --diagrama-linea: #b0b0b0;
  --clase-borde: #737373;
  --clase-cabecera: #2d2d30;
  --clase-cuerpo: #252526;
  --clase-texto: #d4d4d4;
  --clase-tenue: #b5b5b5;
  --clase-seleccion: #569cd6;
  --minimapa-mascara: rgb(0 0 0 / 28%);
}

/* Se heredan los colores del documento, también dentro de React Flow. */
.lienzo {
  --diagrama-fondo: inherit;
  --diagrama-punto: inherit;
  --diagrama-linea: inherit;
  --clase-borde: inherit;
  --clase-cabecera: inherit;
  --clase-cuerpo: inherit;
  --clase-texto: inherit;
  --clase-tenue: inherit;
  --clase-seleccion: inherit;
}

body {
  letter-spacing: 0.005em;
}
button,
input,
select,
textarea {
  font-family: inherit;
}
button:hover:not(:disabled),
input:hover,
select:hover,
textarea:hover {
  border-color: var(--borde-fuerte);
}
button.principal {
  box-shadow: var(--sombra-1);
}
input,
select,
textarea {
  background: var(--superficie);
}
::selection {
  background: var(--acento-suave);
  color: var(--texto);
}
* {
  scrollbar-width: thin;
  scrollbar-color: var(--borde-fuerte) transparent;
}

.theme-select {
  position: relative;
  display: inline-flex;
  flex-direction: row;
  align-items: center;
  gap: 0.375rem;
  flex-shrink: 0;
  color: var(--texto-suave);
}
.theme-trigger {
  width: 6rem;
  min-height: 2rem;
  padding-block: 0.25rem;
  padding-left: 0.5rem;
  background: transparent;
  border-color: transparent;
  font-size: var(--t-md);
  color: var(--texto);
}
.theme-select:focus-within {
  color: var(--acento-texto);
}
.theme-trigger {
  width: auto;
  gap: 0.5rem;
  border-radius: 0.375rem;
  padding-inline: 0.625rem;
}
.theme-trigger:hover:not(:disabled),
.theme-trigger[aria-expanded='true'] {
  background: var(--suave-fuerte);
  border-color: var(--borde);
}
.theme-menu {
  position: absolute;
  top: calc(100% + 0.5rem);
  right: 0;
  width: 16rem;
  max-width: calc(100vw - 1.5rem);
  z-index: 50;
  padding: 0.375rem;
  border: 1px solid var(--borde-fuerte);
  border-radius: 0.5rem;
  background: var(--superficie);
  color: var(--texto);
  box-shadow: var(--sombra-2);
}
.theme-menu-title {
  margin: 0;
  padding: 0.5rem 0.625rem;
  color: var(--texto-suave);
  font-size: 0.6875rem;
  letter-spacing: 0.05em;
}
.theme-menu button {
  display: grid;
  grid-template-columns: 1.125rem minmax(0, 1fr) 1rem;
  gap: 0.75rem;
  width: 100%;
  padding: 0.625rem;
  min-height: 3.5rem;
  text-align: left;
  border: 1px solid transparent;
  background: transparent;
  color: var(--texto);
  white-space: normal;
}
.theme-menu button strong {
  display: block;
  font-size: 0.8125rem;
  font-weight: 500;
}
.theme-menu button small {
  display: block;
  margin-top: 0.125rem;
  font-size: 0.6875rem;
  color: var(--texto-suave);
  font-weight: 400;
}
.theme-menu button[aria-checked='true'] {
  background: var(--acento-suave);
}
.theme-menu button[aria-checked='true'] > svg {
  color: var(--acento-texto);
}
.theme-menu button:hover:not(:disabled) {
  background: var(--suave-fuerte);
  border-color: transparent;
}
.theme-menu button:focus-visible {
  outline: 1px solid var(--acento-texto);
  outline-offset: -1px;
}
.acceso-apariencia {
  position: absolute;
  top: 1.5rem;
  right: 1.5rem;
  z-index: 2;
}
.isotipo {
  background: var(--acento);
  border-radius: 0.25rem;
}
.nombre-producto {
  letter-spacing: 0.075em;
  font-size: 0.75rem;
  font-weight: 600;
}
.app-bar {
  min-height: 4rem;
  padding-inline: clamp(1rem, 4vw, 3.5rem);
}
.pagina {
  max-width: 1160px;
  padding-top: 2.5rem;
}
.encabezado-pagina {
  margin-bottom: 2rem;
}
.encabezado-pagina h1 {
  font-family: var(--editorial);
  font-weight: 500;
  font-size: 2rem;
  letter-spacing: -0.035em;
}
.subtitulo {
  line-height: 1.6;
}
.barra-acciones {
  gap: 1.5rem;
  margin-bottom: 1.25rem;
}
.accion-principal,
.accion-secundaria {
  background: transparent;
  padding: 0;
  border: 0;
  border-radius: 0;
}
.accion-secundaria {
  border-left: 1px solid var(--borde);
  padding-left: 2rem;
}
.rejilla-tarjetas {
  grid-template-columns: 1fr;
  gap: 0;
  border-top: 1px solid var(--borde);
}
.tarjeta-recurso {
  flex-direction: row;
  flex-wrap: wrap;
  align-items: center;
  border: 0;
  border-bottom: 1px solid var(--borde);
  border-radius: 0;
  background: transparent;
}
.tarjeta-recurso:hover {
  background: var(--suave);
}
.cuerpo-tarjeta {
  padding: 1.25rem 0.75rem;
  min-width: 12rem;
}
.pie-tarjeta {
  border-top: 0;
  padding: 0.75rem;
  gap: 1rem;
}
.icono-recurso {
  background: transparent;
  border: 1px solid var(--borde-fuerte);
  border-radius: 0.25rem;
  color: var(--acento-texto);
}
.insignia-rol,
.insignia-rol.rol-owner {
  background: transparent;
  border-color: var(--borde);
  color: var(--texto-suave);
  border-radius: 0.25rem;
  font-size: 0.6875rem;
}
.colaboradores-proyecto {
  background: transparent;
  border: 1px solid var(--borde);
  padding: 0;
  margin-block: 0 1.25rem;
}
.colaboradores-proyecto h2 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
}
.resumen-colaboradores {
  width: 100%;
  min-height: 3.25rem;
  display: flex;
  flex-wrap: wrap;
  gap: 0.375rem 0.75rem;
  padding: 0.75rem 1rem;
  border: 0;
  background: transparent;
  color: var(--texto);
  text-align: left;
  white-space: normal;
}
.conteo-colaboradores {
  color: var(--texto-suave);
  font-size: 0.8125rem;
  font-weight: 400;
}
.flecha-colaboradores {
  margin-left: auto;
  transition: transform var(--transicion);
}
.resumen-colaboradores[aria-expanded='true'] .flecha-colaboradores {
  transform: rotate(180deg);
}
.detalle-colaboradores {
  padding: 0 1rem 1rem;
  border-top: 1px solid var(--borde);
  font-size: 0.875rem;
}
.detalle-colaboradores h3 {
  margin-block: 1rem 0.5rem;
  font-size: 0.9375rem;
}
.detalle-colaboradores .pista {
  margin-block: 0.75rem;
}
.detalle-colaboradores .lista-colaboradores {
  margin: 0;
}
.colaboradores-proyecto > p {
  margin: 0;
  padding: 0.75rem 1rem;
}
.estado-vacio-panel {
  border: 0;
  background: transparent;
}

/* Acceso: composición editorial, sin gradientes ni tarjetas superpuestas. */
.acceso {
  position: relative;
  background: var(--fondo);
}
.acceso-marca {
  background: var(--superficie-2);
  padding: 4rem;
}
.acceso-marca-contenido {
  max-width: 30rem;
}
.acceso-marca h2 {
  margin-top: 1.5rem;
  font-size: 0.875rem;
  letter-spacing: 0.12em;
  font-weight: 600;
}
.acceso-marca .lema {
  font-family: var(--editorial);
  font-size: clamp(2rem, 3.4vw, 3.25rem);
  letter-spacing: -0.045em;
  line-height: 1.15;
  color: var(--texto);
  margin-block: 2.5rem 1.5rem;
}
.acceso-detalle {
  max-width: 25rem;
  font-size: 0.9375rem;
  line-height: 1.8;
  color: var(--texto-suave);
}
.acceso-diagrama {
  opacity: 0.8;
  margin-top: 2.5rem;
}
.acceso-diagrama .caja {
  stroke: var(--borde-fuerte);
}
.acceso-formulario .tarjeta {
  border: 0;
  background: transparent;
  box-shadow: none;
  padding: 1.5rem;
}
.acceso-titulo h1 {
  font-family: var(--editorial);
  font-weight: 500;
  font-size: 1.875rem;
  line-height: 1.2;
  letter-spacing: -0.03em;
}
.pestanas {
  border-radius: 0;
  border: 0;
  border-bottom: 1px solid var(--borde);
  padding: 0;
  background: transparent;
  gap: 1rem;
}
.pestanas button {
  border-radius: 0;
  padding-inline: 0.125rem;
}
.pestanas button.activa {
  background: transparent;
  border-color: transparent;
  color: var(--texto);
  box-shadow: inset 0 -2px var(--acento);
}

/* Editor: jerarquía por espacio y tipografía, no por recuadros. */
.barra-editor {
  background: var(--superficie);
}
.barra-editor h1 {
  font-weight: 600;
  letter-spacing: -0.025em;
}
.conexion {
  border: 0;
  background: transparent;
  padding-inline: 0.375rem;
}
.conexion.conectado {
  background: transparent;
  color: var(--ok-texto);
}
.toolbox-header {
  min-height: 3.5rem;
}
.toolbox-header h2 {
  font-size: 0.9375rem;
}
.toolbox-eyebrow {
  letter-spacing: 0.1em;
  color: var(--texto-suave);
}
.toolbox-badge {
  border: 0;
  background: transparent;
  color: var(--texto-tenue);
  font-weight: 400;
}
.toolbox-item {
  border-radius: 0.25rem;
}
button.toolbox-item.active,
.toolbox-item.active .toolbox-item-icon {
  color: var(--acento-texto);
}
.toolbox-item.active .toolbox-item-copy small {
  color: var(--texto-suave);
}
.nodo-clase.con-error {
  border-color: var(--error);
}
.nodo-clase.con-aviso {
  border-color: var(--aviso);
}
.toolbox-status {
  background: var(--superficie);
  font-size: 0.75rem;
  line-height: 1.6;
}
.toolbox-status-icon {
  border: 0;
  background: transparent;
}
.pestanas-panel {
  background: var(--superficie);
}
.pestanas-panel button {
  font-size: 0.8125rem;
}
.pestanas-panel button.activa {
  background: transparent;
  color: var(--acento-texto);
  box-shadow: inset 0 -2px var(--acento);
}
.inspector-header span {
  border: 0;
  padding: 0;
  font-size: 0.6875rem;
  letter-spacing: 0.02em;
}
.inspector h3 {
  text-transform: none;
  font-size: 0.8125rem;
  letter-spacing: 0;
}
.derivados {
  color: var(--texto-tenue);
  font-size: 0.6875rem;
}
.lista-atributos li {
  border-radius: 0.25rem;
}
.validacion {
  overflow-x: hidden;
  padding: 0.75rem 1rem;
}
.validacion-titulo {
  flex-basis: 100%;
  color: var(--texto);
  font-size: 0.8125rem;
  font-weight: 600;
}
.validacion header {
  gap: 0.25rem 0.625rem;
}
.validacion .contador {
  padding: 0;
  border: 0;
  border-radius: 0;
  background: transparent;
  font-weight: 400;
}
.validacion .estado {
  font-size: 0.6875rem;
  font-weight: 400;
}
.validacion ul {
  gap: 0;
}
.validacion li {
  border-bottom: 1px solid var(--borde);
}
.validacion li:last-child {
  border-bottom: 0;
}
.validacion li button {
  position: relative;
  min-width: 0;
  padding: 0.75rem 0 0.75rem 1rem;
  border: 0;
  border-radius: 0;
  background: transparent;
  white-space: normal;
  line-height: 1.5;
}
.validacion li button::before {
  content: '';
  position: absolute;
  top: 1.0625rem;
  left: 0;
  width: 0.3rem;
  height: 0.3rem;
  border: 1px solid currentColor;
  border-radius: 50%;
}
.validacion li.aviso button::before {
  color: var(--aviso);
}
.validacion li.error button::before {
  color: var(--error);
  background: currentColor;
}
.validacion li button:hover {
  background: var(--suave);
}
.validacion .mensaje {
  max-width: 100%;
  overflow-wrap: anywhere;
  font-weight: 400;
  color: var(--texto);
}
.validacion .sugerencia {
  max-width: 100%;
  overflow-wrap: anywhere;
  line-height: 1.5;
}
.barra-estado {
  background: var(--superficie);
}
.conversacion {
  background: transparent;
}
.conversacion li:not(.usuario) > p {
  background: transparent;
  padding-inline: 0;
  line-height: 1.6;
}
.propuesta {
  border-left-width: 1px;
  border-radius: 0.25rem;
}
.toolbox-item-copy small {
  white-space: normal;
  line-height: 1.4;
}
.atributos .pk,
.atributos .obligatorio {
  color: var(--aviso-texto);
}
.react-flow__node.selected .react-flow__handle-right.conector-rapido {
  background: var(--acento);
  border-color: var(--clase-cuerpo);
}

/* Lienzo y estados legibles tanto en claro como en oscuro. */
.nodo-clase {
  box-shadow: var(--sombra-1);
}
.nodo-clase.con-error header {
  background: var(--error-suave);
}
.nodo-clase.con-aviso header {
  background: var(--aviso-suave);
}
.estado-lienzo-vacio {
  border: 1px solid var(--clase-borde);
  background: var(--clase-cuerpo);
  box-shadow: none;
  border-radius: 0.375rem;
}
.estado-lienzo-vacio p {
  color: var(--clase-tenue);
}
.estado-lienzo-icono {
  border-color: var(--clase-borde);
  color: var(--clase-texto);
}
.modo-lienzo {
  background: var(--superficie);
  color: var(--texto);
  border-color: var(--borde-fuerte);
  box-shadow: var(--sombra-1);
}
.modo-lienzo > span:not(.modo-lienzo-punto) {
  color: var(--texto-suave);
}
.modo-lienzo .cancelar-modo {
  background: var(--suave);
  color: var(--texto);
  border-color: var(--borde);
}
.modo-lienzo .cancelar-modo kbd {
  background: transparent;
  color: var(--texto-suave);
}
.modo-lienzo-punto {
  background: var(--acento-texto);
  box-shadow: none;
}
.react-flow__minimap {
  background: var(--diagrama-fondo);
}

@media (max-width: 900px) {
  .acceso-marca {
    padding: 2rem;
  }
  .pagina {
    padding-top: 1.5rem;
  }
  .barra-acciones {
    gap: 1rem;
  }
  .accion-secundaria {
    padding-left: 1rem;
  }
}
@media (max-width: 640px) {
  :root {
    --alto-control: 2.75rem;
    --alto-control-sm: 2.75rem;
  }
  .app-bar {
    padding-inline: 0.75rem;
    gap: 0.5rem;
  }
  .app-bar .nombre-producto {
    font-size: 0.625rem;
    letter-spacing: 0.025em;
  }
  .theme-select {
    gap: 0.125rem;
  }
  .theme-trigger {
    width: 6.5rem;
    min-height: 2.75rem;
    font-size: 1rem;
  }
  .acceso-apariencia {
    top: 0.75rem;
    right: 0.75rem;
  }
  .acceso-formulario {
    padding-top: 4.5rem;
  }
  .acceso-formulario .tarjeta {
    padding: 0.5rem;
  }
  .encabezado-pagina h1 {
    font-size: 1.75rem;
  }
  .encabezado-pagina:has(.volver) {
    display: grid;
    grid-template-columns: auto minmax(0, 1fr);
    align-items: start;
    gap: 0.5rem 0.75rem;
  }
  .encabezado-pagina > .insignia-rol {
    grid-column: 2;
    justify-self: start;
  }
  .resumen-colaboradores {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto;
  }
  .conteo-colaboradores {
    grid-column: 1;
  }
  .flecha-colaboradores {
    grid-column: 2;
    grid-row: 1 / 3;
    align-self: center;
  }
  .barra-acciones {
    gap: 1.5rem;
  }
  .accion-secundaria {
    border-left: 0;
    padding-left: 0;
  }
  .pie-tarjeta {
    flex-wrap: wrap;
    gap: 0.75rem;
  }
  .cuerpo-tarjeta {
    padding-bottom: 0.5rem;
  }
  .barra-editor .theme-select {
    margin-left: auto;
  }
  .app-bar .theme-trigger > svg:first-child {
    display: none;
  }
  .validacion {
    padding-inline: 0.75rem;
  }
}
@media (max-width: 640px), (max-width: 900px) and (max-height: 500px) {
  :root {
    --alto-control: 2.75rem;
    --alto-control-sm: 2.75rem;
  }
  .theme-trigger {
    min-height: 2.75rem;
  }
  .barra-editor .theme-select {
    grid-row: 3;
    grid-column: 2;
    margin: 0;
    justify-self: end;
  }
  .barra-editor .estado-barra {
    grid-column: 1;
  }
}
```

---

### `frontend/src/main.tsx`

```tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App.js';
import './styles.css';
import './design.css';
import { ThemeProvider } from './components/ThemeProvider.js';

if (import.meta.env.PROD && 'serviceWorker' in navigator && window.isSecureContext) {
  void navigator.serviceWorker
    .register('/sw.js', { updateViaCache: 'none' })
    .catch((error: unknown) => {
      console.warn('No se pudo preparar la aplicación para abrir sin conexión.', error);
    });
}

const contenedor = document.getElementById('root');
if (!contenedor) {
  throw new Error('No existe el elemento #root en index.html');
}

createRoot(contenedor).render(
  <StrictMode>
    <ThemeProvider>
      <App />
    </ThemeProvider>
  </StrictMode>,
);
```

---

### `frontend/src/styles.css`

```css
/* ==================================================================== */
/* Sistema visual                                                        */
/*                                                                       */
/* Una herramienta de productividad, no una pagina de presentacion: el    */
/* lienzo manda y todo lo demas es cromo que tiene que estorbar poco.     */
/*                                                                       */
/* Los valores viven aqui porque antes habia 43 tamanos distintos         */
/* repartidos por el archivo —0.64rem, 0.68rem, 0.72rem…— que nadie podia */
/* recordar ni respetar. Una escala corta se recuerda.                    */
/* ==================================================================== */

:root {
  /* Base estructural; design.css define las paletas claro y oscuro. */
  color-scheme: dark;
  font-family:
    system-ui,
    -apple-system,
    'Segoe UI',
    sans-serif;
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;

  /* --- Superficies ---------------------------------------------------
     Cuatro niveles, del fondo hacia arriba. Cada uno se distingue del
     anterior por luminosidad, no por sombra: en oscuro una sombra no se
     ve, y apilar sombras para simular profundidad ensucia la pantalla. */
  --fondo: #0b0d10;
  --superficie: #13161b;
  --superficie-2: #181c23;
  --superficie-3: #1e232b;
  /* Opaco a proposito: las barras pegadas al pie de un panel que se
     desplaza necesitan tapar lo que pasa por debajo. */
  --fondo-panel: #13161b;
  --suave: rgb(255 255 255 / 4%);
  --suave-fuerte: rgb(255 255 255 / 8%);

  /* --- Texto ---------------------------------------------------------
     Tres niveles y ninguna opacidad: `opacity` sobre texto pequeno baja
     del 4.5:1 que pide WCAG, y un gris declarado se puede medir. */
  --texto: #f4f7fa;
  --texto-suave: #9ca6b4;
  --texto-tenue: #8793a3;

  /* --- Bordes --------------------------------------------------------
     Blanco translucido, no gris solido: asi funcionan igual sobre las
     cuatro superficies sin tener una variante por nivel. */
  --borde: rgb(255 255 255 / 8%);
  --borde-fuerte: rgb(255 255 255 / 14%);

  /* --- Color con significado -----------------------------------------
     El acento dirige la atencion; el resto solo aparece cuando hay algo
     que decir. Rojo unicamente para lo que destruye. */
  --acento: #2f78c4;
  --acento-vivo: #3b8ddd;
  --acento-texto: #9dcbf5;
  --acento-suave: rgb(47 120 196 / 15%);

  --error: #ef4444;
  --error-texto: #fca5a5;
  --error-suave: rgb(239 68 68 / 12%);

  --aviso: #d99a2b;
  --aviso-texto: #f0c274;
  --aviso-suave: rgb(217 154 43 / 12%);

  --ok: #2ea36a;
  --ok-texto: #6ee7a8;
  --ok-suave: rgb(46 163 106 / 14%);

  /* --- Escala de espacio ---------------------------------------------
     4, 6, 8, 12, 16, 24, 32, 40 px. */
  --e-1: 0.25rem;
  --e-2: 0.375rem;
  --e-3: 0.5rem;
  --e-4: 0.75rem;
  --e-5: 1rem;
  --e-6: 1.5rem;
  --e-7: 2rem;
  --e-8: 2.5rem;

  /* --- Escala tipografica --------------------------------------------
     11, 12, 13, 14, 16, 20, 28 px. Siete tamanos para toda la aplicacion. */
  --t-xs: 0.6875rem;
  --t-sm: 0.75rem;
  --t-md: 0.8125rem;
  --t-base: 0.875rem;
  --t-lg: 1rem;
  --t-xl: 1.25rem;
  --t-2xl: 1.75rem;
  --mono: ui-monospace, 'Cascadia Code', 'Consolas', monospace;

  /* --- Radios ---------------------------------------------------------
     Controles 8, tarjetas 10, paneles 12. Nada mas redondo que eso: una
     interfaz tecnica con esquinas de pastilla parece un juguete. */
  --r-sm: 0.25rem;
  --r-md: 0.5rem;
  --r-lg: 0.625rem;
  --r-xl: 0.75rem;
  --r-completo: 999px;

  /* --- Elevacion ------------------------------------------------------
     Dos niveles y muy contenidos. En oscuro la profundidad la da el
     escalon de superficie; la sombra solo separa lo que flota. */
  --sombra-1: 0 1px 2px rgb(0 0 0 / 40%);
  --sombra-2: 0 8px 24px rgb(0 0 0 / 45%);

  /* --- Controles ------------------------------------------------------ */
  --alto-control: 2.125rem;
  --alto-control-sm: 1.75rem;
  --foco: 2px;
  --transicion: 140ms ease;
}

.colaboradores-proyecto {
  margin-block: 1.5rem;
  padding: 1rem;
  border: 1px solid var(--borde);
  border-radius: 0.5rem;
  background: var(--superficie);
}
.lista-colaboradores {
  list-style: none;
  padding: 0;
}
.lista-colaboradores > li {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.75rem;
  padding-block: 0.75rem;
  border-bottom: 1px solid var(--borde);
}
.lista-colaboradores > li > span:first-child {
  flex: 1 1 12rem;
  min-width: 0;
  overflow-wrap: anywhere;
}
.lista-colaboradores small {
  display: block;
  color: var(--texto-suave);
}
.lista-colaboradores code {
  overflow-wrap: anywhere;
  white-space: normal;
}
.operacion-candidato {
  position: relative;
  border-bottom: 1px solid var(--borde);
}
.operacion-candidato > .quitar {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  padding: 0.15rem 0.3rem;
}
.operacion-candidato > .fila-candidato {
  padding-right: 2rem;
  grid-template-columns: minmax(5rem, 1fr) minmax(6rem, 1.25fr);
}
.validacion-candidato {
  padding: 0.75rem;
  background: var(--superficie-2);
}
.validacion-candidato ul {
  max-height: 10rem;
  overflow: auto;
}
.operacion-candidato .relacion-candidato {
  display: flex;
  flex-wrap: wrap;
}
.operacion-candidato .relacion-candidato > label {
  min-width: 0;
  flex: 1 1 9rem;
}
.operacion-candidato .relacion-candidato input,
.operacion-candidato .relacion-candidato select {
  max-width: 100%;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  min-height: 100vh;
  background: var(--fondo);
  color: var(--texto);
}

#root {
  min-height: 100vh;
}

/* Foco visible, en un solo sitio y para todo.
   No habia ninguna regla de foco en todo el archivo: quien navega con el
   teclado no podia saber donde estaba. Es WCAG 2.4.7, y ademas es lo que
   hace usable el editor sin soltar las manos del teclado.
   `:focus-visible` y no `:focus`: el anillo aparece al tabular y no al
   hacer clic, que es lo que molesta y lleva a que alguien lo quite. */
:focus-visible {
  outline: var(--foco) solid var(--acento);
  outline-offset: 2px;
  border-radius: var(--r-sm);
}

/* ------------------------------------------------------------------ */
/* Botones                                                             */
/*                                                                     */
/* Cinco variantes y ninguna mas: secundario (por defecto), principal,  */
/* fantasma, peligro e icono. Cada pantalla tiene UNA accion principal. */
/* ------------------------------------------------------------------ */

button {
  font: inherit;
  font-size: var(--t-base);
  font-weight: 500;
  min-height: var(--alto-control);
  padding: 0 var(--e-4);
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-md);
  background: var(--superficie-2);
  color: var(--texto);
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--e-2);
  white-space: nowrap;
  transition:
    background-color var(--transicion),
    border-color var(--transicion),
    color var(--transicion);
}

button:hover:not(:disabled) {
  background: var(--superficie-3);
  border-color: rgb(255 255 255 / 22%);
}

button:active:not(:disabled) {
  transform: translateY(1px);
}

button:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

/* Principal: la accion que la pantalla existe para hacer. Relleno de
   acento, uno por vista. Antes era verde —el color de «correcto»— y eso
   dejaba sin distintivo a la accion de verdad. */
button.principal {
  background: var(--acento);
  border-color: var(--acento);
  color: #fff;
  font-weight: 600;
}

button.principal:hover:not(:disabled) {
  background: var(--acento-vivo);
  border-color: var(--acento-vivo);
}

/* Fantasma: acciones discretas que no compiten con nada. */
button.fantasma {
  background: transparent;
  border-color: transparent;
  color: var(--texto-suave);
}

button.fantasma:hover:not(:disabled) {
  background: var(--suave-fuerte);
  color: var(--texto);
}

/* Peligro: solo lo que destruye. Discreto en reposo y rojo al apuntarlo,
   para que se lea como una advertencia y no como una invitacion. */
button.peligro {
  background: transparent;
  border-color: transparent;
  color: var(--texto-suave);
}

/* Con texto necesita borde: sin el, «Eliminar clase» se lee como un enlace
   y no como el boton que es. Los de icono se quedan limpios. */
button.peligro:not(.icono) {
  border-color: var(--borde-fuerte);
}

button.peligro:hover:not(:disabled) {
  background: var(--error-suave);
  border-color: rgb(239 68 68 / 35%);
  color: var(--error-texto);
}

/* Boton de icono: cuadrado, sin fondo hasta que se apunta. 34px de area,
   que es el minimo comodo con raton en una herramienta de escritorio. */
button.icono {
  min-width: var(--alto-control);
  padding: 0;
  background: transparent;
  border-color: transparent;
  color: var(--texto-suave);
}

button.icono:hover:not(:disabled) {
  background: var(--suave-fuerte);
  color: var(--texto);
}

button.icono.peligro:hover:not(:disabled) {
  background: var(--error-suave);
  color: var(--error-texto);
}

/* ------------------------------------------------------------------ */
/* Campos                                                              */
/* ------------------------------------------------------------------ */

input,
select,
textarea {
  font: inherit;
  font-size: var(--t-base);
  min-height: var(--alto-control);
  padding: 0 var(--e-3);
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-md);
  background: var(--fondo);
  color: var(--texto);
  transition:
    border-color var(--transicion),
    box-shadow var(--transicion);
}

input:hover:not(:disabled),
select:hover:not(:disabled) {
  border-color: rgb(255 255 255 / 22%);
}

/* El foco de un campo se marca con el acento y un halo, no con el anillo
   del navegador: dentro de un formulario oscuro el contorno solo se pierde. */
input:focus-visible,
select:focus-visible,
textarea:focus-visible {
  outline: none;
  border-color: var(--acento);
  box-shadow: 0 0 0 3px var(--acento-suave);
}

input:disabled,
select:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

input::placeholder {
  color: var(--texto-tenue);
}

/* Las casillas conservan su tamaño; la etiqueta ofrece el área táctil. */
input[type='checkbox'],
input[type='radio'] {
  width: 1.125rem;
  height: 1.125rem;
  min-height: 0;
  flex: 0 0 1.125rem;
  padding: 0;
  margin: 0;
  accent-color: var(--acento);
}

label.opcion-checkbox {
  flex-direction: row;
  align-items: center;
  gap: var(--e-3);
  min-height: 2.75rem;
  padding-block: var(--e-2);
  cursor: pointer;
}

.opcion-checkbox > span {
  min-width: 0;
  line-height: 1.5;
}

.opcion-checkbox small {
  display: block;
  color: var(--texto-suave);
  font-size: var(--t-md);
}

/* Un campo con error se marca en rojo ademas de con su mensaje. */
input[aria-invalid='true'] {
  border-color: var(--error);
}

label {
  display: flex;
  flex-direction: column;
  gap: var(--e-1);
  font-size: var(--t-md);
}

/* El texto de una etiqueta, cuando el control va al lado y no debajo. */
label > span:first-child {
  color: var(--texto-suave);
  font-weight: 500;
}

.error {
  color: var(--error-texto);
}

.pista {
  color: var(--texto-suave);
}

/* Movimiento reducido: quien lo pide en su sistema no quiere transiciones,
   y este es el unico sitio donde hay que decirlo para toda la aplicacion. */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    transition-duration: 0.01ms !important;
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
  }
}

/* ------------------------------------------------------------------ */
/* Pantallas de ruta: cargando, error, sin permiso                     */
/*                                                                     */
/* Eran un parrafo suelto centrado en una pagina en blanco. Con un      */
/* titulo, una explicacion y una salida, quien se topa con una dice     */
/* que le pasa y que puede hacer.                                      */
/* ------------------------------------------------------------------ */

.estado-ruta {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--e-3);
  max-width: 26rem;
  text-align: center;
}

.estado-ruta h1 {
  font-size: var(--t-lg);
  margin: 0;
  color: var(--texto);
}

.estado-ruta p {
  margin: 0;
  color: var(--texto-suave);
  font-size: var(--t-base);
}

/* El enlace de salida se ve como un boton: es la accion de la pantalla. */
.estado-ruta a {
  margin-top: var(--e-2);
  display: inline-flex;
  align-items: center;
  min-height: var(--alto-control);
  padding: 0 var(--e-4);
  border: 1px solid var(--borde);
  border-radius: var(--r-md);
  background: var(--suave);
  color: inherit;
  text-decoration: none;
  font-size: var(--t-base);
}

.estado-ruta a:hover {
  background: var(--suave-fuerte);
  border-color: var(--borde-fuerte);
}

/* Indicador de carga. Un circulo que gira dice «esto sigue vivo», que es
   justo lo que un texto quieto no dice. */
.girando {
  width: 1.25rem;
  height: 1.25rem;
  border: 2px solid var(--borde-fuerte);
  border-top-color: var(--acento);
  border-radius: 50%;
  animation: girar 0.7s linear infinite;
}

@keyframes girar {
  to {
    transform: rotate(360deg);
  }
}

/* Solo para lectores de pantalla: texto que da contexto a un control que
   visualmente ya se entiende por su posicion. */
.visualmente-oculto {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip-path: inset(50%);
  white-space: nowrap;
}

/* ------------------------------------------------------------------ */
/* Armazon de las pantallas administrativas                            */
/* ------------------------------------------------------------------ */

.marco {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-bar {
  display: flex;
  align-items: center;
  gap: var(--e-4);
  padding: var(--e-3) var(--e-6);
  border-bottom: 1px solid var(--borde);
  background: var(--superficie);
  position: sticky;
  top: 0;
  z-index: 10;
}

.app-bar .separa {
  flex: 1;
}

.marca {
  display: inline-flex;
  align-items: center;
  gap: var(--e-3);
  text-decoration: none;
  color: var(--texto);
}

/* Isotipo: dos clases unidas, sobre el acento. Es lo unico de la interfaz
   que lleva el color de marca en relleno. */
.isotipo {
  display: inline-grid;
  place-items: center;
  width: 1.75rem;
  height: 1.75rem;
  border-radius: var(--r-md);
  background: linear-gradient(160deg, var(--acento-vivo), var(--acento));
  color: #fff;
}

.isotipo.grande {
  width: 2.75rem;
  height: 2.75rem;
  border-radius: var(--r-lg);
}

.nombre-producto {
  font-size: var(--t-base);
  font-weight: 600;
  letter-spacing: -0.01em;
}

/* --- Menu del usuario --- */

.menu-usuario {
  position: relative;
}

.disparador-usuario {
  padding: 0 var(--e-2) 0 var(--e-1);
  gap: var(--e-2);
}

.nombre-usuario {
  font-size: var(--t-md);
  max-width: 10rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.avatar {
  display: inline-grid;
  place-items: center;
  border-radius: 50%;
  color: #fff;
  font-weight: 700;
  letter-spacing: 0.02em;
  flex-shrink: 0;
}

.desplegable {
  position: absolute;
  right: 0;
  top: calc(100% + var(--e-2));
  min-width: 13rem;
  padding: var(--e-1);
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-lg);
  background: var(--superficie-2);
  box-shadow: var(--sombra-2);
  z-index: 20;
  animation: aparecer 140ms ease;
}

@keyframes aparecer {
  from {
    opacity: 0;
    transform: translateY(-4px);
  }
}

.cabecera-desplegable {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
  margin: 0;
  padding: var(--e-3) var(--e-3) var(--e-2);
  border-bottom: 1px solid var(--borde);
}

.cabecera-desplegable .titulo {
  font-size: var(--t-md);
  font-weight: 600;
}

.cabecera-desplegable .meta {
  font-size: var(--t-xs);
  color: var(--texto-tenue);
}

.opcion-desplegable {
  width: 100%;
  justify-content: flex-start;
  margin-top: var(--e-1);
  color: var(--texto);
}

/* ------------------------------------------------------------------ */
/* Paginas                                                             */
/* ------------------------------------------------------------------ */

.centrado {
  min-height: 60vh;
  flex: 1;
  display: grid;
  place-items: center;
  padding: var(--e-7);
  gap: var(--e-4);
  text-align: center;
  color: var(--texto-suave);
}

.pagina {
  width: 100%;
  max-width: 72rem;
  margin: 0 auto;
  padding: var(--e-7) var(--e-6) var(--e-8);
}

.encabezado-pagina {
  display: flex;
  align-items: center;
  gap: var(--e-4);
  margin-bottom: var(--e-6);
}

.encabezado-pagina h1 {
  font-size: var(--t-2xl);
  font-weight: 650;
  letter-spacing: -0.02em;
  margin: 0;
}

.subtitulo {
  margin: var(--e-1) 0 0;
  font-size: var(--t-base);
  color: var(--texto-suave);
}

.volver {
  display: inline-grid;
  place-items: center;
  width: var(--alto-control);
  height: var(--alto-control);
  border: 1px solid var(--borde);
  border-radius: var(--r-md);
  text-decoration: none;
  color: var(--texto-suave);
  flex-shrink: 0;
}

.volver:hover {
  background: var(--suave-fuerte);
  color: var(--texto);
}

/* --- Barra de acciones: crear a la izquierda, unirse al lado --- */

.barra-acciones {
  display: grid;
  grid-template-columns: minmax(0, 1.35fr) minmax(0, 1fr);
  gap: var(--e-4);
  margin-bottom: var(--e-6);
}

.accion-principal,
.accion-secundaria {
  display: flex;
  align-items: flex-end;
  gap: var(--e-3);
  padding: var(--e-4);
  border: 1px solid var(--borde);
  border-radius: var(--r-xl);
  background: var(--superficie);
}

.accion-principal label,
.accion-secundaria label {
  flex: 1;
  min-width: 0;
}

.accion-secundaria.invitaciones {
  flex-direction: column;
  align-items: stretch;
  gap: var(--e-2);
}

.etiqueta-bloque {
  font-size: var(--t-md);
  font-weight: 500;
  color: var(--texto-suave);
}

.botones-invitar {
  display: flex;
  gap: var(--e-2);
}

.botones-invitar button {
  flex: 1;
}

.codigo {
  padding: var(--e-2) var(--e-3);
  border-radius: var(--r-md);
  background: var(--fondo);
  border: 1px dashed var(--borde-fuerte);
  font-family: var(--mono);
  font-size: var(--t-md);
  color: var(--acento-texto);
  user-select: all;
  overflow-wrap: anywhere;
}

/* --- Tarjetas de proyecto y de pizarra --- */

.rejilla-tarjetas {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: var(--e-4);
  grid-template-columns: repeat(auto-fill, minmax(17rem, 1fr));
}

.tarjeta-recurso {
  display: flex;
  flex-direction: column;
  border: 1px solid var(--borde);
  border-radius: var(--r-lg);
  background: var(--superficie);
  overflow: hidden;
  transition:
    border-color var(--transicion),
    background-color var(--transicion);
}

.tarjeta-recurso:hover {
  border-color: var(--borde-fuerte);
  background: var(--superficie-2);
}

/* El cuerpo es el enlace: casi toda la tarjeta abre el recurso, y las
   acciones viven abajo para que pulsar «eliminar» no sea pulsar la tarjeta. */
.cuerpo-tarjeta {
  display: flex;
  align-items: center;
  gap: var(--e-3);
  padding: var(--e-5) var(--e-5) var(--e-4);
  text-decoration: none;
  color: inherit;
  flex: 1;
}

.cuerpo-tarjeta strong {
  font-size: var(--t-lg);
  font-weight: 600;
  letter-spacing: -0.01em;
  overflow-wrap: anywhere;
}

.icono-recurso {
  display: inline-grid;
  place-items: center;
  width: 2.125rem;
  height: 2.125rem;
  border-radius: var(--r-md);
  background: var(--acento-suave);
  color: var(--acento-texto);
  flex-shrink: 0;
}

.pie-tarjeta {
  display: flex;
  align-items: center;
  gap: var(--e-4);
  padding: var(--e-3) var(--e-3) var(--e-3) var(--e-5);
  border-top: 1px solid var(--borde);
  font-size: var(--t-md);
  color: var(--texto-suave);
}

.dato-tarjeta {
  display: inline-flex;
  align-items: center;
  gap: var(--e-1);
  white-space: nowrap;
}

/* Las acciones destructivas se separan del resto y solo se tinen al
   apuntarlas: presentes, discretas, nunca lo primero que se ve. */
.accion-tarjeta {
  margin-left: auto;
}

/* El modificador va con prefijo —`rol-editor`, no `editor`— y esto no es
   cosmetica: la version sin prefijo colisionaba con `.editor`, la clase del
   armazon del editor UML, que declara `height: 100vh`. La insignia de un
   EDITOR medía 720 pixeles de alto y estiraba la tarjeta entera. Con OWNER no
   se veia, porque `.owner` no choca con nada. */
.insignia-rol {
  font-size: var(--t-xs);
  font-weight: 600;
  letter-spacing: 0.04em;
  padding: 0.1rem var(--e-2);
  border-radius: var(--r-sm);
  border: 1px solid var(--borde-fuerte);
  color: var(--texto-tenue);
}

.insignia-rol.rol-owner {
  border-color: rgb(99 102 241 / 40%);
  background: var(--acento-suave);
  color: var(--acento-texto);
}

/* --- Estado vacio --- */

.estado-vacio-panel {
  grid-column: 1 / -1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--e-2);
  padding: var(--e-8) var(--e-6);
  border: 1px dashed var(--borde-fuerte);
  border-radius: var(--r-xl);
  text-align: center;
}

.estado-vacio-panel h2 {
  font-size: var(--t-lg);
  margin: var(--e-2) 0 0;
}

.estado-vacio-panel p {
  margin: 0;
  max-width: 34rem;
  color: var(--texto-suave);
  font-size: var(--t-base);
}

.icono-vacio {
  display: inline-grid;
  place-items: center;
  width: 3rem;
  height: 3rem;
  border-radius: var(--r-lg);
  background: var(--superficie-2);
  color: var(--texto-suave);
}

/* --- Mensajes --- */

.aviso-error {
  display: flex;
  gap: var(--e-2);
  margin: 0 0 var(--e-5);
  padding: var(--e-3) var(--e-4);
  border: 1px solid rgb(239 68 68 / 35%);
  border-radius: var(--r-md);
  background: var(--error-suave);
  color: var(--error-texto);
  font-size: var(--t-base);
}

/* ------------------------------------------------------------------ */
/* Perfil de la cuenta                                                 */
/* ------------------------------------------------------------------ */

/* Formularios y no una rejilla de tarjetas: se leen en vertical, uno detras
   de otro, y no compiten por el ancho. */
.pagina-estrecha {
  max-width: 46rem;
}

.panel-perfil {
  padding: var(--e-6);
  margin-bottom: var(--e-5);
  border: 1px solid var(--borde);
  border-radius: var(--r-xl);
  background: var(--superficie);
}

.cabecera-panel {
  margin-bottom: var(--e-5);
}

.cabecera-panel h2 {
  font-size: var(--t-lg);
  font-weight: 600;
  margin: 0;
}

.cabecera-panel .subtitulo {
  font-size: var(--t-md);
}

.formulario-perfil {
  display: flex;
  flex-direction: column;
  gap: var(--e-4);
  max-width: 24rem;
}

.acciones-formulario {
  display: flex;
  align-items: center;
  gap: var(--e-3);
  margin-top: var(--e-1);
  flex-wrap: wrap;
}

.fila-foto {
  display: flex;
  align-items: center;
  gap: var(--e-5);
  flex-wrap: wrap;
}

.avatar-grande {
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid var(--borde-fuerte);
}

.acciones-foto {
  display: flex;
  align-items: center;
  gap: var(--e-3);
  flex-wrap: wrap;
}

/* Confirmacion de una operacion que salio bien. Verde y discreta: dice que
   ocurrio, no celebra. */
.aviso-ok {
  display: inline-flex;
  align-items: center;
  gap: var(--e-2);
  margin: 0;
  font-size: var(--t-md);
  color: var(--ok-texto);
}

.ayuda.error {
  color: var(--error-texto);
}

/* Enlace de texto dentro de un formulario: «olvide mi contrasena», «volver». */
.enlace-discreto {
  align-self: center;
  font-size: var(--t-md);
  min-height: var(--alto-control-sm);
  color: var(--texto-suave);
  text-decoration: none;
}

.enlace-discreto:hover {
  color: var(--texto);
}

/* Una opcion del menu que es enlace y no boton: se ve igual. */
.enlace-menu {
  display: inline-flex;
  align-items: center;
  gap: var(--e-2);
  min-height: var(--alto-control);
  padding: 0 var(--e-4);
  border-radius: var(--r-md);
  font-size: var(--t-base);
  text-decoration: none;
  color: var(--texto);
}

.enlace-menu:hover {
  background: var(--suave-fuerte);
}

/* La pantalla de restablecer no tiene panel de marca: la tarjeta va sola. */
.acceso-suelto {
  min-height: 100vh;
}

.acceso-suelto .acceso-titulo {
  display: flex;
  flex-direction: column;
  gap: var(--e-2);
}

/* ------------------------------------------------------------------ */
/* Acceso                                                              */
/* ------------------------------------------------------------------ */

.acceso {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 1.05fr 0.95fr;
}

.acceso-marca {
  display: grid;
  place-items: center;
  padding: var(--e-8);
  border-right: 1px solid var(--borde);
  /* Un solo degradado, muy contenido, y un tinte de acento: suficiente para
     que el panel no sea un rectangulo plano, lejos del neon. */
  background:
    radial-gradient(120% 80% at 15% 0%, rgb(99 102 241 / 12%), transparent 60%), var(--superficie);
}

.acceso-marca-contenido {
  max-width: 26rem;
}

.acceso-marca h2 {
  font-size: var(--t-2xl);
  font-weight: 650;
  letter-spacing: -0.02em;
  margin: var(--e-5) 0 0;
}

.acceso-marca .lema {
  margin: var(--e-2) 0 0;
  font-size: var(--t-lg);
  color: var(--acento-texto);
}

.acceso-detalle {
  margin: var(--e-3) 0 0;
  color: var(--texto-suave);
  font-size: var(--t-base);
}

.acceso-diagrama {
  width: 100%;
  max-width: 20rem;
  margin-top: var(--e-7);
  color: var(--borde-fuerte);
}

.acceso-diagrama .caja {
  stroke: rgb(255 255 255 / 22%);
  fill: var(--superficie-2);
  stroke-width: 1.5;
}

.acceso-formulario {
  display: grid;
  place-items: center;
  padding: var(--e-7) var(--e-6);
}

.tarjeta {
  width: min(24rem, 100%);
  display: flex;
  flex-direction: column;
  gap: var(--e-4);
  padding: var(--e-6);
  border: 1px solid var(--borde);
  border-radius: var(--r-xl);
  background: var(--superficie);
  box-shadow: var(--sombra-2);
  text-align: left;
}

.acceso-titulo h1 {
  font-size: var(--t-xl);
  font-weight: 650;
  letter-spacing: -0.02em;
  margin: 0;
}

.acceso-titulo .subtitulo {
  font-size: var(--t-md);
}

/* Interruptor segmentado. Antes las dos opciones se veian igual de activas. */
.pestanas {
  display: flex;
  gap: var(--e-1);
  padding: var(--e-1);
  background: var(--fondo);
  border: 1px solid var(--borde);
  border-radius: var(--r-md);
}

.pestanas button {
  flex: 1;
  min-height: var(--alto-control-sm);
  border-color: transparent;
  background: transparent;
  color: var(--texto-suave);
  font-size: var(--t-md);
}

.pestanas button.activa {
  background: var(--superficie-3);
  border-color: var(--borde-fuerte);
  color: var(--texto);
  font-weight: 600;
}

/* Campo con un boton dentro, como mostrar u ocultar la contrasena. */
.campo-con-accion {
  display: flex;
  gap: var(--e-2);
  align-items: center;
}

.campo-con-accion input {
  flex: 1;
  min-width: 0;
}

.ver-password {
  font-size: var(--t-sm);
  min-height: var(--alto-control);
  padding: 0 var(--e-3);
}

.ayuda {
  font-size: var(--t-sm);
  color: var(--texto-tenue);
}

/* --- Adaptacion de las pantallas administrativas --- */

@media (max-width: 1024px) {
  .barra-acciones {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 900px) {
  .acceso {
    grid-template-columns: 1fr;
  }

  /* El panel de marca pasa a ser una franja: presenta el producto sin
     robarle la pantalla al formulario. */
  .acceso-marca {
    border-right: 0;
    border-bottom: 1px solid var(--borde);
    padding: var(--e-6);
  }

  .acceso-diagrama {
    display: none;
  }
}

@media (max-width: 640px) {
  .acceso {
    grid-template-columns: minmax(0, 1fr);
  }

  .acceso-formulario {
    min-width: 0;
    padding-inline: var(--e-5);
  }

  .acceso-formulario .tarjeta {
    min-width: 0;
    padding: var(--e-5);
  }

  .pagina {
    padding: var(--e-5) var(--e-4) var(--e-7);
  }

  .app-bar {
    padding: var(--e-3) var(--e-4);
  }

  .nombre-producto,
  .nombre-usuario {
    display: none;
  }

  .accion-principal,
  .accion-secundaria {
    flex-direction: column;
    align-items: stretch;
  }

  .rejilla-tarjetas {
    grid-template-columns: 1fr;
  }
}

/* ------------------------------------------------------------------ */
/* Editor                                                              */
/* ------------------------------------------------------------------ */

.editor {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: var(--fondo);
}

/* Barra superior en tres zonas: identidad a la izquierda, accion en el
   centro, estado y personas a la derecha. Antes era una fila donde «Nueva
   clase», el estado de conexion y «Salir» estaban al mismo nivel, asi que
   nada destacaba y la accion principal no se distinguia de una insignia. */
.barra-editor {
  display: flex;
  align-items: center;
  gap: var(--e-3);
  padding: var(--e-2) var(--e-4);
  border-bottom: 1px solid var(--borde);
  background: var(--superficie);
  box-shadow: var(--sombra-1);
  z-index: 2;
}

.barra-editor .identidad {
  display: flex;
  align-items: center;
  gap: var(--e-2);
  min-width: 0;
}

/* Proyecto › Pizarra. Estando dentro del editor no se veia de que proyecto
   era la pizarra abierta, y volver era una flecha sin nombre. */
.barra-editor .miga {
  display: flex;
  align-items: baseline;
  gap: var(--e-2);
  min-width: 0;
  font-size: var(--t-md);
}

.barra-editor .miga a {
  color: var(--texto-suave);
  text-decoration: none;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 14rem;
}

.barra-editor .miga a:hover {
  color: var(--texto);
  text-decoration: underline;
}

.barra-editor .miga .separador {
  color: var(--texto-tenue);
}

.barra-editor h1 {
  font-size: var(--t-lg);
  font-weight: 600;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Empuja el estado y las personas al extremo derecho. */
.barra-editor .separa {
  flex: 1;
}

.controles-vista {
  display: flex;
  align-items: center;
  gap: var(--e-1);
  padding-left: var(--e-2);
  border-left: 1px solid var(--borde);
}

.barra-editor button.boton-panel {
  min-height: var(--alto-control-sm);
  padding-inline: var(--e-2);
  font-size: var(--t-sm);
}

.icono-panel {
  width: 0.9rem;
  height: 0.75rem;
  border: 1px solid currentColor;
  border-radius: 2px;
  opacity: 0.85;
}

.icono-panel-izquierdo {
  box-shadow: inset 3px 0 0 currentColor;
}

.icono-panel-derecho {
  box-shadow: inset -3px 0 0 currentColor;
}

.barra-editor .estado-barra {
  display: flex;
  align-items: center;
  gap: var(--e-2);
}

.conexion {
  display: inline-flex;
  align-items: center;
  gap: var(--e-1);
  font-size: var(--t-sm);
  padding: 0.15rem var(--e-3);
  border-radius: var(--r-completo);
  border: 1px solid var(--borde);
  color: var(--texto-suave);
  white-space: nowrap;
}

/* El punto delante: el estado no se transmite solo con color, que es lo que
   pide WCAG 1.4.1 y lo que necesita quien no distingue verde de rojo. La
   forma del punto cambia con el estado. */
.conexion::before {
  content: '';
  width: 0.45rem;
  height: 0.45rem;
  border-radius: 50%;
  background: currentColor;
  flex-shrink: 0;
}

.conexion.conectando::before {
  animation: latido 1.2s ease-in-out infinite;
}

.conexion.conectado {
  color: var(--ok-texto);
  border-color: color-mix(in srgb, var(--ok) 40%, transparent);
  background: color-mix(in srgb, var(--ok) 8%, transparent);
}

.conexion.desconectado,
.conexion.rechazado {
  color: var(--error-texto);
  border-color: color-mix(in srgb, var(--error) 40%, transparent);
  background: color-mix(in srgb, var(--error) 8%, transparent);
}

@keyframes latido {
  50% {
    opacity: 0.3;
  }
}

@media (prefers-reduced-motion: reduce) {
  .conexion.conectando::before {
    animation: none;
  }
}

.solo-lectura {
  font-size: var(--t-sm);
  padding: 0.15rem var(--e-3);
  border-radius: var(--r-completo);
  border: 1px solid color-mix(in srgb, var(--aviso) 45%, transparent);
  background: color-mix(in srgb, var(--aviso) 15%, transparent);
  color: var(--aviso-texto);
  white-space: nowrap;
}

.presencia {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  /* Superpuestos: ocupan menos y se leen como un grupo, no como una lista. */
  padding-left: 0.4rem;
}

.presencia li {
  width: 1.75rem;
  height: 1.75rem;
  border-radius: 50%;
  display: grid;
  place-items: center;
  font-size: var(--t-xs);
  font-weight: 700;
  color: #fff;
  margin-left: -0.4rem;
  border: 2px solid var(--superficie);
  cursor: default;
}

.banda {
  margin: 0;
  padding: var(--e-3) var(--e-5);
  background: color-mix(in srgb, var(--error) 12%, transparent);
  border-bottom: 1px solid color-mix(in srgb, var(--error) 30%, transparent);
  font-size: var(--t-base);
}

.lienzo {
  flex: 1;
  display: grid;
  /* 26rem y no 22: con cinco paneles apilados en 22rem cada uno se quedaba con
     unos centimetros. Las herramientas van ahora en pestanas, y el ancho extra
     es para que el asistente y el candidato de importacion se lean. */
  grid-template-columns: 1fr 26rem;
  min-height: 0;
}

.paneles {
  border-left: 1px solid var(--borde);
  display: flex;
  flex-direction: column;
  min-height: 0;
  /* Nada se sale de la columna: cada region tiene su propio desplazamiento. */
  overflow: hidden;
  background: var(--superficie);
}

/* Pestanas de herramienta: asistente, importar, generar. */
.pestanas-panel {
  display: flex;
  border-bottom: 1px solid var(--borde);
  flex-shrink: 0;
}

.pestanas-panel button {
  flex: 1;
  border: 0;
  border-bottom: 2px solid transparent;
  border-radius: 0;
  background: transparent;
  padding: var(--e-3) var(--e-2);
  font-size: var(--t-md);
  color: var(--texto-suave);
}

.pestanas-panel button:hover:not(.activa) {
  background: var(--suave);
  color: var(--texto);
}

/* La pestana activa se marca con el acento y no solo con el peso de la
   letra: en una fila de tres, «un poco mas negrita» no se ve. */
.pestanas-panel button.activa {
  color: var(--acento-texto);
  font-weight: 600;
  border-bottom-color: var(--acento);
  background: color-mix(in srgb, var(--acento) 7%, transparent);
}

/* El hueco de la herramienta activa.
   `flex: 0 1 auto` y no `1 1 55%`: una herramienta corta —generar son dos
   controles— dejaba medio panel en blanco. Asi cada una ocupa lo que necesita,
   hasta el tope, y el inspector se queda con el resto. */
.herramienta {
  /* No se encoge. Antes cedia altura al inspector y al panel de validacion
     hasta quedarse por debajo de su contenido, y lo primero que caia fuera
     era el campo de entrada del asistente. Quien cede es quien puede
     desplazarse sin perder su accion principal. */
  flex: 0 0 auto;
  /* 65% y no 60: el candidato de importacion con avisos no cabia, y lo que
     sobresalia era justo la fila de botones. */
  max-height: 65%;
  /* Y un suelo: las tres regiones de la columna pedian juntas mas del 100%,
     asi que la herramienta se encogia hasta que su propio campo de entrada
     quedaba debajo del borde. La herramienta es donde se trabaja; el que
     cede espacio es el panel de validacion, que es de consulta. */
  min-height: 12.5rem;
  overflow-y: auto;
}

/* El tope del asistente lo pone su conversacion: asi el panel entero nunca
   supera lo que la columna puede darle, y lo que se desplaza es la lista de
   mensajes y no la caja que contiene el campo de escribir. */

/* Cuando hay una vista previa que la persona debe revisar, la herramienta deja
   de competir por altura como si fuera un formulario corto. Reservarle espacio
   evita que la barra fija de Aplicar tape precisamente los atributos editables. */
.herramienta:has(.candidato) {
  flex: 0 0 68%;
  max-height: 68%;
}

.herramienta > div {
  display: flex;
  flex-direction: column;
  min-height: 0;
}

/* Sin esto las tres herramientas se ven a la vez: la regla de arriba declara
   `display` y gana a la del navegador para `[hidden]`, que es la que deberia
   ocultarlas. */
.herramienta > div[hidden] {
  display: none;
}

.inspector {
  flex: 1 1 auto;
  min-height: 7rem;
  border-top: 1px solid var(--borde);
  overflow-y: auto;
  padding: var(--e-4);
  display: flex;
  flex-direction: column;
  gap: var(--e-4);
}

.inspector-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--e-3);
  margin: calc(var(--e-1) * -1) 0 0;
  padding-bottom: var(--e-3);
  border-bottom: 1px solid var(--borde);
}

.inspector-header h2 {
  margin: 0;
  font-size: var(--t-base);
  font-weight: 650;
}

.inspector-header span {
  padding: 0.1rem var(--e-2);
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-completo);
  color: var(--texto-suave);
  font-size: var(--t-xs);
}

.inspector-vacio {
  margin: auto 0;
  display: grid;
  justify-items: center;
  gap: var(--e-2);
  padding: var(--e-5);
  color: var(--texto-suave);
  text-align: center;
}

.inspector-vacio > span {
  width: 2rem;
  height: 2rem;
  display: grid;
  place-items: center;
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-md);
  background: var(--superficie-2);
  color: var(--acento-texto);
  font-size: var(--t-lg);
}

.inspector-vacio p,
.inspector-vacio small {
  margin: 0;
}

.inspector-vacio small {
  color: var(--texto-tenue);
  line-height: 1.45;
}

/* Titulo de seccion del panel. Se repite el patron de la barra de estado:
   mayusculas pequenas, color atenuado, para que separe sin gritar. */
.inspector h3 {
  font-size: var(--t-sm);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--texto-suave);
  margin: var(--e-2) 0 0;
  padding-bottom: var(--e-1);
  border-bottom: 1px solid var(--borde);
}

/* Los nombres derivados: como quedara la clase en el codigo y en la base.
   En monoespaciada porque son identificadores, no prosa. */
.derivados {
  margin: 0;
  font-size: var(--t-sm);
  color: var(--texto-suave);
  font-family: var(--mono);
}

.derivados > span:not([aria-hidden='true']) {
  font-family: system-ui, sans-serif;
  color: var(--texto-tenue);
}

.lista-atributos {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: var(--e-2);
}

.lista-atributos li {
  display: grid;
  grid-template-columns: minmax(7rem, 1fr) minmax(5.5rem, 0.7fr) auto;
  gap: var(--e-1);
  align-items: center;
  padding: var(--e-2);
  border: 1px solid var(--borde);
  border-radius: var(--r-md);
}

.lista-atributos li:hover {
  background: var(--suave);
}

.lista-atributos input,
.lista-atributos select {
  min-width: 0;
  min-height: var(--alto-control-sm);
  font-size: var(--t-md);
}

.lista-atributos li > input {
  grid-column: 1;
  grid-row: 1;
}

.lista-atributos li > select {
  grid-column: 2;
  grid-row: 1;
}

.lista-atributos li > .quitar {
  grid-column: 3;
  grid-row: 1 / 3;
}

.lista-atributos li.atributos-vacios {
  display: block;
  padding: var(--e-3);
  border-style: dashed;
  color: var(--texto-suave);
  font-size: var(--t-sm);
  text-align: center;
}

/* PK / NN / U: tres casillas en muy poco sitio. La etiqueta va pegada a su
   casilla y el conjunto se lee como una unidad. */
.marcadores {
  grid-column: 1 / 3;
  grid-row: 2;
  display: flex;
  gap: var(--e-4);
  font-size: var(--t-xs);
  color: var(--texto-suave);
}

.marcadores label {
  flex-direction: row;
  align-items: center;
  gap: 0.1rem;
  cursor: pointer;
}

.marcadores input {
  min-height: 0;
  margin: 0;
  accent-color: var(--acento);
}

.extremos-relacion {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: var(--e-3);
}

.extremos-relacion fieldset {
  min-width: 0;
  margin: 0;
  padding: var(--e-3);
  display: flex;
  flex-direction: column;
  gap: var(--e-3);
  border: 1px solid var(--borde);
  border-radius: var(--r-md);
}

.extremos-relacion legend {
  max-width: 100%;
  padding-inline: var(--e-1);
  overflow: hidden;
  color: var(--texto);
  font-size: var(--t-sm);
  font-weight: 600;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.extremos-relacion select,
.extremos-relacion input {
  width: 100%;
}

.quitar {
  min-height: var(--alto-control-sm);
  min-width: var(--alto-control-sm);
  padding: 0 var(--e-2);
  line-height: 1;
}

.nuevo-atributo {
  display: flex;
  gap: var(--e-2);
}

.nuevo-atributo input {
  flex: 1;
  min-width: 0;
}

.validacion {
  flex: 0 1 auto;
  border-top: 1px solid var(--borde);
  max-height: 30%;
  min-height: 2.75rem;
  overflow-y: auto;
  padding: var(--e-4);
  background: var(--superficie);
}

.validacion header {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 0.5rem;
}

.contador {
  font-size: var(--t-sm);
  font-weight: 600;
  padding: 0.1rem var(--e-3);
  border-radius: var(--r-completo);
  border: 1px solid var(--borde);
  color: var(--texto-suave);
}

/* Un contador en cero no tiene por que llamar la atencion; en rojo, si. */
.contador.error {
  color: var(--error-texto);
  border-color: color-mix(in srgb, var(--error) 40%, transparent);
  background: color-mix(in srgb, var(--error) 10%, transparent);
}

.contador.aviso {
  color: var(--aviso-texto);
  border-color: color-mix(in srgb, var(--aviso) 40%, transparent);
  background: color-mix(in srgb, var(--aviso) 10%, transparent);
}

.contador.ok {
  color: var(--texto-tenue);
}

.estado {
  font-size: var(--t-sm);
  font-weight: 600;
  margin-left: auto;
}

.estado.bloqueado {
  color: var(--error-texto);
}

.estado.listo {
  color: var(--ok-texto);
}

.validacion ul {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: var(--e-2);
}

.validacion li button {
  width: 100%;
  text-align: left;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: flex-start;
  gap: var(--e-1);
  font-size: var(--t-md);
  padding: var(--e-2) var(--e-3);
  border-left-width: 3px;
}

.validacion li.error button {
  border-left-color: var(--error);
}

.validacion li.aviso button {
  border-left-color: var(--aviso);
}

/* La sugerencia dice como arreglarlo. Va debajo del mensaje y mas tenue:
   se lee cuando hace falta, no compite con el titulo del hallazgo. */
.sugerencia {
  color: var(--texto-suave);
  font-size: var(--t-sm);
  white-space: normal;
}

/* Barra de estado: lo que se mira de reojo sin dejar de dibujar. */
.barra-estado {
  display: flex;
  align-items: center;
  gap: var(--e-5);
  padding: var(--e-1) var(--e-5);
  border-top: 1px solid var(--borde);
  background: var(--superficie);
  font-size: var(--t-sm);
  color: var(--texto-suave);
}

.barra-estado .separa {
  flex: 1;
}

.barra-estado .dato {
  display: inline-flex;
  align-items: center;
  gap: var(--e-1);
  white-space: nowrap;
}

/* Igual que las insignias de conexion: un punto delante para que el estado
   no dependa solo del color. */
.barra-estado .dato.listo,
.barra-estado .dato.bloqueado {
  font-weight: 600;
}

.barra-estado .dato.listo {
  color: var(--ok-texto);
}

.barra-estado .dato.bloqueado {
  color: var(--error-texto);
}

.barra-estado .dato.listo::before,
.barra-estado .dato.bloqueado::before {
  content: '';
  width: 0.45rem;
  height: 0.45rem;
  border-radius: 50%;
  background: currentColor;
}

/* ------------------------------------------------------------------ */
/* El diagrama                                                         */
/*                                                                     */
/* Notacion UML 2.5 con el aspecto de una herramienta de modelado y no  */
/* el de un grafo: caja con compartimentos, linea recta fina, y las     */
/* multiplicidades en su extremo.                                      */
/*                                                                     */
/* El lienzo es claro aunque la aplicacion sea oscura, y es deliberado: */
/* un diagrama es un documento. Se proyecta, se imprime y se compara    */
/* con el de Enterprise Architect, y en claro se lee igual en los tres  */
/* sitios. El cromo de alrededor sigue siendo oscuro.                   */
/* ------------------------------------------------------------------ */

.lienzo {
  --diagrama-fondo: #f4f2ed;
  --diagrama-punto: #cdc8be;
  --diagrama-linea: #4a4740;
  --clase-borde: #857a63;
  --clase-cabecera: #f2e3c4;
  --clase-cuerpo: #fdf7e9;
  --clase-texto: #23201b;
  --clase-tenue: #7a7266;
  --clase-seleccion: #2f6fd0;
}

.react-flow__pane,
.react-flow__renderer {
  background: var(--diagrama-fondo);
}

/* --- La caja de una clase --- */

.nodo-clase {
  /* El ancho y el alto los declara el nodo de React Flow: la tarjeta los ocupa
     enteros para que lo dibujado coincida con lo que el minimapa y las aristas
     creen que mide. */
  width: 100%;
  height: 100%;
  /* Esquinas rectas: una caja UML es un rectangulo. El redondeo la convertia
     en una tarjeta de aplicacion. */
  border: 1px solid var(--clase-borde);
  border-radius: 0;
  background: var(--clase-cuerpo);
  color: var(--clase-texto);
  box-shadow: 0 1px 2px rgb(0 0 0 / 12%);
  font-size: 0.78rem;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.nodo-clase .atributos {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
}

/* Seleccion: el marco se refuerza y se anade un halo. En un diagrama impreso
   el color no siempre esta, asi que el grosor tambien cambia. */
.nodo-clase.seleccionado {
  border-color: var(--clase-seleccion);
  box-shadow: 0 0 0 2px color-mix(in srgb, var(--clase-seleccion) 35%, transparent);
}

.nodo-clase.con-error {
  border-color: #b3261e;
}

.nodo-clase.con-aviso {
  border-color: #a5761b;
}

/* Compartimento del nombre: centrado y en negrita, como manda UML. */
.nodo-clase header {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 0.35rem;
  padding: 0.3rem 0.5rem;
  border-bottom: 1px solid var(--clase-borde);
  background: var(--clase-cabecera);
  text-align: center;
}

.nodo-clase.con-error header {
  background: #f3d9d6;
}

.nodo-clase.con-aviso header {
  background: #f4e6c3;
}

.nodo-clase .nombre {
  font-weight: 700;
  font-size: 0.82rem;
}

.nodo-clase .tecnico {
  font-size: 0.62rem;
  color: var(--clase-tenue);
  font-family: ui-monospace, monospace;
}

.nodo-clase .editando {
  position: absolute;
  top: 0.15rem;
  right: 0.25rem;
  font-size: 0.58rem;
  color: #fff;
  padding: 0.05rem 0.3rem;
  border-radius: 999px;
}

/* --- Compartimento de atributos --- */

.atributos {
  list-style: none;
  margin: 0;
  padding: 0.25rem 0;
}

/* `- nombre: Tipo`, y las marcas de clave a la derecha. La visibilidad ocupa
   una columna fija para que los nombres queden alineados. */
.atributos li {
  display: grid;
  grid-template-columns: 0.7rem 1fr auto;
  gap: 0.25rem;
  align-items: baseline;
  padding: 0.06rem 0.45rem;
  line-height: 1.45;
}

.atributos .visibilidad {
  color: var(--clase-tenue);
  text-align: center;
}

.atributos .campo {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.atributos .separador,
.atributos .tipo {
  color: var(--clase-tenue);
}

.atributos .obligatorio {
  color: #a5761b;
  text-decoration: none;
  font-weight: 700;
}

.atributos .vacio {
  display: block;
  padding: 0.2rem 0.5rem;
  color: var(--clase-tenue);
  font-style: italic;
}

.atributos .marcas {
  font-size: 0.56rem;
  font-weight: 700;
  letter-spacing: 0.02em;
}

.atributos .pk {
  color: #8a6d1b;
  text-decoration: none;
}

.atributos .uq {
  color: var(--clase-tenue);
  text-decoration: none;
}

/* --- La asociacion --- */

.asociacion-linea {
  fill: none;
  stroke: var(--diagrama-linea);
  stroke-width: 1.2;
}

/* Franja invisible para poder acertarle con el raton: una linea de un pixel
   es casi imposible de seleccionar. */
.asociacion-zona {
  fill: none;
  stroke: transparent;
  stroke-width: 14;
}

.asociacion:hover .asociacion-linea {
  stroke-width: 1.8;
}

.asociacion.seleccionada .asociacion-linea {
  stroke: var(--clase-seleccion);
  stroke-width: 2;
}

.arista-con-error .asociacion-linea {
  stroke: #b3261e;
  stroke-width: 1.8;
}

/* Las multiplicidades: pequenas, del color de la linea y sin fondo, como en
   cualquier herramienta UML. */
.multiplicidad,
.rol-asociacion {
  fill: var(--clase-texto);
  font-size: 11px;
  font-family: system-ui, sans-serif;
  text-anchor: middle;
  dominant-baseline: middle;
  paint-order: stroke;
  stroke: var(--diagrama-fondo);
  stroke-width: 3;
  stroke-linejoin: round;
  pointer-events: none;
  user-select: none;
}

.rol-asociacion {
  font-style: italic;
  fill: var(--clase-tenue);
}

/* Los conectores solo se ven al apuntar la clase: cuatro puntos por caja
   convierten el diagrama en un erizo. */
.nodo-clase .react-flow__handle {
  width: 7px;
  height: 7px;
  background: var(--clase-seleccion);
  border: 1px solid #fff;
  opacity: 0;
  transition: opacity 120ms ease;
}

.react-flow__node:hover .react-flow__handle,
.react-flow__node.selected .react-flow__handle {
  opacity: 1;
}

/* Los dos anclajes inferiores de una autorrelacion quedan separados, como en
   Enterprise Architect. React Flow los mantiene unidos al nodo al moverlo. */
.nodo-clase .react-flow__handle-bottom.conector-bucle-origen {
  left: 42%;
}

.nodo-clase .react-flow__handle-bottom.conector-bucle-destino {
  left: 58%;
}

/* ------------------------------------------------------------------ */
/* Asistente                                                           */
/* ------------------------------------------------------------------ */

/* El alto lo pone la conversacion, no el panel.
   `max-height: 40%` no hacia nada: el contenedor tiene alto automatico y un
   porcentaje contra un alto indefinido se ignora. El resultado era que el
   asistente crecia con la conversacion hasta que el panel lo recortaba, y lo
   primero que desaparecia era su propio campo de entrada. */
.asistente {
  display: flex;
  flex-direction: column;
  border-bottom: 1px solid var(--borde);
  min-height: 9rem;
}

.asistente > header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--e-3);
  padding: var(--e-3) var(--e-4) 0;
}

.asistente-aprendizaje {
  padding: var(--e-2) var(--e-4) 0;
}

.asistente-aprendizaje > button {
  width: 100%;
}

.guia-ia {
  box-sizing: border-box;
  width: min(38rem, calc(100vw - 2rem));
  max-height: calc(100dvh - 2rem);
  overflow-y: auto;
  overflow-wrap: anywhere;
  padding: var(--e-5);
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-lg);
  background: var(--superficie);
  color: var(--texto);
  box-shadow: var(--sombra-2);
}

.guia-ia::backdrop {
  background: rgb(0 0 0 / 55%);
}

.guia-ia-cabecera,
.guia-ia-acciones {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: var(--e-3);
}

.guia-ia-cabecera h2 {
  margin: 0;
  flex: 1 1 12rem;
  font-size: var(--t-lg);
}

.guia-ia-paso {
  color: var(--acento-texto);
  font-weight: 600;
}

.guia-ia-consejo,
.guia-ia-ejemplo {
  padding: var(--e-3);
  background: var(--superficie-2);
  border-radius: var(--r-md);
}

.guia-ia-ejemplo h4 {
  margin: 0;
}

.guia-ia-nota {
  color: var(--texto-suave);
  font-size: var(--t-sm);
}

.guia-ia-practica {
  min-width: 0;
  margin: 0;
  padding: var(--e-3);
  border: 1px solid var(--borde-fuerte);
}

.guia-ia-practica label {
  display: flex;
  align-items: flex-start;
  gap: var(--e-2);
  margin-block: var(--e-3);
}

.guia-ia-practica input {
  width: auto;
  flex-shrink: 0;
  margin-top: 0.35rem;
}

.guia-ia-acciones,
.guia-ia-ayuda {
  margin-top: var(--e-4);
}

.guia-ia-ayuda summary {
  cursor: pointer;
}

.ayuda-software-boton {
  flex-shrink: 0;
}

.tour-layer {
  position: fixed;
  inset: 0;
  z-index: 10000;
  pointer-events: none;
}

.tour-spotlight {
  position: fixed;
  border-radius: var(--r-md);
  outline: 3px solid var(--acento);
  box-shadow: 0 0 0 9999px rgb(0 0 0 / 25%);
  pointer-events: none;
}

.tour-coach {
  position: fixed;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  width: min(23rem, calc(100vw - 24px));
  max-height: calc(100dvh - 24px);
  overflow-y: auto;
  overscroll-behavior: contain;
  pointer-events: auto;
  padding: var(--e-4);
  color: var(--texto);
  background: var(--superficie);
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-lg);
  box-shadow: var(--sombra-2);
  font-size: var(--t-base);
  overflow-wrap: anywhere;
}

.tour-coach header,
.tour-coach nav {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: var(--e-2);
}

.tour-eyebrow {
  font-size: var(--t-xs);
  letter-spacing: 0.06em;
  color: var(--acento-texto);
  font-weight: 600;
}

.tour-progress-label,
.tour-note {
  font-size: var(--t-sm);
  color: var(--texto-suave);
}

.tour-coach progress {
  flex-shrink: 0;
  width: 100%;
  height: 0.4rem;
  accent-color: var(--acento);
}

.tour-coach h2 {
  flex-shrink: 0;
  font-size: var(--t-lg);
  line-height: 1.4;
}

.tour-feedback {
  padding: var(--e-3);
  background: var(--superficie-2);
  border-radius: var(--r-md);
}

.tour-body {
  min-height: 0;
  overflow-y: auto;
  overscroll-behavior: contain;
}

.tour-target-button {
  margin-bottom: var(--e-3);
}

.tour-note {
  flex-shrink: 0;
  margin-bottom: 0;
}

@media (max-width: 700px) {
  .tour-coach {
    max-height: 45dvh;
  }

  .tour-note {
    display: none;
  }
}

.guia-software {
  width: min(62rem, calc(100vw - 2rem));
  text-align: left;
  font-weight: 400;
  font-size: var(--t-md);
}

.guia-software-progreso {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--e-3);
  margin-block: var(--e-4);
}

.guia-software-busqueda {
  display: grid;
  gap: var(--e-2);
}

.guia-software-contenido {
  display: grid;
  grid-template-columns: minmax(0, 13rem) minmax(0, 1fr);
  gap: var(--e-5);
  margin-top: var(--e-4);
}

.guia-software-temas {
  list-style: none;
  padding: 0;
  display: grid;
  gap: var(--e-2);
}

.guia-software-temas button {
  width: 100%;
  justify-content: space-between;
  text-align: left;
  white-space: normal;
}

.guia-software-temas button[aria-current='step'] {
  border-color: var(--acento);
  background: var(--acento-suave);
  color: var(--acento-texto);
}

.guia-software-temas small {
  margin-left: var(--e-2);
}

.guia-software-leccion li {
  margin-bottom: var(--e-3);
}

.guia-software-leido {
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
  gap: var(--e-2);
}

.guia-software-leido input {
  width: auto;
}

@media (max-width: 700px) {
  .guia-software-contenido {
    grid-template-columns: minmax(0, 1fr);
  }

  .guia-software-temas {
    max-height: 11rem;
    overflow-y: auto;
  }
}

.conversacion {
  flex: 1;
  /* En unidades de ventana y no en porcentaje: asi el campo de entrada y el
     boton de aplicar caben siempre, que es lo unico que no puede quedar
     debajo del borde. */
  max-height: 34vh;
  min-height: 0;
  overflow-y: auto;
  list-style: none;
  margin: 0;
  padding: var(--e-4);
  display: flex;
  flex-direction: column;
  gap: var(--e-3);
  font-size: var(--t-md);
}

.conversacion li p {
  margin: 0;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  padding: 0.35rem 0.6rem;
  border-radius: 0.45rem;
  background: var(--suave);
}

.conversacion li.usuario p {
  align-self: flex-end;
  border: 1px solid var(--borde);
}

.conversacion .ancla-conversacion {
  height: 0;
  padding: 0;
}

.propuesta {
  border: 1px solid var(--borde);
  border-left: 3px solid var(--ok);
  border-radius: 0.45rem;
  padding: 0.5rem 0.6rem;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.propuesta .advertencia {
  margin: 0;
  color: var(--aviso);
  background: none;
  padding: 0;
}

.propuesta .resumen {
  margin: 0;
  padding-left: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  /* Con tope, igual que el candidato de importacion: una propuesta de treinta
     operaciones empujaba el boton de aplicar fuera del panel. */
  max-height: 8rem;
  overflow-y: auto;
}

/* Y el boton se queda pegado al pie de su propuesta, por si aun asi no cabe. */
.propuesta > button {
  position: sticky;
  bottom: 0;
  align-self: flex-start;
  background: var(--fondo-panel);
}

.propuesta .aplicada {
  margin: 0;
  color: var(--ok);
  background: none;
  padding: 0;
  font-size: 0.75rem;
}

.contexto-asistente {
  margin: 0 0.9rem 0.15rem;
  padding: 0.45rem 0.55rem;
  border: 1px solid color-mix(in srgb, var(--aviso) 55%, var(--borde));
  border-radius: 0.45rem;
  background: color-mix(in srgb, var(--aviso) 8%, transparent);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  font-size: 0.72rem;
}

.contexto-asistente button {
  flex: none;
  padding: 0.25rem 0.45rem;
  font-size: 0.7rem;
}

.entrada {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
  padding: 0.6rem 0.9rem;
  border-top: 1px solid var(--borde);
}

.entrada textarea {
  flex: 1;
  flex-basis: 100%;
  min-width: 0;
  resize: vertical;
  max-height: 15rem;
}

.estado-dictado,
.revision-dictado,
.limite-asistente {
  margin: 0;
  padding: 0.4rem 0.9rem;
  font-size: 0.8rem;
  overflow-wrap: anywhere;
}

.revision-dictado p {
  margin: 0 0 0.4rem;
}

.entrada button.escuchando {
  color: var(--error);
  border-color: var(--error);
}

/* ------------------------------------------------------------------ */
/* Importacion y exportacion                                           */
/* ------------------------------------------------------------------ */

.importacion {
  border-bottom: 1px solid var(--borde);
  padding: 0.7rem 0.9rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.importacion h3 {
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  opacity: 0.6;
  margin: 0;
}

.importacion .modo {
  flex-direction: row;
  align-items: center;
  gap: 0.4rem;
  justify-content: space-between;
}

.importacion .acciones {
  display: flex;
  gap: 0.3rem;
  flex-wrap: wrap;
}

.importacion .acciones button {
  font-size: 0.75rem;
  flex: 1;
  min-width: 7rem;
}

.importacion .aplicada {
  margin: 0;
  color: var(--ok);
  font-size: 0.75rem;
}

.candidato {
  border: 1px solid var(--borde);
  border-left: 3px solid var(--aviso);
  border-radius: 0.45rem;
  padding: 0.5rem 0.6rem;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  font-size: 0.78rem;
  /* Sin recorte propio: el que se desplaza es el panel de la herramienta.
     Con `overflow` aqui, la barra de acciones se pegaba al pie **de esta caja**,
     y esta caja la recortaba el panel por debajo — el boton salia cortado por la
     mitad. Una captura lo enseño; la asercion no, porque `toBeInViewport` se
     conforma con un pixel. */
}

.candidato .advertencia {
  margin: 0;
  color: var(--aviso);
}

.candidato-cabecera {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
}

.candidato-cabecera > span {
  max-width: 12rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: color-mix(in srgb, currentColor 68%, transparent);
  font-size: 0.7rem;
}

.bloque-avisos,
.resumen-tecnico {
  border: 1px solid color-mix(in srgb, var(--aviso) 45%, var(--borde));
  border-radius: 0.35rem;
  padding: 0.35rem 0.45rem;
}

.bloque-avisos > summary,
.resumen-tecnico > summary {
  cursor: pointer;
  color: var(--aviso);
  font-weight: 600;
}

.editor-candidato {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  max-height: 15rem;
  overflow-y: auto;
  padding-right: 0.2rem;
}

.fila-candidato {
  display: grid;
  grid-template-columns: minmax(7rem, 1fr) minmax(8rem, 1.25fr);
  align-items: center;
  gap: 0.35rem;
  padding: 0.4rem;
  border: 1px solid var(--borde);
  border-radius: 0.35rem;
  background: color-mix(in srgb, var(--fondo-panel) 85%, white 3%);
}

.fila-candidato > span:first-child {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: color-mix(in srgb, currentColor 68%, transparent);
}

.atributo-candidato {
  grid-template-columns: minmax(7rem, 1fr) minmax(6rem, 1fr);
}

.atributo-candidato > span:first-child {
  grid-column: 1 / -1;
}

.relacion-candidato {
  grid-template-columns: minmax(8rem, 1fr) 4.5rem auto 4.5rem;
}

.marca-candidato {
  display: inline-flex;
  flex-direction: row;
  align-items: center;
  gap: 0.2rem;
  white-space: nowrap;
  font-size: 0.68rem;
}

.marca-candidato input {
  width: auto;
}

.fila-candidato.solo-lectura {
  grid-template-columns: 1fr;
  opacity: 0.8;
}

.estado-vacio {
  margin: 0;
  color: var(--ok);
  line-height: 1.4;
}

/* Las dos listas del candidato tienen tope y su propio desplazamiento.
   Sin tope, un archivo con un aviso por atributo empuja «Aplicar» fuera del
   panel: se ven avisos, no se ve ningun boton, y la conclusion razonable es que
   la importacion no funciona. Lo que hace falta ver primero es la accion. */
.avisos-importacion,
.candidato .resumen {
  max-height: 7.5rem;
  overflow-y: auto;
}

.avisos-importacion {
  margin: 0;
  padding-left: 1rem;
  font-size: 0.72rem;
  color: var(--aviso);
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

/* La accion se queda pegada al pie del panel que se desplaza —la herramienta—,
   no al del candidato: es la unica forma de que no la recorte el borde de
   abajo. Los margenes negativos hacen que la banda ocupe todo el ancho del
   candidato, para que el contenido no se vea pasar por los lados. */
.candidato .acciones {
  position: sticky;
  bottom: 0;
  z-index: 1;
  margin: 0 -0.6rem -0.5rem;
  padding: 0.45rem 0.6rem;
  background: var(--fondo-panel);
  border-top: 1px solid var(--borde);
}

/* Generacion (RF-060 a RF-072) */
.generacion {
  border-bottom: 1px solid var(--borde);
  padding: 0.7rem 0.9rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.generacion h3 {
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  opacity: 0.6;
  margin: 0;
}

.generacion .paquete {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  font-size: 0.72rem;
  opacity: 0.75;
}

.generacion .descargas {
  display: flex;
  gap: 0.3rem;
  flex-wrap: wrap;
}

.generacion .descargas button {
  font-size: 0.75rem;
  flex: 1;
  min-width: 7rem;
}

.generacion .aviso,
.generacion .error {
  margin: 0;
  font-size: 0.72rem;
}

.generacion .historial {
  margin: 0;
  padding: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  font-size: 0.7rem;
  opacity: 0.8;
}

.generacion .historial li {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  flex-wrap: wrap;
}

.generacion .historial .estado {
  border: 1px solid var(--borde);
  border-radius: 999px;
  padding: 0.08rem 0.35rem;
  margin-left: auto;
}

.generacion .historial .estado-ready {
  color: var(--exito);
}

.generacion .historial .estado-failed {
  color: var(--error);
}

/* El manifiesto congelado: nombre y paquete con los que se genero. */
.generacion .historial .manifiesto {
  flex-basis: 100%;
  padding-left: 2.2rem;
  opacity: 0.75;
  font-family: ui-monospace, monospace;
  font-size: 0.64rem;
}

.generacion .historial li.fallida .manifiesto {
  color: var(--error);
  opacity: 1;
}

.generacion .historial button {
  min-height: var(--alto-control-sm);
  font-size: 0.68rem;
  padding: 0.1rem 0.4rem;
}

.generacion .historial .acciones-historial {
  display: flex;
  gap: 0.3rem;
  padding-left: 2.2rem;
  flex-wrap: wrap;
}

/* Retirar una generacion es irreversible: se distingue de las descargas y se
   empuja al final de la fila para que no quede al lado de «Backend». */
.generacion .historial .acciones-historial .eliminar {
  margin-left: auto;
  color: var(--error);
}

/* Tiradores de redimension: solo con la tarjeta seleccionada, y del color
   de la seleccion para que se lean como parte de ella. */
.tirador-redimension {
  width: 8px;
  height: 8px;
  border: 1px solid var(--superficie);
  border-radius: 2px;
  background: var(--acento);
}

.borde-redimension {
  border-color: var(--acento);
}

/* ------------------------------------------------------------------ */
/* Cromo de React Flow                                                 */
/* ------------------------------------------------------------------ */

/* Los controles y el minimapa vienen con fondo blanco por defecto. Sobre el
   lienzo oscuro quedaban como dos rectangulos blancos flotando, que es lo
   primero que se ve en una captura de pantalla. `colorMode="system"` hace que
   React Flow aplique su propio tema; esto ajusta lo que queda para que use los
   colores de la aplicacion en lugar de los suyos. */
/* El cromo de React Flow vive sobre el lienzo claro, no sobre la aplicacion
   oscura: se le da la paleta del diagrama para que no aparezcan dos
   rectangulos de otro tema flotando encima. */
.react-flow__controls,
.react-flow__minimap {
  border: 1px solid var(--clase-borde);
  border-radius: var(--r-md);
  overflow: hidden;
  box-shadow: 0 1px 3px rgb(0 0 0 / 18%);
  background: var(--clase-cuerpo);
}

/* Los controles traen su propia geometria; aqui solo se ajusta al tema y se
   respeta el alto que ellos declaran. */
.react-flow__controls-button {
  min-height: 0;
  width: 26px;
  height: 26px;
  padding: 0;
  border: 0;
  border-bottom: 1px solid var(--clase-borde);
  border-radius: 0;
  background: var(--clase-cuerpo);
  color: var(--clase-texto);
}

.react-flow__controls-button:hover:not(:disabled) {
  background: var(--clase-cabecera);
  border-color: var(--clase-borde);
}

/* El icono es un SVG que hereda `fill`, no `color`. */
.react-flow__controls-button svg {
  fill: var(--clase-texto);
  max-width: 13px;
  max-height: 13px;
}

/* ------------------------------------------------------------------ */
/* Adaptacion a la pantalla                                            */
/*                                                                     */
/* La prioridad es el escritorio y, dentro de el, el lienzo: lo que se  */
/* estrecha es la columna de paneles, nunca el diagrama. Se calibra en  */
/* 1920x1080, 1600x900 y 1366x768, que son las tres pantallas donde     */
/* esto se va a usar de verdad.                                        */
/* ------------------------------------------------------------------ */

@media (max-width: 1500px) {
  .lienzo {
    grid-template-columns: 1fr 23rem;
  }
}

@media (max-width: 1200px) {
  .lienzo {
    grid-template-columns: 1fr 21rem;
  }

  .barra-editor .miga a {
    max-width: 8rem;
  }
}

/* Portatiles de 768px de alto: el cromo vertical se recorta para que la
   herramienta y el inspector sigan cabiendo. */
@media (max-height: 800px) {
  .conversacion {
    max-height: 26vh;
  }

  .herramienta {
    min-height: 11rem;
  }

  .validacion {
    max-height: 26%;
  }
}

/* Por debajo de esto la columna estorba mas de lo que ayuda: pasa a ocupar
   el ancho completo debajo del lienzo en lugar de comerselo. */
@media (max-width: 900px) {
  .lienzo {
    grid-template-columns: 1fr;
    grid-template-rows: minmax(18rem, 1fr) auto;
  }

  .paneles {
    border-left: 0;
    border-top: 1px solid var(--borde);
    max-height: 45vh;
  }
}

/* Acciones sobre una pizarra o un proyecto en las listas. */
.acciones-pizarra {
  display: flex;
  gap: 0.3rem;
  padding: 0 0.6rem 0.6rem;
}

.acciones-pizarra button,
.tarjetas li > .quitar {
  font-size: 0.72rem;
  padding: 0.2rem 0.5rem;
}

.tarjetas li > .quitar {
  margin: 0 0.6rem 0.6rem;
}

/* Salir no destruye nada: en rojo competia con las acciones que si lo hacen
   y con las insignias de estado, que es lo que hay que mirar en esa barra. */
.barra-editor .salir {
  font-size: var(--t-md);
  min-height: var(--alto-control-sm);
  background: transparent;
  border-color: transparent;
  color: var(--texto-suave);
}

.barra-editor .salir:hover:not(:disabled) {
  background: var(--suave-fuerte);
  color: var(--texto);
}

/* ================================================================== */
/* Toolbox UML                                                        */
/*                                                                    */
/* La paleta adopta la densidad de una herramienta de escritorio. No  */
/* intenta reproducir todo Enterprise Architect: muestra solamente lo */
/* que esta pizarra entiende y puede llevar al proyecto del examen.    */
/* ================================================================== */

.lienzo {
  --ancho-toolbox: 15rem;
  --ancho-panel: 26rem;

  grid-template-columns: var(--ancho-toolbox) minmax(0, 1fr) var(--ancho-panel);
  grid-template-rows: minmax(0, 1fr);
}

.lienzo.sin-toolbox {
  --ancho-toolbox: 0rem;
}

.lienzo.sin-panel {
  --ancho-panel: 0rem;
}

.contenedor-toolbox {
  grid-column: 1;
  grid-row: 1;
  min-width: 0;
  min-height: 0;
}

.contenedor-toolbox[hidden],
.paneles[hidden] {
  display: none;
}

.contenedor-toolbox > .toolbox {
  width: 100%;
  height: 100%;
}

.tablero {
  grid-column: 2;
  grid-row: 1;
  min-width: 0;
  min-height: 0;
}

.paneles {
  grid-column: 3;
  grid-row: 1;
}

.toolbox {
  min-width: 0;
  min-height: 0;
  display: flex;
  flex-direction: column;
  border-right: 1px solid var(--borde);
  background: var(--superficie);
  color: var(--texto);
  z-index: 1;
}

.toolbox-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--e-3);
  min-height: 3.5rem;
  padding: var(--e-3) var(--e-4);
  border-bottom: 1px solid var(--borde);
}

.toolbox-header h2 {
  margin: 0;
  font-size: var(--t-lg);
  font-weight: 650;
  letter-spacing: -0.01em;
}

.toolbox-eyebrow {
  display: block;
  color: var(--texto-tenue);
  font-size: 0.625rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  line-height: 1.2;
  text-transform: uppercase;
}

.toolbox-badge {
  padding: 0.12rem 0.35rem;
  border: 1px solid color-mix(in srgb, var(--acento) 45%, var(--borde));
  border-radius: var(--r-sm);
  background: var(--acento-suave);
  color: var(--acento-texto);
  font-family: var(--mono);
  font-size: 0.625rem;
  font-weight: 700;
}

.toolbox-search {
  position: relative;
  display: block;
  padding: var(--e-3);
  border-bottom: 1px solid var(--borde);
}

.toolbox-search svg {
  position: absolute;
  top: 50%;
  left: 1.05rem;
  width: 0.9rem;
  height: 0.9rem;
  color: var(--texto-tenue);
  fill: none;
  stroke: currentColor;
  stroke-width: 1.8;
  transform: translateY(-50%);
  pointer-events: none;
}

.toolbox-search input {
  width: 100%;
  min-height: 1.85rem;
  padding-left: 1.85rem;
  border-radius: var(--r-sm);
  background: var(--fondo);
  font-size: var(--t-sm);
}

.toolbox-scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: var(--e-2) 0;
}

.toolbox-section + .toolbox-section {
  margin-top: var(--e-2);
  padding-top: var(--e-2);
  border-top: 1px solid var(--borde);
}

.toolbox-section h3 {
  margin: 0;
  padding: var(--e-2) var(--e-4);
  color: var(--texto-tenue);
  font-size: 0.625rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.toolbox-items {
  display: flex;
  flex-direction: column;
  gap: 1px;
  padding: 0 var(--e-2);
}

button.toolbox-item {
  width: 100%;
  min-height: 3rem;
  display: grid;
  grid-template-columns: 1.75rem minmax(0, 1fr) auto;
  gap: var(--e-2);
  align-items: center;
  justify-content: initial;
  padding: var(--e-2);
  border: 1px solid transparent;
  border-radius: var(--r-sm);
  background: transparent;
  text-align: left;
}

button.toolbox-item:hover:not(:disabled) {
  border-color: var(--borde);
  background: var(--suave);
}

button.toolbox-item.active {
  border-color: color-mix(in srgb, var(--acento) 45%, var(--borde));
  background: var(--acento-suave);
  color: #fff;
  box-shadow: inset 2px 0 0 var(--acento);
}

.toolbox-item.active .toolbox-item-copy small {
  color: #c7def3;
}

.toolbox-item-icon {
  width: 1.75rem;
  height: 1.75rem;
  display: grid;
  place-items: center;
  border: 1px solid var(--borde-fuerte);
  border-radius: var(--r-sm);
  background: var(--superficie-2);
  color: var(--texto-suave);
}

.toolbox-item.active .toolbox-item-icon {
  border-color: color-mix(in srgb, var(--acento) 65%, white 10%);
  background: color-mix(in srgb, var(--acento) 28%, var(--superficie-2));
  color: #fff;
}

.toolbox-item-icon svg {
  width: 1.15rem;
  height: 1.15rem;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.6;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.toolbox-item-icon svg .filled {
  fill: currentColor;
}

.toolbox-item-icon svg .marker:not(.filled) {
  fill: var(--superficie-2);
}

.toolbox-item-copy {
  min-width: 0;
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.toolbox-item-copy strong {
  overflow: hidden;
  font-size: var(--t-md);
  font-weight: 600;
  text-overflow: ellipsis;
}

.toolbox-item-copy small {
  margin-top: 0.16rem;
  overflow: hidden;
  color: var(--texto-tenue);
  font-size: 0.625rem;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.toolbox-item kbd,
.modo-lienzo kbd {
  min-width: 1.25rem;
  padding: 0.08rem 0.25rem;
  border: 1px solid var(--borde-fuerte);
  border-bottom-color: rgb(255 255 255 / 25%);
  border-radius: 3px;
  background: var(--fondo);
  color: var(--texto-tenue);
  font-family: var(--mono);
  font-size: 0.6rem;
  text-align: center;
}

.toolbox-empty {
  margin: var(--e-4);
  color: var(--texto-tenue);
  font-size: var(--t-sm);
}

.toolbox-status {
  display: grid;
  grid-template-columns: 1.5rem 1fr;
  gap: var(--e-2);
  align-items: start;
  min-height: 3.5rem;
  padding: var(--e-3);
  border-top: 1px solid var(--borde);
  background: var(--fondo);
  color: var(--texto-suave);
  font-size: 0.65rem;
  line-height: 1.4;
}

.toolbox-status-icon {
  width: 1.45rem;
  height: 1.45rem;
  display: grid;
  place-items: center;
  border: 1px solid color-mix(in srgb, var(--acento) 50%, var(--borde));
  border-radius: var(--r-sm);
  background: var(--acento-suave);
  color: var(--acento-texto);
  font-family: var(--mono);
  font-weight: 700;
}

/* La insignia sobre el lienzo deja visible el modo incluso cuando la mirada
   esta lejos de la paleta. */
.modo-lienzo {
  display: flex;
  align-items: center;
  gap: var(--e-2);
  margin: var(--e-4) !important;
  padding: var(--e-2) var(--e-3);
  border: 1px solid color-mix(in srgb, var(--acento) 55%, #64748b);
  border-radius: var(--r-md);
  background: rgb(15 23 42 / 92%);
  color: #eef6ff;
  box-shadow: var(--sombra-2);
  font-size: var(--t-sm);
  backdrop-filter: blur(8px);
}

.modo-lienzo > span:not(.modo-lienzo-punto) {
  color: #aebbc9;
}

.modo-lienzo .cancelar-modo {
  min-height: 1.6rem;
  padding-inline: var(--e-2);
  border-color: rgb(255 255 255 / 16%);
  background: rgb(255 255 255 / 7%);
  color: #eef6ff;
  font-size: var(--t-xs);
}

.modo-lienzo .cancelar-modo:hover:not(:disabled) {
  background: rgb(255 255 255 / 14%);
}

.modo-lienzo .cancelar-modo kbd {
  margin-left: var(--e-1);
  background: rgb(0 0 0 / 18%);
  color: #d7e5f2;
}

.estado-lienzo-vacio {
  width: min(24rem, calc(100% - 2rem));
  margin-top: clamp(3rem, 16vh, 8rem) !important;
  padding: var(--e-6);
  display: grid;
  justify-items: center;
  gap: var(--e-3);
  border: 1px solid #c8c0b1;
  border-radius: var(--r-lg);
  background: rgb(253 247 233 / 92%);
  color: var(--clase-texto);
  box-shadow: 0 8px 24px rgb(74 71 64 / 12%);
  text-align: center;
  backdrop-filter: blur(4px);
}

.estado-lienzo-vacio h2,
.estado-lienzo-vacio p {
  margin: 0;
}

.estado-lienzo-vacio h2 {
  font-size: var(--t-lg);
}

.estado-lienzo-vacio p {
  max-width: 20rem;
  color: #5f594f;
  font-size: var(--t-md);
}

.estado-lienzo-icono {
  width: 2.25rem;
  height: 2.25rem;
  display: grid;
  place-items: center;
  border: 1px solid #a99d86;
  border-radius: var(--r-md);
  background: var(--clase-cabecera);
  color: #4b4336;
  font-size: var(--t-xl);
}

.modo-lienzo-punto {
  width: 0.45rem;
  height: 0.45rem;
  border-radius: 50%;
  background: #5fb0ff;
  box-shadow: 0 0 0 3px rgb(95 176 255 / 16%);
}

.herramienta-class .react-flow__pane,
.herramienta-association .react-flow__node,
.herramienta-generalization .react-flow__node,
.herramienta-composition .react-flow__node,
.herramienta-aggregation .react-flow__node {
  cursor: crosshair;
}

/* Primera clase de una relacion creada desde la paleta. El borde discontinuo
   comunica que la operacion aun no termino y no depende solo del color. */
.nodo-clase.origen-relacion {
  border: 2px dashed var(--clase-seleccion);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--clase-seleccion) 18%, transparent);
}

/* Accion contextual al estilo de Architect: al seleccionar una clase aparece
   una flecha grande a su derecha. Se arrastra al conector de otra clase y crea
   una asociacion sin tener que volver al toolbox. */
.react-flow__node.selected .react-flow__handle-right.conector-rapido {
  right: -2.4rem;
  width: 1.8rem;
  height: 1.8rem;
  border: 1px solid #f8fafc;
  border-radius: var(--r-md);
  background: #1f67ad;
  color: #fff;
  opacity: 1;
  box-shadow: 0 2px 8px rgb(15 23 42 / 35%);
}

.react-flow__node.selected .react-flow__handle-right.conector-rapido::after {
  content: '\2192';
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  color: #fff;
  font-size: 1rem;
  font-weight: 700;
  line-height: 1;
  pointer-events: none;
}

/* Marcadores UML. El lienzo queda visible bajo las figuras huecas; la
   composicion se rellena para distinguirla tambien en escala de grises. */
.marcador-relacion {
  fill: var(--diagrama-fondo);
  stroke: var(--diagrama-linea);
  stroke-width: 1.35;
  stroke-linejoin: round;
  pointer-events: none;
}

.marcador-relacion.relleno {
  fill: var(--diagrama-linea);
}

.asociacion.seleccionada .marcador-relacion {
  stroke: var(--clase-seleccion);
  stroke-width: 2;
}

.asociacion.seleccionada .marcador-relacion.relleno {
  fill: var(--clase-seleccion);
}

.pista-relacion {
  margin: calc(var(--e-2) * -1) 0 0;
  padding: var(--e-2) var(--e-3);
  border-left: 2px solid var(--acento);
  background: var(--acento-suave);
  color: var(--texto-suave);
  font-size: var(--t-sm);
}

@media (max-width: 1500px) {
  .lienzo {
    --ancho-toolbox: 13.5rem;
    --ancho-panel: 23rem;
  }
}

@media (max-width: 1180px) {
  .lienzo {
    --ancho-toolbox: 4.25rem;
    --ancho-panel: 21rem;
  }

  .toolbox-header {
    justify-content: center;
    padding-inline: var(--e-2);
  }

  .toolbox-header > div,
  .toolbox-badge,
  .toolbox-search,
  .toolbox-section h3,
  .toolbox-item-copy,
  .toolbox-item kbd,
  .toolbox-status > span:last-child {
    display: none;
  }

  .toolbox-scroll {
    padding-top: var(--e-3);
  }

  .toolbox-section + .toolbox-section {
    margin-top: var(--e-3);
    padding-top: var(--e-3);
  }

  .toolbox-items {
    align-items: center;
    padding-inline: var(--e-2);
  }

  button.toolbox-item {
    width: 2.75rem;
    min-height: 2.75rem;
    grid-template-columns: 1fr;
    place-items: center;
    padding: var(--e-2);
  }

  .toolbox-status {
    grid-template-columns: 1fr;
    place-items: center;
    min-height: 3.5rem;
  }
}

@media (max-width: 900px) {
  .lienzo {
    --ancho-toolbox: 4.25rem;

    grid-template-columns: var(--ancho-toolbox) minmax(0, 1fr);
    grid-template-rows: minmax(18rem, 1fr) auto;
  }

  .contenedor-toolbox {
    grid-row: 1 / 3;
  }

  .tablero {
    grid-column: 2;
    grid-row: 1;
  }

  .paneles {
    grid-column: 2;
    grid-row: 2;
  }

  .barra-editor {
    gap: var(--e-2);
    /* Entre el teléfono y el escritorio la barra seguia siendo una sola fila
       sin ceder: con la pizarra guardada para abrir sin conexión, los avisos
       de estado piden casi 400 px y en una tableta de 768 empujaban Salir
       fuera de la pantalla —la página entera se ensanchaba a 858—. Aquí baja
       a una segunda fila, que es lo que ya hace el telefono. */
    flex-wrap: wrap;
  }

  .barra-editor .estado-barra {
    flex-wrap: wrap;
    min-width: 0;
  }

  .barra-editor button.boton-panel {
    width: var(--alto-control-sm);
    padding: 0;
    font-size: 0;
  }

  .barra-editor .boton-panel .icono-panel {
    font-size: initial;
  }

  .extremos-relacion {
    grid-template-columns: 1fr;
  }

  .react-flow__minimap {
    display: none;
  }
}

/* En telefonos, cada grupo tiene espacio propio: la presencia no puede
   superponerse a Salir ni empujar los controles fuera de la pantalla. */
@media (max-width: 640px) {
  .contenedor-toolbox {
    grid-row: 1;
  }

  .paneles {
    grid-column: 1 / -1;
  }

  .barra-editor {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto auto;
  }

  .barra-editor .identidad {
    grid-column: 1 / -1;
  }

  .barra-editor .identidad .miga {
    flex-shrink: 0;
  }

  .barra-editor .separa {
    display: none;
  }

  .barra-editor .salir {
    grid-column: 3;
    grid-row: 2;
  }

  .barra-editor .estado-barra {
    grid-column: 1 / 3;
    flex-wrap: wrap;
    min-width: 0;
  }

  .barra-editor .presencia {
    justify-content: flex-end;
    flex-wrap: wrap;
    max-width: 4.5rem;
  }

  .barra-editor .presencia li {
    flex-shrink: 0;
  }

  .barra-editor button.boton-panel,
  .barra-editor .salir {
    min-height: 2.75rem;
  }

  .barra-editor button.boton-panel {
    width: 2.75rem;
  }
}

/* Lo que una clase recibe por herencia (RM-07).

   Se distingue de sus propios atributos a proposito: son de solo lectura y se
   editan en la clase que los declara. El borde a la izquierda es el mismo
   recurso que usa `.pista-relacion` para lo mismo — informacion que acompana,
   no un control. */
.herencia {
  margin: 0;
  padding: var(--e-2) var(--e-3);
  border-left: 2px solid var(--acento);
  background: var(--acento-suave);
  font-size: var(--t-sm);
  color: var(--texto-suave);
  display: flex;
  flex-direction: column;
  gap: var(--e-1);
}

.herencia p {
  margin: 0;
}

.atributos-heredados {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-wrap: wrap;
  gap: var(--e-1) var(--e-2);
  font-family: var(--mono);
  color: var(--texto-tenue);
}

.atributos-heredados .tipo {
  color: var(--texto-suave);
}

.atributos-heredados .marca-clave {
  color: var(--acento);
}

/* Un enlace, no un boton: lleva a otro elemento del mismo diagrama. Se dibuja
   como texto para que no compita con los controles que si modifican. */
.enlace-clase {
  padding: 0;
  border: 0;
  background: none;
  font: inherit;
  color: var(--acento);
  text-decoration: underline;
  cursor: pointer;
}

.enlace-clase:hover {
  color: var(--texto);
}

/* Captura por cámara dentro del panel de importación.

   Ocupa el ancho del panel en lugar de abrir un diálogo: el panel ya está a la
   derecha del lienzo y un modal encima taparía el diagrama que se está por
   comparar con la foto. */
.camara {
  display: flex;
  flex-direction: column;
  gap: var(--e-2);
  padding: var(--e-3);
  border: 1px solid var(--borde);
  border-radius: var(--r-md);
  background: var(--superficie);
}

.camara-vista {
  width: 100%;
  max-height: 15rem;
  object-fit: cover;
  border-radius: var(--r-md);
  background: #000;
}

.camara-acciones {
  display: flex;
  gap: var(--e-2);
}

.camara-acciones button {
  flex: 1;
}

/* En un teléfono el formulario y el diagrama necesitan todo el ancho.
   Se desplaza la página, sin comprimir tres regiones en un panel de 45vh. */
@media (max-width: 640px), (max-width: 900px) and (max-height: 500px) {
  :root {
    --alto-control: 2.75rem;
    --alto-control-sm: 2.75rem;
  }

  .acceso-formulario {
    min-width: 0;
    padding: var(--e-5) var(--e-4);
  }

  .tarjeta,
  .panel-perfil {
    min-width: 0;
    padding: var(--e-5);
  }

  .encabezado-pagina > div,
  .formulario-perfil,
  .tarjeta > *,
  .paneles > * {
    min-width: 0;
  }

  .encabezado-pagina h1,
  .derivados,
  .herencia,
  .manifiesto {
    overflow-wrap: anywhere;
  }

  input:not([type='checkbox']):not([type='radio']),
  select,
  textarea,
  .lista-atributos input:not([type='checkbox']),
  .lista-atributos select {
    min-width: 0;
    font-size: 1rem;
  }

  .editor {
    height: auto;
    min-height: 100dvh;
  }

  .barra-editor {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto auto;
    gap: var(--e-2);
    padding: var(--e-3);
  }

  .barra-editor .identidad {
    grid-column: 1 / -1;
  }

  .barra-editor .miga {
    flex-shrink: 0;
  }

  .barra-editor .separa {
    display: none;
  }

  .barra-editor .estado-barra {
    grid-column: 1 / 3;
    grid-row: 3;
    flex-wrap: wrap;
    min-width: 0;
  }

  .barra-editor .presencia {
    grid-column: 3;
    grid-row: 3;
    max-width: 5rem;
    overflow-x: auto;
    justify-self: end;
  }

  .barra-editor .salir {
    grid-column: 3;
    grid-row: 2;
  }

  .lienzo {
    flex: none;
    grid-template-columns: minmax(0, 1fr);
    grid-template-rows: auto clamp(16rem, 45dvh, 28rem) auto;
    min-width: 0;
  }

  .contenedor-toolbox {
    grid-column: 1;
    grid-row: 1;
  }

  .toolbox {
    border-right: 0;
    border-bottom: 1px solid var(--borde);
  }

  .toolbox-header,
  .toolbox-status {
    display: none;
  }

  .toolbox-scroll {
    display: flex;
    overflow-x: auto;
    padding: var(--e-2);
  }

  .toolbox-section,
  .toolbox-section + .toolbox-section {
    flex-shrink: 0;
    margin: 0;
    padding: 0;
    border: 0;
  }

  .toolbox-items {
    flex-direction: row;
    gap: var(--e-1);
    padding: 0 var(--e-1) 0 0;
  }

  .tablero {
    grid-column: 1;
    grid-row: 2;
    height: 100%;
  }

  .paneles {
    grid-column: 1;
    grid-row: 3;
    max-height: none;
    overflow: visible;
  }

  .herramienta,
  .herramienta:has(.candidato),
  .inspector,
  .validacion {
    flex: none;
    min-height: 0;
    max-height: none;
    overflow: visible;
  }

  .lista-atributos li {
    grid-template-columns: minmax(0, 1fr) minmax(0, 1fr) auto;
  }

  .marcadores {
    flex-wrap: wrap;
    gap: var(--e-2) var(--e-3);
  }

  .marcadores label {
    min-height: var(--alto-control);
  }

  .validacion li button {
    white-space: normal;
    overflow-wrap: anywhere;
  }

  .modo-lienzo {
    max-width: calc(100% - 1.5rem);
    flex-wrap: wrap;
  }

  .importacion .modo {
    flex-direction: column;
    align-items: stretch;
  }

  .entrada {
    flex-wrap: wrap;
  }

  .entrada textarea {
    flex-basis: 100%;
  }

  .entrada button:last-child {
    flex: 1;
  }

  .editor:has(.lienzo.sin-panel) {
    height: 100dvh;
  }

  .lienzo.sin-panel {
    flex: 1;
    grid-template-rows: auto minmax(16rem, 1fr);
  }

  .lienzo.sin-panel .tablero {
    height: 100%;
  }
}

/* Nombre del archivo antes de exportar.

   Va dentro del panel, como la cámara: el diálogo del navegador no se puede
   probar de extremo a extremo y en un Chromium sin interfaz se cuelga. */
.nombre-export {
  display: flex;
  flex-direction: column;
  gap: var(--e-2);
  padding: var(--e-3);
  border: 1px solid var(--borde);
  border-radius: var(--r-md);
  background: var(--superficie);
}

.nombre-export label {
  display: flex;
  flex-direction: column;
  gap: var(--e-1);
}

.nombre-export code {
  font-family: var(--mono);
  color: var(--acento);
}
```

---

### `frontend/src/vite-env.d.ts`

```ts
/// <reference types="vite/client" />
```

---

### `frontend/src/components/AppBar.tsx`

```tsx
import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router';
import { avatarUrl } from '../lib/api.js';
import { ThemeSelect } from './ThemeProvider.js';
import { SoftwareGuide } from '../features/help/SoftwareGuide.js';
import { IconoChevron, IconoDiagrama, IconoSalir, IconoProyecto } from './icons.js';

/**
 * Barra superior de las pantallas administrativas.
 *
 * Es presentacional: recibe el usuario y la funcion de salir, y no sabe de
 * donde vienen. La sesion se sigue gestionando exactamente donde se gestionaba.
 *
 * «Salir» pasa al menu del usuario porque antes era un boton permanente al lado
 * del titulo, con el mismo peso visual que las acciones que uno si usa a
 * menudo. Cerrar sesion se hace una vez al dia.
 */
export function AppBar({
  displayName,
  userId,
  avatarVersion = 0,
  onLogout,
}: {
  readonly displayName: string | undefined;
  /** Para la foto de perfil. Sin el, el avatar son las iniciales. */
  readonly userId?: string | undefined;
  /**
   * Cambia cuando la persona sube o quita su foto.
   *
   * Sin esto la barra se queda con lo que decidio al montarse: si no habia
   * foto, el avatar cayo a las iniciales y no vuelve a mirar. Cambiar el
   * numero fuerza otra peticion y remonta el componente.
   */
  readonly avatarVersion?: number;
  onLogout(): void;
}): React.JSX.Element {
  return (
    <header className="app-bar">
      <Link to="/proyectos" className="marca" aria-label="UMLFORGE AI, ir a mis proyectos">
        <span className="isotipo" aria-hidden="true">
          <IconoDiagrama size={18} />
        </span>
        <span className="nombre-producto">UMLFORGE AI</span>
      </Link>

      <div className="separa" />
      <SoftwareGuide />
      <ThemeSelect />

      <MenuUsuario
        displayName={displayName}
        userId={userId}
        avatarVersion={avatarVersion}
        onLogout={onLogout}
      />
    </header>
  );
}

/**
 * Menu del usuario.
 *
 * Se cierra al pulsar fuera y con Escape, y devuelve el foco al disparador:
 * un menu que se queda abierto detras de otra cosa, o que deja el foco
 * perdido, es peor que no tenerlo.
 */
function MenuUsuario({
  displayName,
  userId,
  avatarVersion,
  onLogout,
}: {
  readonly displayName: string | undefined;
  readonly userId?: string | undefined;
  readonly avatarVersion: number;
  onLogout(): void;
}): React.JSX.Element {
  const [abierto, setAbierto] = useState(false);
  const contenedor = useRef<HTMLDivElement>(null);
  const disparador = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (!abierto) return;

    const alPulsarFuera = (evento: MouseEvent): void => {
      if (!contenedor.current?.contains(evento.target as Node)) setAbierto(false);
    };
    const alTeclear = (evento: KeyboardEvent): void => {
      if (evento.key !== 'Escape') return;
      setAbierto(false);
      disparador.current?.focus();
    };

    document.addEventListener('mousedown', alPulsarFuera);
    document.addEventListener('keydown', alTeclear);
    return () => {
      document.removeEventListener('mousedown', alPulsarFuera);
      document.removeEventListener('keydown', alTeclear);
    };
  }, [abierto]);

  const nombre = displayName ?? '';

  return (
    <div className="menu-usuario" ref={contenedor}>
      <button
        type="button"
        ref={disparador}
        className="fantasma disparador-usuario"
        aria-haspopup="menu"
        aria-expanded={abierto}
        data-testid="menu-usuario"
        onClick={() => setAbierto((previo) => !previo)}
      >
        {/* La clave remonta el avatar cuando la foto cambia: es lo que hace
            que deje de mostrar las iniciales en cuanto hay una. */}
        <Avatar key={avatarVersion} nombre={nombre} userId={userId} version={avatarVersion} />
        <span className="nombre-usuario">{nombre}</span>
        <IconoChevron size={14} />
      </button>

      {abierto && (
        <div className="desplegable" role="menu">
          <p className="cabecera-desplegable">
            <span className="titulo">{nombre}</span>
            <span className="meta">Sesión iniciada</span>
          </p>
          <Link
            to="/cuenta"
            role="menuitem"
            className="opcion-desplegable enlace-menu"
            data-testid="mi-cuenta"
            onClick={() => setAbierto(false)}
          >
            <IconoProyecto size={15} />
            Mi cuenta
          </Link>

          <button
            type="button"
            role="menuitem"
            className="fantasma opcion-desplegable"
            data-testid="salir"
            onClick={() => {
              setAbierto(false);
              onLogout();
            }}
          >
            <IconoSalir size={15} />
            Cerrar sesión
          </button>
        </div>
      )}
    </div>
  );
}

/** Iniciales sobre un color derivado del nombre: estable entre recargas. */
export function Avatar({
  nombre,
  userId,
  version = 0,
  size = 28,
}: {
  readonly nombre: string;
  readonly userId?: string | undefined;
  readonly version?: number;
  readonly size?: number;
}): React.JSX.Element {
  const iniciales = nombre.trim().slice(0, 2).toUpperCase() || '?';
  const matiz = [...nombre].reduce((total, letra) => total + letra.charCodeAt(0), 0) % 360;
  // Si la persona no tiene foto la ruta responde 404 y se vuelve a las
  // iniciales, en lugar de dejar el icono de imagen rota.
  const [sinFoto, setSinFoto] = useState(false);

  if (userId !== undefined && !sinFoto) {
    return (
      <img
        className="avatar"
        src={avatarUrl(userId, version)}
        alt=""
        width={size}
        height={size}
        style={{ width: size, height: size }}
        onError={() => setSinFoto(true)}
      />
    );
  }

  return (
    <span
      className="avatar"
      aria-hidden="true"
      style={{
        width: size,
        height: size,
        background: `oklch(0.55 0.13 ${matiz})`,
        fontSize: size * 0.4,
      }}
    >
      {iniciales}
    </span>
  );
}
```

---

### `frontend/src/components/ThemeProvider.tsx`

```tsx
import {
  createContext,
  useContext,
  useEffect,
  useLayoutEffect,
  useMemo,
  useState,
  useRef,
  useId,
  type ReactNode,
} from 'react';

type ThemePreference = 'light' | 'dark' | 'system';
type Theme = 'light' | 'dark';
const KEY = 'umlforge.theme';
const QUERY = '(prefers-color-scheme: dark)';
const normalize = (value: string | null): ThemePreference =>
  value === 'light' || value === 'dark' ? value : 'system';
const ThemeContext = createContext<{
  preference: ThemePreference;
  resolved: Theme;
  setPreference(value: ThemePreference): void;
} | null>(null);

export function ThemeProvider({ children }: { children: ReactNode }): React.JSX.Element {
  const [preference, setValue] = useState<ThemePreference>(() => {
    try {
      return normalize(localStorage.getItem(KEY));
    } catch {
      return 'system';
    }
  });
  const [systemDark, setSystemDark] = useState(() => window.matchMedia(QUERY).matches);
  const resolved = preference === 'system' ? (systemDark ? 'dark' : 'light') : preference;

  useEffect(() => {
    const media = window.matchMedia(QUERY);
    const onChange = (): void => setSystemDark(media.matches);
    const onStorage = (event: StorageEvent): void => {
      if (event.key === KEY || event.key === null) {
        try {
          setValue(normalize(localStorage.getItem(KEY)));
        } catch {
          /* Conserva la selección actual. */
        }
      }
    };
    onChange();
    media.addEventListener('change', onChange);
    window.addEventListener('storage', onStorage);
    return () => {
      media.removeEventListener('change', onChange);
      window.removeEventListener('storage', onStorage);
    };
  }, []);

  useLayoutEffect(() => {
    document.documentElement.dataset['theme'] = resolved;
    document.documentElement.style.colorScheme = resolved;
    document
      .querySelector('meta[name="theme-color"]')
      ?.setAttribute('content', resolved === 'dark' ? '#1e1e1e' : '#f5f4f0');
  }, [resolved]);

  const value = useMemo(
    () => ({
      preference,
      resolved,
      setPreference(next: ThemePreference): void {
        setValue(next);
        try {
          localStorage.setItem(KEY, next);
        } catch {
          /* El tema sigue funcionando en esta pestaña. */
        }
      },
    }),
    [preference, resolved],
  );
  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): NonNullable<React.ContextType<typeof ThemeContext>> {
  const value = useContext(ThemeContext);
  if (value === null) throw new Error('Falta ThemeProvider');
  return value;
}

export function ThemeSelect(): React.JSX.Element {
  const { preference, setPreference } = useTheme();
  const [open, setOpen] = useState(false);
  const container = useRef<HTMLDivElement>(null);
  const trigger = useRef<HTMLButtonElement>(null);
  const options = useRef<(HTMLButtonElement | null)[]>([]);
  const menuId = useId();
  const choices = [
    { value: 'light', label: 'Claro', description: 'Superficies luminosas' },
    { value: 'dark', label: 'Oscuro', description: 'Grises al estilo VS Code' },
    { value: 'system', label: 'Sistema', description: 'Seguir la apariencia del equipo' },
  ] as const;
  const selected = choices.findIndex((choice) => choice.value === preference);
  useEffect(() => {
    if (!open) return;
    options.current[selected]?.focus();
    const outside = (event: PointerEvent): void => {
      if (!container.current?.contains(event.target as Node)) setOpen(false);
    };
    document.addEventListener('pointerdown', outside);
    return () => document.removeEventListener('pointerdown', outside);
  }, [open, selected]);
  const close = (): void => {
    setOpen(false);
    trigger.current?.focus();
  };
  return (
    <div
      className="theme-select"
      ref={container}
      onBlur={(event) => {
        if (!event.currentTarget.contains(event.relatedTarget as Node | null)) setOpen(false);
      }}
    >
      <button
        type="button"
        className="theme-trigger"
        ref={trigger}
        aria-label="Apariencia"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={open ? menuId : undefined}
        onClick={() => setOpen(!open)}
        onKeyDown={(event) => {
          if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
            event.preventDefault();
            setOpen(true);
          }
        }}
      >
        <ThemeIcon theme={preference} />
        <span>{choices[selected]?.label}</span>
        <svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true">
          <path d="m3 4.5 3 3 3-3" fill="none" stroke="currentColor" strokeWidth="1.3" />
        </svg>
      </button>
      {open && (
        <div
          className="theme-menu"
          role="menu"
          aria-label="Apariencia"
          id={menuId}
          onKeyDown={(event) => {
            if (event.key === 'Escape') {
              event.preventDefault();
              event.stopPropagation();
              close();
            }
            const index = options.current.indexOf(document.activeElement as HTMLButtonElement);
            const next =
              event.key === 'ArrowDown'
                ? (index + 1) % 3
                : event.key === 'ArrowUp'
                  ? (index + 2) % 3
                  : event.key === 'Home'
                    ? 0
                    : event.key === 'End'
                      ? 2
                      : null;
            if (next !== null) {
              event.preventDefault();
              options.current[next]?.focus();
            }
          }}
        >
          <p className="theme-menu-title">Apariencia</p>
          {choices.map((choice, index) => (
            <button
              type="button"
              role="menuitemradio"
              aria-label={choice.label}
              aria-checked={preference === choice.value}
              tabIndex={index === selected ? 0 : -1}
              key={choice.value}
              ref={(element) => {
                options.current[index] = element;
              }}
              onClick={() => {
                setPreference(choice.value);
                close();
              }}
            >
              <ThemeIcon theme={choice.value} />
              <span>
                <strong>{choice.label}</strong>
                <small>{choice.description}</small>
              </span>
              {preference === choice.value && (
                <svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true">
                  <path d="m3 8 3 3 7-7" fill="none" stroke="currentColor" strokeWidth="1.6" />
                </svg>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

function ThemeIcon({ theme }: { theme: ThemePreference }): React.JSX.Element {
  return (
    <svg
      viewBox="0 0 20 20"
      width="17"
      height="17"
      aria-hidden="true"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.4"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {theme === 'light' ? (
        <>
          <circle cx="10" cy="10" r="3.5" />
          <path d="M10 1v2m0 14v2M1 10h2m14 0h2M3.6 3.6 5 5m10 10 1.4 1.4M3.6 16.4 5 15M15 5l1.4-1.4" />
        </>
      ) : theme === 'dark' ? (
        <path d="M16.8 12.2A7.2 7.2 0 0 1 7.8 3.2a7.2 7.2 0 1 0 9 9Z" />
      ) : (
        <>
          <rect x="2" y="3" width="16" height="11" rx="1.5" />
          <path d="M7 18h6m-3-4v4" />
        </>
      )}
    </svg>
  );
}
```

---

### `frontend/src/components/icons.tsx`

```tsx
/**
 * Iconografia de la plataforma.
 *
 * SVG en linea y no una libreria: el proyecto no tenia ninguna, y anadir una
 * dependencia entera —con su cadena de versiones y su peso— para dibujar quince
 * trazos no se paga. Todos heredan `currentColor` y el tamano del contexto, asi
 * que un icono dentro de un boton de peligro se pone rojo solo.
 *
 * Todos son decorativos: van junto a un texto o dentro de un boton que ya lleva
 * su nombre accesible. Por eso `aria-hidden`, y por eso ningun boton de icono
 * puede quedarse sin `aria-label`.
 */

export interface IconProps {
  readonly size?: number;
  readonly className?: string;
}

function Svg({
  size = 16,
  className,
  children,
}: IconProps & { children: React.ReactNode }): React.JSX.Element {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.75}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...(className === undefined ? {} : { className })}
    >
      {children}
    </svg>
  );
}

/** Proyecto: una carpeta de trabajo. */
export function IconoProyecto(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z" />
    </Svg>
  );
}

/** Pizarra: el marco de un diagrama. */
export function IconoPizarra(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <rect x="3" y="4" width="18" height="14" rx="2" />
      <path d="M8 21h8M12 18v3" />
    </Svg>
  );
}

/** Diagrama de clases: dos cajas unidas, que es el isotipo del producto. */
export function IconoDiagrama(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <rect x="3" y="3" width="8" height="6" rx="1.5" />
      <rect x="13" y="15" width="8" height="6" rx="1.5" />
      <path d="M7 9v5a2 2 0 0 0 2 2h4" />
    </Svg>
  );
}

export function IconoMiembros(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <circle cx="9" cy="8" r="3.25" />
      <path d="M3.5 19a5.5 5.5 0 0 1 11 0" />
      <path d="M16 5.5a3.25 3.25 0 0 1 0 6M17.5 14.2A5.5 5.5 0 0 1 20.5 19" />
    </Svg>
  );
}

export function IconoMas(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <path d="M12 5v14M5 12h14" />
    </Svg>
  );
}

export function IconoLapiz(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <path d="M4 20h4L19 9a2.1 2.1 0 0 0-3-3L5 17Z" />
      <path d="M14.5 6.5 17.5 9.5" />
    </Svg>
  );
}

export function IconoPapelera(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <path d="M4 7h16M10 4h4M6 7l1 12a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-12" />
      <path d="M10 11v6M14 11v6" />
    </Svg>
  );
}

export function IconoInvitar(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <circle cx="10" cy="8" r="3.25" />
      <path d="M4 19a6 6 0 0 1 12 0" />
      <path d="M18 8v6M15 11h6" />
    </Svg>
  );
}

export function IconoSalir(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <path d="M14 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3" />
      <path d="M10 8l-4 4 4 4M6 12h9" />
    </Svg>
  );
}

export function IconoVolver(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <path d="M15 6l-6 6 6 6" />
    </Svg>
  );
}

export function IconoBuscar(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <circle cx="11" cy="11" r="6" />
      <path d="M20 20l-4.5-4.5" />
    </Svg>
  );
}

export function IconoLlave(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <circle cx="8" cy="12" r="4" />
      <path d="M12 12h9M18 12v3M15.5 12v2.5" />
    </Svg>
  );
}

export function IconoChevron(props: IconProps): React.JSX.Element {
  return (
    <Svg {...props}>
      <path d="M6 9l6 6 6-6" />
    </Svg>
  );
}
```

---

### `frontend/src/features/assistant/AssistantLearningGuide.tsx`

```tsx
import { useId, useRef, useState } from 'react';
import type { SemanticModel } from '@uml/contracts';
import { instructionExample, learningSteps, type AssistantMode } from './learning-guide.js';

const completionKey = 'uml.assistant-learning.v1';

interface Props {
  readonly model: SemanticModel;
  readonly canWrite: boolean;
  readonly canUseExample: boolean;
  useExample(mode: AssistantMode, text: string): void;
}

export function AssistantLearningGuide({ model, canWrite, canUseExample, useExample }: Props) {
  const dialog = useRef<HTMLDialogElement>(null);
  const headingId = useId();
  const [step, setStep] = useState(0);
  const [answer, setAnswer] = useState<'send' | 'review' | null>(null);
  const [completed, setCompleted] = useState(() => {
    try {
      return localStorage.getItem(completionKey) === 'completed';
    } catch {
      return false;
    }
  });
  const lesson = learningSteps[step]!;
  const example =
    step === 0 ? '¿Qué clases hay en el diagrama y cómo se relacionan?' : instructionExample(model);

  function finish() {
    setCompleted(true);
    try {
      localStorage.setItem(completionKey, 'completed');
    } catch {
      // The guide remains usable when the browser blocks local storage.
    }
    dialog.current?.close();
  }

  return (
    <>
      <button type="button" onClick={() => dialog.current?.showModal()}>
        {completed ? 'Repasar guía de IA' : 'Aprender a usar la IA'}
      </button>
      <dialog ref={dialog} className="guia-ia" aria-labelledby={headingId}>
        <header className="guia-ia-cabecera">
          <h2 id={headingId}>Aprende a usar el asistente</h2>
          <button
            type="button"
            autoFocus
            onClick={() => dialog.current?.close()}
            aria-label="Cerrar guía"
          >
            Cerrar
          </button>
        </header>
        <p>Guía interactiva · Puedes practicar sin enviar solicitudes ni cambiar el diagrama.</p>
        <div aria-live="polite" aria-atomic="true">
          <p className="guia-ia-paso">
            Paso {step + 1} de {learningSteps.length}
          </p>
          <h3>{lesson.title}</h3>
          <p>{lesson.text}</p>
          <p className="guia-ia-consejo">{lesson.tip}</p>
        </div>
        {step < 2 && (
          <div className="guia-ia-ejemplo">
            <h4>Ejemplo para tu pizarra</h4>
            <p>{example}</p>
            <button
              type="button"
              disabled={!canUseExample || (step === 1 && !canWrite)}
              onClick={() => {
                dialog.current?.close();
                useExample(step === 0 ? 'preguntar' : 'instruir', example);
              }}
            >
              Usar ejemplo como borrador
            </button>
            <p className="guia-ia-nota">
              {!canUseExample
                ? 'Conservamos tu trabajo: termina la solicitud o el dictado y vacía el borrador. Si hay una aclaración en curso, resuélvela o pulsa Empezar de nuevo.'
                : step === 1 && !canWrite
                  ? 'Tu rol permite consultar. Para instruir necesitas permiso de edición.'
                  : 'Solo rellena el cuadro de texto. Tú decides si lo editas y lo envías.'}
            </p>
          </div>
        )}
        {step === learningSteps.length - 1 && (
          <fieldset className="guia-ia-practica">
            <legend>Práctica: la IA propone borrar una clase. ¿Qué haces?</legend>
            <label>
              <input
                type="radio"
                name={headingId}
                checked={answer === 'send'}
                onChange={() => setAnswer('send')}
              />
              Aplicar sin revisar porque lo propuso la IA.
            </label>
            <label>
              <input
                type="radio"
                name={headingId}
                checked={answer === 'review'}
                onChange={() => setAnswer('review')}
              />
              Revisar lo que se borrará y aplicar solo si es lo que pedí.
            </label>
            <p role="status">
              {answer === 'review'
                ? 'Correcto. La IA puede equivocarse; tú confirmas los cambios después de revisarlos.'
                : answer === 'send'
                  ? 'Antes de aplicar, comprueba el alcance del cambio. Puedes dejar la propuesta sin aplicar y pedir una corrección.'
                  : 'Esta práctica no modifica tu pizarra.'}
            </p>
          </fieldset>
        )}
        <nav aria-label="Pasos de la guía" className="guia-ia-acciones">
          <button type="button" disabled={step === 0} onClick={() => setStep(step - 1)}>
            Anterior
          </button>
          {step < learningSteps.length - 1 ? (
            <button type="button" className="principal" onClick={() => setStep(step + 1)}>
              Siguiente
            </button>
          ) : (
            <button
              type="button"
              className="principal"
              disabled={answer !== 'review'}
              onClick={finish}
            >
              Completar guía
            </button>
          )}
          <button
            type="button"
            onClick={() => {
              setStep(0);
              setAnswer(null);
            }}
          >
            Reiniciar guía
          </button>
        </nav>
        <details className="guia-ia-ayuda">
          <summary>¿La IA no responde o no puedo aplicar?</summary>
          <p>
            Para enviar solicitudes necesitas conexión y un proveedor de IA disponible en el
            servidor. Revisa el mensaje de error; si indica un límite, espera antes de reintentar.
            Esta guía sigue disponible mientras tengas abierta la aplicación.
          </p>
          <p>
            Si solicita una aclaración, contesta con el dato que falta. Para cambiar de tema, pulsa
            Empezar de nuevo. Aplicar requiere permiso de edición y una propuesta vigente.
          </p>
        </details>
      </dialog>
    </>
  );
}
```

---

### `frontend/src/features/assistant/AssistantPanel.tsx`

```tsx
import {
  appendClarification,
  clarificationText,
  contextToDraft,
  exceedsContext,
} from './conversation-context.js';
import type { BoardState, CommandBatch, SemanticModel, ValidationIssue } from '@uml/contracts';
import { useEffect, useRef, useState } from 'react';
import { apiRequest } from '../../lib/api.js';
import { useSpeech } from './useSpeech.js';
import { prepareDictation } from './prepare-dictation.js';
import { AssistantLearningGuide } from './AssistantLearningGuide.js';

/**
 * Asistente por texto y voz (RF-030 a RF-037).
 *
 * El servidor resuelve la instruccion y devuelve un lote; **este panel lo
 * aplica por el mismo camino que la interfaz grafica**. El asistente es otro
 * adaptador que produce comandos, no una via paralela.
 *
 * Nada se aplica sin que el usuario lo vea: lo que llega se muestra como
 * propuesta con su resumen, y hay un boton para aceptarla.
 */

type Outcome =
  | { kind: 'BATCH'; batch: CommandBatch; summary: string[]; rationale: string | null }
  | {
      kind: 'CONFIRMATION';
      batch: CommandBatch;
      summary: string[];
      question: string;
      rationale: string | null;
    }
  | { kind: 'QUESTION'; question: string; options?: string[]; rationale: string | null }
  | { kind: 'REJECTED'; issues: ValidationIssue[]; rationale: string | null };

type Entrada =
  | { rol: 'usuario'; texto: string }
  | { rol: 'asistente'; texto: string }
  | {
      rol: 'propuesta';
      outcome: Extract<Outcome, { kind: 'BATCH' | 'CONFIRMATION' }>;
      aplicada: boolean;
      obsolete: boolean;
      expected: SemanticModel;
      instruction: string;
      context: readonly TurnoDeContexto[];
    };

type TurnoDeContexto = { readonly role: 'user' | 'assistant'; readonly text: string };

export interface AssistantPanelProps {
  readonly boardId: string;
  readonly state: BoardState;
  readonly canWrite: boolean;
  /** Aplica el lote por el mismo camino que la interfaz. */
  apply(batch: CommandBatch, expected?: SemanticModel): readonly ValidationIssue[] | null;
}

export function AssistantPanel({
  boardId,
  state,
  canWrite,
  apply,
}: AssistantPanelProps): React.JSX.Element {
  const [historial, setHistorial] = useState<readonly Entrada[]>([]);
  const [texto, setTexto] = useState('');
  const [pendiente, setPendiente] = useState(false);
  const [modo, setModo] = useState<'instruir' | 'preguntar'>('instruir');
  const [contexto, setContexto] = useState<readonly TurnoDeContexto[]>([]);
  const [dictadoOriginal, setDictadoOriginal] = useState<string | null>(null);
  const antesDelDictado = useRef('');
  const enviando = useRef(false);
  const revision = useRef(0);
  const solicitud = useRef<{ controller: AbortController; instruction: string } | null>(null);
  const entrada = useRef<HTMLTextAreaElement>(null);
  const voz = useSpeech((transcrito) => {
    if (transcrito.trim() === '') {
      setTexto(antesDelDictado.current);
      setDictadoOriginal(null);
      return;
    }
    const original = [antesDelDictado.current, transcrito].filter(Boolean).join(' ');
    setDictadoOriginal(original);
    setTexto(prepareDictation(original));
  });
  const contextoLleno = modo === 'instruir' && exceedsContext(contexto);
  const dictando = voz.listening || voz.stopping;
  const visible = dictando
    ? [antesDelDictado.current, voz.transcript].filter(Boolean).join(' ')
    : texto;

  useEffect(() => {
    if (dictando && entrada.current) entrada.current.scrollTop = entrada.current.scrollHeight;
  }, [visible, dictando]);

  /**
   * La conversacion crece hacia abajo y no se movia sola.
   *
   * A la tercera o cuarta instruccion, la propuesta nueva —con su boton de
   * aplicar— aparecia fuera de la vista: la persona escribe, parece que no pasa
   * nada, y vuelve a escribir. `block: 'nearest'` desplaza lo justo, y recorre
   * todos los contenedores con desplazamiento, no solo el mas cercano: aqui hay
   * dos anidados y cual de los dos se mueve depende del alto disponible.
   */
  const finDeConversacion = useRef<HTMLLIElement>(null);

  useEffect(() => {
    // Al montar el panel vacío no hay un mensaje que revelar. Desplazar su
    // ancla entonces ocultaba la cabecera del editor en pantallas pequeñas.
    if (historial.length > 0) finDeConversacion.current?.scrollIntoView({ block: 'nearest' });
  }, [historial]);

  useEffect(() => {
    // Una aclaracion pertenece a una pizarra concreta. Si la navegacion cambia
    // el `boardId` sin desmontar el panel, no debe filtrarse al nuevo modelo.
    setHistorial([]);
    setContexto([]);
    setTexto('');
    setDictadoOriginal(null);
    setPendiente(false);
    enviando.current = false;
    voz.cancel();
    revision.current++;
    return () => {
      revision.current++;
      solicitud.current?.controller.abort();
      solicitud.current = null;
    };
  }, [boardId, voz.cancel]);

  async function enviar(entrada: string): Promise<void> {
    const limpio = entrada.trim();
    if (
      contextoLleno ||
      limpio === '' ||
      limpio.length > 2000 ||
      enviando.current ||
      dictando ||
      (modo === 'instruir' && !canWrite)
    )
      return;
    enviando.current = true;
    const actual = revision.current;
    const controller = new AbortController();
    solicitud.current = { controller, instruction: limpio };

    setHistorial((previo) => [...previo, { rol: 'usuario', texto: limpio }]);
    setTexto('');
    setDictadoOriginal(null);
    setPendiente(true);

    try {
      if (modo === 'preguntar') {
        const respuesta = await apiRequest<{ answer: string }>(
          `/boards/${boardId}/assistant/question`,
          {
            method: 'POST',
            body: { question: limpio, model: state.semantic },
            signal: controller.signal,
          },
        );
        if (actual !== revision.current) return;
        setHistorial((previo) => [...previo, { rol: 'asistente', texto: respuesta.answer }]);
        return;
      }

      const outcome = await apiRequest<Outcome>(`/boards/${boardId}/assistant/instruction`, {
        method: 'POST',
        body: { instruction: limpio, context: contexto, model: state.semantic },
        signal: controller.signal,
      });

      if (actual !== revision.current) return;
      setHistorial((previo) => [...previo, entradaDe(outcome, state.semantic, limpio, contexto)]);

      if (outcome.kind === 'QUESTION') {
        // La pregunta del asistente y la respuesta siguiente forman una sola
        // solicitud. Conservar ambas evita que una aclaracion como «id es int»
        // haga desaparecer las clases y atributos pedidos en el primer turno.
        setContexto((previo) =>
          appendClarification(previo, limpio, outcome.question, outcome.options),
        );
      } else {
        // La solicitud ya produjo una propuesta o un rechazo definitivo. El
        // turno siguiente debe comenzar limpio para no repetir operaciones.
        setContexto([]);
      }
    } catch (error) {
      if (actual !== revision.current) return;
      setTexto(limpio);
      setHistorial((previo) => [
        ...previo,
        { rol: 'asistente', texto: error instanceof Error ? error.message : 'Algo salio mal.' },
      ]);
    } finally {
      if (actual === revision.current) {
        solicitud.current = null;
        enviando.current = false;
        setPendiente(false);
      }
    }
  }

  function cancelarSolicitud(): void {
    const active = solicitud.current;
    if (!active) return;
    revision.current++;
    solicitud.current = null;
    active.controller.abort();
    enviando.current = false;
    setPendiente(false);
    setTexto(active.instruction);
    setHistorial((previo) => [
      ...previo,
      {
        rol: 'asistente',
        texto: 'Solicitud cancelada. Puedes revisar el texto y volver a enviarlo.',
      },
    ]);
  }

  function aplicar(indice: number, batch: CommandBatch): void {
    const propuesta = historial[indice];
    if (propuesta?.rol !== 'propuesta' || propuesta.obsolete || propuesta.aplicada) return;
    const rechazo = apply(batch, propuesta.expected);
    const obsolete = rechazo?.some((issue) => issue.code === 'STALE_PROPOSAL') ?? false;
    if (obsolete) {
      setTexto(propuesta.instruction);
      setContexto(propuesta.context);
    }

    setHistorial((previo) =>
      previo.map((entrada, posicion) => {
        if (posicion !== indice || entrada.rol !== 'propuesta') return entrada;
        return { ...entrada, aplicada: rechazo === null, obsolete };
      }),
    );

    if (rechazo !== null && rechazo.length > 0) {
      setHistorial((previo) => [
        ...previo,
        {
          rol: 'asistente',
          texto: `No se pudo aplicar: ${rechazo[0]?.message ?? 'el lote fue rechazado.'}`,
        },
      ]);
    }
  }

  return (
    <section className="asistente" data-testid="asistente">
      <header>
        <div className="pestanas">
          <button
            type="button"
            className={modo === 'instruir' ? 'activa' : ''}
            data-testid="modo-instruir"
            disabled={pendiente || dictando}
            onClick={() => setModo('instruir')}
          >
            Instruir
          </button>
          <button
            type="button"
            className={modo === 'preguntar' ? 'activa' : ''}
            data-testid="modo-preguntar"
            disabled={pendiente || dictando}
            onClick={() => setModo('preguntar')}
          >
            Consultar
          </button>
        </div>
      </header>

      <div className="asistente-aprendizaje">
        <AssistantLearningGuide
          key={boardId}
          model={state.semantic}
          canWrite={canWrite}
          canUseExample={!pendiente && !dictando && texto.trim() === '' && contexto.length === 0}
          useExample={(nextMode, example) => {
            setModo(nextMode);
            setTexto(example);
            setDictadoOriginal(null);
            entrada.current?.focus();
          }}
        />
      </div>

      <ol className="conversacion" data-testid="conversacion">
        {historial.length === 0 && (
          <li className="pista">
            {modo === 'instruir'
              ? 'Por ejemplo: «agrega telefono tipo String a Cliente».'
              : 'Por ejemplo: «¿puedo generar el backend?».'}
          </li>
        )}

        {historial.map((entrada, indice) => (
          <li key={indice} className={entrada.rol}>
            {entrada.rol !== 'propuesta' && <p>{entrada.texto}</p>}

            {entrada.rol === 'propuesta' && (
              <div className="propuesta" data-testid="propuesta">
                {entrada.outcome.kind === 'CONFIRMATION' && (
                  <p className="advertencia" data-testid="confirmacion">
                    {entrada.outcome.question}
                  </p>
                )}

                {entrada.outcome.rationale && <p>{entrada.outcome.rationale}</p>}
                <ul className="resumen">
                  {entrada.outcome.summary.map((linea, posicion) => (
                    <li key={posicion}>{linea}</li>
                  ))}
                </ul>

                {entrada.aplicada ? (
                  <p className="aplicada">Aplicado.</p>
                ) : entrada.obsolete ? (
                  <p className="advertencia" data-testid="propuesta-obsoleta">
                    Propuesta desactualizada. La instrucción se recuperó en el cuadro de texto para
                    que puedas enviarla y revisarla de nuevo.
                  </p>
                ) : (
                  <button
                    type="button"
                    className="principal"
                    disabled={!canWrite || pendiente || dictando}
                    data-testid="aplicar-propuesta"
                    onClick={() => aplicar(indice, entrada.outcome.batch)}
                  >
                    {entrada.outcome.kind === 'CONFIRMATION' ? 'Sí, aplicar' : 'Aplicar'}
                  </button>
                )}
              </div>
            )}
          </li>
        ))}

        {/* Ancla del desplazamiento automatico. Va dentro de la lista para que
            quede debajo de lo ultimo que se anadio. */}
        <li ref={finDeConversacion} className="ancla-conversacion" aria-hidden="true" />
      </ol>

      {contexto.length > 0 && (
        <div className="contexto-asistente" data-testid="contexto-asistente" role="status">
          <span>
            {contextoLleno
              ? 'Hay muchas aclaraciones pendientes. Revisa la solicitud completa antes de continuar.'
              : 'Aclaración en curso: recordaré la solicitud anterior en tu próximo mensaje.'}
          </span>
          {contextoLleno && (
            <button
              type="button"
              disabled={pendiente || dictando}
              data-testid="revisar-contexto"
              onClick={() => {
                setTexto(contextToDraft(contexto, texto));
                setContexto([]);
                setDictadoOriginal(null);
              }}
            >
              Revisar solicitud completa
            </button>
          )}
          <button
            type="button"
            disabled={pendiente}
            data-testid="descartar-contexto"
            onClick={() => setContexto([])}
          >
            Empezar de nuevo
          </button>
        </div>
      )}

      {voz.error !== null && <p className="error">{voz.error}</p>}
      {dictando && (
        <p role="status" className="estado-dictado">
          {voz.stopping
            ? 'Finalizando el dictado…'
            : 'Escuchando. Pulsa Parar cuando termines; después podrás revisar el texto.'}
        </p>
      )}
      {!dictando && dictadoOriginal !== null && (
        <div className="revision-dictado" data-testid="revision-dictado">
          <p>Revisa el dictado antes de enviarlo.</p>
          {dictadoOriginal !== texto && (
            <button type="button" onClick={() => setTexto(dictadoOriginal)} disabled={pendiente}>
              Recuperar dictado original
            </button>
          )}
        </div>
      )}

      <form
        className="entrada"
        onSubmit={(evento) => {
          evento.preventDefault();
          void enviar(texto);
        }}
      >
        <textarea
          ref={entrada}
          rows={3}
          value={visible}
          disabled={pendiente}
          readOnly={dictando}
          aria-label={
            modo === 'instruir' ? 'Instrucción para el asistente' : 'Pregunta para el asistente'
          }
          placeholder={modo === 'instruir' ? 'Instrucción…' : 'Pregunta…'}
          data-testid="entrada-asistente"
          onChange={(evento) => setTexto(evento.target.value)}
        />

        {voz.supported && (
          <button
            type="button"
            className={voz.listening ? 'escuchando' : ''}
            title={voz.listening ? 'Parar dictado' : 'Dictar'}
            disabled={pendiente || voz.stopping || (modo === 'instruir' && !canWrite)}
            data-testid="dictar"
            onClick={() => {
              if (voz.listening) voz.stop();
              else {
                antesDelDictado.current = texto;
                setDictadoOriginal(null);
                voz.start();
              }
            }}
          >
            {voz.listening ? 'Parar' : voz.stopping ? 'Finalizando…' : 'Dictar'}
          </button>
        )}
        {dictando && (
          <button
            type="button"
            onClick={() => {
              voz.cancel();
              setTexto(antesDelDictado.current);
            }}
          >
            Cancelar dictado
          </button>
        )}

        <button
          type="submit"
          disabled={
            pendiente ||
            contextoLleno ||
            dictando ||
            texto.trim() === '' ||
            texto.trim().length > 2000 ||
            (modo === 'instruir' && !canWrite)
          }
          data-testid="enviar-asistente"
        >
          {pendiente ? '…' : 'Enviar'}
        </button>
        {pendiente && (
          <button type="button" onClick={cancelarSolicitud} data-testid="cancelar-solicitud">
            Cancelar solicitud
          </button>
        )}
      </form>
      <p className={visible.trim().length > 2000 ? 'error' : 'limite-asistente'}>
        {visible.trim().length}/2000 caracteres
        {visible.trim().length > 2000
          ? '. Acorta el texto antes de enviar; tu dictado se conserva completo.'
          : ''}
      </p>
    </section>
  );
}

function entradaDe(
  outcome: Outcome,
  expected: SemanticModel,
  instruction: string,
  context: readonly TurnoDeContexto[],
): Entrada {
  switch (outcome.kind) {
    case 'BATCH':
    case 'CONFIRMATION':
      return {
        rol: 'propuesta',
        outcome,
        aplicada: false,
        obsolete: false,
        expected,
        instruction,
        context,
      };

    case 'QUESTION':
      return {
        rol: 'asistente',
        texto: clarificationText(outcome.question, outcome.options),
      };

    case 'REJECTED':
      return {
        rol: 'asistente',
        texto: `No puedo hacer eso: ${outcome.issues.map((item) => item.message).join(' ')}`,
      };
  }
}
```

---

### `frontend/src/features/assistant/conversation-context.ts`

```ts
export interface PendingTurn {
  readonly role: 'user' | 'assistant';
  readonly text: string;
}
export const MAX_CONTEXT_TURNS = 10;

/** La numeración visible debe ser idéntica a la enviada: «la segunda» necesita su referente. */
export function clarificationText(question: string, options: readonly string[] = []): string {
  return [
    question,
    ...options.map((option, index) => `${index + 1}. ${JSON.stringify(option)}`),
  ].join('\n');
}

export function exceedsContext(context: readonly PendingTurn[]): boolean {
  return context.length > MAX_CONTEXT_TURNS || context.some((turn) => turn.text.length > 2000);
}

export function appendClarification(
  context: readonly PendingTurn[],
  instruction: string,
  question: string,
  options: readonly string[] = [],
): readonly PendingTurn[] {
  return [
    ...context,
    { role: 'user', text: instruction },
    { role: 'assistant', text: clarificationText(question, options) },
  ];
}

/** Conserva también las preguntas: «sí» no se entiende sin su antecedente. */
export function contextToDraft(context: readonly PendingTurn[], draft: string): string {
  return [
    ...context.map((turn) => `${turn.role === 'user' ? 'Solicitud' : 'Pregunta'}: ${turn.text}`),
    draft,
  ]
    .filter(Boolean)
    .join('\n');
}
```

---

### `frontend/src/features/assistant/learning-guide.ts`

```ts
import type { SemanticModel } from '@uml/contracts';

export type AssistantMode = 'instruir' | 'preguntar';
export const learningSteps = [
  {
    title: 'Elige lo que necesitas',
    text: 'Consultar sirve para entender el diagrama o revisar si está listo para generar código. Instruir sirve para proponer cambios en clases, atributos y relaciones. Una consulta no modifica tu pizarra.',
    tip: 'Empieza consultando qué contiene tu diagrama.',
  },
  {
    title: 'Escribe una instrucción concreta',
    text: 'Indica la acción, el nombre exacto de la clase y los detalles del cambio. Por ejemplo, al añadir un atributo, incluye su nombre y tipo. Pide un cambio a la vez; si falta información, responde a la aclaración del asistente.',
    tip: 'El ejemplo se adapta a la pizarra actual. Puedes editarlo antes de enviarlo.',
  },
  {
    title: 'También puedes dictar',
    text: 'Pulsa Dictar, concede acceso al micrófono y habla con claridad. Pulsa Parar y revisa nombres, tipos y negaciones en el texto. Solo pulsa Enviar cuando esté correcto.',
    tip: 'Si no aparece Dictar, escribe tu solicitud. El reconocimiento depende del navegador, sus permisos y, en algunos casos, de internet.',
  },
  {
    title: 'Revisa antes de aplicar',
    text: 'Enviar una instrucción prepara una propuesta. Lee el resumen y comprueba las clases, atributos y relaciones afectados antes de pulsar Aplicar o Sí, aplicar. Si no coincide con tu intención, no la apliques y escribe una instrucción corregida.',
    tip: 'Si otro participante cambia el diagrama, una propuesta puede quedar desactualizada. Vuelve a enviarla y revisa la nueva propuesta.',
  },
] as const;

export function instructionExample(model: SemanticModel): string {
  const first = model.classes[0];
  if (!first) return 'Crea una clase Cliente con un atributo nombre de tipo String.';
  let name = 'notaIA';
  for (
    let suffix = 2;
    first.attributes.some((attribute) => attribute.codeName === name);
    suffix++
  ) {
    name = `notaIA${suffix}`;
  }
  return `Agrega el atributo ${name} de tipo String a la clase ${first.codeName}.`;
}
```

---

### `frontend/src/features/assistant/prepare-dictation.ts`

```ts
/** Depuración conservadora sin llamadas a modelos. Mantiene instrucciones,
 * negaciones, correcciones, nombres, tipos y cantidades. Siempre es revisable.
 */
export function prepareDictation(raw: string): string {
  return raw
    .trim()
    .replace(/^(?:(?:eh+|em+|ehm+)\s*[,;]\s*)+/i, '')
    .replace(
      /^(?:(?:hola|bueno|a ver)\s*[,!.]\s*)?(?:por favor\s*,?\s*)?(?:(?:lo que )?(?:quiero|necesito)(?: es)? que|me gustaría que|(?:me )?(?:puedes|podrías))\s+(?=(?:no\s+)?(?:crees|crear|agregues|agregar|añadas|añadir|elimines|eliminar|borres|borrar|cambies|cambiar|relaciones|relacionar|renombres|renombrar|expliques|explicar)\b)/i,
      '',
    )
    .replace(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|`[^`]*`|«[^»]*»|\s+/gu, (part) =>
      /^\s/u.test(part) ? ' ' : part,
    )
    .trim();
}
```

---

### `frontend/src/features/assistant/speech-session.ts`

```ts
export interface SpeechRecognitionLike {
  lang: string;
  continuous: boolean;
  interimResults: boolean;
  start(): void;
  stop(): void;
  abort(): void;
  onresult: ((event: { results: ArrayLike<ArrayLike<{ transcript: string }>> }) => void) | null;
  onerror: ((event: { error: string }) => void) | null;
  onend: (() => void) | null;
}

export type SpeechPhase = 'idle' | 'listening' | 'stopping';

/** Una sesión del usuario puede abarcar varias sesiones del servicio del navegador.
 * Ningún resultado parcial dispara una petición a la IA.
 */
export function createSpeechSession(
  create: () => SpeechRecognitionLike,
  callbacks: {
    phase(value: SpeechPhase): void;
    text(value: string): void;
    error(value: string | null): void;
    complete(value: string): void;
  },
) {
  let current: SpeechRecognitionLike | null = null;
  let active = false;
  let phase: SpeechPhase = 'idle';
  let prefix = '';
  let text = '';
  let timer: ReturnType<typeof setTimeout> | undefined;
  const setPhase = (value: SpeechPhase) => {
    phase = value;
    callbacks.phase(value);
  };
  const clear = () => {
    clearTimeout(timer);
    timer = undefined;
  };
  const detach = () => {
    const previous = current;
    current = null;
    if (previous) previous.onresult = previous.onerror = previous.onend = null;
    return previous;
  };
  const finish = () => {
    if (phase === 'idle') return;
    active = false;
    clear();
    const previous = detach();
    try {
      previous?.abort();
    } catch {
      /* Ya puede estar desconectado. */
    }
    setPhase('idle');
    callbacks.complete(text);
  };
  const begin = () => {
    if (!active) return;
    try {
      const engine = create();
      current = engine;
      engine.lang = 'es-ES';
      engine.continuous = true;
      engine.interimResults = true;
      engine.onresult = (event) => {
        if (current !== engine) return;
        // results contiene toda esta sesión, incluidos resultados revisados.
        // Reemplazar esa parte evita duplicarla al llegar el siguiente evento.
        const segment = Array.from(event.results)
          .map((r) => r[0]?.transcript ?? '')
          .join(' ');
        text = [prefix, segment.trim()].filter(Boolean).join(' ');
        callbacks.text(text);
      };
      engine.onerror = ({ error }) => {
        if (current !== engine || error === 'no-speech') return;
        callbacks.error(
          error === 'not-allowed' || error === 'service-not-allowed'
            ? 'No se pudo acceder al micrófono. Revisa el permiso del navegador.'
            : `El dictado se interrumpió (${error}). Conservamos el texto para que puedas revisarlo.`,
        );
        finish();
      };
      engine.onend = () => {
        if (current !== engine) return;
        detach();
        if (!active) {
          finish();
          return;
        }
        prefix = text;
        // Las pausas/límites del servicio no terminan el dictado del usuario.
        timer = setTimeout(begin, 250);
      };
      engine.start();
    } catch {
      callbacks.error('No se pudo iniciar el dictado. El texto capturado se conserva.');
      finish();
    }
  };
  return {
    start() {
      if (phase !== 'idle') return;
      prefix = text = '';
      callbacks.error(null);
      callbacks.text('');
      active = true;
      setPhase('listening');
      begin();
    },
    stop() {
      if (phase !== 'listening') return;
      active = false;
      clear();
      setPhase('stopping');
      if (!current) {
        finish();
        return;
      }
      // Plazo solo después de una parada explícita, nunca límite del dictado.
      timer = setTimeout(finish, 3000);
      try {
        current.stop();
      } catch {
        finish();
      }
    },
    cancel() {
      active = false;
      clear();
      const previous = detach();
      try {
        previous?.abort();
      } catch {
        /* Sin resultado al cancelar. */
      }
      prefix = text = '';
      callbacks.text('');
      callbacks.error(null);
      setPhase('idle');
    },
  };
}
```

---

### `frontend/src/features/assistant/useSpeech.ts`

```ts
import { useCallback, useEffect, useRef, useState } from 'react';
import {
  createSpeechSession,
  type SpeechPhase,
  type SpeechRecognitionLike,
} from './speech-session.js';

type Constructor = new () => SpeechRecognitionLike;
function recognitionConstructor(): Constructor | undefined {
  const browser = window as unknown as {
    SpeechRecognition?: Constructor;
    webkitSpeechRecognition?: Constructor;
  };
  return browser.SpeechRecognition ?? browser.webkitSpeechRecognition;
}

/** Dictado del navegador: no sube audio al backend ni utiliza sus cuotas de IA.
 * El servicio del navegador puede depender de conexión y permisos.
 */
export function useSpeech(onComplete: (text: string) => void) {
  const [phase, setPhase] = useState<SpeechPhase>('idle');
  const [transcript, setTranscript] = useState('');
  const [error, setError] = useState<string | null>(null);
  const callback = useRef(onComplete);
  callback.current = onComplete;
  const session = useRef<ReturnType<typeof createSpeechSession> | null>(null);
  const start = useCallback(() => {
    if (session.current === null) {
      const Recognition = recognitionConstructor();
      if (!Recognition) {
        setError('Este navegador no admite dictado. Puedes escribir tu solicitud.');
        return;
      }
      session.current = createSpeechSession(() => new Recognition(), {
        phase: setPhase,
        text: setTranscript,
        error: setError,
        complete: (text) => callback.current(text),
      });
    }
    session.current.start();
  }, []);
  const stop = useCallback(() => session.current?.stop(), []);
  const cancel = useCallback(() => session.current?.cancel(), []);
  useEffect(
    () => () => {
      session.current?.cancel();
      session.current = null;
    },
    [],
  );
  return {
    supported: recognitionConstructor() !== undefined,
    listening: phase === 'listening',
    stopping: phase === 'stopping',
    transcript,
    error,
    start,
    stop,
    cancel,
  };
}
```

---

### `frontend/src/features/auth/LoginPage.tsx`

```tsx
import { useState } from 'react';
import { Link, useNavigate } from 'react-router';
import { IconoDiagrama } from '../../components/icons.js';
import { ThemeSelect } from '../../components/ThemeProvider.js';
import { perfil } from '../../lib/api.js';
import { useAsyncAction, useSession } from './session.js';

/** Registro e inicio de sesión en una sola pantalla (RF-A01 y RF-A02). */
export function LoginPage(): React.JSX.Element {
  const { login, register } = useSession();
  const navegar = useNavigate();
  const { error, pending, run } = useAsyncAction();

  // «olvide» es un tercer modo del mismo formulario y no una ruta aparte: el
  // correo ya esta escrito, y mandar a otra pagina obligaria a teclearlo otra vez.
  const [modo, setModo] = useState<'entrar' | 'registrar' | 'olvide'>('entrar');
  const [enviado, setEnviado] = useState(false);
  const [email, setEmail] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [password, setPassword] = useState('');
  // Solo cambia el `type` del campo. La contrasena y su envio no se tocan.
  const [verPassword, setVerPassword] = useState(false);
  const [activacion, setActivacion] = useState<string | null>(null);

  return (
    <main className="acceso">
      <div className="acceso-apariencia">
        <ThemeSelect />
      </div>
      {/* Mitad izquierda: quien llega por un enlace no sabe que es esto.
          El dibujo son dos clases y su relacion —lo que la herramienta hace—
          no una ilustracion decorativa. */}
      <section className="acceso-marca" aria-hidden="true">
        <div className="acceso-marca-contenido">
          <span className="isotipo grande">
            <IconoDiagrama size={26} />
          </span>
          <h2>UMLFORGE AI</h2>
          <p className="lema">Diagramas de clases en equipo.</p>
          <p className="acceso-detalle">
            Edita diagramas UML, comparte pizarras y genera un proyecto Java a partir del modelo.
          </p>

          <DiagramaDecorativo />
        </div>
      </section>

      <section className="acceso-formulario">
        <form
          className="tarjeta"
          onSubmit={(evento) => {
            evento.preventDefault();
            void run(async () => {
              if (modo === 'olvide') {
                await perfil.pedirRecuperacion(email);
                // Se confirma el envio siempre, haya cuenta o no: el servidor
                // responde igual en los dos casos a proposito, y contarlo aqui
                // convertiria el formulario en un comprobador de correos.
                setEnviado(true);
                return;
              }

              if (modo === 'entrar') await login(email, password);
              else {
                const result = await register(email, displayName, password);
                setActivacion(
                  result.emailSent
                    ? `Revisa tu correo ${email}. Te enviamos un enlace para activar la cuenta; caduca en 24 horas. Revisa también spam.`
                    : 'Tu cuenta está creada, pero no pudimos enviar el correo. Solicita otro enlace de activación.',
                );
                setPassword('');
                setModo('entrar');
                return;
              }
              void navegar('/proyectos');
            });
          }}
        >
          <div className="acceso-titulo">
            <h1>
              {modo === 'entrar'
                ? 'Bienvenido de nuevo'
                : modo === 'registrar'
                  ? 'Crea tu cuenta'
                  : 'Recupera tu acceso'}
            </h1>
            <p className="subtitulo">
              {modo === 'entrar'
                ? 'Entra para seguir con tus diagramas.'
                : modo === 'registrar'
                  ? 'Te enviaremos un enlace para activar tu cuenta.'
                  : 'Te enviamos un enlace para elegir una contraseña nueva.'}
            </p>
          </div>

          <div className="pestanas" role="group" aria-label="Entrar o crear una cuenta">
            <button
              type="button"
              className={modo === 'entrar' ? 'activa' : ''}
              aria-pressed={modo === 'entrar'}
              onClick={() => {
                setModo('entrar');
                setEnviado(false);
              }}
            >
              Entrar
            </button>
            <button
              type="button"
              className={modo === 'registrar' ? 'activa' : ''}
              aria-pressed={modo === 'registrar'}
              onClick={() => {
                setModo('registrar');
                setEnviado(false);
              }}
            >
              Crear cuenta
            </button>
          </div>

          <label>
            <span>Correo</span>
            <input
              type="email"
              required
              autoComplete="email"
              placeholder="tu@correo.com"
              data-testid="email"
              value={email}
              onChange={(evento) => setEmail(evento.target.value)}
            />
          </label>

          {modo === 'registrar' && (
            <label>
              <span>Nombre</span>
              <input
                required
                placeholder="Cómo te verán los demás"
                data-testid="displayName"
                value={displayName}
                onChange={(evento) => setDisplayName(evento.target.value)}
              />
            </label>
          )}

          {modo !== 'olvide' && (
            <label>
              <span>Contraseña</span>
              <span className="campo-con-accion">
                <input
                  type={verPassword ? 'text' : 'password'}
                  required
                  minLength={modo === 'registrar' ? 8 : 1}
                  autoComplete={modo === 'registrar' ? 'new-password' : 'current-password'}
                  data-testid="password"
                  aria-describedby={modo === 'registrar' ? 'ayuda-password' : undefined}
                  value={password}
                  onChange={(evento) => setPassword(evento.target.value)}
                />
                <button
                  type="button"
                  className="fantasma ver-password"
                  aria-pressed={verPassword}
                  aria-label={verPassword ? 'Ocultar la contraseña' : 'Mostrar la contraseña'}
                  onClick={() => setVerPassword((previo) => !previo)}
                >
                  {verPassword ? 'Ocultar' : 'Mostrar'}
                </button>
              </span>
              {modo === 'registrar' && (
                <span className="ayuda" id="ayuda-password">
                  Al menos 8 caracteres.
                </span>
              )}
            </label>
          )}

          {error !== null && (
            <p className="aviso-error" role="alert" data-testid="error-sesion">
              {error}
            </p>
          )}

          {activacion && (
            <p className="aviso-ok" role="status" data-testid="activacion-pendiente">
              {activacion}
            </p>
          )}
          <Link to="/activar" className="enlace-discreto">
            ¿No recibiste el enlace de activación?
          </Link>

          {enviado && (
            <p className="aviso-ok" role="status" data-testid="recuperacion-enviada">
              Si existe una cuenta con ese correo, recibirás un enlace para cambiar la contraseña.
            </p>
          )}

          <button type="submit" className="principal" disabled={pending} data-testid="enviar">
            {pending
              ? 'Un momento…'
              : modo === 'entrar'
                ? 'Entrar'
                : modo === 'registrar'
                  ? 'Crear cuenta'
                  : 'Enviarme el enlace'}
          </button>

          {modo === 'entrar' ? (
            <button
              type="button"
              className="fantasma enlace-discreto"
              data-testid="olvide-password"
              onClick={() => {
                setModo('olvide');
                setEnviado(false);
              }}
            >
              ¿Olvidaste tu contraseña?
            </button>
          ) : modo === 'olvide' ? (
            <button
              type="button"
              className="fantasma enlace-discreto"
              onClick={() => {
                setModo('entrar');
                setEnviado(false);
              }}
            >
              Volver a entrar
            </button>
          ) : null}
        </form>
      </section>
    </main>
  );
}

/**
 * Dos clases y una relacion, dibujadas con la misma retorica del editor.
 *
 * Decorativo: no representa ningun modelo real y no lleva texto que un lector
 * de pantalla deba anunciar. Lo envuelve un `aria-hidden` mas arriba.
 */
function DiagramaDecorativo(): React.JSX.Element {
  return (
    <svg className="acceso-diagrama" viewBox="0 0 320 180" fill="none" focusable="false">
      <path d="M96 52h60" stroke="currentColor" strokeWidth="1.5" strokeDasharray="4 4" />
      <path d="M156 52v60h-52" stroke="currentColor" strokeWidth="1.5" strokeDasharray="4 4" />

      <g className="caja">
        <rect x="16" y="24" width="80" height="56" rx="8" />
        <path d="M16 42h80" />
        <path d="M28 56h34M28 68h46" strokeWidth="1.5" />
      </g>

      <g className="caja">
        <rect x="156" y="24" width="88" height="56" rx="8" />
        <path d="M156 42h88" />
        <path d="M168 56h40M168 68h30" strokeWidth="1.5" />
      </g>

      <g className="caja">
        <rect x="60" y="112" width="96" height="52" rx="8" />
        <path d="M60 130h96" />
        <path d="M72 144h50" strokeWidth="1.5" />
      </g>
    </svg>
  );
}
```

---

### `frontend/src/features/auth/ProfilePage.tsx`

```tsx
import { useRef, useState } from 'react';
import { AppBar, Avatar } from '../../components/AppBar.js';
import { IconoLapiz, IconoLlave, IconoPapelera } from '../../components/icons.js';
import { avatarUrl, perfil } from '../../lib/api.js';
import { useAsyncAction, useSession } from './session.js';

/**
 * Perfil de la cuenta (RF-A10).
 *
 * Tres bloques independientes, cada uno con su propio envio y su propio aviso:
 * la foto, los datos y la contrasena. Separados porque fallan por motivos
 * distintos —una imagen demasiado grande no tiene nada que ver con una
 * contrasena mal escrita— y juntarlos obligaria a un solo mensaje de error que
 * no diria cual de las tres cosas se atasco.
 */
export function ProfilePage(): React.JSX.Element {
  const { user, logout, actualizarUsuario } = useSession();
  // Vive aqui y no dentro del bloque de la foto porque la barra superior
  // tambien lo necesita: al subir una foto tiene que dejar de mostrar las
  // iniciales sin recargar la pagina.
  const [avatarVersion, setAvatarVersion] = useState(() => Date.now());

  if (user === null) {
    return (
      <div className="marco">
        <main className="centrado">
          <div className="estado-ruta" role="status">
            <div className="girando" aria-hidden="true" />
            <p>Cargando tu perfil…</p>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="marco">
      <AppBar
        displayName={user.displayName}
        userId={user.id}
        avatarVersion={avatarVersion}
        onLogout={() => void logout()}
      />

      <main className="pagina pagina-estrecha">
        <header className="encabezado-pagina">
          <div>
            <h1>Mi cuenta</h1>
            <p className="subtitulo">Tu foto, tus datos y tu contraseña.</p>
          </div>
        </header>

        <BloqueFoto
          userId={user.id}
          displayName={user.displayName}
          version={avatarVersion}
          onCambio={setAvatarVersion}
        />

        <BloqueDatos
          displayName={user.displayName}
          email={user.email}
          onGuardado={actualizarUsuario}
        />

        <BloquePassword />
      </main>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Foto
// ---------------------------------------------------------------------------

function BloqueFoto({
  userId,
  displayName,
  version,
  onCambio,
}: {
  readonly userId: string;
  readonly displayName: string;
  /** Cambia al subir o quitar: obliga al navegador a volver a pedir la imagen. */
  readonly version: number;
  onCambio(version: number): void;
}): React.JSX.Element {
  const { error, pending, run } = useAsyncAction();
  const [tieneFoto, setTieneFoto] = useState(true);
  const archivo = useRef<HTMLInputElement>(null);

  return (
    <section className="panel-perfil">
      <div className="cabecera-panel">
        <h2>Foto de perfil</h2>
        <p className="subtitulo">Se recorta a 256×256 antes de enviarse.</p>
      </div>

      <div className="fila-foto">
        {tieneFoto ? (
          <img
            className="avatar avatar-grande"
            src={avatarUrl(userId, version)}
            alt=""
            width={72}
            height={72}
            // Si no hay foto la ruta responde 404: en lugar de dejar el icono
            // de imagen rota, se cae a las iniciales.
            onError={() => setTieneFoto(false)}
          />
        ) : (
          <Avatar nombre={displayName} size={72} />
        )}

        <div className="acciones-foto">
          <button
            type="button"
            disabled={pending}
            data-testid="elegir-foto"
            onClick={() => archivo.current?.click()}
          >
            <IconoLapiz size={15} />
            {pending ? 'Subiendo…' : 'Cambiar foto'}
          </button>

          {tieneFoto && (
            <button
              type="button"
              className="peligro"
              disabled={pending}
              data-testid="quitar-foto"
              onClick={() =>
                void run(async () => {
                  await perfil.quitarAvatar();
                  setTieneFoto(false);
                  onCambio(Date.now());
                })
              }
            >
              <IconoPapelera size={15} />
              Quitar
            </button>
          )}

          <p className="ayuda">JPG, PNG o WebP.</p>
        </div>
      </div>

      <input
        ref={archivo}
        type="file"
        accept="image/png,image/jpeg,image/webp"
        hidden
        data-testid="archivo-foto"
        onChange={(evento) => {
          const elegido = evento.target.files?.[0];
          evento.target.value = '';
          if (elegido === undefined) return;

          void run(async () => {
            const recortada = await recortar(elegido);
            await perfil.subirAvatar(recortada.base64, recortada.mediaType);
            setTieneFoto(true);
            onCambio(Date.now());
          });
        }}
      />

      {error !== null && (
        <p className="aviso-error" role="alert" data-testid="error-foto">
          {error}
        </p>
      )}
    </section>
  );
}

/**
 * Recorta la imagen a un cuadrado de 256x256 y la reencoda como JPEG.
 *
 * Se hace en el navegador y no en el servidor por dos razones: una foto de
 * telefono son varios megabytes y no tiene sentido subirlos para tirarlos, y el
 * servidor no tiene una biblioteca de imagenes —anadirla por esto seria una
 * dependencia nativa entera—.
 *
 * El recorte es central, que es lo que espera quien sube un retrato.
 */
async function recortar(archivo: File): Promise<{ base64: string; mediaType: string }> {
  const LADO = 256;
  const imagen = await cargarImagen(archivo);

  const lienzo = document.createElement('canvas');
  lienzo.width = LADO;
  lienzo.height = LADO;

  const contexto = lienzo.getContext('2d');
  if (contexto === null) throw new Error('El navegador no pudo procesar la imagen.');

  const lado = Math.min(imagen.width, imagen.height);
  contexto.drawImage(
    imagen,
    (imagen.width - lado) / 2,
    (imagen.height - lado) / 2,
    lado,
    lado,
    0,
    0,
    LADO,
    LADO,
  );

  // 0.85: por encima el archivo crece sin que la diferencia se vea a 72 pixeles.
  const url = lienzo.toDataURL('image/jpeg', 0.85);
  return { base64: url.slice(url.indexOf(',') + 1), mediaType: 'image/jpeg' };
}

function cargarImagen(archivo: File): Promise<HTMLImageElement> {
  return new Promise((resolver, rechazar) => {
    const url = URL.createObjectURL(archivo);
    const imagen = new Image();

    imagen.onload = () => {
      URL.revokeObjectURL(url);
      resolver(imagen);
    };
    imagen.onerror = () => {
      URL.revokeObjectURL(url);
      rechazar(new Error('Ese archivo no es una imagen que el navegador pueda abrir.'));
    };

    imagen.src = url;
  });
}

// ---------------------------------------------------------------------------
// Datos basicos
// ---------------------------------------------------------------------------

function BloqueDatos({
  displayName,
  email,
  onGuardado,
}: {
  readonly displayName: string;
  readonly email: string;
  onGuardado(usuario: { id: string; email: string; displayName: string }): void;
}): React.JSX.Element {
  const { error, pending, run } = useAsyncAction();
  const [nombre, setNombre] = useState(displayName);
  const [guardado, setGuardado] = useState(false);

  return (
    <section className="panel-perfil">
      <div className="cabecera-panel">
        <h2>Datos</h2>
        <p className="subtitulo">El nombre es el que ven los demás en las pizarras.</p>
      </div>

      <form
        className="formulario-perfil"
        onSubmit={(evento) => {
          evento.preventDefault();
          setGuardado(false);
          void run(async () => {
            onGuardado(await perfil.actualizar(nombre.trim()));
            setGuardado(true);
          });
        }}
      >
        <label>
          <span>Nombre</span>
          <input
            required
            maxLength={120}
            data-testid="perfil-nombre"
            value={nombre}
            onChange={(evento) => {
              setNombre(evento.target.value);
              setGuardado(false);
            }}
          />
        </label>

        <label>
          <span>Correo</span>
          {/* De solo lectura: es la identidad de la cuenta y la direccion a la
              que llega la recuperacion. Cambiarlo sin verificar el buzon nuevo
              permitiria apropiarse de una cuenta. */}
          <input type="email" value={email} readOnly disabled data-testid="perfil-correo" />
          <span className="ayuda">El correo no se puede cambiar.</span>
        </label>

        <div className="acciones-formulario">
          <button
            type="submit"
            className="principal"
            disabled={pending || nombre.trim() === ''}
            data-testid="guardar-perfil"
          >
            {pending ? 'Guardando…' : 'Guardar cambios'}
          </button>
          {guardado && (
            <span className="aviso-ok" role="status" data-testid="perfil-guardado">
              Datos actualizados.
            </span>
          )}
        </div>
      </form>

      {error !== null && (
        <p className="aviso-error" role="alert" data-testid="error-perfil">
          {error}
        </p>
      )}
    </section>
  );
}

// ---------------------------------------------------------------------------
// Contrasena
// ---------------------------------------------------------------------------

function BloquePassword(): React.JSX.Element {
  const { error, pending, run } = useAsyncAction();
  const [actual, setActual] = useState('');
  const [nueva, setNueva] = useState('');
  const [repetida, setRepetida] = useState('');
  const [hecho, setHecho] = useState(false);

  const noCoinciden = repetida !== '' && nueva !== repetida;

  return (
    <section className="panel-perfil">
      <div className="cabecera-panel">
        <h2>Contraseña</h2>
        <p className="subtitulo">
          Al cambiarla se cierran las demás sesiones. La de esta pestaña sigue abierta.
        </p>
      </div>

      <form
        className="formulario-perfil"
        onSubmit={(evento) => {
          evento.preventDefault();
          setHecho(false);
          void run(async () => {
            await perfil.cambiarPassword(actual, nueva);
            setActual('');
            setNueva('');
            setRepetida('');
            setHecho(true);
          });
        }}
      >
        <label>
          <span>Contraseña actual</span>
          <input
            type="password"
            required
            autoComplete="current-password"
            data-testid="password-actual"
            value={actual}
            onChange={(evento) => setActual(evento.target.value)}
          />
        </label>

        <label>
          <span>Contraseña nueva</span>
          <input
            type="password"
            required
            minLength={8}
            autoComplete="new-password"
            data-testid="password-nueva"
            value={nueva}
            onChange={(evento) => setNueva(evento.target.value)}
          />
          <span className="ayuda">Al menos 8 caracteres.</span>
        </label>

        <label>
          <span>Repite la nueva</span>
          <input
            type="password"
            required
            autoComplete="new-password"
            data-testid="password-repetida"
            aria-invalid={noCoinciden}
            value={repetida}
            onChange={(evento) => setRepetida(evento.target.value)}
          />
          {/* Se comprueba aqui y no en el servidor: la repeticion existe para
              atrapar una errata al teclear, no es un dato que el backend
              necesite. */}
          {noCoinciden && <span className="ayuda error">Las dos no coinciden.</span>}
        </label>

        <div className="acciones-formulario">
          <button
            type="submit"
            className="principal"
            disabled={pending || noCoinciden || nueva === ''}
            data-testid="cambiar-password"
          >
            <IconoLlave size={15} />
            {pending ? 'Cambiando…' : 'Cambiar contraseña'}
          </button>
          {hecho && (
            <span className="aviso-ok" role="status" data-testid="password-cambiada">
              Contraseña actualizada.
            </span>
          )}
        </div>
      </form>

      {error !== null && (
        <p className="aviso-error" role="alert" data-testid="error-password">
          {error}
        </p>
      )}
    </section>
  );
}
```

---

### `frontend/src/features/auth/ResetPage.tsx`

```tsx
import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router';
import { IconoDiagrama } from '../../components/icons.js';
import { perfil } from '../../lib/api.js';
import { useAsyncAction, useSession } from './session.js';

/**
 * Elegir una contrasena nueva desde el enlace del correo (RF-A11).
 *
 * El testigo llega en la direccion. No se guarda en ningun sitio ni se muestra:
 * se usa una vez y el servidor lo consume.
 */
export function ResetPage(): React.JSX.Element {
  const [parametros] = useSearchParams();
  const navegar = useNavigate();
  const { error, pending, run } = useAsyncAction();
  const { logout } = useSession();

  const token = parametros.get('token') ?? '';
  const [nueva, setNueva] = useState('');
  const [repetida, setRepetida] = useState('');
  const [hecho, setHecho] = useState(false);

  const noCoinciden = repetida !== '' && nueva !== repetida;

  if (token === '') {
    return (
      <main className="centrado">
        <div className="estado-ruta" role="alert">
          <h1>Ese enlace está incompleto</h1>
          <p>Falta el código de recuperación. Pide uno nuevo desde la pantalla de acceso.</p>
          <Link to="/entrar">Volver a entrar</Link>
        </div>
      </main>
    );
  }

  return (
    <main className="acceso-formulario acceso-suelto">
      <div className="tarjeta">
        <div className="acceso-titulo">
          <span className="isotipo" aria-hidden="true">
            <IconoDiagrama size={16} />
          </span>
          <h1>Elige una contraseña nueva</h1>
          <p className="subtitulo">
            Al guardarla se cerrarán todas las sesiones abiertas de esta cuenta.
          </p>
        </div>

        {hecho ? (
          <>
            <p className="aviso-ok" role="status" data-testid="password-restablecida">
              Contraseña actualizada. Ya puedes entrar con ella.
            </p>
            <button
              type="button"
              className="principal"
              onClick={() => void navegar('/entrar')}
              data-testid="ir-a-entrar"
            >
              Ir a entrar
            </button>
          </>
        ) : (
          <form
            className="formulario-perfil"
            onSubmit={(evento) => {
              evento.preventDefault();
              void run(async () => {
                await perfil.restablecer(token, nueva);
                // El servidor revoca los refrescos; React tambien debe dejar de
                // tratar la sesion anterior como activa al volver a /entrar.
                await logout();
                setHecho(true);
              });
            }}
          >
            <label>
              <span>Contraseña nueva</span>
              <input
                type="password"
                required
                minLength={8}
                autoComplete="new-password"
                data-testid="nueva-password"
                value={nueva}
                onChange={(evento) => setNueva(evento.target.value)}
              />
              <span className="ayuda">Al menos 8 caracteres.</span>
            </label>

            <label>
              <span>Repítela</span>
              <input
                type="password"
                required
                autoComplete="new-password"
                data-testid="repetir-password"
                aria-invalid={noCoinciden}
                value={repetida}
                onChange={(evento) => setRepetida(evento.target.value)}
              />
              {noCoinciden && <span className="ayuda error">Las dos no coinciden.</span>}
            </label>

            {error !== null && (
              <p className="aviso-error" role="alert" data-testid="error-restablecer">
                {error}
              </p>
            )}

            <button
              type="submit"
              className="principal"
              disabled={pending || noCoinciden || nueva === ''}
              data-testid="guardar-password"
            >
              {pending ? 'Guardando…' : 'Guardar contraseña'}
            </button>
          </form>
        )}

        <Link to="/entrar" className="enlace-discreto">
          Volver a entrar
        </Link>
      </div>
    </main>
  );
}
```

---

### `frontend/src/features/auth/VerificationPage.tsx`

```tsx
import { useState } from 'react';
import { Link, useLocation } from 'react-router';
import { verification } from '../../lib/api.js';
import { useAsyncAction } from './session.js';

export function VerificationPage(): React.JSX.Element {
  const location = useLocation();
  const token = new URLSearchParams(location.hash.slice(1)).get('token') ?? '';
  const [done, setDone] = useState(false);
  const { error, pending, run } = useAsyncAction();

  return (
    <main className="acceso-formulario acceso-suelto">
      <div className="tarjeta">
        <div className="acceso-titulo">
          <h1>{done ? 'Cuenta activada' : 'Activa tu cuenta'}</h1>
          <p className="subtitulo">
            {done
              ? 'Tu correo está confirmado. Ya puedes iniciar sesión.'
              : 'Confirma tu correo para comenzar a crear tus diagramas.'}
          </p>
        </div>
        {done ? (
          <p className="aviso-ok" role="status" data-testid="cuenta-activada">
            Tu cuenta está lista.
          </p>
        ) : token ? (
          <button
            className="principal"
            disabled={pending}
            onClick={() =>
              void run(async () => {
                await verification.confirm(token);
                setDone(true);
                window.history.replaceState(null, '', location.pathname);
              })
            }
          >
            {pending ? 'Activando…' : 'Activar mi cuenta'}
          </button>
        ) : (
          <p className="aviso-error" role="alert">
            Falta el código de activación. Abre el enlace completo del correo o solicita uno nuevo.
          </p>
        )}
        {error && (
          <p className="aviso-error" role="alert">
            {error}
          </p>
        )}
        {!done && <ResendVerification />}
        <Link to="/entrar">Ir a iniciar sesión</Link>
      </div>
    </main>
  );
}

export function ResendVerification(): React.JSX.Element {
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);
  const { error, pending, run } = useAsyncAction();
  return (
    <form
      className="formulario-perfil"
      onSubmit={(event) => {
        event.preventDefault();
        void run(async () => {
          setSent(false);
          await verification.resend(email);
          setSent(true);
        });
      }}
    >
      <label>
        <span>Correo de tu cuenta</span>
        <input
          type="email"
          autoComplete="email"
          required
          value={email}
          onChange={(event) => {
            setEmail(event.target.value);
            setSent(false);
          }}
        />
      </label>
      <button className="secundario" disabled={pending}>
        {pending ? 'Solicitando…' : 'Reenviar enlace de activación'}
      </button>
      {sent && (
        <p className="aviso-ok" role="status">
          Si tu cuenta está pendiente, recibirás un enlace. Revisa también spam. Espera un minuto
          antes de volver a solicitarlo.
        </p>
      )}
      {error && (
        <p className="aviso-error" role="alert">
          {error}
        </p>
      )}
    </form>
  );
}
```

---

### `frontend/src/features/auth/session.tsx`

```tsx
import { createContext, use, useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  fetchMe,
  currentAccessToken,
  isConnectionUnavailable,
  login as loginRequest,
  logout as logoutRequest,
  refreshSession,
  sessionRefreshUnavailable,
  register as registerRequest,
  setAccessToken,
  type SessionUser,
  type RegistrationResponse,
} from '../../lib/api.js';
import {
  forgetUser,
  logoutPending,
  offlineUser,
  OFFLINE_USER_KEY,
  rememberUser,
} from '../../lib/offline.js';

interface SessionValue {
  readonly user: SessionUser | null;
  readonly loading: boolean;
  readonly offline: boolean;
  /** Activa la copia local cuando una renovación falla por conectividad. */
  activateOfflineCopy(): void;
  login(email: string, password: string): Promise<void>;
  register(email: string, displayName: string, password: string): Promise<RegistrationResponse>;
  logout(): Promise<void>;
  /**
   * Refresca el usuario de la sesion tras editar el perfil.
   *
   * No vuelve a pedirlo al servidor: la ruta de perfil ya devuelve el usuario
   * actualizado, y quien lo tiene lo pasa. Asi el nombre cambia en la barra
   * superior sin una segunda vuelta.
   */
  actualizarUsuario(usuario: SessionUser): void;
}

const SessionContext = createContext<SessionValue | null>(null);

/** Margen para que un cambio de red no cuente como quedarse sin conexion. */
const CONFIRMAR_SIN_RED = 2000;

export function SessionProvider({ children }: { children: React.ReactNode }): React.JSX.Element {
  const [user, setUser] = useState<SessionUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [offline, setOffline] = useState(false);
  const revision = useRef(0);
  const currentUser = useRef(user);
  currentUser.current = user;
  const isOffline = useRef(offline);
  isOffline.current = offline;
  const activateOfflineCopy = useCallback(() => setOffline(true), []);

  // Al arrancar se intenta renovar: el token de acceso vive en memoria y no
  // sobrevive a una recarga, pero la cookie de refresco si.
  useEffect(() => {
    let vigente = true;
    let checking = false;

    const restore = async (): Promise<void> => {
      if (checking || !vigente) return;
      const currentRevision = revision.current;
      const active = (): boolean => vigente && currentRevision === revision.current;
      checking = true;
      try {
        if (!navigator.onLine) {
          setUser(offlineUser());
          setOffline(true);
          return;
        }
        if (logoutPending()) {
          await logoutRequest();
          if (!active() || logoutPending()) return;
        }
        // Al volver la red puede seguir vigente el acceso en memoria. Consultar
        // el perfil lo verifica y renueva solo ante 401. Rotar siempre aquí
        // consumía la cookie si el usuario recargaba antes de recibir la nueva.
        const renovado = currentAccessToken() !== null || (await refreshSession());
        if (!active()) return;
        if (!renovado) {
          if (sessionRefreshUnavailable()) {
            setUser(offlineUser());
            setOffline(true);
          } else {
            forgetUser();
            setUser(null);
            setOffline(false);
          }
          return;
        }
        try {
          const perfil = await fetchMe(AbortSignal.timeout(8000));
          if (!active()) return;
          rememberUser(perfil);
          setUser(perfil);
          setOffline(false);
        } catch (error) {
          if (!active()) return;
          if (isConnectionUnavailable(error)) {
            setUser(offlineUser());
            setOffline(true);
          } else {
            forgetUser();
            setUser(null);
            setOffline(false);
          }
        }
      } finally {
        checking = false;
        if (active()) setLoading(false);
      }
    };
    void restore();
    let confirmacion: number | undefined;
    const cancelarConfirmacion = (): void => {
      if (confirmacion === undefined) return;
      window.clearTimeout(confirmacion);
      confirmacion = undefined;
    };
    const reconnect = (): void => {
      cancelarConfirmacion();
      void restore();
    };
    // Evita cambiar de réplica por un parpadeo. Las otras páginas permanecen
    // montadas aunque la desconexión dure más que este margen.
    const disconnect = (): void => {
      if (!vigente || isOffline.current || confirmacion !== undefined) return;
      confirmacion = window.setTimeout(() => {
        confirmacion = undefined;
        if (vigente && !navigator.onLine) setOffline(true);
      }, CONFIRMAR_SIN_RED);
    };
    const retry = (): void => {
      if (isOffline.current && navigator.onLine) reconnect();
    };
    const changedAccount = (event: StorageEvent): void => {
      if (event.key !== OFFLINE_USER_KEY && event.key !== null) return;
      if (offlineUser()?.id === currentUser.current?.id) return;
      // A different tab cannot silently replace the author of this tab's drafts.
      revision.current += 1;
      setAccessToken(null);
      setUser(null);
      setLoading(false);
    };
    window.addEventListener('online', reconnect);
    window.addEventListener('offline', disconnect);
    window.addEventListener('storage', changedAccount);
    window.addEventListener('focus', retry);
    // navigator.onLine can remain true when the route to the server disappears.
    // Retry independently of the browser's connectivity events, without blocking edits.
    const timer = window.setInterval(retry, 5000);

    return () => {
      vigente = false;
      cancelarConfirmacion();
      window.removeEventListener('online', reconnect);
      window.removeEventListener('offline', disconnect);
      window.removeEventListener('storage', changedAccount);
      window.removeEventListener('focus', retry);
      window.clearInterval(timer);
    };
  }, []);

  const value = useMemo<SessionValue>(
    () => ({
      user,
      loading,
      offline,
      activateOfflineCopy,
      login: async (email, password) => {
        revision.current += 1;
        const perfil = await loginRequest(email, password);
        rememberUser(perfil);
        setUser(perfil);
        setOffline(false);
      },
      register: registerRequest,
      logout: async () => {
        revision.current += 1;
        forgetUser();
        setAccessToken(null);
        setUser(null);
        await logoutRequest();
      },
      actualizarUsuario: (perfil) => {
        rememberUser(perfil);
        setUser(perfil);
      },
    }),
    [user, loading, offline, activateOfflineCopy],
  );

  return <SessionContext value={value}>{children}</SessionContext>;
}

export function useSession(): SessionValue {
  const value = use(SessionContext);
  if (value === null) throw new Error('useSession fuera de SessionProvider');
  return value;
}

export function useRequireSession(): SessionUser | null {
  const { user } = useSession();
  return user;
}

/** Envuelve una accion asincrona para mostrar su error sin repetir el try. */
export function useAsyncAction(): {
  error: string | null;
  pending: boolean;
  run(accion: () => Promise<void>): Promise<void>;
} {
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  const run = useCallback(async (accion: () => Promise<void>) => {
    setPending(true);
    setError(null);
    try {
      await accion();
    } catch (causa) {
      setError(causa instanceof Error ? causa.message : 'Algo salio mal.');
    } finally {
      setPending(false);
    }
  }, []);

  return { error, pending, run };
}
```

---

### `frontend/src/features/editor/AsociacionEdge.tsx`

```tsx
import type { RelationshipKind } from '@uml/contracts';
import { getStraightPath, type Edge, type EdgeProps } from '@xyflow/react';

export interface AsociacionData extends Record<string, unknown> {
  readonly origen: string;
  readonly destino: string;
  readonly rolOrigen: string | undefined;
  readonly rolDestino: string | undefined;
  readonly kind: RelationshipKind;
  readonly parallelIndex: number;
  readonly parallelCount: number;
}

export type AsociacionEdgeType = Edge<AsociacionData, 'asociacion'>;

/**
 * Asociacion dibujada como en UML 2.5.
 *
 * Tres diferencias con la arista que traia React Flow, y las tres son las que
 * hacen que un diagrama se lea como un diagrama y no como un grafo:
 *
 * **Linea recta.** Una curva de Bezier entre dos clases sugiere un flujo; en un
 * diagrama de clases la relacion es una linea, sin mas.
 *
 * **Las multiplicidades van en los extremos.** Cada una pertenece al lado que
 * toca: «1» junto a Persona y «0..*» junto a Estudiante significa una cosa, y
 * puestas juntas en el medio como «1 → 0..*» hay que recordar cual era cual.
 *
 * **El texto va dentro del SVG**, no en una capa flotante. Asi se desplaza y se
 * escala con el diagrama, y al exportar la vista sale con el.
 */
export function AsociacionEdge({
  sourceX,
  sourceY,
  targetX,
  targetY,
  source,
  target,
  data,
  selected,
}: EdgeProps<AsociacionEdgeType>): React.JSX.Element {
  const esRecursiva = source === target;
  const parallelIndex = data?.parallelIndex ?? 0;
  const parallelCount = data?.parallelCount ?? 1;
  const desplazamientoCarril = (parallelIndex - (parallelCount - 1) / 2) * 24;
  const profundidadBucle = 58 + parallelIndex * 28;
  const ruta = esRecursiva
    ? rutaRecursiva(sourceX, sourceY, targetX, targetY, profundidadBucle)
    : rutaParalela(sourceX, sourceY, targetX, targetY, desplazamientoCarril);
  const path = ruta.path;

  const origen = esRecursiva
    ? { x: sourceX - 18, y: sourceY + 18 + parallelIndex * 10 }
    : desplazar(extremo(sourceX, sourceY, targetX, targetY), ruta.normal, desplazamientoCarril);
  const destino = esRecursiva
    ? { x: targetX + 18, y: targetY + 18 + parallelIndex * 10 }
    : desplazar(extremo(targetX, targetY, sourceX, sourceY), ruta.normal, desplazamientoCarril);
  const rolOrigen = esRecursiva
    ? { x: sourceX - 24, y: sourceY + 38 + parallelIndex * 14 }
    : desplazar(
        extremo(sourceX, sourceY, targetX, targetY, 42, 8),
        ruta.normal,
        desplazamientoCarril,
      );
  const rolDestino = esRecursiva
    ? { x: targetX + 24, y: targetY + 38 + parallelIndex * 14 }
    : desplazar(
        extremo(targetX, targetY, sourceX, sourceY, 42, 8),
        ruta.normal,
        desplazamientoCarril,
      );
  const kind = data?.kind ?? 'ASSOCIATION';
  const className = [
    'asociacion',
    `tipo-${kind.toLocaleLowerCase()}`,
    selected === true ? 'seleccionada' : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <g className={className} data-relationship-kind={kind}>
      {/* Una franja invisible y ancha sobre la linea: una linea de un pixel es
          casi imposible de acertar con el raton. */}
      <path className="asociacion-zona" d={path} />
      <path className="asociacion-linea" d={path} />
      <RelationshipMarker
        kind={kind}
        sourceX={sourceX}
        sourceY={sourceY}
        targetX={targetX}
        targetY={targetY}
        sourceTowardX={ruta.sourceToward.x}
        sourceTowardY={ruta.sourceToward.y}
        targetTowardX={ruta.targetToward.x}
        targetTowardY={ruta.targetToward.y}
      />

      {kind !== 'GENERALIZATION' && (
        <>
          <text className="multiplicidad" x={origen.x} y={origen.y}>
            {data?.origen}
          </text>
          <text className="multiplicidad" x={destino.x} y={destino.y}>
            {data?.destino}
          </text>
        </>
      )}

      {kind !== 'GENERALIZATION' && data?.rolOrigen !== undefined && (
        <text className="rol-asociacion" x={rolOrigen.x} y={rolOrigen.y}>
          {data.rolOrigen}
        </text>
      )}
      {kind !== 'GENERALIZATION' && data?.rolDestino !== undefined && (
        <text className="rol-asociacion" x={rolDestino.x} y={rolDestino.y}>
          {data.rolDestino}
        </text>
      )}
    </g>
  );
}

function RelationshipMarker({
  kind,
  sourceX,
  sourceY,
  targetX,
  targetY,
  sourceTowardX,
  sourceTowardY,
  targetTowardX,
  targetTowardY,
}: {
  readonly kind: RelationshipKind;
  readonly sourceX: number;
  readonly sourceY: number;
  readonly targetX: number;
  readonly targetY: number;
  readonly sourceTowardX: number;
  readonly sourceTowardY: number;
  readonly targetTowardX: number;
  readonly targetTowardY: number;
}): React.JSX.Element | null {
  if (kind === 'ASSOCIATION') return null;

  if (kind === 'GENERALIZATION') {
    const angle = angleBetween(targetX, targetY, targetTowardX, targetTowardY);
    return (
      <polygon
        className="marcador-relacion triangulo"
        points="0,0 18,-9 18,9"
        transform={`translate(${targetX} ${targetY}) rotate(${angle})`}
      />
    );
  }

  const angle = angleBetween(sourceX, sourceY, sourceTowardX, sourceTowardY);
  return (
    <polygon
      className={`marcador-relacion diamante${kind === 'COMPOSITION' ? ' relleno' : ''}`}
      points="0,0 10,-7 20,0 10,7"
      transform={`translate(${sourceX} ${sourceY}) rotate(${angle})`}
    />
  );
}

interface RutaRelacion {
  readonly path: string;
  readonly normal: { x: number; y: number };
  /** Primer punto despues del origen y ultimo punto antes del destino. */
  readonly sourceToward: { x: number; y: number };
  readonly targetToward: { x: number; y: number };
}

function rutaRecursiva(
  sourceX: number,
  sourceY: number,
  targetX: number,
  targetY: number,
  profundidad: number,
): RutaRelacion {
  const sourceToward = { x: sourceX, y: sourceY + profundidad };
  const targetToward = { x: targetX, y: targetY + profundidad };
  return {
    path:
      `M${sourceX} ${sourceY} L${sourceToward.x} ${sourceToward.y} ` +
      `L${targetToward.x} ${targetToward.y} L${targetX} ${targetY}`,
    normal: { x: 0, y: 0 },
    sourceToward,
    targetToward,
  };
}

function rutaParalela(
  sourceX: number,
  sourceY: number,
  targetX: number,
  targetY: number,
  carril: number,
): RutaRelacion {
  if (carril === 0) {
    return {
      path: getStraightPath({ sourceX, sourceY, targetX, targetY })[0],
      normal: normalEntre(sourceX, sourceY, targetX, targetY),
      sourceToward: { x: targetX, y: targetY },
      targetToward: { x: sourceX, y: sourceY },
    };
  }

  const dx = targetX - sourceX;
  const dy = targetY - sourceY;
  const largo = Math.hypot(dx, dy) || 1;
  const direccion = { x: dx / largo, y: dy / largo };
  const normal = { x: -direccion.y, y: direccion.x };
  const guia = Math.min(32, largo / 3);
  const sourceToward = {
    x: sourceX + direccion.x * guia + normal.x * carril,
    y: sourceY + direccion.y * guia + normal.y * carril,
  };
  const targetToward = {
    x: targetX - direccion.x * guia + normal.x * carril,
    y: targetY - direccion.y * guia + normal.y * carril,
  };

  return {
    path:
      `M${sourceX} ${sourceY} L${sourceToward.x} ${sourceToward.y} ` +
      `L${targetToward.x} ${targetToward.y} L${targetX} ${targetY}`,
    normal,
    sourceToward,
    targetToward,
  };
}

function normalEntre(
  sourceX: number,
  sourceY: number,
  targetX: number,
  targetY: number,
): { x: number; y: number } {
  const dx = targetX - sourceX;
  const dy = targetY - sourceY;
  const largo = Math.hypot(dx, dy) || 1;
  return { x: -dy / largo, y: dx / largo };
}

function desplazar(
  punto: { x: number; y: number },
  normal: { x: number; y: number },
  distancia: number,
): { x: number; y: number } {
  return { x: punto.x + normal.x * distancia, y: punto.y + normal.y * distancia };
}

function angleBetween(fromX: number, fromY: number, toX: number, toY: number): number {
  return (Math.atan2(toY - fromY, toX - fromX) * 180) / Math.PI;
}

/**
 * Donde va la etiqueta de un extremo: separada de la clase y a un lado de la
 * linea, como la coloca cualquier herramienta UML.
 */
function extremo(
  x: number,
  y: number,
  haciaX: number,
  haciaY: number,
  separacion = 18,
  ajusteVertical = -6,
): { x: number; y: number } {
  const dx = haciaX - x;
  const dy = haciaY - y;
  const largo = Math.hypot(dx, dy) || 1;

  return {
    x: x + (dx / largo) * separacion,
    // Por encima de la linea, salvo cuando la linea es casi vertical: ahi
    // estorbaria, y se aparta al lado.
    y: y + (dy / largo) * separacion + (Math.abs(dy / largo) > 0.8 ? 0 : ajusteVertical),
  };
}
```

---

### `frontend/src/features/editor/BoardCanvas.tsx`

```tsx
import type { BoardState, Size, ValidationIssue } from '@uml/contracts';
import { resolvePrimaryKey } from '@uml/domain-core';
import {
  Background,
  ConnectionMode,
  Controls,
  MiniMap,
  Panel,
  ReactFlow,
  getViewportForBounds,
  type Connection,
  type NodeChange,
  useReactFlow,
  useStore,
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import { useTheme } from '../../components/ThemeProvider.js';
import { useEffect, useMemo, useRef } from 'react';
import { AsociacionEdge, type AsociacionEdgeType } from './AsociacionEdge.js';
import { ClassNode, type ClassNodeType } from './ClassNode.js';
import { toolLabel, type EditorTool } from './editor-tools.js';
import type { Participant } from './useBoardDocument.js';

const nodeTypes = { umlClass: ClassNode };
const edgeTypes = { asociacion: AsociacionEdge };
const FIT_VIEW_OPTIONS = { maxZoom: 1 } as const;

export interface BoardCanvasProps {
  readonly state: BoardState;
  readonly issues: readonly ValidationIssue[];
  readonly participants: readonly Participant[];
  readonly selectedId: string | null;
  /** Clase creada localmente que debe quedar completa dentro de la vista. */
  readonly revealClassId: string | null;
  readonly activeTool: EditorTool;
  readonly relationshipSourceId: string | null;
  readonly canWrite: boolean;
  onSelect(elementId: string | null): void;
  onClassClick(classId: string): void;
  onCancelTool(): void;
  onCreateClass(position: { x: number; y: number }): void;
  /**
   * Colocar o redimensionar. El tamano solo viaja cuando alguien lo cambio a
   * mano; arrastrar lo omite y el que hubiera se conserva.
   */
  onMove(classId: string, position: { x: number; y: number }, size?: Size): void;
  onConnect(sourceClassId: string, targetClassId: string): void;
}

/**
 * El lienzo es una proyeccion del documento.
 *
 * React Flow no guarda estado propio de nodos: se le entregan derivados del
 * modelo en cada render. Dejar que los gestione el lienzo crearia una segunda
 * copia que habria que reconciliar con la que llega por la red.
 */
export function BoardCanvas(props: BoardCanvasProps): React.JSX.Element {
  const { resolved: resolvedTheme } = useTheme();
  const {
    state,
    issues,
    participants,
    selectedId,
    revealClassId,
    activeTool,
    relationshipSourceId,
    canWrite,
  } = props;
  const { screenToFlowPosition, setViewport } = useReactFlow<ClassNodeType, AsociacionEdgeType>();
  const canvasWidth = useStore((store) => store.width);
  const canvasHeight = useStore((store) => store.height);
  const ultimaClaseRevelada = useRef<string | null>(null);

  // Que elementos estan implicados en un error, para pintarlos.
  const { conError, conAviso } = useMemo(() => {
    const errores = new Set<string>();
    const avisos = new Set<string>();

    for (const hallazgo of issues) {
      const destino = hallazgo.severity === 'ERROR' ? errores : avisos;
      for (const id of hallazgo.elementIds) destino.add(id);
    }
    return { conError: errores, conAviso: avisos };
  }, [issues]);

  const editoresPorElemento = useMemo(() => {
    const mapa = new Map<string, { displayName: string; color: string }>();
    for (const participante of participants) {
      if (participante.editing !== null) {
        mapa.set(participante.editing, {
          displayName: participante.displayName,
          color: participante.color,
        });
      }
    }
    return mapa;
  }, [participants]);

  const nodes: ClassNodeType[] = useMemo(
    () =>
      state.semantic.classes.map((umlClass) => {
        const resolucion = resolvePrimaryKey(umlClass);
        const medida = state.layout.sizes[umlClass.id];
        const primaryKeyId =
          resolucion.kind === 'DECLARED' || resolucion.kind === 'INFERRED'
            ? resolucion.attribute.id
            : null;

        return {
          id: umlClass.id,
          type: 'umlClass' as const,
          position: state.layout.positions[umlClass.id] ?? { x: 0, y: 0 },
          // El tamano se declara en lugar de dejar que la tarjeta crezca con su
          // contenido. Dos razones: un diagrama con tarjetas de anchos dispares
          // no se lee como un diagrama de clases, y el minimapa **solo dibuja
          // los nodos que declaran tamano** — sin esto salia un recuadro vacio.
          // El tamano elegido a mano manda sobre el calculado. Si no, anadir
          // un atributo desharia el ajuste que alguien acaba de hacer.
          width: medida?.width ?? ANCHO_NODO,
          height: medida?.height ?? altoDeNodo(umlClass.attributes.length),
          selected: umlClass.id === selectedId,
          draggable: canWrite,
          ariaLabel: `Clase ${umlClass.displayName}, ${umlClass.attributes.length} ${umlClass.attributes.length === 1 ? 'atributo' : 'atributos'}`,
          data: {
            umlClass,
            canWrite,
            primaryKeyId,
            hasError: conError.has(umlClass.id),
            hasWarning: conAviso.has(umlClass.id),
            isRelationshipSource: umlClass.id === relationshipSourceId,
            editedBy: editoresPorElemento.get(umlClass.id) ?? null,
          },
        };
      }),
    [state, selectedId, relationshipSourceId, canWrite, conError, conAviso, editoresPorElemento],
  );

  const edges: AsociacionEdgeType[] = useMemo(() => {
    const clasesExistentes = new Set(state.semantic.classes.map((item) => item.id));
    const dibujables = state.semantic.relationships.filter(
      (relacion) =>
        clasesExistentes.has(relacion.sourceClassId) &&
        clasesExistentes.has(relacion.targetClassId),
    );
    const paralelas = agruparRelacionesParalelas(dibujables);

    return dibujables.map((relacion) => {
      // Cada multiplicidad viaja por separado: van en su extremo, no juntas
      // en el medio. El rol solo aparece cuando existe, que es cuando
      // desambigua dos relaciones entre el mismo par.
      const lados = ladosMasCortos(
        state.layout,
        relacion.sourceClassId,
        relacion.targetClassId,
        state.semantic.classes,
      );
      const carril = paralelas.get(relacion.id) ?? { index: 0, count: 1 };

      const arista: AsociacionEdgeType = {
        id: relacion.id,
        type: 'asociacion',
        source: relacion.sourceClassId,
        target: relacion.targetClassId,
        sourceHandle: lados.origen,
        targetHandle: lados.destino,
        selected: relacion.id === selectedId,
        ariaLabel: `${relacion.kind ?? 'ASSOCIATION'} entre ${state.semantic.classes.find((item) => item.id === relacion.sourceClassId)?.displayName ?? 'clase'} y ${state.semantic.classes.find((item) => item.id === relacion.targetClassId)?.displayName ?? 'clase'}`,
        data: {
          origen: relacion.sourceMultiplicity,
          destino: relacion.targetMultiplicity,
          rolOrigen: relacion.sourceRoleName,
          rolDestino: relacion.targetRoleName,
          kind: relacion.kind ?? 'ASSOCIATION',
          parallelIndex: carril.index,
          parallelCount: carril.count,
        },
      };

      return conError.has(relacion.id) ? { ...arista, className: 'arista-con-error' } : arista;
    });
  }, [state.semantic.relationships, state.semantic.classes, state.layout, selectedId, conError]);

  useEffect(() => {
    if (revealClassId === null || ultimaClaseRevelada.current === revealClassId) return;
    const nueva = nodes.find((node) => node.id === revealClassId);
    if (nueva === undefined || canvasWidth === 0 || canvasHeight === 0) return;
    ultimaClaseRevelada.current = revealClassId;

    // La accion rapida de la barra crea en coordenadas del modelo. Si la vista
    // estaba centrada en otra clase, la nueva podia quedar debajo del panel
    // lateral. Solo se centra cuando es una creacion local (queda seleccionada),
    // para no moverle la camara a los demas colaboradores.
    // Sin animacion ni un frame diferido: el siguiente gesto suele ser
    // arrastrar un conector y la camara no debe moverse debajo del puntero.
    // El nodo puede no estar aun en el registro interno de React Flow. Usar
    // sus dimensiones conocidas evita que fitView omita la clase recien creada.
    void setViewport(
      getViewportForBounds(
        {
          ...nueva.position,
          width: nueva.width ?? ANCHO_NODO,
          height: nueva.height ?? altoDeNodo(nueva.data.umlClass.attributes.length),
        },
        canvasWidth,
        canvasHeight,
        0.2,
        1,
        0.25,
      ),
      { duration: 0 },
    );
  }, [canvasWidth, canvasHeight, setViewport, nodes, revealClassId]);

  return (
    <ReactFlow
      data-testid="pizarra-diagrama"
      nodes={nodes}
      edges={edges}
      nodeTypes={nodeTypes}
      edgeTypes={edgeTypes}
      className={`tablero herramienta-${activeTool.toLocaleLowerCase()}`}
      // Permite unir cualquier lado con cualquier lado. Con el modo estricto
      // cada clase solo podia salir por la derecha y entrar por la izquierda,
      // asi que una relacion hacia atras dibujaba un lazo alrededor de la caja.
      connectionMode={ConnectionMode.Loose}
      nodesDraggable={canWrite}
      nodesConnectable={canWrite}
      elementsSelectable
      aria-label="Lienzo del diagrama de clases"
      ariaLabelConfig={{
        'controls.ariaLabel': 'Controles del lienzo',
        'controls.zoomIn.ariaLabel': 'Acercar',
        'controls.zoomOut.ariaLabel': 'Alejar',
        'controls.fitView.ariaLabel': 'Ajustar diagrama a la vista',
        'minimap.ariaLabel': 'Vista general del diagrama',
        'handle.ariaLabel': 'Conector de relación',
      }}
      fitView
      fitViewOptions={FIT_VIEW_OPTIONS}
      minZoom={0.2}
      maxZoom={2}
      proOptions={{ hideAttribution: true }}
      // El tema cambia la presentación, sin remontar el documento colaborativo.
      colorMode={resolvedTheme}
      onNodesChange={(cambios: NodeChange<ClassNodeType>[]) => {
        for (const cambio of cambios) {
          // Solo al soltar. Emitir un comando por cada pixel llenaria la
          // auditoria de ruido y castigaria la red sin que nadie lo note.
          if (
            cambio.type === 'position' &&
            cambio.position !== undefined &&
            cambio.dragging !== true
          ) {
            const nodo = nodes.find((item) => item.id === cambio.id);
            if (nodo !== undefined) props.onMove(cambio.id, cambio.position ?? nodo.position);
          }

          // React Flow emite `dimensions` mientras se arrastra el tirador y una
          // ultima vez al soltar, con `resizing` en falso. Solo esa ultima
          // interesa: una por pixel llenaria la auditoria de ruido.
          if (cambio.type === 'dimensions' && cambio.resizing === false) {
            const nodo = nodes.find((item) => item.id === cambio.id);
            const medida = cambio.dimensions;
            if (nodo !== undefined && medida !== undefined) {
              props.onMove(cambio.id, nodo.position, {
                width: Math.round(medida.width),
                height: Math.round(medida.height),
              });
            }
          }
        }
      }}
      onNodeClick={(_, nodo) => props.onClassClick(nodo.id)}
      onEdgeClick={(_, arista) => props.onSelect(arista.id)}
      onKeyDownCapture={(event) => {
        if (event.key !== 'Enter' && event.key !== ' ') return;
        const target = event.target;
        if (!(target instanceof Element)) return;

        const node = target.closest<HTMLElement>('.react-flow__node[data-id]');
        if (node !== null) {
          event.preventDefault();
          event.stopPropagation();
          const id = node.dataset.id;
          if (id !== undefined) props.onClassClick(id);
          return;
        }

        const edge = target.closest<SVGGElement>('.react-flow__edge[data-id]');
        if (edge !== null) {
          event.preventDefault();
          event.stopPropagation();
          const id = edge.dataset.id;
          if (id !== undefined) props.onSelect(id);
        }
      }}
      onPaneClick={(event) => {
        if (activeTool === 'CLASS' && canWrite) {
          const point = screenToFlowPosition({ x: event.clientX, y: event.clientY });
          props.onCreateClass({ x: point.x - ANCHO_NODO / 2, y: point.y - 48 });
          return;
        }
        props.onSelect(null);
      }}
      onConnect={(conexion: Connection) => {
        if (conexion.source !== null && conexion.target !== null) {
          props.onConnect(conexion.source, conexion.target);
        }
      }}
    >
      <Background color="var(--diagrama-punto)" gap={16} size={1} />
      {state.semantic.classes.length === 0 && activeTool === 'SELECT' && (
        <Panel
          position="top-center"
          className="estado-lienzo-vacio"
          data-testid="lienzo-vacio"
          role="status"
          aria-live="polite"
        >
          <span className="estado-lienzo-icono" aria-hidden="true">
            +
          </span>
          <h2>{canWrite ? 'Empieza con una clase' : 'La pizarra está vacía'}</h2>
          <p>
            {canWrite
              ? 'Crea una entidad y añade sus atributos desde el panel de propiedades.'
              : 'Todavía no se han añadido clases a este diagrama.'}
          </p>
          {canWrite && (
            <button
              type="button"
              className="principal"
              onClick={() => props.onCreateClass({ x: 80, y: 80 })}
            >
              Crear primera clase
            </button>
          )}
        </Panel>
      )}
      {activeTool !== 'SELECT' && (
        <Panel position="top-left" className="modo-lienzo" data-testid="modo-lienzo">
          <span className="modo-lienzo-punto" aria-hidden="true" />
          <strong>{toolLabel(activeTool)}</strong>
          <span>
            {activeTool === 'CLASS'
              ? 'Haz clic para colocarla'
              : relationshipSourceId === null
                ? 'Elige la clase de origen'
                : 'Elige la clase de destino'}
          </span>
          <button type="button" className="cancelar-modo" onClick={props.onCancelTool}>
            Cancelar <kbd>Esc</kbd>
          </button>
        </Panel>
      )}
      <Controls showInteractive={false} />
      {/* El tamano va en `style` y no en la hoja de estilos: React Flow lee
          `style.width` y `style.height` para calcular la geometria del SVG, asi
          que encogerlo por CSS dejaba los nodos fuera del recorte — un recuadro
          vacio, que es justo lo que se veia. */}
      <MiniMap
        pannable
        zoomable
        style={{ width: 176, height: 112 }}
        nodeColor="var(--clase-borde)"
        maskColor="var(--minimapa-mascara)"
        ariaLabel="Vista general del diagrama"
      />
    </ReactFlow>
  );
}

/**
 * Carriles estables para relaciones que unen el mismo par de clases.
 *
 * Dos asociaciones distintas son validas cuando sus roles las desambiguan. Si
 * se dibujan sobre la misma linea parecen una sola y una de ellas ni siquiera
 * se puede seleccionar. El id ordenado hace que todos los colaboradores les
 * asignen el mismo carril sin sincronizar informacion de layout adicional.
 */
function agruparRelacionesParalelas(
  relaciones: BoardState['semantic']['relationships'],
): Map<string, { index: number; count: number }> {
  const grupos = new Map<string, string[]>();

  for (const relacion of relaciones) {
    const extremos = [relacion.sourceClassId, relacion.targetClassId].sort();
    const clave = `${extremos[0] ?? ''}|${extremos[1] ?? ''}`;
    const existentes = grupos.get(clave) ?? [];
    existentes.push(relacion.id);
    grupos.set(clave, existentes);
  }

  const resultado = new Map<string, { index: number; count: number }>();
  for (const ids of grupos.values()) {
    ids.sort();
    ids.forEach((id, index) => resultado.set(id, { index, count: ids.length }));
  }
  return resultado;
}

/** Ancho fijo de la tarjeta de clase, en pixeles del diagrama. */
const ANCHO_NODO = 240;
const ALTO_CABECERA = 34;
const ALTO_FILA = 22;
const RELLENO_LISTA = 10;

/**
 * Alto de la tarjeta segun cuantos atributos tiene.
 *
 * Es una estimacion, no una medida: React Flow necesita el numero **antes** de
 * dibujar. Si se queda corto la tarjeta se recorta, asi que la lista de
 * atributos se deja desplazable dentro de su alto.
 */
function altoDeNodo(atributos: number): number {
  return ALTO_CABECERA + RELLENO_LISTA + Math.max(atributos, 1) * ALTO_FILA;
}

/**
 * Por que lado sale y entra cada linea.
 *
 * Se elige el par de lados que deja el trazo mas corto, que es lo que hace una
 * herramienta UML: la relacion sale por donde queda enfrente. Antes los lados
 * eran fijos —siempre derecha a izquierda— y una relacion hacia atras dibujaba
 * un lazo rodeando la caja.
 *
 * El calculo usa la disposicion, que ya esta en memoria: no hace falta medir
 * nada en el navegador.
 */
function ladosMasCortos(
  layout: BoardState['layout'],
  origenId: string,
  destinoId: string,
  clases: BoardState['semantic']['classes'],
): {
  origen: 'l' | 'r' | 't' | 'b' | 'b-loop-source';
  destino: 'l' | 'r' | 't' | 'b' | 'b-loop-target';
} {
  if (origenId === destinoId) {
    return { origen: 'b-loop-source', destino: 'b-loop-target' };
  }

  const centro = (classId: string): { x: number; y: number } => {
    const posicion = layout.positions[classId] ?? { x: 0, y: 0 };
    const medida = layout.sizes[classId];
    const atributos = clases.find((item) => item.id === classId)?.attributes.length ?? 0;

    return {
      x: posicion.x + (medida?.width ?? ANCHO_NODO) / 2,
      y: posicion.y + (medida?.height ?? altoDeNodo(atributos)) / 2,
    };
  };

  const desde = centro(origenId);
  const hasta = centro(destinoId);
  const dx = hasta.x - desde.x;
  const dy = hasta.y - desde.y;

  // El eje dominante decide: si estan mas separadas en horizontal, la linea
  // sale por un costado; si en vertical, por arriba o por abajo.
  if (Math.abs(dx) >= Math.abs(dy)) {
    return dx >= 0 ? { origen: 'r', destino: 'l' } : { origen: 'l', destino: 'r' };
  }
  return dy >= 0 ? { origen: 'b', destino: 't' } : { origen: 't', destino: 'b' };
}
```

---

### `frontend/src/features/editor/BoardPage.tsx`

```tsx
import { hasErrors, type Position, type RelationshipKind } from '@uml/contracts';
import { ReactFlowProvider } from '@xyflow/react';
import { useCallback, useEffect, useState } from 'react';
import { Link, useParams } from 'react-router';
import {
  api,
  ApiError,
  isConnectionUnavailable,
  flushAuditQueue,
  pendingAuditCount,
  subscribeAuditQueue,
} from '../../lib/api.js';
import { useSession } from '../auth/session.js';
import { AssistantPanel } from '../assistant/AssistantPanel.js';
import { GenerationPanel } from '../generation/GenerationPanel.js';
import { ImportPanel } from '../import/ImportPanel.js';
import { BoardCanvas } from './BoardCanvas.js';
import { EditorToolbox } from './EditorToolbox.js';
import { Inspector } from './Inspector.js';
import { ValidationPanel } from './ValidationPanel.js';
import { gui, makeBatch, newId, type CommandBody } from './commands.js';
import { isRelationshipTool, relationshipKindFor, type EditorTool } from './editor-tools.js';
import { useBoardDocument } from './useBoardDocument.js';
import { ThemeSelect } from '../../components/ThemeProvider.js';
import { SoftwareGuide } from '../help/SoftwareGuide.js';
import { cachedBoard, forgetBoard, type OfflineBoard } from '../../lib/offline.js';

type Herramienta = 'asistente' | 'importar' | 'generar';

const HERRAMIENTAS: readonly (readonly [Herramienta, string])[] = [
  ['asistente', 'Asistente'],
  ['importar', 'Importar'],
  ['generar', 'Generar'],
];

const ESTADO_CONEXION = {
  conectando: 'Conectando…',
  conectado: 'En vivo',
  desconectado: 'Sin conexión',
  rechazado: 'Acceso denegado',
} as const;

export function BoardPage(): React.JSX.Element {
  const { boardId } = useParams<{ boardId: string }>();
  const { user } = useSession();
  const [selection, setSelection] = useState<{ boardId: string; id: string | null } | null>(null);
  const select = useCallback(
    (id: string | null) => {
      if (boardId !== undefined) setSelection({ boardId, id });
    },
    [boardId],
  );

  if (boardId === undefined) {
    return (
      <main className="centrado">
        <div className="estado-ruta" role="alert">
          <h1>Esa dirección no lleva a ninguna pizarra</h1>
          <p>Puede que el enlace esté incompleto.</p>
          <Link to="/proyectos">Volver a mis proyectos</Link>
        </div>
      </main>
    );
  }

  // React conserva el componente cuando solo cambia un parametro de ruta. La
  // clave fuerza una sesion nueva y, con ella, un Y.Doc nuevo: el contenido de
  // una pizarra nunca puede viajar a la siguiente por reutilizar el hook.
  return (
    <BoardLoader
      key={`${user?.id}:${boardId}`}
      boardId={boardId}
      selectedId={selection?.boardId === boardId ? selection.id : null}
      setSelectedId={select}
    />
  );
}

interface BoardSelectionProps {
  readonly boardId: string;
  readonly selectedId: string | null;
  readonly setSelectedId: (id: string | null) => void;
}

/** Keep the local editor mounted until both the session and board API recover. */
function BoardLoader(props: BoardSelectionProps): React.JSX.Element {
  const { user, offline: sessionOffline } = useSession();
  const [board, setBoard] = useState<OfflineBoard | null>(null);
  const [offline, setOffline] = useState(sessionOffline);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (user === null) return;
    let active = true;
    let inFlight = false;
    let retry = false;
    const controller = new AbortController();
    const openLocal = (): void => {
      const local = cachedBoard(user.id, props.boardId);
      if (local === null) {
        setError('Esta pizarra no está disponible sin conexión. Ábrela con conexión primero.');
      } else {
        setBoard(local);
        setOffline(true);
        setError(null);
      }
    };
    const load = async (): Promise<void> => {
      if (!active || inFlight) return;
      if (sessionOffline) {
        openLocal();
        return;
      }
      inFlight = true;
      try {
        const remote = await api.getBoard(
          props.boardId,
          AbortSignal.any([controller.signal, AbortSignal.timeout(8000)]),
        );
        if (!active) return;
        setBoard(remote);
        setOffline(false);
        setError(null);
        retry = false;
      } catch (cause) {
        if (!active) return;
        if (isConnectionUnavailable(cause)) {
          retry = true;
          openLocal();
        } else {
          retry = false;
          if (cause instanceof ApiError && [403, 404].includes(cause.status))
            forgetBoard(user.id, props.boardId);
          setBoard(null);
          setError(cause instanceof Error ? cause.message : 'No se pudo abrir la pizarra.');
        }
      } finally {
        inFlight = false;
      }
    };
    void load();
    const reconnect = (): void => {
      if (retry && navigator.onLine) void load();
    };
    const timer = window.setInterval(reconnect, 5000);
    window.addEventListener('online', reconnect);
    window.addEventListener('focus', reconnect);
    return () => {
      active = false;
      controller.abort();
      window.clearInterval(timer);
      window.removeEventListener('online', reconnect);
      window.removeEventListener('focus', reconnect);
    };
  }, [props.boardId, user, sessionOffline]);

  if (error !== null)
    return (
      <main className="centrado">
        <div className="estado-ruta" role="alert">
          <h1>No se pudo abrir la pizarra</h1>
          <p className="error">{error}</p>
          <Link to="/proyectos">Volver a mis proyectos</Link>
        </div>
      </main>
    );
  if (board === null)
    return (
      <main className="centrado">
        <div className="estado-ruta" role="status">
          <div className="girando" aria-hidden="true" />
          <p>Abriendo la pizarra…</p>
        </div>
      </main>
    );
  // Sin `key`: cambiar de modo no remonta el editor. La réplica limpia de Yjs
  // la crea `useBoardDocument`, que es quien sabe cuándo hace falta; remontar
  // desde aquí tiraba además la conversación del asistente y el candidato de
  // importación en curso, que es trabajo que puede haber costado una llamada
  // de IA y que el usuario no ha pedido descartar.
  return <BoardSession {...props} board={board} offline={offline} />;
}

function BoardSession({
  boardId,
  selectedId,
  setSelectedId,
  board,
  offline,
}: BoardSelectionProps & {
  readonly board: OfflineBoard;
  readonly offline: boolean;
}): React.JSX.Element {
  const { user, logout } = useSession();
  const [shellReady, setShellReady] = useState(false);
  useEffect(() => {
    if (!import.meta.env.PROD || !('serviceWorker' in navigator) || !window.isSecureContext) return;
    let active = true;
    void navigator.serviceWorker.ready.then(() => {
      if (active) setShellReady(true);
    });
    return () => {
      active = false;
    };
  }, []);

  const [rechazo, setRechazo] = useState<string | null>(null);
  const userId = user?.id ?? null;
  const [auditoriasPendientes, setAuditoriasPendientes] = useState(() => pendingAuditCount(userId));
  const [activeTool, setActiveTool] = useState<EditorTool>('SELECT');
  const [relationshipSourceId, setRelationshipSourceId] = useState<string | null>(null);
  const [classToRevealId, setClassToRevealId] = useState<string | null>(null);
  const [toolboxVisible, setToolboxVisible] = useState(true);
  const [panelVisible, setPanelVisible] = useState(true);

  // Las tres herramientas comparten un solo hueco. Apiladas no cabian: cada una
  // se quedaba con unos centimetros y todas con su propia barra de
  // desplazamiento, asi que ninguna se podia usar de verdad.
  const [herramienta, setHerramienta] = useState<Herramienta>('asistente');

  useEffect(() => {
    const updateCount = (): void => setAuditoriasPendientes(pendingAuditCount(userId));
    const cancelar = subscribeAuditQueue(updateCount);
    updateCount();
    const reintentar = (): void => void flushAuditQueue().catch(() => undefined);
    window.addEventListener('online', reintentar);
    reintentar();
    return () => {
      cancelar();
      window.removeEventListener('online', reintentar);
    };
  }, [userId]);

  const documento = useBoardDocument(board?.room ?? null, user, boardId, offline, board);
  const canWrite = documento.canWrite;

  const run = useCallback(
    (...commands: readonly CommandBody[]) => {
      if (user === null) return;

      const rechazado = documento.dispatch(makeBatch(user.id, ...commands));
      // RA-03: si el lote se rechaza no cambia nada, y hay que decir por que.
      setRechazo(
        rechazado === null || rechazado.length === 0
          ? null
          : (rechazado[0]?.message ?? 'El cambio no se pudo aplicar.'),
      );
    },
    [documento, user],
  );

  // Se depende de la funcion, que es estable, y no del objeto del documento, que
  // cambia con cada actualizacion del modelo.
  const { announceEditing } = documento;
  useEffect(() => {
    announceEditing(selectedId);
  }, [announceEditing, selectedId]);

  const chooseTool = useCallback((tool: EditorTool): void => {
    setActiveTool(tool);
    setRelationshipSourceId(null);
  }, []);

  const createClassAt = useCallback(
    (position: Position): void => {
      const classId = newId();
      setSelectedId(classId);
      setClassToRevealId(classId);
      run(gui.createClass(classId, 'Clase nueva', position));
      setActiveTool('SELECT');
    },
    [run],
  );

  const createRelationship = useCallback(
    (sourceClassId: string, targetClassId: string, kind: RelationshipKind): void => {
      if (sourceClassId === targetClassId && kind === 'GENERALIZATION') {
        setRechazo(
          'Una clase no puede heredar de si misma. Usa Asociación para crear una relación recursiva.',
        );
        setRelationshipSourceId(null);
        setActiveTool('SELECT');
        return;
      }
      const relationshipId = newId();
      run(gui.createRelationship(relationshipId, sourceClassId, targetClassId, kind));
      setSelectedId(relationshipId);
      setRelationshipSourceId(null);
      setActiveTool('SELECT');
    },
    [run],
  );

  const selectClassForTool = useCallback(
    (classId: string): void => {
      if (!isRelationshipTool(activeTool)) {
        setSelectedId(classId);
        return;
      }

      if (relationshipSourceId === null) {
        setRelationshipSourceId(classId);
        setSelectedId(classId);
        return;
      }

      createRelationship(relationshipSourceId, classId, relationshipKindFor(activeTool));
    },
    [activeTool, relationshipSourceId, createRelationship],
  );

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent): void => {
      const target = event.target as HTMLElement | null;
      // A modal owns keyboard interaction, including Escape and tool shortcuts.
      if (target?.closest('dialog[open], [data-tour-ui]')) return;
      if (
        target instanceof HTMLInputElement ||
        target instanceof HTMLTextAreaElement ||
        target instanceof HTMLSelectElement ||
        target?.isContentEditable === true
      ) {
        return;
      }

      if (event.key === 'Delete' && selectedId !== null && canWrite) {
        const esClase = documento.state.semantic.classes.some((item) => item.id === selectedId);
        const esRelacion = documento.state.semantic.relationships.some(
          (item) => item.id === selectedId,
        );
        if (!esClase && !esRelacion) return;

        event.preventDefault();
        run(esClase ? gui.deleteClass(selectedId) : gui.deleteRelationship(selectedId));
        setSelectedId(null);
        setRelationshipSourceId(null);
        return;
      }

      const toolByKey: Partial<Record<string, EditorTool>> = {
        v: 'SELECT',
        c: 'CLASS',
        '1': 'ASSOCIATION',
        '2': 'GENERALIZATION',
        '3': 'COMPOSITION',
        '4': 'AGGREGATION',
      };
      const tool = event.key === 'Escape' ? 'SELECT' : toolByKey[event.key.toLocaleLowerCase()];
      if (tool === undefined || (!canWrite && tool !== 'SELECT')) return;

      event.preventDefault();
      chooseTool(tool);
    };

    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [canWrite, chooseTool, documento.state.semantic, run, selectedId]);

  useEffect(() => {
    if (
      relationshipSourceId !== null &&
      !documento.state.semantic.classes.some((item) => item.id === relationshipSourceId)
    ) {
      setRelationshipSourceId(null);
    }
  }, [documento.state.semantic.classes, relationshipSourceId]);

  // Una eliminacion remota puede dejar el inspector apuntando a un elemento
  // inexistente y la presencia anunciando que seguimos editandolo. La seleccion
  // es estado local de interfaz: se limpia en cuanto el documento confirma que
  // la clase o relacion ya no existe.
  useEffect(() => {
    // Una réplica recién creada está vacía y todavía no confirma nada: al
    // cambiar entre servidor y copia local no puede borrar la selección.
    if (
      selectedId === null ||
      (documento.state.semantic.classes.length === 0 && documento.status === 'conectando')
    )
      return;

    const sigueExistiendo =
      documento.state.semantic.classes.some((item) => item.id === selectedId) ||
      documento.state.semantic.relationships.some((item) => item.id === selectedId);
    if (!sigueExistiendo) setSelectedId(null);
  }, [
    documento.state.semantic.classes,
    documento.state.semantic.relationships,
    documento.status,
    selectedId,
    setSelectedId,
  ]);

  return (
    <div className="editor">
      <header className="barra-editor">
        <div className="identidad">
          {/* Proyecto › Pizarra. Antes solo habia una flecha sin nombre: dentro
              del editor no se sabia a donde llevaba, ni de que proyecto era la
              pizarra abierta. */}
          <nav className="miga" aria-label="Ubicación">
            <Link to={`/proyectos/${board.projectId}`} title="Volver al proyecto">
              Proyecto
            </Link>
            <span className="separador" aria-hidden="true">
              ›
            </span>
          </nav>
          <h1>{board.displayName}</h1>
        </div>

        <button
          type="button"
          className="principal"
          disabled={!canWrite}
          data-testid="crear-clase"
          title={canWrite ? 'Añadir una clase al diagrama' : 'Tu rol es de solo lectura'}
          onClick={() => {
            const classId = newId();
            setSelectedId(classId);
            setClassToRevealId(classId);
            // Se coloca escalonada para que las nuevas no se apilen encima.
            const total = documento.state.semantic.classes.length;
            run(
              gui.createClass(classId, 'Clase nueva', {
                x: 80 + (total % 4) * 300,
                y: 80 + Math.floor(total / 4) * 240,
              }),
            );
            chooseTool('SELECT');
          }}
        >
          Nueva clase
        </button>

        <div className="controles-vista" aria-label="Paneles del editor">
          <button
            type="button"
            className="fantasma boton-panel"
            aria-controls="editor-toolbox"
            aria-expanded={toolboxVisible}
            data-testid="alternar-toolbox"
            title={toolboxVisible ? 'Ocultar caja de herramientas' : 'Mostrar caja de herramientas'}
            onClick={() => setToolboxVisible((visible) => !visible)}
          >
            <span className="icono-panel icono-panel-izquierdo" aria-hidden="true" />
            Herramientas
          </button>
          <button
            type="button"
            className="fantasma boton-panel"
            aria-controls="panel-editor"
            aria-expanded={panelVisible}
            data-testid="alternar-panel"
            title={panelVisible ? 'Ocultar panel lateral' : 'Mostrar panel lateral'}
            onClick={() => setPanelVisible((visible) => !visible)}
          >
            <span className="icono-panel icono-panel-derecho" aria-hidden="true" />
            Propiedades
          </button>
        </div>

        <div className="separa" />
        <SoftwareGuide
          topic={
            herramienta === 'generar'
              ? 'generation'
              : herramienta === 'importar'
                ? 'import'
                : 'diagram'
          }
        />
        <ThemeSelect />

        <div className="estado-barra" role="status" aria-live="polite">
          <span className={`conexion ${documento.status}`} data-testid="estado-conexion">
            {ESTADO_CONEXION[documento.status]}
          </span>
          {shellReady && documento.offlineReady && !offline && (
            <span className="conexion" data-testid="offline-disponible">
              Disponible sin conexión
            </span>
          )}

          {auditoriasPendientes > 0 && (
            <span
              className="conexion desconectado"
              data-testid="auditoria-pendiente"
              title="Se volverá a intentar automáticamente al recuperar la conexión"
            >
              {auditoriasPendientes} cambio{auditoriasPendientes === 1 ? '' : 's'} por auditar
            </span>
          )}

          {!canWrite && (
            <span
              className="solo-lectura"
              data-testid="solo-lectura"
              title="Puedes ver y descargar, no editar"
            >
              Solo lectura
            </span>
          )}
        </div>

        <ul
          className="presencia"
          data-testid="presencia"
          aria-label={`${documento.participants.length} participante(s) en esta pizarra`}
        >
          {documento.participants.map((participante) => (
            <li
              key={participante.clientId}
              style={{ background: participante.color }}
              title={
                participante.editing === null
                  ? participante.displayName
                  : `${participante.displayName} está editando`
              }
            >
              <span aria-hidden="true">{participante.displayName.slice(0, 2).toUpperCase()}</span>
              <span className="visualmente-oculto">{participante.displayName}</span>
            </li>
          ))}
        </ul>

        {/* Cerrar sesion desde el editor: es donde se pasa el tiempo, y tener
            que volver a la lista de proyectos para salir invita a dejar la
            sesion abierta en una maquina compartida. */}
        <button type="button" className="salir" data-testid="salir" onClick={() => void logout()}>
          Salir
        </button>
      </header>

      {documento.status === 'rechazado' && (
        <p className="error banda">
          El servidor rechazó la conexión: {documento.rejection ?? 'sin motivo'}
        </p>
      )}
      {offline && (
        <p className="advertencia banda" role="status" data-testid="modo-offline">
          Estás trabajando con una copia local. Al volver la conexión se comprobarán tus permisos y
          se sincronizarán los cambios. El asistente y la generación requieren conexión.{' '}
          <Link to="/sin-conexion">Ver pizarras guardadas</Link>
        </p>
      )}
      {rechazo !== null && (
        <p className="error banda" data-testid="lote-rechazado">
          {rechazo}
        </p>
      )}
      {documento.accessNotice !== null && (
        <p className="advertencia banda" role="status" data-testid="aviso-permisos">
          {documento.accessNotice}
        </p>
      )}

      <div
        className={`lienzo${toolboxVisible ? '' : ' sin-toolbox'}${panelVisible ? '' : ' sin-panel'}`}
      >
        <div hidden={!toolboxVisible} className="contenedor-toolbox">
          <EditorToolbox
            activeTool={activeTool}
            relationshipSourceName={
              documento.state.semantic.classes.find((item) => item.id === relationshipSourceId)
                ?.displayName ?? null
            }
            canWrite={canWrite}
            onToolChange={chooseTool}
          />
        </div>

        <ReactFlowProvider>
          <BoardCanvas
            state={documento.state}
            issues={documento.issues}
            participants={documento.participants}
            selectedId={selectedId}
            revealClassId={classToRevealId}
            activeTool={activeTool}
            relationshipSourceId={relationshipSourceId}
            canWrite={canWrite}
            onSelect={setSelectedId}
            onClassClick={selectClassForTool}
            onCancelTool={() => chooseTool('SELECT')}
            onCreateClass={createClassAt}
            onMove={(classId, position, size) => run(gui.moveClass(classId, position, size))}
            onConnect={(origen, destino) =>
              createRelationship(
                origen,
                destino,
                isRelationshipTool(activeTool) ? relationshipKindFor(activeTool) : 'ASSOCIATION',
              )
            }
          />
        </ReactFlowProvider>

        <div id="panel-editor" className="paneles" hidden={!panelVisible}>
          <div className="pestanas-panel" role="tablist" aria-label="Herramientas auxiliares">
            {HERRAMIENTAS.map(([clave, etiqueta], indice) => (
              <button
                key={clave}
                id={`pestana-${clave}`}
                type="button"
                role="tab"
                aria-selected={herramienta === clave}
                aria-controls={`panel-${clave}`}
                tabIndex={herramienta === clave ? 0 : -1}
                className={herramienta === clave ? 'activa' : undefined}
                data-testid={`pestana-${clave}`}
                onClick={() => setHerramienta(clave)}
                onKeyDown={(event) => {
                  if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return;
                  event.preventDefault();
                  const ultimo = HERRAMIENTAS.length - 1;
                  const destino =
                    event.key === 'Home'
                      ? 0
                      : event.key === 'End'
                        ? ultimo
                        : event.key === 'ArrowRight'
                          ? (indice + 1) % HERRAMIENTAS.length
                          : (indice - 1 + HERRAMIENTAS.length) % HERRAMIENTAS.length;
                  const siguiente = HERRAMIENTAS[destino]?.[0];
                  if (siguiente === undefined) return;
                  setHerramienta(siguiente);
                  document.getElementById(`pestana-${siguiente}`)?.focus();
                }}
              >
                {etiqueta}
              </button>
            ))}
          </div>

          {/* Se ocultan con `hidden` en lugar de desmontarse: el asistente
              guarda la conversacion y la importacion el candidato en curso, y
              cambiar de pestana no puede tirarlos. */}
          <div className="herramienta">
            <div
              id="panel-asistente"
              role="tabpanel"
              aria-labelledby="pestana-asistente"
              hidden={herramienta !== 'asistente'}
            >
              <AssistantPanel
                boardId={board.id}
                state={documento.state}
                canWrite={canWrite}
                apply={documento.dispatch}
              />
            </div>
            <div
              id="panel-importar"
              role="tabpanel"
              aria-labelledby="pestana-importar"
              hidden={herramienta !== 'importar'}
            >
              <ImportPanel
                boardId={board.id}
                boardName={board.displayName}
                state={documento.state}
                canWrite={canWrite}
                apply={documento.dispatch}
              />
            </div>
            <div
              id="panel-generar"
              role="tabpanel"
              aria-labelledby="pestana-generar"
              hidden={herramienta !== 'generar'}
            >
              <GenerationPanel boardId={board.id} issues={documento.issues} canWrite={canWrite} />
            </div>
          </div>

          <Inspector
            state={documento.state}
            selectedId={selectedId}
            canWrite={canWrite}
            run={run}
            onSelect={setSelectedId}
          />
          <ValidationPanel issues={documento.issues} onSelect={setSelectedId} />
        </div>
      </div>

      <footer className="barra-estado">
        <span className="dato">{documento.state.semantic.classes.length} clases</span>
        <span className="dato">{documento.state.semantic.relationships.length} relaciones</span>

        <span className="separa" />

        {/* El mismo criterio que el panel de validacion, en el sitio donde se
            mira sin pensar: los errores bloquean generar, no editar. */}
        <span
          className={`dato ${hasErrors(documento.issues) ? 'bloqueado' : 'listo'}`}
          data-testid="puede-generar"
        >
          {hasErrors(documento.issues) ? 'Generación bloqueada' : 'Generación disponible'}
        </span>
      </footer>
    </div>
  );
}
```

---

### `frontend/src/features/editor/ClassNode.tsx`

```tsx
import {
  MIN_CLASS_HEIGHT,
  MIN_CLASS_WIDTH,
  type UmlAttribute,
  type UmlClass,
} from '@uml/contracts';
import {
  Handle,
  NodeResizer,
  Position,
  useUpdateNodeInternals,
  type NodeProps,
  type Node,
} from '@xyflow/react';
import { useEffect } from 'react';

export interface ClassNodeData extends Record<string, unknown> {
  readonly umlClass: UmlClass;
  /** Quien no puede escribir tampoco redimensiona. */
  readonly canWrite: boolean;
  /** Clave primaria resuelta, para marcarla aunque no este declarada. */
  readonly primaryKeyId: string | null;
  readonly hasError: boolean;
  readonly hasWarning: boolean;
  /** Primera clase elegida al construir una relacion desde el toolbox. */
  readonly isRelationshipSource: boolean;
  /** Quien la esta editando ahora mismo, si alguien. */
  readonly editedBy: { displayName: string; color: string } | null;
}

export type ClassNodeType = Node<ClassNodeData, 'umlClass'>;

/**
 * Tarjeta de una clase.
 *
 * Muestra los tres nombres de forma escalonada: el visual grande, y el tecnico
 * debajo solo cuando difiere. Asi el usuario ve como va a quedar la tabla sin
 * tener que abrir nada, que es donde se detectan las colisiones a simple vista.
 */
export function ClassNode({
  id,
  data,
  selected,
  width,
  height,
}: NodeProps<ClassNodeType>): React.JSX.Element {
  const updateNodeInternals = useUpdateNodeInternals();
  useEffect(() => {
    // El lienzo reconstruye los nodos desde Yjs sin conservar `measured`.
    // React Flow invalida entonces sus conectores, incluso cuando solo cambia
    // la presencia. Medimos despues de montar/actualizar esta tarjeta: hacerlo
    // solo al cambiar los extremos dejaba relaciones remotas sin dibujar.
    // La seleccion tambien mueve el conector rapido mediante CSS.
    updateNodeInternals(id);
  }, [id, data, selected, width, height, updateNodeInternals]);

  const { umlClass, primaryKeyId, hasError, hasWarning, isRelationshipSource, editedBy, canWrite } =
    data;
  const tecnicoDistinto = umlClass.codeName !== umlClass.displayName;

  const clases = [
    'nodo-clase',
    selected === true ? 'seleccionado' : '',
    isRelationshipSource ? 'origen-relacion' : '',
    hasError ? 'con-error' : hasWarning ? 'con-aviso' : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <div
      className={clases}
      data-testid={`clase-${umlClass.codeName}`}
      style={editedBy === null ? undefined : { outline: `2px solid ${editedBy.color}` }}
    >
      {/* Los tiradores solo aparecen con la tarjeta seleccionada: visibles
          siempre, cuatro esquinas por clase convierten el diagrama en un
          erizo. El minimo evita encoger hasta perder el nombre de vista. */}
      <NodeResizer
        color="var(--clase-seleccion)"
        isVisible={selected === true && canWrite}
        minWidth={MIN_CLASS_WIDTH}
        minHeight={MIN_CLASS_HEIGHT}
        lineClassName="borde-redimension"
        handleClassName="tirador-redimension"
      />

      {/* En modo Loose un conector source tambien puede recibir relaciones,
          pero el extremo de origen siempre debe resolver a un source. Por eso
          los cuatro lados son source: al mover y cruzar clases, la arista puede
          cambiar de lado sin quedarse sin un conector valido. */}
      <Handle type="source" position={Position.Top} id="t" />
      <Handle type="source" position={Position.Left} id="l" />
      <Handle
        type="source"
        position={Position.Right}
        id="r"
        className="conector-rapido"
        aria-label={`Crear asociación desde ${umlClass.displayName}`}
        title="Arrastra hacia otra clase para crear una asociación"
      />
      <Handle type="source" position={Position.Bottom} id="b" />
      {/* Dos anclajes inferiores separados forman el bucle de una asociacion
          recursiva. En modo Loose pueden actuar como ambos extremos. */}
      <Handle
        type="source"
        position={Position.Bottom}
        id="b-loop-source"
        className="conector-bucle conector-bucle-origen"
        aria-label={`Iniciar asociación recursiva desde ${umlClass.displayName}`}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        id="b-loop-target"
        className="conector-bucle conector-bucle-destino"
        aria-label={`Completar asociación recursiva en ${umlClass.displayName}`}
      />

      {/* Compartimento del nombre. En UML va centrado y en negrita, y es lo
          unico que lleva la caja cuando la clase no tiene atributos. */}
      <header>
        <span className="nombre">{umlClass.displayName}</span>
        {tecnicoDistinto && <span className="tecnico">{umlClass.databaseName}</span>}
        {editedBy !== null && (
          <span className="editando" style={{ background: editedBy.color }}>
            {editedBy.displayName}
          </span>
        )}
      </header>

      <ul className="atributos">
        {umlClass.attributes.length === 0 && <li className="vacio">sin atributos</li>}
        {umlClass.attributes.map((atributo) => (
          <AttributeRow
            key={atributo.id}
            attribute={atributo}
            isPrimaryKey={atributo.id === primaryKeyId}
          />
        ))}
      </ul>
    </div>
  );
}

function AttributeRow({
  attribute,
  isPrimaryKey,
}: {
  attribute: UmlAttribute;
  isPrimaryKey: boolean;
}): React.JSX.Element {
  // Notacion UML: `- nombre: Tipo`. El guion es la visibilidad privada, que es
  // lo que corresponde a un atributo de una entidad de datos.
  return (
    <li>
      <span className="visibilidad" aria-hidden="true">
        -
      </span>
      <span className="campo">
        {attribute.displayName}
        <span className="separador">: </span>
        <span className="tipo">{attribute.type}</span>
        {!attribute.nullable && !isPrimaryKey && (
          <abbr className="obligatorio" title="obligatorio">
            {' '}
            *
          </abbr>
        )}
      </span>
      <span className="marcas">
        {isPrimaryKey && (
          <abbr className="pk" title="clave primaria">
            PK
          </abbr>
        )}
        {attribute.unique && !isPrimaryKey && (
          <abbr className="uq" title="unico">
            U
          </abbr>
        )}
      </span>
    </li>
  );
}
```

---

### `frontend/src/features/editor/EditorToolbox.tsx`

```tsx
import { useMemo, useState } from 'react';
import { RELATIONSHIP_TOOLS, type EditorTool } from './editor-tools.js';

export interface EditorToolboxProps {
  readonly activeTool: EditorTool;
  readonly relationshipSourceName: string | null;
  readonly canWrite: boolean;
  onToolChange(tool: EditorTool): void;
}

/**
 * Caja de herramientas deliberadamente corta: solo contiene lo que el examen
 * puede convertir a PostgreSQL y Spring Boot. Funciona como una paleta UML de
 * escritorio, pero evita mostrar elementos que el proyecto no soporta.
 */
export function EditorToolbox(props: EditorToolboxProps): React.JSX.Element {
  const [query, setQuery] = useState('');
  const normalizedQuery = query.trim().toLocaleLowerCase('es');
  const visibleRelationships = useMemo(
    () =>
      RELATIONSHIP_TOOLS.filter((item) =>
        `${item.label} ${item.description}`.toLocaleLowerCase('es').includes(normalizedQuery),
      ),
    [normalizedQuery],
  );
  const showSelect = 'seleccionar mover'.includes(normalizedQuery);
  const showClass = 'clase entidad tabla'.includes(normalizedQuery);

  const status = toolStatus(props.activeTool, props.relationshipSourceName);

  return (
    <aside id="editor-toolbox" className="toolbox" aria-label="Caja de herramientas UML">
      <header className="toolbox-header">
        <div>
          <span className="toolbox-eyebrow">Diagrama de clases</span>
          <h2>Toolbox</h2>
        </div>
        <span className="toolbox-badge">UML</span>
      </header>

      <label className="toolbox-search">
        <span className="visualmente-oculto">Buscar herramienta</span>
        <ToolIcon kind="SEARCH" />
        <input
          type="search"
          value={query}
          placeholder="Buscar herramienta"
          onChange={(event) => setQuery(event.target.value)}
        />
      </label>

      <div className="toolbox-scroll">
        {(showSelect || showClass) && (
          <ToolSection title="Elementos">
            {showSelect && (
              <ToolButton
                tool="SELECT"
                activeTool={props.activeTool}
                label="Seleccionar"
                description="Mover, editar y conectar"
                shortcut="V"
                disabled={false}
                onSelect={props.onToolChange}
              />
            )}
            {showClass && (
              <ToolButton
                tool="CLASS"
                activeTool={props.activeTool}
                label="Clase"
                description="Crear una entidad en la pizarra"
                shortcut="C"
                disabled={!props.canWrite}
                onSelect={props.onToolChange}
              />
            )}
          </ToolSection>
        )}

        {visibleRelationships.length > 0 && (
          <ToolSection title="Relaciones">
            {visibleRelationships.map((item) => (
              <ToolButton
                key={item.tool}
                tool={item.tool}
                activeTool={props.activeTool}
                label={item.label}
                description={item.description}
                shortcut={item.shortcut}
                disabled={!props.canWrite}
                onSelect={props.onToolChange}
              />
            ))}
          </ToolSection>
        )}

        {!showSelect && !showClass && visibleRelationships.length === 0 && (
          <p className="toolbox-empty">No hay herramientas que coincidan.</p>
        )}
      </div>

      <div className="toolbox-status" role="status" aria-live="polite">
        <span className="toolbox-status-icon" aria-hidden="true">
          {props.activeTool === 'SELECT' ? 'V' : props.activeTool === 'CLASS' ? 'C' : '↗'}
        </span>
        <span>{status}</span>
      </div>
    </aside>
  );
}

function ToolSection({
  title,
  children,
}: React.PropsWithChildren<{ title: string }>): React.JSX.Element {
  return (
    <section className="toolbox-section">
      <h3>{title}</h3>
      <div className="toolbox-items">{children}</div>
    </section>
  );
}

function ToolButton({
  tool,
  activeTool,
  label,
  description,
  shortcut,
  disabled,
  onSelect,
}: {
  readonly tool: EditorTool;
  readonly activeTool: EditorTool;
  readonly label: string;
  readonly description: string;
  readonly shortcut: string;
  readonly disabled: boolean;
  onSelect(tool: EditorTool): void;
}): React.JSX.Element {
  const active = tool === activeTool;

  return (
    <button
      type="button"
      className={`toolbox-item${active ? ' active' : ''}`}
      aria-pressed={active}
      disabled={disabled}
      data-testid={`tool-${tool.toLocaleLowerCase()}`}
      title={`${label} · ${description} (${shortcut})`}
      onClick={() => onSelect(tool)}
    >
      <span className="toolbox-item-icon">
        <ToolIcon kind={tool} />
      </span>
      <span className="toolbox-item-copy">
        <strong>{label}</strong>
        <small>{description}</small>
      </span>
      <kbd>{shortcut}</kbd>
    </button>
  );
}

function toolStatus(tool: EditorTool, sourceName: string | null): string {
  if (tool === 'SELECT')
    return 'Selecciona una clase para editarla o usa su flecha para relacionar.';
  if (tool === 'CLASS') return 'Haz clic en un punto libre de la pizarra para crear la clase.';
  if (sourceName === null) return 'Selecciona la clase de origen y después la clase de destino.';
  return `Origen: ${sourceName}. Ahora selecciona la clase de destino.`;
}

function ToolIcon({ kind }: { readonly kind: EditorTool | 'SEARCH' }): React.JSX.Element {
  if (kind === 'SEARCH') {
    return (
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <circle cx="10.5" cy="10.5" r="5.5" />
        <path d="m15 15 5 5" />
      </svg>
    );
  }

  if (kind === 'SELECT') {
    return (
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M6 3.5 18 12l-6.2 1.1L9 19Z" />
      </svg>
    );
  }

  if (kind === 'CLASS') {
    return (
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <rect x="3" y="4" width="18" height="16" rx="1" />
        <path d="M3 9h18M7 13h6M7 16.5h9" />
      </svg>
    );
  }

  const marker =
    kind === 'GENERALIZATION' ? (
      <path className="marker" d="m19 8 4 4-4 4Z" />
    ) : kind === 'COMPOSITION' ? (
      <path className="marker filled" d="m4 12 4-4 4 4-4 4Z" />
    ) : kind === 'AGGREGATION' ? (
      <path className="marker" d="m4 12 4-4 4 4-4 4Z" />
    ) : null;

  return (
    <svg viewBox="0 0 27 24" aria-hidden="true">
      <path d="M4 12h19" />
      {marker}
    </svg>
  );
}
```

---

### `frontend/src/features/editor/Inspector.tsx`

```tsx
import {
  CONCEPTUAL_TYPES,
  MULTIPLICITIES,
  RELATIONSHIP_KINDS,
  type BoardState,
  type ConceptualType,
  type Multiplicity,
  type RelationshipKind,
  type UmlClass,
  type UmlRelationship,
} from '@uml/contracts';
import { ancestorsOf, buildInheritanceGraph } from '@uml/domain-core';
import { useState } from 'react';
import { gui, newId, type CommandBody } from './commands.js';

export interface InspectorProps {
  readonly state: BoardState;
  readonly selectedId: string | null;
  readonly canWrite: boolean;
  run(...commands: readonly CommandBody[]): void;
  onSelect(elementId: string | null): void;
}

/**
 * Panel de edicion del elemento seleccionado.
 *
 * Cada control emite un comando. No hay estado intermedio "pendiente de
 * guardar": lo que se ve es lo que hay en el documento, y lo que se cambia viaja
 * a los demas en el momento.
 */
export function Inspector(props: InspectorProps): React.JSX.Element {
  const { state, selectedId } = props;

  if (selectedId === null) {
    return (
      <aside className="inspector">
        <InspectorHeader title="Propiedades" detail="Nada seleccionado" />
        <div className="inspector-vacio">
          <span aria-hidden="true">↖</span>
          <p>Selecciona una clase o una relación para editar sus propiedades.</p>
          <small>También puedes recorrer el diagrama con Tab y seleccionar con Enter.</small>
        </div>
      </aside>
    );
  }

  const umlClass = state.semantic.classes.find((item) => item.id === selectedId);
  if (umlClass !== undefined) return <ClassInspector {...props} umlClass={umlClass} />;

  const relacion = state.semantic.relationships.find((item) => item.id === selectedId);
  if (relacion !== undefined) return <RelationshipInspector {...props} relationship={relacion} />;

  return (
    <aside className="inspector">
      <InspectorHeader title="Propiedades" detail="Elemento eliminado" />
      <p className="pista">Ese elemento ya no existe.</p>
    </aside>
  );
}

function ClassInspector({
  state,
  umlClass,
  canWrite,
  run,
  onSelect,
}: InspectorProps & { umlClass: UmlClass }): React.JSX.Element {
  const [nuevoAtributo, setNuevoAtributo] = useState('');

  return (
    <aside className="inspector" data-testid="inspector-clase">
      <InspectorHeader title="Propiedades" detail="Clase UML" />
      <label>
        <span>Nombre</span>
        <input
          value={umlClass.displayName}
          disabled={!canWrite}
          data-testid="nombre-clase"
          onChange={(evento) => run(gui.renameClass(umlClass.id, evento.target.value))}
        />
      </label>

      <p className="derivados" title="Nombres que se usarán al generar código y base de datos">
        <span>Código</span> <code>{umlClass.codeName}</code>
        <span aria-hidden="true">·</span>
        <span>Tabla</span> <code>{umlClass.databaseName}</code>
      </p>

      <Herencia state={state} umlClass={umlClass} onSelect={onSelect} />

      <h3>Atributos</h3>
      <ul className="lista-atributos">
        {umlClass.attributes.length === 0 && (
          <li className="atributos-vacios">Esta clase todavía no tiene atributos.</li>
        )}
        {umlClass.attributes.map((atributo) => (
          <li key={atributo.id}>
            <input
              aria-label={`Nombre del atributo ${atributo.displayName}`}
              value={atributo.displayName}
              disabled={!canWrite}
              onChange={(evento) =>
                run(
                  gui.updateAttribute(umlClass.id, atributo.id, {
                    displayName: evento.target.value,
                  }),
                )
              }
            />
            <select
              aria-label={`Tipo del atributo ${atributo.displayName}`}
              value={atributo.type}
              disabled={!canWrite}
              onChange={(evento) =>
                run(
                  gui.updateAttribute(umlClass.id, atributo.id, {
                    type: evento.target.value as ConceptualType,
                  }),
                )
              }
            >
              {CONCEPTUAL_TYPES.map((tipo) => (
                <option key={tipo} value={tipo}>
                  {tipo}
                </option>
              ))}
            </select>

            <span className="marcadores">
              <label title="Clave primaria">
                <input
                  type="checkbox"
                  aria-label={`${atributo.displayName}: clave primaria`}
                  checked={atributo.primaryKey}
                  disabled={!canWrite}
                  onChange={(evento) =>
                    run(
                      gui.updateAttribute(umlClass.id, atributo.id, {
                        primaryKey: evento.target.checked,
                      }),
                    )
                  }
                />
                Clave primaria
              </label>
              <label title="Requerido (no admite valores nulos)">
                <input
                  type="checkbox"
                  aria-label={`${atributo.displayName}: requerido`}
                  checked={!atributo.nullable}
                  disabled={!canWrite}
                  onChange={(evento) =>
                    run(
                      gui.updateAttribute(umlClass.id, atributo.id, {
                        nullable: !evento.target.checked,
                      }),
                    )
                  }
                />
                Requerido
              </label>
              <label title="Valor único">
                <input
                  type="checkbox"
                  aria-label={`${atributo.displayName}: valor único`}
                  checked={atributo.unique}
                  disabled={!canWrite}
                  onChange={(evento) =>
                    run(
                      gui.updateAttribute(umlClass.id, atributo.id, {
                        unique: evento.target.checked,
                      }),
                    )
                  }
                />
                Único
              </label>
            </span>

            <button
              type="button"
              className="quitar"
              disabled={!canWrite}
              aria-label={`Eliminar ${atributo.displayName}`}
              onClick={() => run(gui.deleteAttribute(umlClass.id, atributo.id))}
            >
              ×
            </button>
          </li>
        ))}
      </ul>

      <form
        className="nuevo-atributo"
        onSubmit={(evento) => {
          evento.preventDefault();
          const nombre = nuevoAtributo.trim();
          if (nombre === '') return;

          run(gui.addAttribute(umlClass.id, newId(), nombre, 'String'));
          setNuevoAtributo('');
        }}
      >
        <input
          aria-label="Nombre del nuevo atributo"
          placeholder="Nuevo atributo"
          value={nuevoAtributo}
          disabled={!canWrite}
          data-testid="nuevo-atributo"
          onChange={(evento) => setNuevoAtributo(evento.target.value)}
        />
        <button type="submit" disabled={!canWrite}>
          Añadir
        </button>
      </form>

      <button
        type="button"
        className="peligro"
        disabled={!canWrite}
        onClick={() => {
          run(gui.deleteClass(umlClass.id));
          onSelect(null);
        }}
      >
        Eliminar clase
      </button>
    </aside>
  );
}

/**
 * Lo que la clase recibe por herencia, y de quien.
 *
 * La lista de atributos de esta clase muestra solo los suyos, como en cualquier
 * herramienta UML. Pero desde que la generalizacion se genera de verdad
 * (RM-07), lo heredado aparece en la tabla, en el DTO y en la ruta REST de esta
 * clase, y la clave primaria ni siquiera esta aqui: viene de la raiz. Sin este
 * resumen, la unica forma de saberlo es abrir el ZIP.
 *
 * Es solo lectura: un atributo heredado se edita donde se declaro, y el enlace
 * lleva justo ahi.
 */
function Herencia({
  state,
  umlClass,
  onSelect,
}: {
  readonly state: BoardState;
  readonly umlClass: UmlClass;
  onSelect(elementId: string | null): void;
}): React.JSX.Element | null {
  const grafo = buildInheritanceGraph(state.semantic);
  const ancestros = ancestorsOf(grafo, umlClass.id);
  const subclases = grafo.subclassesById.get(umlClass.id) ?? [];
  if (ancestros.length === 0 && subclases.length === 0) return null;

  const clase = (classId: string): UmlClass | undefined =>
    state.semantic.classes.find((item) => item.id === classId);

  const superclase = clase(ancestros[0] as string);
  const raiz = clase(ancestros[ancestros.length - 1] as string);
  // De la raiz hacia abajo, que es el orden en que se emiten.
  const heredados = [...ancestros].reverse().flatMap((id) => clase(id)?.attributes ?? []);

  return (
    <div className="herencia" data-testid="herencia-clase">
      {superclase !== undefined && (
        <p>
          Hereda de{' '}
          <button type="button" className="enlace-clase" onClick={() => onSelect(superclase.id)}>
            {superclase.displayName}
          </button>
          {raiz !== undefined && raiz.id !== superclase.id && <> · raíz {raiz.displayName}</>}
        </p>
      )}

      {heredados.length > 0 && (
        <ul className="atributos-heredados">
          {heredados.map((atributo) => (
            <li key={atributo.id}>
              {atributo.displayName}
              <span aria-hidden="true"> : </span>
              <span className="tipo">{atributo.type}</span>
              {atributo.primaryKey && <span className="marca-clave"> clave</span>}
            </li>
          ))}
        </ul>
      )}

      {subclases.length > 0 && (
        <p>
          Subclases:{' '}
          {subclases.map((id, indice) => {
            const subclase = clase(id);
            if (subclase === undefined) return null;
            return (
              <span key={id}>
                {indice > 0 && ', '}
                <button
                  type="button"
                  className="enlace-clase"
                  onClick={() => onSelect(subclase.id)}
                >
                  {subclase.displayName}
                </button>
              </span>
            );
          })}
        </p>
      )}
    </div>
  );
}

function RelationshipInspector({
  state,
  relationship,
  canWrite,
  run,
  onSelect,
}: InspectorProps & { relationship: UmlRelationship }): React.JSX.Element {
  const nombre = (classId: string): string =>
    state.semantic.classes.find((item) => item.id === classId)?.displayName ?? '?';
  const relationshipKind = relationship.kind ?? 'ASSOCIATION';
  const esRecursiva = relationship.sourceClassId === relationship.targetClassId;

  return (
    <aside className="inspector" data-testid="inspector-relacion">
      <InspectorHeader title="Propiedades" detail="Relación UML" />
      <p className="derivados">
        {nombre(relationship.sourceClassId)} → {nombre(relationship.targetClassId)}
      </p>

      <label>
        <span>Tipo UML</span>
        <select
          value={relationshipKind}
          disabled={!canWrite}
          data-testid="tipo-relacion"
          onChange={(evento) =>
            run(
              gui.updateRelationship(relationship.id, {
                kind: evento.target.value as RelationshipKind,
              }),
            )
          }
        >
          {RELATIONSHIP_KINDS.map((kind) => (
            <option key={kind} value={kind}>
              {RELATIONSHIP_LABELS[kind]}
            </option>
          ))}
        </select>
      </label>

      <p className="pista-relacion">{RELATIONSHIP_HELP[relationshipKind]}</p>

      {relationshipKind !== 'GENERALIZATION' && (
        <>
          <h3>Extremos</h3>
          <div className="extremos-relacion">
            <fieldset>
              <legend>
                {nombre(relationship.sourceClassId)}
                {esRecursiva && ' · origen'}
              </legend>
              <label>
                <span>Multiplicidad</span>
                <select
                  value={relationship.sourceMultiplicity}
                  disabled={!canWrite}
                  data-testid="multiplicidad-origen"
                  onChange={(evento) =>
                    run(
                      gui.changeMultiplicity(relationship.id, evento.target.value as Multiplicity),
                    )
                  }
                >
                  {MULTIPLICITIES.map((valor) => (
                    <option key={valor} value={valor}>
                      {valor}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                <span>Nombre del rol</span>
                <input
                  value={relationship.sourceRoleName ?? ''}
                  disabled={!canWrite}
                  data-testid="rol-origen"
                  placeholder="Sin rol"
                  onChange={(evento) =>
                    run(
                      gui.updateRelationship(relationship.id, {
                        sourceRoleName:
                          evento.target.value.trim() === '' ? null : evento.target.value,
                      }),
                    )
                  }
                />
              </label>
            </fieldset>

            <fieldset>
              <legend>
                {nombre(relationship.targetClassId)}
                {esRecursiva && ' · destino'}
              </legend>
              <label>
                <span>Multiplicidad</span>
                <select
                  value={relationship.targetMultiplicity}
                  disabled={!canWrite}
                  data-testid="multiplicidad-destino"
                  onChange={(evento) =>
                    run(
                      gui.changeMultiplicity(
                        relationship.id,
                        undefined,
                        evento.target.value as Multiplicity,
                      ),
                    )
                  }
                >
                  {MULTIPLICITIES.map((valor) => (
                    <option key={valor} value={valor}>
                      {valor}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                <span>Nombre del rol</span>
                <input
                  value={relationship.targetRoleName ?? ''}
                  disabled={!canWrite}
                  data-testid="rol-destino"
                  placeholder="Sin rol"
                  onChange={(evento) =>
                    run(
                      gui.updateRelationship(relationship.id, {
                        targetRoleName:
                          evento.target.value.trim() === '' ? null : evento.target.value,
                      }),
                    )
                  }
                />
              </label>
            </fieldset>
          </div>
        </>
      )}

      <button
        type="button"
        className="peligro"
        disabled={!canWrite}
        onClick={() => {
          run(gui.deleteRelationship(relationship.id));
          onSelect(null);
        }}
      >
        Eliminar relación
      </button>
    </aside>
  );
}

function InspectorHeader({
  title,
  detail,
}: {
  readonly title: string;
  readonly detail: string;
}): React.JSX.Element {
  return (
    <header className="inspector-header">
      <h2>{title}</h2>
      <span>{detail}</span>
    </header>
  );
}

const RELATIONSHIP_LABELS: Readonly<Record<RelationshipKind, string>> = {
  ASSOCIATION: 'Asociación',
  GENERALIZATION: 'Generalización',
  COMPOSITION: 'Composición',
  AGGREGATION: 'Agregación',
};

const RELATIONSHIP_HELP: Readonly<Record<RelationshipKind, string>> = {
  ASSOCIATION: 'Vínculo estructural entre dos clases.',
  GENERALIZATION: 'El origen es la subclase y el destino la superclase.',
  COMPOSITION: 'El origen representa el todo y controla el ciclo de vida de la parte.',
  AGGREGATION: 'El origen representa el todo; la parte puede existir por separado.',
};
```

---

### `frontend/src/features/editor/OfflineBoardsPage.tsx`

```tsx
import { Link } from 'react-router';
import { AppBar } from '../../components/AppBar.js';
import { cachedBoards } from '../../lib/offline.js';
import { useSession } from '../auth/session.js';

export function OfflineBoardsPage(): React.JSX.Element {
  const { user, logout } = useSession();
  const boards = user === null ? [] : cachedBoards(user.id);
  return (
    <div className="marco">
      <AppBar displayName={user?.displayName} userId={user?.id} onLogout={() => void logout()} />
      <main className="pagina">
        <header className="encabezado-pagina">
          <div>
            <h1>Pizarras sin conexión</h1>
            <p className="subtitulo">
              Puedes abrir las pizarras guardadas en este navegador. Los cambios se sincronizarán
              cuando vuelvas a conectarte.
            </p>
          </div>
        </header>
        <ul className="rejilla-tarjetas" data-testid="pizarras-offline">
          {boards.map((board) => (
            <li key={board.id} className="estado-vacio-panel">
              <Link to={`/pizarras/${board.id}`}>{board.displayName}</Link>
              <p>{board.role === 'VIEWER' ? 'Solo lectura' : 'Edición local disponible'}</p>
            </li>
          ))}
        </ul>
        {boards.length === 0 && (
          <p>
            No hay pizarras guardadas para esta cuenta. Abre una pizarra con conexión para que esté
            disponible aquí.
          </p>
        )}
        <p>
          Crear proyectos, administrar miembros y usar el asistente o la generación requiere
          conexión.
        </p>
      </main>
    </div>
  );
}
```

---

### `frontend/src/features/editor/ValidationPanel.tsx`

```tsx
import { errorsOf, warningsOf, type ValidationIssue } from '@uml/contracts';

export interface ValidationPanelProps {
  readonly issues: readonly ValidationIssue[];
  onSelect(elementId: string): void;
}

/**
 * Errores y avisos del modelo (RF-017).
 *
 * Los errores bloquean la generacion; los avisos la permiten. La distincion se
 * ve en el panel para que nadie descubra en la defensa que la pizarra no se
 * podia generar.
 *
 * Cada hallazgo que corresponde a una construccion no soportada trae su
 * sugerencia: el validador dice como modelarlo, no solo que esta mal.
 */
export function ValidationPanel({ issues, onSelect }: ValidationPanelProps): React.JSX.Element {
  const errores = errorsOf(issues);
  const avisos = warningsOf(issues);

  return (
    <section className="validacion" data-testid="panel-validacion">
      <header>
        <strong className="validacion-titulo">Revisión del modelo</strong>
        <span className={errores.length > 0 ? 'contador error' : 'contador ok'}>
          {errores.length} {errores.length === 1 ? 'error' : 'errores'}
        </span>
        <span className="contador aviso">
          {avisos.length} {avisos.length === 1 ? 'aviso' : 'avisos'}
        </span>
        <span className={errores.length > 0 ? 'estado bloqueado' : 'estado listo'}>
          {errores.length > 0 ? 'No se puede generar' : 'Listo para generar'}
        </span>
      </header>

      {issues.length === 0 && <p className="pista">El modelo no tiene observaciones.</p>}

      <ul>
        {[...errores, ...avisos].map((hallazgo, indice) => (
          <li
            key={`${hallazgo.code}-${hallazgo.elementIds.join(',')}-${indice}`}
            className={hallazgo.severity === 'ERROR' ? 'error' : 'aviso'}
          >
            <button
              type="button"
              onClick={() => {
                const primero = hallazgo.elementIds[0];
                if (primero !== undefined) onSelect(primero);
              }}
            >
              <span className="mensaje">{hallazgo.message}</span>
              {hallazgo.suggestion !== undefined && (
                <span className="sugerencia">{hallazgo.suggestion}</span>
              )}
            </button>
          </li>
        ))}
      </ul>
    </section>
  );
}
```

---

### `frontend/src/features/editor/board-drafts.ts`

```ts
import type { CommandBatch } from '@uml/contracts';
import { applyBatchToDocument, readBoardState } from '@uml/yjs-adapter';
import * as Y from 'yjs';

/** A separate slot per mounted editor avoids overwriting another tab's offline work. */
export class BoardDrafts {
  private readonly prefix: string;
  private readonly key: string;
  private readonly snapshotKey: string;

  constructor(
    private readonly storage: Storage,
    userId: string,
    room: string,
  ) {
    this.prefix = `uml_board_draft_v1:${encodeURIComponent(userId)}:${encodeURIComponent(room)}:`;
    this.key = this.prefix + crypto.randomUUID();
    this.snapshotKey = `uml_board_snapshot_v1:${encodeURIComponent(userId)}:${encodeURIComponent(room)}`;
  }

  /**
   * Last authorized server state, also saved for readers and untouched boards.
   *
   * Throws when storage rejects the write: the caller shows the board as
   * available offline and must not claim that before the copy exists.
   */
  snapshot(doc: Y.Doc): void {
    this.storage.setItem(this.snapshotKey, encode(doc));
  }

  /** Offline replicas never go directly into a provider; reconnect starts clean. */
  openOffline(doc: Y.Doc, includeDrafts: boolean): boolean {
    const value = this.storage.getItem(this.snapshotKey);
    if (value === null) return false;
    const candidate = new Y.Doc();
    try {
      Y.applyUpdate(candidate, decode(value));
      const drafts = includeDrafts ? this.entries() : [];
      for (const [, draft] of drafts) Y.applyUpdate(candidate, decode(draft));
      readBoardState(candidate);
      Y.applyUpdate(doc, Y.encodeStateAsUpdate(candidate));
      // Abrir solo lee, incluso con borradores de varias pestañas. `restore`
      // unifica las ranuras al reconectar; hacerlo aquí duplicaría la instantánea
      // completa y consumiría cuota sin que el usuario haya editado nada.
      return true;
    } finally {
      candidate.destroy();
    }
  }

  /** On a live replica, call only after server write authorization and initial sync. */
  restore(doc: Y.Doc): boolean {
    const entries = this.entries();
    if (entries.length === 0) return false;
    const candidate = new Y.Doc();
    try {
      Y.applyUpdate(candidate, Y.encodeStateAsUpdate(doc));
      for (const [, value] of entries) {
        Y.applyUpdate(candidate, decode(value));
      }
      readBoardState(candidate);
      // Persist the merged copy before deleting old slots or modifying the editor.
      this.save(candidate, entries);
      Y.applyUpdate(doc, Y.encodeStateAsUpdate(candidate));
      return true;
    } finally {
      candidate.destroy();
    }
  }

  /** Commit to local storage before publishing: quota/privacy failures cannot lose a change. */
  apply(doc: Y.Doc, batch: CommandBatch): ReturnType<typeof applyBatchToDocument> {
    const candidate = new Y.Doc();
    try {
      Y.applyUpdate(candidate, Y.encodeStateAsUpdate(doc));
      const result = applyBatchToDocument(candidate, batch);
      if (!result.applied) return result;
      this.save(candidate, []);
      Y.applyUpdate(doc, Y.encodeStateAsUpdate(candidate));
      return result;
    } finally {
      candidate.destroy();
    }
  }

  private entries(): [string, string][] {
    const entries: [string, string][] = [];
    for (let i = 0; i < this.storage.length; i += 1) {
      const key = this.storage.key(i);
      if (key?.startsWith(this.prefix)) {
        const value = this.storage.getItem(key);
        if (value !== null) entries.push([key, value]);
      }
    }
    return entries;
  }

  private save(doc: Y.Doc, previous: [string, string][]): void {
    this.storage.setItem(this.key, encode(doc));
    for (const [key, value] of previous) {
      // Another tab may have updated its slot since we read it.
      if (key !== this.key && this.storage.getItem(key) === value) this.storage.removeItem(key);
    }
  }
}

function encode(doc: Y.Doc): string {
  const bytes = Y.encodeStateAsUpdate(doc);
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function decode(value: string): Uint8Array {
  return Uint8Array.from(atob(value), (char) => char.charCodeAt(0));
}
```

---

### `frontend/src/features/editor/commands.ts`

```ts
import type {
  Command,
  CommandBatch,
  ConceptualType,
  Multiplicity,
  Position,
  RelationshipKind,
  Size,
} from '@uml/contracts';

/**
 * Fabrica de lotes desde la interfaz grafica.
 *
 * Todo lo que hace el usuario en el lienzo pasa por aqui y sale como comandos
 * del vocabulario cerrado. La interfaz no escribe el documento directamente:
 * es un adaptador mas, exactamente igual que el asistente o la importacion
 * (RA-01).
 */

export type CommandBody = Pick<Command, 'type' | 'payload'>;

export function newId(): string {
  return crypto.randomUUID();
}

export function makeBatch(actorId: string, ...commands: readonly CommandBody[]): CommandBatch {
  const issuedAt = new Date().toISOString();

  return {
    batchId: newId(),
    origin: 'GUI',
    actorId,
    issuedAt,
    commands: commands.map(
      (body) => ({ ...body, commandId: newId(), origin: 'GUI', actorId, issuedAt }) as Command,
    ),
  };
}

export const gui = {
  createClass: (classId: string, displayName: string, position: Position): CommandBody => ({
    type: 'CREATE_CLASS',
    payload: { classId, displayName, position },
  }),

  renameClass: (classId: string, displayName: string): CommandBody => ({
    type: 'RENAME_CLASS',
    payload: { classId, displayName },
  }),

  deleteClass: (classId: string): CommandBody => ({ type: 'DELETE_CLASS', payload: { classId } }),

  /**
   * Coloca una clase, y opcionalmente le fija el tamano.
   *
   * Sin `size` el tamano que hubiera se conserva: arrastrar no puede deshacer
   * un ajuste manual de ancho.
   */
  moveClass: (classId: string, position: Position, size?: Size): CommandBody => ({
    type: 'MOVE_CLASS',
    payload: { classId, position, ...(size === undefined ? {} : { size }) },
  }),

  addAttribute: (
    classId: string,
    attributeId: string,
    displayName: string,
    type: ConceptualType,
  ): CommandBody => ({
    type: 'ADD_ATTRIBUTE',
    payload: { classId, attributeId, displayName, type },
  }),

  updateAttribute: (
    classId: string,
    attributeId: string,
    cambios: {
      displayName?: string;
      type?: ConceptualType;
      primaryKey?: boolean;
      nullable?: boolean;
      unique?: boolean;
    },
  ): CommandBody => ({
    type: 'UPDATE_ATTRIBUTE',
    payload: { classId, attributeId, ...cambios },
  }),

  deleteAttribute: (classId: string, attributeId: string): CommandBody => ({
    type: 'DELETE_ATTRIBUTE',
    payload: { classId, attributeId },
  }),

  createRelationship: (
    relationshipId: string,
    sourceClassId: string,
    targetClassId: string,
    kind: RelationshipKind = 'ASSOCIATION',
    sourceMultiplicity?: Multiplicity,
    targetMultiplicity?: Multiplicity,
  ): CommandBody => {
    const defaults =
      kind === 'GENERALIZATION'
        ? ({ source: '1', target: '1' } as const)
        : ({ source: '1', target: '0..*' } as const);

    return {
      type: 'CREATE_RELATIONSHIP',
      payload: {
        relationshipId,
        kind,
        sourceClassId,
        targetClassId,
        sourceMultiplicity: sourceMultiplicity ?? defaults.source,
        targetMultiplicity: targetMultiplicity ?? defaults.target,
      },
    };
  },

  updateRelationship: (
    relationshipId: string,
    changes: {
      kind?: RelationshipKind;
      sourceRoleName?: string | null;
      targetRoleName?: string | null;
    },
  ): CommandBody => ({
    type: 'UPDATE_RELATIONSHIP',
    payload: { relationshipId, ...changes },
  }),

  changeMultiplicity: (
    relationshipId: string,
    sourceMultiplicity?: Multiplicity,
    targetMultiplicity?: Multiplicity,
  ): CommandBody => ({
    type: 'CHANGE_MULTIPLICITY',
    payload: {
      relationshipId,
      ...(sourceMultiplicity === undefined ? {} : { sourceMultiplicity }),
      ...(targetMultiplicity === undefined ? {} : { targetMultiplicity }),
    },
  }),

  deleteRelationship: (relationshipId: string): CommandBody => ({
    type: 'DELETE_RELATIONSHIP',
    payload: { relationshipId },
  }),
};
```

---

### `frontend/src/features/editor/editor-tools.ts`

```ts
import type { RelationshipKind } from '@uml/contracts';

export type EditorTool =
  'SELECT' | 'CLASS' | 'ASSOCIATION' | 'GENERALIZATION' | 'COMPOSITION' | 'AGGREGATION';

export interface RelationshipToolDefinition {
  readonly tool: Exclude<EditorTool, 'SELECT' | 'CLASS'>;
  readonly kind: RelationshipKind;
  readonly label: string;
  readonly description: string;
  readonly shortcut: string;
}

export const RELATIONSHIP_TOOLS: readonly RelationshipToolDefinition[] = [
  {
    tool: 'ASSOCIATION',
    kind: 'ASSOCIATION',
    label: 'Asociación',
    description: 'Vínculo estructural con multiplicidades',
    shortcut: '1',
  },
  {
    tool: 'GENERALIZATION',
    kind: 'GENERALIZATION',
    label: 'Generalización',
    description: 'Herencia: subclase hacia superclase',
    shortcut: '2',
  },
  {
    tool: 'COMPOSITION',
    kind: 'COMPOSITION',
    label: 'Composición',
    description: 'El origen controla el ciclo de vida',
    shortcut: '3',
  },
  {
    tool: 'AGGREGATION',
    kind: 'AGGREGATION',
    label: 'Agregación',
    description: 'Relación todo-parte independiente',
    shortcut: '4',
  },
];

export function isRelationshipTool(tool: EditorTool): tool is RelationshipToolDefinition['tool'] {
  return tool !== 'SELECT' && tool !== 'CLASS';
}

export function relationshipKindFor(tool: RelationshipToolDefinition['tool']): RelationshipKind {
  return tool;
}

export function toolLabel(tool: EditorTool): string {
  if (tool === 'SELECT') return 'Seleccionar';
  if (tool === 'CLASS') return 'Clase';
  return RELATIONSHIP_TOOLS.find((item) => item.tool === tool)?.label ?? tool;
}
```

---

### `frontend/src/features/editor/export-image.ts`

```ts
/** Captures the complete rendered diagram without changing the user's camera. */
export async function exportDiagramPng(): Promise<Blob> {
  const viewport = document.querySelector<HTMLElement>(
    '[data-testid="pizarra-diagrama"] .react-flow__viewport',
  );
  if (viewport === null || viewport.querySelector('.react-flow__node') === null) {
    throw new Error('Añade al menos una clase antes de exportar la imagen.');
  }

  await document.fonts.ready;
  const { toBlob } = await import('html-to-image');
  // SVG bounds include labels, markers, parallel relations and recursive loops.
  // React Flow renders offscreen nodes too (onlyRenderVisibleElements is false).
  const rectangles = Array.from(
    viewport.querySelectorAll('.react-flow__node, .react-flow__edge'),
    (element) => element.getBoundingClientRect(),
  );
  const origin = viewport.getBoundingClientRect();
  const zoom = new DOMMatrixReadOnly(getComputedStyle(viewport).transform).a;
  if (!Number.isFinite(zoom) || zoom <= 0) {
    throw new Error('El diagrama todavía no está listo. Intenta exportarlo de nuevo.');
  }
  const left = Math.min(...rectangles.map((rect) => rect.left));
  const top = Math.min(...rectangles.map((rect) => rect.top));
  const right = Math.max(...rectangles.map((rect) => rect.right));
  const bottom = Math.max(...rectangles.map((rect) => rect.bottom));
  const padding = 32;
  const width = Math.ceil((right - left) / zoom + padding * 2);
  const height = Math.ceil((bottom - top) / zoom + padding * 2);
  // Bound both canvas dimensions and memory for very large boards.
  const pixelRatio = Math.min(
    2,
    8192 / width,
    8192 / height,
    Math.sqrt(16_000_000 / (width * height)),
  );
  if (pixelRatio < 0.25) {
    throw new Error(
      'El diagrama es demasiado grande para una imagen legible. Acerca las clases e inténtalo de nuevo.',
    );
  }
  const backgroundColor =
    getComputedStyle(viewport.closest('.react-flow') ?? viewport)
      .getPropertyValue('--diagrama-fondo')
      .trim() || '#ffffff';
  const blob = await toBlob(viewport, {
    width,
    height,
    pixelRatio,
    backgroundColor,
    // The application uses system fonts; avoid traversing external stylesheets.
    skipFonts: true,
    filter: (node) =>
      !(
        node instanceof Element &&
        node.matches(
          '.react-flow__handle, .react-flow__resize-control, .editando, .asociacion-zona',
        )
      ),
    style: {
      width: `${width}px`,
      height: `${height}px`,
      transformOrigin: '0 0',
      transform: `translate(${padding - (left - origin.left) / zoom}px, ${padding - (top - origin.top) / zoom}px) scale(1)`,
    },
  });
  if (blob === null) throw new Error('No se pudo crear la imagen. Inténtalo de nuevo.');
  return blob;
}
```

---

### `frontend/src/features/editor/useBoardDocument.ts`

```ts
import { HocuspocusProvider } from '@hocuspocus/provider';
import {
  emptyBoardState,
  type BoardState,
  type CommandBatch,
  type SemanticModel,
  type ValidationIssue,
} from '@uml/contracts';
import { validateModel, validateProposalPreconditions } from '@uml/domain-core';
import { readBoardState } from '@uml/yjs-adapter';
import { useEffect, useMemo, useRef, useState } from 'react';
import * as Y from 'yjs';
import {
  api,
  currentAccessToken,
  refreshSession,
  sessionRefreshUnavailable,
} from '../../lib/api.js';
import { useSession } from '../auth/session.js';
import { BoardDrafts } from './board-drafts.js';
import {
  downgradeBoard,
  forgetBoard,
  rememberBoard,
  type OfflineBoard,
} from '../../lib/offline.js';

/**
 * Enlaza React con el documento colaborativo.
 *
 * El modelo **no** se guarda en el estado de la interfaz: vive en el documento y
 * lo que React mantiene es una proyeccion que se recalcula en cada actualizacion.
 * Guardarlo en Zustand crearia una segunda copia que habria que mantener
 * sincronizada a mano, y el editor visual siempre es una proyeccion del
 * documento, nunca la fuente de verdad (plan maestro 4.5).
 */

export type ConnectionStatus = 'conectando' | 'conectado' | 'desconectado' | 'rechazado';

export interface Participant {
  readonly clientId: number;
  readonly displayName: string;
  readonly color: string;
  /** Identificador del elemento que esta editando, si lo hay. */
  readonly editing: string | null;
}

export interface BoardDocument {
  readonly state: BoardState;
  readonly issues: readonly ValidationIssue[];
  readonly status: ConnectionStatus;
  readonly rejection: string | null;
  readonly accessNotice: string | null;
  readonly participants: readonly Participant[];
  readonly canWrite: boolean;
  readonly offlineReady: boolean;
  /** Aplica un lote. Devuelve los hallazgos si se rechaza. */
  dispatch(
    batch: CommandBatch,
    expected?: SemanticModel,
    scope?: 'AFFECTED' | 'MODEL',
  ): readonly ValidationIssue[] | null;
  /** Anuncia que elemento se esta editando, para la presencia. */
  announceEditing(elementId: string | null): void;
}

const COLORES = [
  '#2563eb',
  '#16a34a',
  '#db2777',
  '#ea580c',
  '#7c3aed',
  '#0891b2',
  '#ca8a04',
  '#dc2626',
];

function colorPara(clientId: number): string {
  return COLORES[Math.abs(clientId) % COLORES.length] as string;
}

/** Sin cambios durante este tiempo, la copia para abrir sin conexion se reescribe. */
const ESPERA_INSTANTANEA = 1000;

export function useBoardDocument(
  room: string | null,
  me: { id: string; displayName: string } | null,
  /**
   * Pizarra a la que atribuir los lotes aplicados (RF-A09).
   *
   * Va aparte de `room` porque el registro es HTTP y la sala es del canal de
   * tiempo real: CA-023.1 dice que el protocolo colaborativo transporta
   * actualizaciones del documento, no comandos, y que los comandos se registran
   * para auditoria y no para sincronizar.
   */
  boardId: string | null = null,
  offline = false,
  board: OfflineBoard | null = null,
): BoardDocument {
  const { activateOfflineCopy } = useSession();
  const [doc, setDoc] = useState(() => new Y.Doc());
  const [canWrite, setCanWrite] = useState(false);
  const [offlineReady, setOfflineReady] = useState(false);
  const writeAllowed = useRef(false);
  const [accessNotice, setAccessNotice] = useState<string | null>(null);
  const [state, setState] = useState<BoardState>(() => emptyBoardState());
  const [status, setStatus] = useState<ConnectionStatus>('conectando');
  const [rejection, setRejection] = useState<string | null>(null);
  const [participants, setParticipants] = useState<readonly Participant[]>([]);
  const providerRef = useRef<HocuspocusProvider | null>(null);
  const draftsRef = useRef<BoardDrafts | null>(null);
  const userId = me?.id;
  // Una ranura por editor, no por reintento de conexión: volver a consultar la
  // sesión o los metadatos no debe acumular otra copia completa por edición.
  const drafts = useMemo(() => {
    if (userId === undefined || room === null) return null;
    try {
      return new BoardDrafts(window.localStorage, userId, room);
    } catch {
      return null;
    }
  }, [userId, room]);

  /**
   * Cada modo trabaja sobre su propia replica.
   *
   * Al reconectar no se puede enchufar al proveedor la replica que estuvo sin
   * red: los borradores se mezclan despues, y solo tras confirmar escritura. Y
   * al perder la red hay que partir del estado autorizado en disco.
   *
   * El cambio se hace aqui, ajustando el estado durante el render, y no
   * remontando el editor desde la ruta: `BoardSession` guarda la conversacion
   * del asistente y el candidato de importacion en curso — trabajo que puede
   * haber costado una llamada de IA — y un corte de red no puede tirarlos.
   * React vuelve a renderizar antes de confirmar, asi que el efecto se ejecuta
   * una sola vez, ya con el documento nuevo.
   */
  const [replicaMode, setReplicaMode] = useState(offline);
  if (replicaMode !== offline) {
    setReplicaMode(offline);
    setDoc(new Y.Doc());
    setState(emptyBoardState());
    writeAllowed.current = false;
    setCanWrite(false);
    // `conectando` describe exactamente este instante: hay una replica vacia que
    // todavia no dice nada del modelo. Quien observa la proyeccion lo necesita
    // para no confundirla con un diagrama al que le borraron todo.
    setStatus('conectando');
    setOfflineReady(false);
  }

  useEffect(() => {
    if (room === null || me === null) return;

    setStatus(navigator.onLine ? 'conectando' : 'desconectado');
    setRejection(null);
    setParticipants([]);
    draftsRef.current = drafts;
    if (drafts === null) {
      setAccessNotice('El almacenamiento local no está disponible. No se podrán guardar cambios.');
    }

    if (offline) {
      setStatus('desconectado');
      try {
        const writable = board !== null && board.role !== 'VIEWER';
        if (!draftsRef.current?.openOffline(doc, writable)) throw new Error('No hay copia local');
        writeAllowed.current = writable;
        setCanWrite(writable);
        setOfflineReady(true);
        setState(readBoardState(doc));
      } catch {
        writeAllowed.current = false;
        setCanWrite(false);
        setAccessNotice(
          'No se pudo abrir la copia local. Vuelve a conectarte para recuperar la pizarra.',
        );
      }
      const update = (): void => setState(readBoardState(doc));
      doc.on('update', update);
      return () => {
        doc.off('update', update);
        draftsRef.current = null;
      };
    }

    const token = currentAccessToken();
    if (token === null) {
      setStatus('rechazado');
      setRejection('No hay sesion.');
      return;
    }

    const provider = new HocuspocusProvider({
      // Un solo origen: el proxy enruta `/collab` al proceso de colaboracion.
      url: `${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.host}/collab`,
      name: room,
      // El proveedor vuelve a pedir el valor en cada reconexion. Una cadena
      // fija quedaria obsoleta si mientras tanto la API renueva la sesion.
      token: () => currentAccessToken() ?? '',
      document: doc,
    });
    providerRef.current = provider;

    let disposed = false;
    let draftsRestored = false;
    let serverSynced = false;
    const restoreDrafts = (): void => {
      if (
        disposed ||
        !serverSynced ||
        draftsRestored ||
        !writeAllowed.current ||
        draftsRef.current === null
      )
        return;
      // Set before applying: applying the update can synchronously emit synced.
      draftsRestored = true;
      try {
        if (draftsRef.current.restore(doc)) {
          setAccessNotice('Se recuperó la copia local de esta pizarra y se enviará al servidor.');
        }
      } catch {
        writeAllowed.current = false;
        setCanWrite(false);
        setAccessNotice(
          'No se pudo recuperar la copia local. Se conserva intacta; libera espacio o revisa el almacenamiento antes de editar.',
        );
      }
    };
    let snapshotTimer: number | undefined;
    const saveSnapshot = (): void => {
      if (snapshotTimer !== undefined) {
        window.clearTimeout(snapshotTimer);
        snapshotTimer = undefined;
      }
      if (!serverSynced || !provider.isAuthenticated || board === null) return;
      try {
        if (draftsRef.current === null) return;
        draftsRef.current.snapshot(doc);
        rememberBoard(me.id, {
          ...board,
          role: writeAllowed.current ? (board.role === 'OWNER' ? 'OWNER' : 'EDITOR') : 'VIEWER',
        });
        setOfflineReady(true);
      } catch {
        setOfflineReady(false);
        setAccessNotice(
          'No se pudo actualizar la copia para abrir sin conexión. Revisa el espacio del navegador.',
        );
      }
    };
    /**
     * Guardar en cada actualizacion del documento codificaba el modelo completo
     * y lo escribia en `localStorage` de forma sincrona por cada pulsacion de
     * cualquier participante. Se agrupa: la copia solo tiene que estar al dia
     * cuando la pestana deja de recibir cambios, se oculta o se cierra.
     */
    const scheduleSnapshot = (): void => {
      if (snapshotTimer !== undefined || !serverSynced || board === null) return;
      snapshotTimer = window.setTimeout(() => {
        snapshotTimer = undefined;
        saveSnapshot();
      }, ESPERA_INSTANTANEA);
    };
    const flushSnapshot = (): void => {
      if (snapshotTimer !== undefined) saveSnapshot();
    };
    // `pagehide` tambien cubre cerrar la pestana; `visibilitychange` el paso a
    // segundo plano, que en movil es lo ultimo que se ejecuta con garantias.
    window.addEventListener('pagehide', flushSnapshot);
    document.addEventListener('visibilitychange', flushSnapshot);
    let lastPermissionWasWrite = writeAllowed.current;
    const permissions = (readOnly: boolean): void => {
      if (disposed) return;
      const lostWriteAccess = lastPermissionWasWrite && readOnly;
      lastPermissionWasWrite = !readOnly;
      writeAllowed.current = !readOnly;
      setCanWrite(!readOnly);
      // También al autenticar una réplica nueva: el rol de la caché puede venir
      // de una sesión anterior, y no puede esperar a la sincronización.
      if (readOnly && boardId !== null) downgradeBoard(me.id, boardId);
      if (lostWriteAccess) {
        serverSynced = false;
        setOfflineReady(false);
        // La entrada no se retira: la copia sigue siendo la del servidor y su
        // apertura sin red sigue autorizada, pero solo como lectura. Degradarla
        // ahora evita que un corte inmediato permita editar lo que ya no se
        // puede publicar, sin esperar a que termine la resincronizacion.
        setAccessNotice(
          'Tu permiso cambió a solo lectura. Se recargó la pizarra desde el servidor; la copia local se conserva y no se enviará sin permiso de edición.',
        );
        setStatus('conectando');
        provider.disconnect();
        // Mezclar el estado remoto con este Y.Doc volvería a introducir las
        // operaciones rechazadas. Una réplica limpia elimina los cambios fantasma.
        setState(emptyBoardState());
        setDoc(new Y.Doc());
      } else {
        restoreDrafts();
        saveSnapshot();
      }
    };
    provider.on('authenticated', ({ scope }: { scope: string }) =>
      permissions(scope !== 'read-write'),
    );
    provider.on('stateless', ({ payload }: { payload: string }) => {
      try {
        const message: unknown = JSON.parse(payload);
        if (
          typeof message === 'object' &&
          message !== null &&
          'type' in message &&
          message.type === 'access-changed' &&
          'readOnly' in message &&
          typeof message.readOnly === 'boolean'
        ) {
          permissions(message.readOnly);
        }
      } catch {
        /* Otros mensajes stateless no cambian permisos. */
      }
    });
    // También detecta cambios cuando todos los participantes están inactivos.
    const checkAccess = (): void => {
      if (provider.isAuthenticated) provider.sendStateless('check-access');
    };
    const accessTimer = window.setInterval(checkAccess, 5000);
    window.addEventListener('focus', checkAccess);

    let accesoRechazado = false;
    provider.on('synced', () => {
      if (disposed) return;
      serverSynced = true;
      restoreDrafts();
      accesoRechazado = false;
      setStatus('conectado');
      saveSnapshot();
    });
    provider.on('disconnect', () =>
      setStatus((previo) => (previo === 'rechazado' ? previo : 'desconectado')),
    );
    let renovandoToken = false;
    const rejectAccess = ({ reason }: { reason: string }): void => {
      if (disposed) return;
      writeAllowed.current = false;
      setCanWrite(false);
      serverSynced = false;
      // Un token de acceso vencido no es una revocacion: el proceso de
      // colaboracion cierra por ese motivo cada vez que expira (cada quince
      // minutos con una pizarra abierta). Borrar la entrada aqui dejaba la
      // pizarra inabrible sin red si la renovacion no llegaba a completarse,
      // aunque la instantanea siguiera intacta en el navegador.
      if (reason !== 'token-invalido') {
        setOfflineReady(false);
        if (boardId !== null) forgetBoard(me.id, boardId);
      }
      provider.disconnect();
      if (reason === 'token-invalido' && !renovandoToken) {
        renovandoToken = true;
        void refreshSession().then((renovado) => {
          if (disposed) return;
          renovandoToken = false;
          if (renovado) {
            accesoRechazado = false;
            setStatus('conectando');
            setRejection(null);
            provider.connect();
            return;
          }
          if (sessionRefreshUnavailable()) {
            setStatus('desconectado');
            setRejection(null);
            // El proveedor de sesión reintenta mientras se usa la copia local;
            // también cuando navigator.onLine sigue siendo true.
            activateOfflineCopy();
            return;
          }
          accesoRechazado = true;
          writeAllowed.current = false;
          setCanWrite(false);
          setStatus('rechazado');
          setRejection('La sesión expiró. Inicia sesión nuevamente.');
        });
        return;
      }

      accesoRechazado = true;
      writeAllowed.current = false;
      setCanWrite(false);
      setStatus('rechazado');
      setRejection(reason);
      provider.disconnect();
    };
    provider.on('authenticationFailed', rejectAccess);
    // Hocuspocus puede cerrar solo la sala manteniendo abierto el WebSocket.
    // Ese cierre emite `close`, no `authenticationFailed` ni `disconnect`.
    provider.on('close', ({ event }: { event: { reason?: string } }) => {
      if (event.reason === 'sin-acceso-a-la-pizarra' || event.reason === 'token-invalido') {
        rejectAccess({ reason: event.reason });
      }
    });

    provider.setAwarenessField('user', {
      displayName: me.displayName,
      color: colorPara(provider.document.clientID),
    });

    const leerPresencia = (): void => {
      const estados = provider.awareness?.getStates() ?? new Map<number, unknown>();
      const lista: Participant[] = [];

      for (const [clientId, valor] of estados) {
        const usuario = (valor as { user?: { displayName?: string; color?: string } }).user;
        if (usuario?.displayName === undefined) continue;

        lista.push({
          clientId,
          displayName: usuario.displayName,
          color: usuario.color ?? colorPara(clientId),
          editing: (valor as { editing?: string | null }).editing ?? null,
        });
      }

      lista.sort((izq, der) => izq.clientId - der.clientId);

      // Solo se actualiza si de verdad cambio. La presencia se emite en cada
      // latido, y un array nuevo en cada uno provocaria un render por latido.
      setParticipants((previo) => (mismaPresencia(previo, lista) ? previo : lista));
    };

    provider.on('awarenessUpdate', leerPresencia);
    provider.on('awarenessChange', leerPresencia);

    // `disconnect` puede tardar hasta que el socket detecta que la red murio.
    // El navegador ya conoce ese estado y debe reflejarse de inmediato: dejar
    // «En vivo» mientras se trabaja sin conexion hace creer que los demas ya
    // recibieron cambios que todavia solo existen en esta replica.
    const alQuedarSinRed = (): void => {
      // El navegador lo sabe antes que el socket, asi que la conexion todavia
      // esta autenticada: es el ultimo momento en que se puede guardar lo que
      // quedara pendiente del agrupado.
      flushSnapshot();
      setStatus((previo) => (previo === 'rechazado' ? previo : 'desconectado'));
      provider.disconnect();
    };
    const alVolverLaRed = (): void => {
      if (accesoRechazado) return;
      setStatus('conectando');
      provider.connect();
    };
    window.addEventListener('offline', alQuedarSinRed);
    window.addEventListener('online', alVolverLaRed);

    if (!navigator.onLine) provider.disconnect();

    const alActualizar = (): void => {
      setState(readBoardState(doc));
      scheduleSnapshot();
    };
    doc.on('update', alActualizar);
    alActualizar();
    leerPresencia();

    return () => {
      disposed = true;
      window.clearInterval(accessTimer);
      window.removeEventListener('focus', checkAccess);
      doc.off('update', alActualizar);
      window.removeEventListener('offline', alQuedarSinRed);
      window.removeEventListener('online', alVolverLaRed);
      window.removeEventListener('pagehide', flushSnapshot);
      document.removeEventListener('visibilitychange', flushSnapshot);
      // Antes de destruir el proveedor: `saveSnapshot` exige que la conexion
      // siga autenticada para no guardar un estado que el servidor no confirmo.
      flushSnapshot();
      provider.destroy();
      providerRef.current = null;
      draftsRef.current = null;
    };
  }, [doc, room, me, offline, board, boardId, activateOfflineCopy, drafts]);

  // La validacion se recalcula solo cuando cambia el modelo. El layout cambia en
  // cada arrastre y no afecta a la validez.
  const issues = useMemo(() => validateModel(state.semantic), [state.semantic]);

  const dispatch = useMemo(
    () =>
      (
        batch: CommandBatch,
        expected?: SemanticModel,
        scope: 'AFFECTED' | 'MODEL' = 'AFFECTED',
      ): readonly ValidationIssue[] | null => {
        if (!writeAllowed.current)
          return [
            {
              code: 'WRITE_ACCESS_DENIED',
              severity: 'ERROR',
              elementIds: [],
              message: 'Ya no tienes permiso para editar esta pizarra.',
            },
          ];
        if (expected !== undefined) {
          const conflicts = validateProposalPreconditions(
            batch,
            expected,
            readBoardState(doc).semantic,
            scope,
          );
          if (conflicts.length > 0) return conflicts;
        }

        const batchAplicado = conPosiciones(doc, batch);
        let resultado;
        try {
          if (draftsRef.current === null) throw new Error('Sin almacenamiento local');
          resultado = draftsRef.current.apply(doc, batchAplicado);
        } catch {
          return [
            {
              code: 'WRITE_ACCESS_DENIED',
              severity: 'ERROR',
              elementIds: [],
              message:
                'No se pudo guardar la copia local. El cambio no se aplicó. Libera espacio o habilita el almacenamiento del navegador y reintenta.',
            },
          ];
        }
        if (!resultado.applied) return resultado.issues;

        // Se registra despues de aplicar y sin esperar la respuesta: el cambio ya
        // esta en el documento y en las demas pantallas, asi que un fallo del
        // registro no puede deshacerlo. Se avisa por consola y se sigue — perder
        // una linea de auditoria es malo, congelar el editor por ella es peor.
        if (boardId !== null) {
          // Se registra el lote materializado, incluida la posicion que esta
          // capa asigna a clases importadas o propuestas por el asistente. Asi
          // la auditoria describe exactamente el cambio que recibio Yjs.
          void api.recordBatch(boardId, batchAplicado).catch((causa: unknown) => {
            console.warn('No se pudo registrar el lote para auditoria', causa);
          });
        }

        // La proyeccion se refresca por el evento `update`, pero se adelanta aqui
        // para que la interfaz no espere un ciclo de eventos tras cada accion.
        setState(readBoardState(doc));
        return null;
      },
    [doc, canWrite, boardId],
  );

  const announceEditing = useMemo(
    () =>
      (elementId: string | null): void => {
        providerRef.current?.setAwarenessField('editing', elementId);
      },
    [],
  );

  // El objeto se memoiza: devolverlo nuevo en cada render haria que cualquier
  // efecto que dependa de el se dispare siempre, y `announceEditing` provocaria
  // una actualizacion de presencia por render — un bucle sin fondo.
  return useMemo(
    () => ({
      state,
      issues,
      status,
      rejection,
      accessNotice,
      participants,
      canWrite,
      offlineReady,
      dispatch,
      announceEditing,
    }),
    [
      state,
      issues,
      status,
      rejection,
      accessNotice,
      participants,
      canWrite,
      offlineReady,
      dispatch,
      announceEditing,
    ],
  );
}

function mismaPresencia(izq: readonly Participant[], der: readonly Participant[]): boolean {
  if (izq.length !== der.length) return false;

  return izq.every((participante, indice) => {
    const otro = der[indice];
    return (
      otro !== undefined &&
      participante.clientId === otro.clientId &&
      participante.displayName === otro.displayName &&
      participante.editing === otro.editing
    );
  });
}

/**
 * Coloca en rejilla las clases que llegan sin posicion.
 *
 * El modelo canonico no lleva posiciones: viven en la capa de disposicion. El
 * boton «Nueva clase» ya calculaba una, pero el asistente y las importaciones
 * no, asi que **todo lo que crean caia en (0, 0)**: importar un diagrama de
 * cinco clases las dejaba una encima de otra, y encima de las que ya estaban.
 *
 * Se resuelve aqui, en el unico punto por el que pasan todos los lotes, y no en
 * cada panel. La posicion viaja dentro del comando, asi que los demas
 * participantes ven la misma disposicion en lugar de calcular cada uno la suya.
 */
function conPosiciones(doc: Y.Doc, batch: CommandBatch): CommandBatch {
  const nuevas = batch.commands.filter(
    (comando) => comando.type === 'CREATE_CLASS' && comando.payload.position === undefined,
  );
  if (nuevas.length === 0) return batch;

  let ocupadas = readBoardState(doc).semantic.classes.length;

  return {
    ...batch,
    commands: batch.commands.map((comando) => {
      if (comando.type !== 'CREATE_CLASS' || comando.payload.position !== undefined) {
        return comando;
      }

      const posicion = {
        x: 80 + (ocupadas % 4) * 300,
        y: 80 + Math.floor(ocupadas / 4) * 240,
      };
      ocupadas += 1;

      return { ...comando, payload: { ...comando.payload, position: posicion } };
    }),
  };
}
```

---

### `frontend/src/features/generation/GenerationPanel.tsx`

```tsx
import { hasErrors, type ValidationIssue } from '@uml/contracts';
import { useCallback, useEffect, useState } from 'react';
import { api, ApiError, downloadGeneration, type GenerationSummary } from '../../lib/api.js';

/**
 * Generación del proyecto desde la pizarra (RF-060 a RF-072, RF-080 a RF-084).
 *
 * Son dos pasos del guion de la defensa: «seleccionar la pizarra y generar» y
 * «descargar el ZIP, abrirlo en el IDE, configurar la base y ejecutar».
 *
 * El botón se apaga cuando el modelo tiene errores, con el mismo criterio que
 * usa el panel de validación: los errores bloquean la generación, no la edición
 * (ADR-003). El servidor lo vuelve a comprobar — un botón deshabilitado no es
 * una autorización — pero decirlo aquí evita el viaje.
 */
export function GenerationPanel({
  boardId,
  issues,
  canWrite,
}: {
  readonly boardId: string;
  readonly issues: readonly ValidationIssue[];
  readonly canWrite: boolean;
}): React.JSX.Element {
  const [historial, setHistorial] = useState<readonly GenerationSummary[]>([]);
  const [ultima, setUltima] = useState<string | null>(null);
  const [estado, setEstado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [trabajando, setTrabajando] = useState(false);
  const [basePackage, setBasePackage] = useState('');
  const [includeMobile, setIncludeMobile] = useState(false);
  const [ultimoMobile, setUltimoMobile] = useState(false);

  const bloqueado = hasErrors(issues);

  const refrescar = useCallback(() => {
    api
      .listGenerations(boardId)
      .then(setHistorial)
      .catch((causa: unknown) =>
        setError(
          causa instanceof Error
            ? `No se pudo cargar el historial: ${causa.message}`
            : 'No se pudo cargar el historial.',
        ),
      );
  }, [boardId]);

  useEffect(refrescar, [refrescar]);

  const generar = useCallback(async () => {
    setTrabajando(true);
    setError(null);
    setEstado(null);

    try {
      const resultado = await api.generate(boardId, basePackage, includeMobile);
      setUltima(resultado.id);
      setUltimoMobile(includeMobile);
      setEstado(
        `Generado ${resultado.artifactName} · ${resultado.entities} entidades · ` +
          `versión ${resultado.snapshotVersion} del modelo · paquete ${resultado.basePackage}`,
      );
      refrescar();
    } catch (causa) {
      // El 422 trae los hallazgos del validador. Se cuentan en lugar de
      // repetirlos: ya están, uno por uno, en el panel de validación.
      if (causa instanceof ApiError && causa.code === 'model_not_generable') {
        const detalles = causa.details as { issues?: readonly unknown[] } | undefined;
        setError(
          `El modelo tiene ${detalles?.issues?.length ?? 0} error(es). ` +
            'Revisa el panel de validación.',
        );
      } else {
        setError(causa instanceof Error ? causa.message : 'No se pudo generar.');
      }
    } finally {
      setTrabajando(false);
    }
  }, [boardId, basePackage, includeMobile, refrescar]);

  const descargar = useCallback(
    async (generationId: string, target: 'spring' | 'mobile' = 'spring') => {
      setError(null);

      try {
        const { blob, fileName } = await downloadGeneration(generationId, target);

        // El navegador no deja guardar un archivo sin un clic: se crea un enlace
        // temporal sobre el blob y se pulsa. La URL se revoca después, porque si
        // no el blob se queda en memoria hasta recargar la página.
        const url = URL.createObjectURL(blob);
        const enlace = document.createElement('a');
        enlace.href = url;
        enlace.download = fileName;
        document.body.appendChild(enlace);
        enlace.click();
        enlace.remove();
        URL.revokeObjectURL(url);

        setEstado(`Descargado ${fileName}`);
      } catch (causa) {
        setError(causa instanceof Error ? causa.message : 'No se pudo descargar.');
      }
    },
    [],
  );

  const eliminar = useCallback(
    async (generacion: GenerationSummary) => {
      // El ZIP no existe en el servidor: lo que se borra es el registro y la
      // version congelada sobre la que se regenera. Eso hace la descarga
      // imposible para siempre, y por eso se pregunta antes.
      const confirmado = window.confirm(
        `¿Eliminar la generación v${generacion.snapshotVersion} de ${generacion.projectName}? ` +
          'Ya no se podrá descargar.',
      );
      if (!confirmado) return;

      setError(null);
      try {
        await api.deleteGeneration(generacion.id);
        if (ultima === generacion.id) {
          setUltima(null);
          setUltimoMobile(false);
        }
        setEstado(`Eliminada la generación v${generacion.snapshotVersion}.`);
        refrescar();
      } catch (causa) {
        setError(causa instanceof Error ? causa.message : 'No se pudo eliminar.');
      }
    },
    [refrescar, ultima],
  );

  return (
    <section className="generacion" data-testid="panel-generacion">
      <h3>Generación</h3>

      {!canWrite && (
        <p className="aviso">Tu rol es de solo lectura: puedes descargar, no generar.</p>
      )}

      <label className="paquete">
        <span>Paquete Java</span>
        <input
          type="text"
          value={basePackage}
          placeholder="bo.edu.sw1"
          data-testid="paquete-base"
          onChange={(evento) => setBasePackage(evento.target.value)}
        />
      </label>

      <label className="opcion-checkbox">
        <input
          type="checkbox"
          checked={includeMobile}
          onChange={(event) => setIncludeMobile(event.target.checked)}
          disabled={trabajando || !canWrite}
          data-testid="incluir-flutter"
        />
        <span>
          Incluir app Android <small>Flutter, inicio de sesión y datos sin conexión.</small>
        </span>
      </label>
      {includeMobile && (
        <p className="aviso">
          Incluye la app Flutter y su backend. Para compilar el APK necesitas Flutter y Android SDK
          en tu equipo. Los modelos de texto y voz se instalan después en el teléfono.
        </p>
      )}
      <button
        type="button"
        className="principal"
        data-testid="generar"
        disabled={!canWrite || bloqueado || trabajando}
        onClick={() => void generar()}
      >
        {trabajando ? 'Generando…' : 'Generar proyecto'}
      </button>

      {bloqueado && (
        <p className="aviso" data-testid="generacion-bloqueada">
          El modelo tiene errores. Corrígelos para poder generar.
        </p>
      )}

      {ultima !== null && (
        <div className="descargas">
          <button
            type="button"
            data-testid="descargar-spring"
            onClick={() => void descargar(ultima)}
          >
            Descargar backend
          </button>
          {ultimoMobile && (
            <button
              type="button"
              data-testid="descargar-mobile"
              onClick={() => void descargar(ultima, 'mobile')}
            >
              Descargar Android + backend
            </button>
          )}
        </div>
      )}

      {estado !== null && (
        <p className="aviso" data-testid="estado-generacion">
          {estado}
        </p>
      )}
      {(includeMobile || ultimoMobile || historial.some((g) => g.mobileSha256)) && (
        <details className="aviso" data-testid="comandos-android">
          <summary>Compilar APK y probar en el celular</summary>
          <p>
            Extrae Android + backend y abre PowerShell en esa carpeta. Activa Depuración USB en el
            celular, conecta el cable y acepta la autorización en su pantalla.
          </p>
          <ul>
            <li>
              <code>.\apk.bat doctor</code> — comprobar Flutter, Android SDK y dispositivos.
            </li>
            <li>
              <code>.\apk.bat build</code> — crear el APK en <code>mobile/dist/</code>.
            </li>
            <li>
              <code>.\apk.bat install</code> — compilar, instalar y abrir la app.
            </li>
            <li>
              <code>.\apk.bat deploy</code> — levantar backend con Docker e instalar con conexión
              USB.
            </li>
            <li>
              <code>.\apk.bat run --usb</code> — probar con recarga en caliente y backend ya
              iniciado.
            </li>
          </ul>
          <p>
            La app funciona sin servidor con admin / admin. Para usar el backend, activa Conectar a
            un servidor en el login. En Linux/macOS usa <code>sh apk.sh</code>.
          </p>
        </details>
      )}
      {error !== null && (
        <p className="error" data-testid="error-generacion">
          {error}
        </p>
      )}

      {historial.length > 0 && (
        <ul className="historial" data-testid="historial-generaciones">
          {historial.slice(0, 5).map((generacion) => (
            <li key={generacion.id} className={generacion.status === 'FAILED' ? 'fallida' : ''}>
              <strong>v{generacion.snapshotVersion}</strong>
              <span>
                {generacion.author.displayName} ·{' '}
                {new Date(generacion.createdAt).toLocaleString('es-BO')}
              </span>
              <span className={`estado estado-${generacion.status.toLowerCase()}`}>
                {generacion.status === 'READY'
                  ? 'Lista'
                  : generacion.status === 'CREATING'
                    ? 'Preparando…'
                    : 'Falló'}
              </span>
              {/* El paquete y el nombre son los que se congelaron, no los de
                  ahora: es justamente lo que permite descargar una generacion
                  vieja y recibir lo mismo que el dia que se hizo. */}
              <span className="manifiesto">
                {generacion.projectName} · {generacion.basePackage}
                {generacion.status === 'FAILED' && ` · falló: ${generacion.error ?? ''}`}
              </span>
              {(generacion.status === 'READY' || canWrite) && (
                <span className="acciones-historial">
                  {generacion.status === 'READY' && (
                    <button
                      type="button"
                      aria-label={`Descargar backend de la versión ${generacion.snapshotVersion}`}
                      onClick={() => void descargar(generacion.id)}
                    >
                      Backend
                    </button>
                  )}
                  {generacion.status === 'READY' && generacion.mobileSha256 && (
                    <button type="button" onClick={() => void descargar(generacion.id, 'mobile')}>
                      Android + backend
                    </button>
                  )}
                  {/* Una generacion fallida o en curso tambien se puede retirar:
                      no tiene artefacto, pero sigue ocupando el historial. */}
                  {canWrite && (
                    <button
                      type="button"
                      className="eliminar"
                      aria-label={`Eliminar la generación v${generacion.snapshotVersion}`}
                      data-testid={`eliminar-generacion-${generacion.snapshotVersion}`}
                      onClick={() => void eliminar(generacion)}
                    >
                      Eliminar
                    </button>
                  )}
                </span>
              )}
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
```

---

### `frontend/src/features/help/InteractiveTour.tsx`

```tsx
import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react';
import { useLocation } from 'react-router';
import { TourCoach } from './TourCoach.js';
import { readTourStep, tourForPath, tourProgressKey, tours } from './tour-steps.js';

const TourContext = createContext<{
  start(topic?: string, resume?: boolean): void;
  pause(): void;
} | null>(null);
export function useInteractiveTour() {
  const context = useContext(TourContext);
  if (!context) throw new Error('InteractiveTourProvider is required');
  return context;
}

export function InteractiveTourProvider({ children }: { readonly children: ReactNode }) {
  const { pathname } = useLocation();
  const kind = tourForPath(pathname);
  const [run, setRun] = useState<{ path: string; index: number } | null>(null);
  const pause = useCallback(() => {
    setRun(null);
    document
      .querySelector<HTMLButtonElement>('.ayuda-software-boton')
      ?.focus({ preventScroll: true });
  }, []);
  useEffect(() => {
    if (!run || run.path === pathname) return;
    // Navigation is always performed by the user. Continue in the screen they opened.
    setRun(kind ? { path: pathname, index: 0 } : null);
  }, [pathname, kind, run]);
  useEffect(() => {
    if (!run || !kind || run.path !== pathname) return;
    try {
      const step = tours[kind].steps[run.index];
      if (step) localStorage.setItem(tourProgressKey, JSON.stringify({ kind, step: step.id }));
      else localStorage.removeItem(tourProgressKey);
    } catch {
      /* The interactive tour also works when storage is unavailable. */
    }
  }, [run, kind, pathname]);
  const start = (topic?: string, resume = false) => {
    if (!kind) return;
    let index = -1;
    if (resume) {
      try {
        index = readTourStep(localStorage.getItem(tourProgressKey), kind);
      } catch {
        /* Start from the context. */
      }
    }
    if (index < 0) index = tours[kind].steps.findIndex((step) => step.id === topic);
    setRun({ path: pathname, index: Math.max(0, index) });
  };
  return (
    <TourContext.Provider value={{ start, pause }}>
      {children}
      {run && kind && run.path === pathname && (
        <TourCoach
          key={`${pathname}:${run.index}`}
          kind={kind}
          index={run.index}
          move={(index) =>
            setRun({
              path: pathname,
              index: Math.max(0, Math.min(index, tours[kind].steps.length)),
            })
          }
          pause={pause}
        />
      )}
    </TourContext.Provider>
  );
}
```

---

### `frontend/src/features/help/SoftwareGuide.tsx`

```tsx
import { useId, useRef, useState } from 'react';
import { useLocation } from 'react-router';
import { useInteractiveTour } from './InteractiveTour.js';
import {
  findSoftwareLessons,
  readSoftwareProgress,
  softwareLessons,
  softwareProgressKey,
} from './software-lessons.js';

function savedProgress(): readonly string[] {
  try {
    return readSoftwareProgress(localStorage.getItem(softwareProgressKey));
  } catch {
    return [];
  }
}

/** Built-in help: opening, searching and reading never execute application actions. */
export function SoftwareGuide({ topic }: { readonly topic?: string }) {
  const tour = useInteractiveTour();
  const { pathname } = useLocation();
  const contextualTopic = topic ?? (pathname === '/cuenta' ? 'account' : 'projects');
  const dialog = useRef<HTMLDialogElement>(null);
  const id = useId();
  const [selected, setSelected] = useState(contextualTopic);
  const [query, setQuery] = useState('');
  const [completed, setCompleted] = useState<readonly string[]>(savedProgress);
  const [storageNotice, setStorageNotice] = useState('');
  const lesson = softwareLessons.find((item) => item.id === selected) ?? softwareLessons[0]!;
  const index = softwareLessons.indexOf(lesson);
  const results = findSoftwareLessons(query);

  function saveProgress(next: readonly string[]) {
    setCompleted(next);
    try {
      localStorage.setItem(softwareProgressKey, JSON.stringify(next));
      setStorageNotice('');
    } catch {
      setStorageNotice(
        'El navegador no permite guardar el progreso. Puedes seguir usando la guía durante esta sesión.',
      );
    }
  }

  return (
    <>
      <button
        type="button"
        className="ayuda-software-boton"
        aria-label="Aprender a usar el software"
        aria-haspopup="dialog"
        onClick={() => {
          tour.pause();
          setSelected(contextualTopic);
          setQuery('');
          dialog.current?.showModal();
        }}
      >
        Ayuda
      </button>
      <dialog ref={dialog} className="guia-ia guia-software" aria-labelledby={`${id}-title`}>
        <header className="guia-ia-cabecera">
          <h2 id={`${id}-title`}>Aprende a usar el software</h2>
          <button
            type="button"
            autoFocus
            aria-label="Cerrar ayuda del software"
            onClick={() => dialog.current?.close()}
          >
            Cerrar
          </button>
        </header>
        <p>
          Desde tu primer proyecto hasta la descarga de tu aplicación. Elige un tema o busca tu
          duda; esta ayuda no realiza cambios en tu trabajo.
        </p>
        <div className="guia-software-progreso">
          <button
            type="button"
            className="principal"
            onClick={() => {
              dialog.current?.close();
              tour.start(contextualTopic);
            }}
          >
            Guiarme en esta pantalla
          </button>
          <button
            type="button"
            onClick={() => {
              dialog.current?.close();
              tour.start(contextualTopic, true);
            }}
          >
            Retomar recorrido interactivo
          </button>
          <span role="status">
            {completed.length} de {softwareLessons.length} temas leídos
          </span>
          <button
            type="button"
            onClick={() => {
              setQuery('');
              setSelected(
                softwareLessons.find((item) => !completed.includes(item.id))?.id ?? 'projects',
              );
            }}
          >
            {completed.length === softwareLessons.length
              ? 'Repasar recorrido'
              : 'Continuar recorrido'}
          </button>
          <button type="button" disabled={completed.length === 0} onClick={() => saveProgress([])}>
            Reiniciar progreso
          </button>
        </div>
        {storageNotice && <p role="status">{storageNotice}</p>}
        <label className="guia-software-busqueda" htmlFor={`${id}-search`}>
          ¿Qué quieres aprender?
          <input
            id={`${id}-search`}
            type="search"
            value={query}
            placeholder="Ej.: invitar, crear clase, descargar Android"
            onChange={(event) => setQuery(event.target.value)}
          />
        </label>
        <div className="guia-software-contenido">
          <nav aria-label="Temas de ayuda del software">
            <p role="status">
              {results.length} {results.length === 1 ? 'tema disponible' : 'temas disponibles'}
            </p>
            {results.length === 0 ? (
              <div>
                <p>
                  No encontré un tema para esa búsqueda. Prueba con «proyecto», «atributo»,
                  «invitar» o «descargar».
                </p>
                <button type="button" onClick={() => setQuery('')}>
                  Ver todos los temas
                </button>
              </div>
            ) : (
              <ul className="guia-software-temas">
                {results.map((item) => (
                  <li key={item.id}>
                    <button
                      type="button"
                      aria-current={selected === item.id ? 'step' : undefined}
                      onClick={() => setSelected(item.id)}
                    >
                      {item.title}
                      {completed.includes(item.id) && <small>Leído</small>}
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </nav>
          <section aria-label="Lección seleccionada" className="guia-software-leccion">
            <div aria-live="polite" aria-atomic="true">
              <p className="guia-ia-paso">
                Tema {index + 1} de {softwareLessons.length} · {lesson.title}
              </p>
              <h3>{lesson.question}</h3>
              <p>{lesson.summary}</p>
              <p className="guia-ia-consejo">
                <strong>Dónde está:</strong> {lesson.where}
              </p>
              <ol>
                {lesson.steps.map((step) => (
                  <li key={step}>{step}</li>
                ))}
              </ol>
              <div className="guia-ia-ejemplo">
                <h4>Prueba a tu ritmo</h4>
                <p>{lesson.practice}</p>
              </div>
              <p>{lesson.tip}</p>
            </div>
            <label className="guia-software-leido">
              <input
                type="checkbox"
                checked={completed.includes(lesson.id)}
                onChange={(event) =>
                  saveProgress(
                    event.target.checked
                      ? [...completed, lesson.id]
                      : completed.filter((value) => value !== lesson.id),
                  )
                }
              />
              Marcar este tema como leído
            </label>
            <nav aria-label="Recorrido de aprendizaje" className="guia-ia-acciones">
              <button
                type="button"
                disabled={index === 0}
                onClick={() => {
                  setQuery('');
                  setSelected(softwareLessons[index - 1]!.id);
                }}
              >
                Tema anterior
              </button>
              <button
                type="button"
                disabled={index === softwareLessons.length - 1}
                onClick={() => {
                  setQuery('');
                  setSelected(softwareLessons[index + 1]!.id);
                }}
              >
                Tema siguiente
              </button>
            </nav>
          </section>
        </div>
      </dialog>
    </>
  );
}
```

---

### `frontend/src/features/help/TourCoach.tsx`

```tsx
import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { tours, type TourKind } from './tour-steps.js';
import { tourTarget, useTourTarget } from './use-tour-target.js';

interface Props {
  readonly kind: TourKind;
  readonly index: number;
  move(index: number): void;
  pause(): void;
}

export function TourCoach({ kind, index, move, pause }: Props) {
  const tour = tours[kind];
  const step = tour.steps[index];
  const { anchor, done } = useTourTarget(step);
  const panel = useRef<HTMLElement>(null);
  const close = useRef<HTMLButtonElement>(null);
  const [size, setSize] = useState({
    width: 360,
    height: 340,
    viewportWidth: window.innerWidth,
    viewportHeight: window.innerHeight,
  });
  useLayoutEffect(() => {
    const measure = () => {
      const box = panel.current?.getBoundingClientRect();
      if (box)
        setSize({
          width: box.width,
          height: box.height,
          viewportWidth: window.innerWidth,
          viewportHeight: window.innerHeight,
        });
    };
    const observer = new ResizeObserver(measure);
    if (panel.current) observer.observe(panel.current);
    window.addEventListener('resize', measure);
    measure();
    close.current?.focus({ preventScroll: true });
    return () => {
      observer.disconnect();
      window.removeEventListener('resize', measure);
    };
  }, []);

  useEffect(() => {
    const escape = (event: KeyboardEvent) => {
      if (event.key !== 'Escape' || document.querySelector('dialog[open]')) return;
      event.preventDefault();
      event.stopPropagation();
      pause();
    };
    document.addEventListener('keydown', escape);
    return () => document.removeEventListener('keydown', escape);
  }, [pause]);

  function focusTarget() {
    if (!step) return;
    // Only disclosure buttons and tabs may be opened by the tour. Never submit forms.
    for (const id of step.reveal ?? []) {
      const control = tourTarget(id);
      if (
        control?.getAttribute('aria-expanded') === 'false' ||
        (control?.getAttribute('role') === 'tab' &&
          control.getAttribute('aria-selected') !== 'true')
      )
        control.click();
    }
    requestAnimationFrame(() => {
      const target = tourTarget(step.target);
      target?.scrollIntoView({ block: 'center', inline: 'nearest', behavior: 'instant' });
      target?.focus({ preventScroll: true });
    });
  }

  const gap = 12;
  const maxX = Math.max(gap, size.viewportWidth - size.width - gap);
  const maxY = Math.max(gap, size.viewportHeight - size.height - gap);
  let left = maxX;
  let top = maxY;
  if (anchor) {
    if (size.viewportWidth > 700 && anchor.x - size.width > gap * 2) {
      left = anchor.x - size.width - gap;
      top = Math.max(gap, Math.min(anchor.y, maxY));
    } else if (
      size.viewportWidth > 700 &&
      anchor.x + anchor.width + size.width + gap * 2 < size.viewportWidth
    ) {
      left = anchor.x + anchor.width + gap;
      top = Math.max(gap, Math.min(anchor.y, maxY));
    } else {
      left = Math.max(gap, Math.min(anchor.x, maxX));
      top = anchor.y + anchor.height / 2 > size.viewportHeight / 2 ? gap : maxY;
    }
  }

  return createPortal(
    <div className="tour-layer" data-tour-ui="true">
      {anchor && (
        <div
          className="tour-spotlight"
          data-testid="tour-spotlight"
          aria-hidden="true"
          style={{
            left: Math.max(2, anchor.x - 4),
            top: Math.max(2, anchor.y - 4),
            width: Math.max(
              0,
              Math.min(anchor.width + 8, size.viewportWidth - Math.max(2, anchor.x - 4) - 2),
            ),
            height: Math.max(
              0,
              Math.min(anchor.height + 8, size.viewportHeight - Math.max(2, anchor.y - 4) - 2),
            ),
          }}
        />
      )}
      <section
        ref={panel}
        className="tour-coach"
        role="dialog"
        aria-modal="false"
        aria-labelledby="tour-title"
        aria-describedby="tour-description"
        style={{ left, top }}
      >
        <header>
          <span className="tour-eyebrow">RECORRIDO INTERACTIVO</span>
          <button type="button" ref={close} onClick={pause} aria-label="Pausar recorrido">
            Pausar
          </button>
        </header>
        {step ? (
          <>
            <p className="tour-progress-label">
              {tour.title} · {index + 1} de {tour.steps.length}
            </p>
            <progress value={index + 1} max={tour.steps.length} aria-label="Paso del recorrido" />
            <h2 id="tour-title">{step.title}</h2>
            <div className="tour-body">
              <p id="tour-description">{step.text}</p>
              <p className="tour-feedback" role="status">
                {!anchor
                  ? (step.unavailable ??
                    'Este control está oculto. Pulsa Mostrar control o abre el panel correspondiente.')
                  : anchor.disabled
                    ? 'Este control no está disponible ahora. Revisa tus permisos o los requisitos; puedes omitir el paso.'
                    : done
                      ? 'Acción detectada. Puedes continuar cuando termines.'
                      : step.action
                        ? 'Hazlo en el control resaltado. El recorrido detectará tu acción.'
                        : 'Explora el control resaltado y continúa cuando estés listo.'}
              </p>
              <button
                type="button"
                className="tour-target-button"
                onClick={focusTarget}
                disabled={anchor?.disabled}
              >
                {anchor ? 'Ir al control' : 'Mostrar control'}
              </button>
            </div>
            <nav aria-label="Controles del recorrido">
              <button type="button" onClick={() => move(index - 1)} disabled={index === 0}>
                Atrás
              </button>
              {step.action && !done ? (
                <>
                  <button type="button" onClick={() => move(index + 1)}>
                    Omitir paso
                  </button>
                  <button type="button" className="principal" disabled>
                    Siguiente
                  </button>
                </>
              ) : (
                <button type="button" className="principal" onClick={() => move(index + 1)}>
                  {index === tour.steps.length - 1 ? 'Terminar recorrido' : 'Siguiente'}
                </button>
              )}
            </nav>
            <p className="tour-note">
              Puedes usar la interfaz. Escape pausa y Ayuda permite retomar.
            </p>
          </>
        ) : (
          <>
            <h2 id="tour-title">Recorrido terminado</h2>
            <p id="tour-description">
              Ya recorriste {tour.title.toLocaleLowerCase()}. Puedes volver a practicar los pasos
              que omitiste o consultar la ayuda cuando lo necesites.
            </p>
            <nav aria-label="Final del recorrido">
              <button type="button" onClick={() => move(0)}>
                Repetir recorrido
              </button>
              <button type="button" className="principal" onClick={pause}>
                Cerrar recorrido
              </button>
            </nav>
          </>
        )}
      </section>
    </div>,
    document.body,
  );
}
```

---

### `frontend/src/features/help/software-lessons.ts`

```ts
export interface SoftwareLesson {
  readonly id: string;
  readonly title: string;
  readonly question: string;
  readonly keywords: string;
  readonly where: string;
  readonly summary: string;
  readonly steps: readonly string[];
  readonly practice: string;
  readonly tip: string;
}

export const softwareLessons: readonly SoftwareLesson[] = [
  {
    id: 'projects',
    title: 'Proyectos y pizarras',
    question: '¿Cómo empiezo mi primer diagrama?',
    keywords: 'empezar inicio crear nuevo proyecto pizarra tablero',
    where: 'Mis proyectos → Crear proyecto → Nueva pizarra',
    summary:
      'Un proyecto reúne tus pizarras y participantes. Cada pizarra contiene un diagrama independiente.',
    steps: [
      'En Mis proyectos escribe un nombre en Nuevo proyecto y pulsa Crear proyecto.',
      'Dentro del proyecto, escribe el nombre de una pizarra y pulsa Nueva pizarra.',
      'Abre la pizarra pulsando su nombre. Para volver al proyecto, usa el enlace Proyecto de la barra superior.',
    ],
    practice:
      'Prueba con un proyecto Sistema de ventas y una pizarra Ventas. Cierra esta ayuda para realizar los pasos cuando quieras.',
    tip: 'Si ya te invitaron, usa Unirme con un código en Mis proyectos. No necesitas crear otro proyecto.',
  },
  {
    id: 'diagram',
    title: 'Clases y atributos',
    question: '¿Cómo dibujo una clase y añado sus campos?',
    keywords:
      'dibujar diagrama entidad tabla campo atributo clase nombre tipo clave primaria requerido unico',
    where: 'Pizarra → Nueva clase → Propiedades',
    summary:
      'Una clase representa un concepto, como Cliente. Sus atributos describen los datos que guardarás, como nombre o correo.',
    steps: [
      'Pulsa Nueva clase. En Propiedades cambia su nombre a Cliente.',
      'En Nuevo atributo escribe nombre y pulsa Añadir. Selecciona el tipo String para texto, u otro tipo según el dato.',
      'Revisa Clave primaria, Requerido y Único según tus necesidades. Selecciona cada clase para editarla y arrástrala para organizar el diagrama.',
    ],
    practice:
      'Crea Cliente con un atributo nombre de tipo String. Añade un identificador id de tipo UUID y márcalo como Clave primaria.',
    tip: 'Herramientas y Propiedades muestran u ocultan los paneles. Tab y Enter permiten recorrer y seleccionar elementos. Los cambios se comparten automáticamente mientras estás conectado.',
  },
  {
    id: 'relationships',
    title: 'Relaciones entre clases',
    question: '¿Cómo conecto dos clases?',
    keywords:
      'conectar unir relacion asociacion herencia generalizacion composicion agregacion cardinalidad multiplicidad',
    where: 'Pizarra → Herramientas → Asociación',
    summary:
      'Las relaciones indican cómo se vinculan los conceptos. Las multiplicidades expresan cuántos elementos pueden participar en cada extremo.',
    steps: [
      'Crea las dos clases que necesitas conectar, por ejemplo Cliente y Pedido.',
      'Elige Asociación en Herramientas, pulsa la clase de origen y después la de destino.',
      'Selecciona la relación y revisa sus propiedades y multiplicidades. Usa Generalización para herencia solo cuando una clase sea una especialización de otra.',
    ],
    practice:
      'Relaciona Cliente con Pedido. Revisa si tu negocio permite varios pedidos por cliente y ajusta las multiplicidades.',
    tip: 'Vuelve a Seleccionar o pulsa Escape para salir de una herramienta. Selecciona un elemento antes de editar sus propiedades.',
  },
  {
    id: 'collaboration',
    title: 'Invitar y colaborar',
    question: '¿Cómo invito a alguien y qué puede hacer?',
    keywords:
      'invitar invitacion codigo compartir colaborar colaboracion equipo permisos rol lector editor miembro guardar guardado sincronizar conexion',
    where: 'Proyecto → Invitar al proyecto → Editor / Lector',
    summary:
      'Los participantes acceden mediante invitaciones. Un editor puede modificar; un lector puede consultar y descargar, pero no editar ni generar.',
    steps: [
      'Desde el proyecto, si tienes permisos, genera una invitación como editor o lector.',
      'Comparte el código con la persona. Ella inicia sesión y lo introduce en Unirme con un código.',
      'Abre la misma pizarra con tu equipo. Consulta el indicador En vivo y la presencia de participantes para saber si la colaboración está conectada.',
    ],
    practice:
      'Decide qué rol darías a quien solo revisará el diagrama: lector. Usa editor para quien deba modificarlo.',
    tip: 'Si ves Solo lectura, solicita permiso de edición al propietario. Si aparece Sin conexión, recupera la conexión y verifica el estado antes de salir; no supongas que tus cambios ya llegaron al servidor.',
  },
  {
    id: 'assistant',
    title: 'Trabajar con la IA',
    question: '¿Cómo le pido ayuda al asistente?',
    keywords:
      'ia inteligencia artificial asistente agente preguntar consultar instruir texto voz dictar microfono',
    where: 'Pizarra → Asistente → Aprender a usar la IA',
    summary:
      'Consultar responde preguntas sobre tu diagrama. Instruir prepara propuestas de cambios por texto o voz que tú revisas antes de aplicar.',
    steps: [
      'En Asistente elige Consultar para entender el modelo, o Instruir para solicitar un cambio concreto.',
      'Escribe la acción, la clase y sus detalles. Si usas Dictar, pulsa Parar y revisa el texto antes de Enviar.',
      'Lee la propuesta antes de Aplicar. Si no es lo que necesitas, déjala sin aplicar y corrige la solicitud. Responde a las aclaraciones cuando falte información.',
    ],
    practice:
      'Abre Aprender a usar la IA para practicar y cargar ejemplos como borradores sin enviarlos automáticamente.',
    tip: 'La guía de IA explica el proceso con más detalle. Las solicitudes reales necesitan acceso al servidor; esta ayuda no consume llamadas de IA.',
  },
  {
    id: 'import',
    title: 'Importar y exportar',
    question: '¿Cómo recupero un diagrama desde XMI o una imagen?',
    keywords:
      'importar exportar xmi png imagen foto camara archivo enterprise architect reemplazar',
    where: 'Pizarra → Importar',
    summary:
      'Puedes importar un XMI o una imagen y revisar el resultado antes de aplicarlo. Exportar XMI permite llevar el modelo a otra herramienta compatible.',
    steps: [
      'En Importar elige Añadir a lo que hay o Reemplazar el contenido según lo que quieras conservar.',
      'Usa Importar XMI o la opción de imagen/cámara. Revisa el modelo propuesto, las observaciones y los cambios antes de aplicarlos.',
      'Para exportar, pulsa Exportar XMI, revisa el nombre y selecciona el formato compatible con tu herramienta de destino.',
      'Para guardar una imagen, pulsa Exportar imagen PNG, elige el nombre y pulsa Guardar PNG. Incluye el diagrama completo con el tema actual, aunque algunas clases queden fuera de la vista. Los lectores también pueden descargarla.',
    ],
    practice:
      'Antes de reemplazar un diagrama importante, exporta su XMI. Después puedes revisar una importación y descartarla si no coincide.',
    tip: 'Reemplazar cambia el contenido actual al aplicar. El reconocimiento de imágenes puede cometer errores; comprueba nombres, tipos y relaciones.',
  },
  {
    id: 'validation',
    title: 'Corregir errores del modelo',
    question: '¿Por qué no puedo generar el proyecto?',
    keywords:
      'errores error validacion revision bloqueado generar fallo advertencia aviso clave tipos',
    where: 'Pizarra → Revisión del modelo / Propiedades',
    summary:
      'La revisión comprueba la estructura del diagrama. Los errores bloquean la generación hasta que se corrijan.',
    steps: [
      'Lee los errores y avisos de Revisión del modelo.',
      'Selecciona la clase o relación afectada. Revisa nombres, tipos, claves y multiplicidades en Propiedades según el mensaje.',
      'Vuelve a Generar cuando no haya errores. Si el botón sigue deshabilitado, comprueba también tu rol y si hay una generación en curso.',
    ],
    practice:
      'Si un mensaje pide una clave primaria, revisa el atributo identificador de esa clase y marca Clave primaria según el diseño.',
    tip: 'Resolver la validación permite generar código; también debes revisar que el diagrama represente correctamente las reglas de tu negocio.',
  },
  {
    id: 'generation',
    title: 'Generar y descargar aplicaciones',
    question: '¿Cómo descargo el backend o la aplicación Android?',
    keywords:
      'generar generacion descargar descarga backend spring java flutter android apk aplicacion zip codigo',
    where: 'Pizarra → Generar → Generar proyecto',
    summary:
      'La web genera un paquete de código desde el diagrama. Puedes incluir el backend y, opcionalmente, el proyecto Flutter Android.',
    steps: [
      'Abre Generar, revisa Paquete Java y corrige los errores del modelo que impidan continuar.',
      'Activa Incluir app Android si también necesitas la app móvil. Pulsa Generar proyecto.',
      'Al terminar, usa Descargar backend o Descargar Android + backend. Descomprime el ZIP y sigue el README incluido para ejecutar o compilar el proyecto.',
    ],
    practice:
      'Decide si necesitas solo el backend o también Android antes de generar. Cada descarga corresponde a una versión del diagrama.',
    tip: 'El ZIP Android contiene el proyecto Flutter: no es una APK lista para instalar. La APK se compila con Flutter: el ZIP trae apk.bat y apk.sh, que con Flutter instalado compilan el APK e incluso lo instalan en el teléfono por USB con una sola orden. Los lectores pueden descargar generaciones existentes. El servidor no guarda los ZIP: los vuelve a emitir desde la versión congelada del diagrama. Eliminar, en el historial, retira esa versión y la generación deja de poder descargarse; no afecta a lo que ya descargaste.',
  },
  {
    id: 'account',
    title: 'Cuenta y preferencias',
    question: '¿Dónde cambio mi perfil o cierro sesión?',
    keywords:
      'cuenta perfil foto avatar nombre contraseña password tema oscuro claro salir cerrar sesion',
    where: 'Barra superior → Menú de usuario → Mi cuenta',
    summary:
      'Desde tu cuenta puedes revisar tus datos de perfil. El selector de tema permite ajustar la apariencia de la interfaz.',
    steps: [
      'Desde Mis proyectos o un proyecto, abre el menú de tu usuario y entra en Mi cuenta.',
      'Usa los controles del perfil para cambiar tus datos, foto o contraseña. Revisa los mensajes de confirmación o error.',
      'Cambia el tema desde la barra superior. Usa Cerrar sesión en el menú, o Salir en el editor, cuando termines en un equipo compartido.',
    ],
    practice:
      'Localiza el menú de usuario y el selector de tema. No necesitas cambiar tus datos para completar esta lección.',
    tip: 'Puedes volver a abrir esta ayuda cuando la necesites. El progreso de lectura se guarda en este navegador; no certifica que hayas ejecutado las acciones.',
  },
];

function normalize(text: string): string {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();
}

const ignoredWords = new Set([
  'a',
  'al',
  'como',
  'con',
  'de',
  'del',
  'el',
  'en',
  'es',
  'la',
  'las',
  'lo',
  'los',
  'me',
  'mi',
  'mis',
  'para',
  'por',
  'puedo',
  'que',
  'quiero',
  'se',
  'un',
  'una',
  'usar',
  'y',
]);

export function findSoftwareLessons(query: string): readonly SoftwareLesson[] {
  const words =
    normalize(query)
      .match(/[a-z0-9]+/g)
      ?.filter((word) => !ignoredWords.has(word)) ?? [];
  if (words.length === 0) return softwareLessons;
  return softwareLessons
    .map((lesson) => {
      const text = normalize(`${lesson.title} ${lesson.question} ${lesson.keywords}`);
      return { lesson, score: words.filter((word) => text.includes(word)).length };
    })
    .filter(({ score }) => score > 0)
    .sort((a, b) => b.score - a.score)
    .map(({ lesson }) => lesson);
}

export const softwareProgressKey = 'uml.software-learning.v1';

export function readSoftwareProgress(raw: string | null): readonly string[] {
  try {
    const value: unknown = JSON.parse(raw ?? '[]');
    return Array.isArray(value)
      ? softwareLessons.filter((lesson) => value.includes(lesson.id)).map((lesson) => lesson.id)
      : [];
  } catch {
    return [];
  }
}
```

---

### `frontend/src/features/help/tour-steps.ts`

```ts
export type TourKind = 'projects' | 'project' | 'board' | 'account';
export interface TourStep {
  readonly id: string;
  readonly target: string;
  readonly title: string;
  readonly text: string;
  readonly action?: 'input' | 'click';
  readonly reveal?: readonly string[];
  readonly unavailable?: string;
}

export const tours: Record<TourKind, { title: string; steps: readonly TourStep[] }> = {
  projects: {
    title: 'Tu primer proyecto',
    steps: [
      {
        id: 'name',
        target: 'nombre-proyecto',
        title: 'Ponle nombre a tu proyecto',
        text: 'Escribe un nombre, por ejemplo Sistema de ventas. Aquí reunirás sus diagramas y participantes.',
        action: 'input',
      },
      {
        id: 'create',
        target: 'crear-proyecto',
        title: 'Crea el espacio de trabajo',
        text: 'Pulsa Crear proyecto cuando el nombre esté listo. Entrarás al proyecto y continuaremos con tu primera pizarra.',
        action: 'click',
      },
      {
        id: 'list',
        target: 'lista-proyectos',
        title: 'O abre un proyecto existente',
        text: 'Pulsa el nombre del proyecto en el que quieras trabajar. El recorrido seguirá en esa pantalla.',
      },
      {
        id: 'join',
        target: 'codigo-invitacion',
        title: 'También puedes unirte a un equipo',
        text: 'Si alguien te pasó un código, escríbelo aquí y pulsa Unirme. El código determina tu permiso como editor o lector.',
      },
    ],
  },
  project: {
    title: 'Prepara tu pizarra',
    steps: [
      {
        id: 'name',
        target: 'nombre-pizarra',
        title: 'Nombra tu diagrama',
        text: 'Escribe el nombre de tu pizarra. Un proyecto puede contener varios diagramas independientes.',
        action: 'input',
      },
      {
        id: 'create',
        target: 'crear-pizarra',
        title: 'Añade la pizarra',
        text: 'Pulsa Nueva pizarra. Cuando aparezca en la lista, podrás abrirla para empezar a dibujar.',
        action: 'click',
      },
      {
        id: 'open',
        target: 'lista-pizarras',
        title: 'Entra al editor',
        text: 'Pulsa el nombre de una pizarra. Te acompañaré por las herramientas del editor.',
      },
      {
        id: 'invite',
        target: 'invitar-editor',
        title: 'Invita a tu equipo',
        text: 'Editor genera un código para quienes modificarán el diagrama. Lector es para quienes solo revisarán. Comparte el código que generes.',
        unavailable:
          'Las invitaciones las administra el propietario. Puedes omitir este paso si tu rol no permite invitar.',
      },
    ],
  },
  board: {
    title: 'Aprende en tu diagrama',
    steps: [
      {
        id: 'create',
        target: 'crear-clase',
        title: 'Añade tu primera clase',
        text: 'Pulsa Nueva clase para crear una entidad real en esta pizarra. Si ya tienes clases, selecciona una y omite este paso.',
        action: 'click',
      },
      {
        id: 'name',
        target: 'nombre-clase',
        title: 'Dale un nombre que describa el concepto',
        text: 'Escribe Cliente, Producto u otro concepto de tu sistema. Las propiedades se actualizan al editar.',
        action: 'input',
        reveal: ['alternar-panel'],
        unavailable: 'Selecciona una clase del diagrama para ver su nombre y sus propiedades.',
      },
      {
        id: 'attribute',
        target: 'nuevo-atributo',
        title: 'Describe sus datos',
        text: 'Escribe el nombre de un atributo, por ejemplo correo, y pulsa Añadir. Después podrás elegir su tipo y marcar si es requerido, único o clave primaria.',
        action: 'input',
        reveal: ['alternar-panel'],
        unavailable: 'Selecciona una clase para añadir o revisar sus atributos.',
      },
      {
        id: 'relationships',
        target: 'tool-association',
        title: 'Conecta tus conceptos',
        text: 'Elige Asociación y pulsa la clase de origen y luego la de destino. Selecciona la línea para revisar sus multiplicidades. Necesitas dos clases para conectarlas.',
        reveal: ['alternar-toolbox'],
      },
      {
        id: 'validation',
        target: 'panel-validacion',
        title: 'Revisa el modelo antes de generar',
        text: 'Aquí aparecen errores y avisos del diagrama. Selecciona el elemento afectado y corrige sus propiedades. Los errores bloquean la generación.',
        reveal: ['alternar-panel'],
      },
      {
        id: 'assistant',
        target: 'entrada-asistente',
        title: 'Pide ayuda con tus palabras',
        text: 'En Consultar puedes preguntar sobre el diagrama. En Instruir, escribe un cambio concreto; Enviar prepara una propuesta que debes revisar antes de Aplicar.',
        reveal: ['alternar-panel', 'pestana-asistente'],
      },
      {
        id: 'import',
        target: 'modo-importacion',
        title: 'Recupera trabajo que ya tienes',
        text: 'Elige Añadir a lo que hay o Reemplazar el contenido antes de importar XMI o una imagen. Revisa la propuesta antes de aplicarla. Exportar XMI te permite conservar una copia.',
        reveal: ['alternar-panel', 'pestana-importar'],
      },
      {
        id: 'generation',
        target: 'incluir-flutter',
        title: 'Elige lo que vas a construir',
        text: 'Activa esta opción si también necesitas el proyecto Flutter Android. Sin ella generarás el backend. El ZIP contiene código; la APK se compila con apk.bat o apk.sh desde su raíz (Flutter instalado), que también la instalan en el teléfono por USB.',
        reveal: ['alternar-panel', 'pestana-generar'],
      },
      {
        id: 'download',
        target: 'generar',
        title: 'Genera cuando estés listo',
        text: 'Pulsa Generar proyecto cuando tu modelo esté listo. Al terminar aparecerán las descargas. Si el botón está bloqueado, revisa errores y permisos; puedes finalizar este recorrido sin generar.',
        reveal: ['alternar-panel', 'pestana-generar'],
      },
    ],
  },
  account: {
    title: 'Tu cuenta',
    steps: [
      {
        id: 'profile',
        target: 'perfil-nombre',
        title: 'Tu identidad en el equipo',
        text: 'Aquí puedes editar tu nombre de perfil. Guarda el cambio solo cuando quieras actualizarlo.',
      },
      {
        id: 'photo',
        target: 'elegir-foto',
        title: 'Personaliza tu perfil',
        text: 'Este control permite elegir una foto. Puedes conservar la actual y pasar al siguiente paso.',
      },
      {
        id: 'password',
        target: 'password-actual',
        title: 'Actualiza tu contraseña',
        text: 'Para cambiarla, introduce la actual y repite la nueva en los campos correspondientes. El recorrido no necesita que escribas ninguna contraseña.',
      },
    ],
  },
};

export function tourForPath(path: string): TourKind | null {
  if (path === '/proyectos') return 'projects';
  if (/^\/proyectos\/[^/]+$/.test(path)) return 'project';
  if (/^\/pizarras\/[^/]+$/.test(path)) return 'board';
  return path === '/cuenta' ? 'account' : null;
}

export const tourProgressKey = 'uml.interactive-tour.v1';
export function readTourStep(raw: string | null, kind: TourKind): number {
  try {
    const value: unknown = JSON.parse(raw ?? 'null');
    if (
      value &&
      typeof value === 'object' &&
      'kind' in value &&
      'step' in value &&
      value.kind === kind
    ) {
      return tours[kind].steps.findIndex((step) => step.id === value.step);
    }
  } catch {
    /* Reading the guide is possible without storage. */
  }
  return -1;
}
```

---

### `frontend/src/features/help/use-tour-target.ts`

```ts
import { useEffect, useState } from 'react';
import type { TourStep } from './tour-steps.js';

export function tourTarget(testId: string): HTMLElement | null {
  return document.querySelector<HTMLElement>(`[data-testid="${testId}"]`);
}

export function useTourTarget(step: TourStep | undefined) {
  const [anchor, setAnchor] = useState<{
    x: number;
    y: number;
    width: number;
    height: number;
    disabled: boolean;
  } | null>(null);
  const [done, setDone] = useState(false);
  useEffect(() => {
    setDone(false);
    setAnchor(null);
    if (!step) return;
    let frame = 0;
    let scrolled: HTMLElement | null = null;
    const measure = () => {
      frame = 0;
      const target = tourTarget(step.target);
      if (!target || target.closest('[hidden]') || target.getClientRects().length === 0) {
        setAnchor(null);
        return;
      }
      if (scrolled !== target) {
        scrolled = target;
        target.scrollIntoView({ block: 'center', inline: 'nearest', behavior: 'instant' });
      }
      const box = target.getBoundingClientRect();
      const next = {
        x: box.x,
        y: box.y,
        width: box.width,
        height: box.height,
        disabled: target.matches(':disabled'),
      };
      setAnchor((old) =>
        old &&
        Object.keys(next).every(
          (key) => old[key as keyof typeof old] === next[key as keyof typeof next],
        )
          ? old
          : next,
      );
    };
    const schedule = () => {
      if (!frame) frame = requestAnimationFrame(measure);
    };
    const checkAction = (event: Event) => {
      const target = tourTarget(step.target);
      if (
        !target ||
        target.matches(':disabled') ||
        !(event.target instanceof Node) ||
        !target.contains(event.target)
      )
        return;
      if (step.action === 'click' && event.type === 'click') setDone(true);
      if (
        step.action === 'input' &&
        event.type === 'input' &&
        (target instanceof HTMLInputElement || target instanceof HTMLTextAreaElement)
      ) {
        setDone(target.value.trim().length > 0);
      }
    };
    // Panel visibility changes and async data can replace or move a target.
    const observer = new MutationObserver((changes) => {
      if (
        changes.some(
          (change) =>
            !(
              change.target instanceof Element ? change.target : change.target.parentElement
            )?.closest('[data-tour-ui]'),
        )
      )
        schedule();
    });
    observer.observe(document.body, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['hidden', 'disabled', 'class', 'style'],
    });
    const resize = () => {
      // Responsive layouts can move an unchanged target outside the viewport.
      scrolled = null;
      schedule();
    };
    window.addEventListener('resize', resize);
    window.addEventListener('scroll', schedule, true);
    document.addEventListener('input', checkAction);
    document.addEventListener('click', checkAction);
    schedule();
    return () => {
      observer.disconnect();
      cancelAnimationFrame(frame);
      window.removeEventListener('resize', resize);
      window.removeEventListener('scroll', schedule, true);
      document.removeEventListener('input', checkAction);
      document.removeEventListener('click', checkAction);
    };
  }, [step]);
  return { anchor, done };
}
```

---

### `frontend/src/features/import/CandidateEditor.tsx`

```tsx
import {
  CONCEPTUAL_TYPES,
  MULTIPLICITIES,
  RELATIONSHIP_KINDS,
  type BoardState,
  type Command,
  type CommandBatch,
} from '@uml/contracts';

export function CandidateEditor({
  batch,
  state,
  onChange,
  onRemove,
}: {
  readonly batch: CommandBatch;
  readonly state: BoardState;
  onChange(commandId: string, editar: (command: Command) => Command): void;
  onRemove(commandId: string): void;
}): React.JSX.Element {
  const nombres = new Map(
    state.semantic.classes.map((umlClass) => [umlClass.id, umlClass.displayName]),
  );
  for (const command of batch.commands) {
    if (command.type === 'CREATE_CLASS')
      nombres.set(command.payload.classId, command.payload.displayName);
  }

  return (
    <div className="editor-candidato" data-testid="editor-candidato">
      {batch.commands.map((command, indice) => {
        const numero = indice + 1;
        const render = (): React.JSX.Element => {
          if (command.type === 'CREATE_CLASS' || command.type === 'RENAME_CLASS') {
            return (
              <label className="fila-candidato" key={command.commandId}>
                <span>
                  {command.type === 'CREATE_CLASS' ? `Clase ${numero}` : `Renombrar ${numero}`}
                </span>
                <input
                  value={command.payload.displayName}
                  aria-label={`Nombre de clase ${numero}`}
                  onChange={(evento) =>
                    onChange(command.commandId, (actual) => {
                      if (actual.type !== command.type) return actual;
                      return {
                        ...actual,
                        payload: { ...actual.payload, displayName: evento.target.value },
                      };
                    })
                  }
                />
              </label>
            );
          }

          if (command.type === 'ADD_ATTRIBUTE') {
            return (
              <div className="fila-candidato atributo-candidato" key={command.commandId}>
                <span>{nombres.get(command.payload.classId) ?? 'Clase'} · atributo</span>
                <input
                  value={command.payload.displayName}
                  aria-label={`Nombre de atributo ${numero}`}
                  onChange={(evento) =>
                    onChange(command.commandId, (actual) =>
                      actual.type === 'ADD_ATTRIBUTE'
                        ? {
                            ...actual,
                            payload: { ...actual.payload, displayName: evento.target.value },
                          }
                        : actual,
                    )
                  }
                />
                <select
                  value={command.payload.type}
                  aria-label={`Tipo de atributo ${numero}`}
                  onChange={(evento) =>
                    onChange(command.commandId, (actual) =>
                      actual.type === 'ADD_ATTRIBUTE'
                        ? {
                            ...actual,
                            payload: {
                              ...actual.payload,
                              type: evento.target.value as (typeof CONCEPTUAL_TYPES)[number],
                            },
                          }
                        : actual,
                    )
                  }
                >
                  {CONCEPTUAL_TYPES.map((tipo) => (
                    <option key={tipo}>{tipo}</option>
                  ))}
                </select>
                <label className="marca-candidato">
                  <input
                    type="checkbox"
                    checked={command.payload.primaryKey ?? false}
                    onChange={(evento) =>
                      onChange(command.commandId, (actual) =>
                        actual.type === 'ADD_ATTRIBUTE'
                          ? {
                              ...actual,
                              payload: { ...actual.payload, primaryKey: evento.target.checked },
                            }
                          : actual,
                      )
                    }
                  />
                  PK
                </label>
                <label className="marca-candidato">
                  <input
                    type="checkbox"
                    checked={!(command.payload.nullable ?? true)}
                    onChange={(evento) =>
                      onChange(command.commandId, (actual) =>
                        actual.type === 'ADD_ATTRIBUTE'
                          ? {
                              ...actual,
                              payload: { ...actual.payload, nullable: !evento.target.checked },
                            }
                          : actual,
                      )
                    }
                  />
                  obligatorio
                </label>
                <label className="marca-candidato">
                  <input
                    type="checkbox"
                    checked={command.payload.unique ?? false}
                    onChange={(e) =>
                      onChange(command.commandId, (actual) =>
                        actual.type === 'ADD_ATTRIBUTE'
                          ? { ...actual, payload: { ...actual.payload, unique: e.target.checked } }
                          : actual,
                      )
                    }
                  />
                  Único
                </label>
              </div>
            );
          }

          if (command.type === 'CREATE_RELATIONSHIP') {
            return (
              <div className="fila-candidato relacion-candidato" key={command.commandId}>
                <select
                  aria-label={`Tipo de relación ${numero}`}
                  value={command.payload.kind ?? 'ASSOCIATION'}
                  onChange={(e) =>
                    onChange(command.commandId, (actual) =>
                      actual.type === 'CREATE_RELATIONSHIP'
                        ? {
                            ...actual,
                            payload: {
                              ...actual.payload,
                              kind: e.target.value as (typeof RELATIONSHIP_KINDS)[number],
                            },
                          }
                        : actual,
                    )
                  }
                >
                  {RELATIONSHIP_KINDS.map((kind) => (
                    <option key={kind} value={kind}>
                      {kind}
                    </option>
                  ))}
                </select>
                {(['sourceClassId', 'targetClassId'] as const).map((field, i) => (
                  <label key={field}>
                    <span>{i === 0 ? 'Clase origen' : 'Clase destino'}</span>
                    <select
                      aria-label={`${i === 0 ? 'Clase origen' : 'Clase destino'} ${numero}`}
                      value={command.payload[field]}
                      onChange={(e) =>
                        onChange(command.commandId, (actual) =>
                          actual.type === 'CREATE_RELATIONSHIP'
                            ? { ...actual, payload: { ...actual.payload, [field]: e.target.value } }
                            : actual,
                        )
                      }
                    >
                      {[...nombres].map(([id, name]) => (
                        <option key={id} value={id}>
                          {name}
                        </option>
                      ))}
                    </select>
                  </label>
                ))}
                {(['sourceRoleName', 'targetRoleName'] as const).map((field, i) => (
                  <label key={field}>
                    <span>{i === 0 ? 'Rol origen' : 'Rol destino'}</span>
                    <input
                      aria-label={`${i === 0 ? 'Rol origen' : 'Rol destino'} ${numero}`}
                      value={command.payload[field] ?? ''}
                      onChange={(e) =>
                        onChange(command.commandId, (actual) => {
                          if (actual.type !== 'CREATE_RELATIONSHIP') return actual;
                          const payload = { ...actual.payload };
                          if (e.target.value.trim() === '') delete payload[field];
                          else payload[field] = e.target.value;
                          return { ...actual, payload };
                        })
                      }
                    />
                  </label>
                ))}
                <span>
                  {nombres.get(command.payload.sourceClassId) ?? 'Clase'} →{' '}
                  {nombres.get(command.payload.targetClassId) ?? 'Clase'}
                </span>
                <select
                  value={command.payload.sourceMultiplicity}
                  aria-label={`Multiplicidad origen ${numero}`}
                  onChange={(evento) =>
                    onChange(command.commandId, (actual) =>
                      actual.type === 'CREATE_RELATIONSHIP'
                        ? {
                            ...actual,
                            payload: {
                              ...actual.payload,
                              sourceMultiplicity: evento.target
                                .value as (typeof MULTIPLICITIES)[number],
                            },
                          }
                        : actual,
                    )
                  }
                >
                  {MULTIPLICITIES.map((multiplicidad) => (
                    <option key={multiplicidad}>{multiplicidad}</option>
                  ))}
                </select>
                <span>—</span>
                <select
                  value={command.payload.targetMultiplicity}
                  aria-label={`Multiplicidad destino ${numero}`}
                  onChange={(evento) =>
                    onChange(command.commandId, (actual) =>
                      actual.type === 'CREATE_RELATIONSHIP'
                        ? {
                            ...actual,
                            payload: {
                              ...actual.payload,
                              targetMultiplicity: evento.target
                                .value as (typeof MULTIPLICITIES)[number],
                            },
                          }
                        : actual,
                    )
                  }
                >
                  {MULTIPLICITIES.map((multiplicidad) => (
                    <option key={multiplicidad}>{multiplicidad}</option>
                  ))}
                </select>
              </div>
            );
          }

          return (
            <div className="fila-candidato solo-lectura" key={command.commandId}>
              <span>{etiquetaComando(command, nombres)}</span>
            </div>
          );
        };
        return (
          <div className="operacion-candidato" key={command.commandId}>
            {render()}
            <button
              type="button"
              className="quitar"
              aria-label={`Quitar operación ${numero}`}
              onClick={() => onRemove(command.commandId)}
            >
              ×
            </button>
          </div>
        );
      })}
    </div>
  );
}

export function etiquetaComando(command: Command, nombres: ReadonlyMap<string, string>): string {
  switch (command.type) {
    case 'CREATE_CLASS':
      return `Crear clase ${command.payload.displayName}`;
    case 'RENAME_CLASS':
      return `Renombrar a ${command.payload.displayName}`;
    case 'ADD_ATTRIBUTE':
      return `Añadir ${command.payload.displayName}: ${command.payload.type} a ${nombres.get(command.payload.classId) ?? 'clase'}`;
    case 'CREATE_RELATIONSHIP':
      return `${nombres.get(command.payload.sourceClassId) ?? 'clase'} [${command.payload.sourceRoleName ?? ''} ${command.payload.sourceMultiplicity}] → ${nombres.get(command.payload.targetClassId) ?? 'clase'} [${command.payload.targetRoleName ?? ''} ${command.payload.targetMultiplicity}] (${command.payload.kind ?? 'ASSOCIATION'})`;
    case 'UPDATE_ATTRIBUTE':
      return `Actualizar atributo de ${nombres.get(command.payload.classId) ?? 'clase'}`;
    case 'DELETE_CLASS':
      return `Eliminar clase ${nombres.get(command.payload.classId) ?? ''}`;
    case 'DELETE_ATTRIBUTE':
      return `Eliminar atributo de ${nombres.get(command.payload.classId) ?? 'clase'}`;
    case 'DELETE_RELATIONSHIP':
      return 'Eliminar relación existente';
    case 'CHANGE_MULTIPLICITY':
      return 'Cambiar multiplicidad';
    case 'UPDATE_RELATIONSHIP':
      return 'Actualizar relación';
    case 'MOVE_CLASS':
      return `Mover clase ${nombres.get(command.payload.classId) ?? ''}`;
  }
}
```

---

### `frontend/src/features/import/CapturaCamara.tsx`

```tsx
import { useCallback, useEffect, useRef, useState } from 'react';

/**
 * Toma una foto con la cámara del dispositivo, sin salir de la aplicación.
 *
 * Existe porque subir un archivo obliga a un rodeo: sacar la foto con el
 * teléfono, pasarla al portátil y buscarla en el explorador. Con la cámara
 * abierta dentro del panel, el diagrama del pizarrón entra en dos toques.
 *
 * Funciona igual con la cámara trasera de un teléfono y con una cámara web:
 * `facingMode: 'environment'` es una preferencia, no una exigencia, así que un
 * portátil que solo tiene cámara frontal la usa sin fallar.
 */

export interface CapturaCamaraProps {
  /** Entrega la foto ya como archivo, listo para el mismo camino que subir uno. */
  onCaptura(archivo: File): void;
  onCerrar(): void;
}

export function CapturaCamara({ onCaptura, onCerrar }: CapturaCamaraProps): React.JSX.Element {
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [lista, setLista] = useState(false);

  const detener = useCallback(() => {
    for (const pista of streamRef.current?.getTracks() ?? []) pista.stop();
    streamRef.current = null;
  }, []);

  useEffect(() => {
    let cancelado = false;

    async function abrir(): Promise<void> {
      if (navigator.mediaDevices?.getUserMedia === undefined) {
        setError('Este navegador no da acceso a la cámara. Sube la foto como archivo.');
        return;
      }

      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: 'environment', width: { ideal: 1920 } },
          audio: false,
        });

        // Si el panel se cerró mientras se pedía el permiso, la cámara tiene
        // que apagarse igual: dejar el piloto encendido asusta, y con razón.
        if (cancelado) {
          for (const pista of stream.getTracks()) pista.stop();
          return;
        }

        streamRef.current = stream;
        if (videoRef.current !== null) {
          videoRef.current.srcObject = stream;
          // No basta con tener el flujo: hasta que no llegan los metadatos,
          // `videoWidth` y `videoHeight` valen cero y la captura saldria como
          // un lienzo de 0x0. Se habilita el boton cuando hay medidas.
          videoRef.current.onloadedmetadata = () => setLista(true);
        }
      } catch (causa) {
        setError(motivo(causa));
      }
    }

    void abrir();

    return () => {
      cancelado = true;
      detener();
    };
  }, [detener]);

  function tomar(): void {
    const video = videoRef.current;
    if (video === null || !lista) return;

    if (video.videoWidth === 0 || video.videoHeight === 0) {
      setError('La cámara todavía no entrega imagen. Espera un momento e inténtalo otra vez.');
      return;
    }

    const lienzo = document.createElement('canvas');
    lienzo.width = video.videoWidth;
    lienzo.height = video.videoHeight;
    lienzo.getContext('2d')?.drawImage(video, 0, 0);

    // JPEG y no PNG: la foto de un pizarrón en PNG son varios megabytes y viaja
    // en base64 dentro de la petición. La calidad de 0,92 no pierde trazo.
    lienzo.toBlob(
      (blob) => {
        if (blob === null) {
          setError('No se pudo capturar la imagen.');
          return;
        }
        const sello = new Date().toISOString().slice(0, 19).replaceAll(':', '-');
        onCaptura(new File([blob], `captura-${sello}.jpg`, { type: 'image/jpeg' }));
      },
      'image/jpeg',
      0.92,
    );
  }

  return (
    <div className="camara" data-testid="camara">
      {error === null ? (
        <>
          <video
            ref={videoRef}
            className="camara-vista"
            autoPlay
            playsInline
            muted
            aria-label="Vista de la cámara"
          />
          <div className="camara-acciones">
            <button type="button" onClick={tomar} disabled={!lista} data-testid="tomar-foto">
              {lista ? 'Tomar foto' : 'Abriendo cámara…'}
            </button>
            <button type="button" className="secundario" onClick={onCerrar}>
              Cancelar
            </button>
          </div>
        </>
      ) : (
        <>
          <p className="error" data-testid="error-camara">
            {error}
          </p>
          <button type="button" className="secundario" onClick={onCerrar}>
            Cerrar
          </button>
        </>
      )}
    </div>
  );
}

/**
 * El motivo, en palabras que digan qué hacer.
 *
 * «NotAllowedError» no le sirve a nadie: lo que hace falta saber es si el
 * permiso está denegado, si no hay cámara o si otra aplicación la tiene tomada.
 */
function motivo(causa: unknown): string {
  const nombre = causa instanceof Error ? causa.name : '';

  switch (nombre) {
    case 'NotAllowedError':
    case 'SecurityError':
      return 'No diste permiso para usar la cámara. Actívalo en el candado de la barra de direcciones.';
    case 'NotFoundError':
    case 'OverconstrainedError':
      return 'No se encontró ninguna cámara en este equipo.';
    case 'NotReadableError':
      return 'La cámara está ocupada por otra aplicación.';
    default:
      return 'No se pudo abrir la cámara. Sube la foto como archivo.';
  }
}
```

---

### `frontend/src/features/import/ExportImage.tsx`

```tsx
import { useState } from 'react';
import { descargarBlob, nombreDeArchivo } from '../../lib/guardar-archivo.js';

export function ExportImage({
  boardName,
  empty,
}: {
  readonly boardName: string;
  readonly empty: boolean;
}) {
  const [name, setName] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  async function download() {
    if (busy || name === null) return;
    setBusy(true);
    setError(null);
    setSuccess(null);
    try {
      const { exportDiagramPng } = await import('../editor/export-image.js');
      const blob = await exportDiagramPng();
      const filename = nombreDeArchivo(name, '.png');
      descargarBlob(blob, filename);
      setName(null);
      setSuccess(`Exportado como ${filename}`);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'La exportación de imagen falló.');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div>
      <button
        type="button"
        data-testid="exportar-png"
        disabled={empty || busy}
        onClick={() => {
          setName(boardName);
          setError(null);
          setSuccess(null);
        }}
      >
        Exportar imagen PNG
      </button>
      <p className="pista">
        {empty
          ? 'Añade una clase para exportar una imagen.'
          : 'Descarga el diagrama completo con el tema actual, también lo que queda fuera de la vista.'}
      </p>
      {name !== null && (
        <form
          className="nombre-export"
          aria-label="Exportar imagen PNG"
          aria-busy={busy}
          onSubmit={(event) => {
            event.preventDefault();
            void download();
          }}
        >
          <label>
            <span>Nombre de la imagen</span>
            <input
              autoFocus
              value={name}
              disabled={busy}
              onChange={(event) => setName(event.target.value)}
            />
          </label>
          <p className="pista">
            Se guardará como <code>{nombreDeArchivo(name, '.png')}</code>
          </p>
          <div className="acciones">
            <button type="submit" disabled={busy || empty}>
              {busy ? 'Preparando imagen…' : 'Guardar PNG'}
            </button>
            <button
              type="button"
              className="secundario"
              disabled={busy}
              onClick={() => setName(null)}
            >
              Cancelar
            </button>
          </div>
        </form>
      )}
      {error !== null && (
        <p className="error" role="alert">
          {error}
        </p>
      )}
      {success !== null && (
        <p className="aplicada" role="status">
          {success}
        </p>
      )}
    </div>
  );
}
```

---

### `frontend/src/features/import/ImportPanel.tsx`

```tsx
import {
  type BoardState,
  type Command,
  type CommandBatch,
  type SemanticModel,
  type ValidationIssue,
} from '@uml/contracts';
import { useLayoutEffect, useMemo, useRef, useState } from 'react';
import { planBatch, validateModel } from '@uml/domain-core';
import { CandidateEditor, etiquetaComando } from './CandidateEditor.js';
import { removeCandidateCommand } from './candidate.js';
import { apiRequest, downloadXmi } from '../../lib/api.js';
import { descargarBlob, nombreDeArchivo } from '../../lib/guardar-archivo.js';
import { CapturaCamara } from './CapturaCamara.js';
import { ExportImage } from './ExportImage.js';

/**
 * Importacion por foto y XMI, y exportacion a XMI (M4 y M5).
 *
 * La foto entra de dos maneras: subiendo un archivo o tomandola con la camara
 * del dispositivo. La segunda existe porque la primera obliga a un rodeo —sacar
 * la foto con el telefono, pasarla al portatil, buscarla en el explorador— y en
 * una defensa ese rodeo son minutos delante del tribunal.
 *
 * **Nada se aplica solo.** Lo que llega es un candidato con su resumen, y el
 * usuario lo revisa antes de aceptarlo: leer un diagrama a mano se va a
 * equivocar en algo, y un candidato que no se puede corregir no sirve (CA-042.1).
 *
 * Los campos principales del candidato se pueden corregir aqui antes de aplicar.
 * El lote conserva sus UUID resueltos; editar un nombre o un tipo no abre una
 * segunda via de escritura y sigue pasando por el mismo aplicador atomico.
 */

type Outcome =
  | { kind: 'BATCH'; batch: CommandBatch; summary: string[] }
  | { kind: 'CONFIRMATION'; batch: CommandBatch; summary: string[]; question: string }
  | { kind: 'QUESTION'; question: string; options?: string[] }
  | { kind: 'NO_CHANGES'; message: string }
  | { kind: 'REJECTED'; issues: ValidationIssue[] };

type Respuesta = Outcome & {
  rationale: string | null;
  warnings: { element: string; reason: string }[];
};

export interface ImportPanelProps {
  readonly boardId: string;
  readonly boardName: string;
  readonly state: BoardState;
  readonly canWrite: boolean;
  apply(
    batch: CommandBatch,
    expected?: SemanticModel,
    scope?: 'AFFECTED' | 'MODEL',
  ): readonly ValidationIssue[] | null;
}

type Modo = 'ADD' | 'REPLACE';
type Fuente =
  | { kind: 'XMI'; name: string; xml: string }
  | { kind: 'IMAGE'; name: string; image: string; mediaType: string };

export function ImportPanel({
  boardId,
  boardName,
  state,
  canWrite,
  apply,
}: ImportPanelProps): React.JSX.Element {
  const [candidato, setCandidato] = useState<Respuesta | null>(null);
  const [baseCandidato, setBaseCandidato] = useState<{ model: SemanticModel; modo: Modo } | null>(
    null,
  );
  const [obsoleto, setObsoleto] = useState(false);
  const [aplicado, setAplicado] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pendiente, setPendiente] = useState(false);
  const [modo, setModo] = useState<Modo>('ADD');
  const [fuente, setFuente] = useState<Fuente | null>(null);
  const [camaraAbierta, setCamaraAbierta] = useState(false);
  const [nombreExport, setNombreExport] = useState<string | null>(null);
  const [formatoExport, setFormatoExport] = useState<'EA_21' | 'UML_251'>('EA_21');
  const imagenRef = useRef<HTMLInputElement>(null);
  const xmiRef = useRef<HTMLInputElement>(null);
  const exportRef = useRef<HTMLFormElement>(null);
  const candidateRef = useRef<HTMLDivElement>(null);
  const exportOpen = nombreExport !== null;
  const candidateOpen = candidato !== null;

  // Los formularios se insertan debajo de los controles de importación. Al
  // abrirlos, desplaza el panel hasta el trabajo nuevo, sin moverlo al escribir.
  //
  // El desplazamiento se repite en el siguiente cuadro: al insertar el
  // formulario, el panel todavía no conoce su alto final —`:has(.candidato)` le
  // cambia el reparto de la columna— y el primer intento no tiene nada que
  // desplazar. Sin la segunda pasada, el panel se queda arriba y lo nuevo
  // aparece fuera de la vista.
  useAparecerALaVista(exportOpen, exportRef, 'end');
  // Y hasta las filas editables, no hasta la cabecera del candidato: alinear su
  // principio dejaba justo el editor debajo de la barra fija de «Aplicar», que
  // se pega al pie del panel. Se veía el botón y no lo que hay que corregir.
  useAparecerALaVista(candidateOpen, candidateRef, 'start', '.editor-candidato');
  const preview = useMemo(() => {
    if (candidato === null || !('batch' in candidato)) return null;
    const plan = planBatch(state, candidato.batch);
    return {
      applied: plan.applied,
      issues: plan.applied ? validateModel(plan.state.semantic) : plan.issues,
    };
  }, [candidato, state]);
  const nombres = new Map(state.semantic.classes.map((c) => [c.id, c.displayName]));
  if (candidato !== null && 'batch' in candidato)
    for (const c of candidato.batch.commands) {
      if (c.type === 'CREATE_CLASS' || c.type === 'RENAME_CLASS')
        nombres.set(c.payload.classId, c.payload.displayName);
    }
  const resumen =
    candidato !== null && 'batch' in candidato
      ? candidato.batch.commands.map((c) => etiquetaComando(c, nombres))
      : [];

  async function enviar(hacer: () => Promise<Respuesta>): Promise<void> {
    setPendiente(true);
    setError(null);
    setAplicado(null);
    setCandidato(null);
    setObsoleto(false);

    try {
      setCandidato(await hacer());
    } catch (causa) {
      setError(causa instanceof Error ? causa.message : 'La importación falló.');
    } finally {
      setPendiente(false);
    }
  }

  async function importarImagen(archivo: File): Promise<void> {
    const base64 = await leerBase64(archivo);
    const nuevaFuente: Fuente = {
      kind: 'IMAGE',
      name: archivo.name,
      image: base64,
      mediaType: archivo.type,
    };
    setFuente(nuevaFuente);
    await importarFuente(nuevaFuente, modo);
  }

  async function importarXmi(archivo: File): Promise<void> {
    const xml = await archivo.text();
    const nuevaFuente: Fuente = { kind: 'XMI', name: archivo.name, xml };
    setFuente(nuevaFuente);
    await importarFuente(nuevaFuente, modo);
  }

  async function importarFuente(origen: Fuente, nuevoModo: Modo): Promise<void> {
    setBaseCandidato({ model: state.semantic, modo: nuevoModo });
    await enviar(() =>
      origen.kind === 'XMI'
        ? apiRequest<Respuesta>(`/boards/${boardId}/import/xmi`, {
            method: 'POST',
            body: { xml: origen.xml, mode: nuevoModo, model: state.semantic },
          })
        : apiRequest<Respuesta>(`/boards/${boardId}/import/image`, {
            method: 'POST',
            body: {
              image: origen.image,
              mediaType: origen.mediaType,
              mode: nuevoModo,
              model: state.semantic,
            },
          }),
    );
  }

  async function reintentarReemplazando(): Promise<void> {
    if (fuente === null) return;
    setModo('REPLACE');
    await importarFuente(fuente, 'REPLACE');
  }

  async function exportar(): Promise<void> {
    setError(null);

    try {
      const { blob } = await downloadXmi(boardId, state.semantic, state.layout, formatoExport);
      const nombre = nombreDeArchivo(nombreExport ?? boardName, '.xmi');

      descargarBlob(blob, nombre);
      setNombreExport(null);
      setAplicado(`Exportado como ${nombre}`);
    } catch (causa) {
      setError(causa instanceof Error ? causa.message : 'La exportación falló.');
    }
  }

  function aplicar(batch: CommandBatch, resumen: readonly string[]): void {
    if (baseCandidato === null || obsoleto) return;
    const rechazo = apply(
      batch,
      baseCandidato.model,
      baseCandidato.modo === 'REPLACE' ? 'MODEL' : 'AFFECTED',
    );

    if (rechazo !== null && rechazo.length > 0) {
      const stale = rechazo.some((issue) => issue.code === 'STALE_PROPOSAL');
      setObsoleto(stale);
      setError(
        stale
          ? 'La pizarra cambió desde que se preparó la importación. Vuelve a preparar el archivo y revisa el candidato nuevo; las correcciones del candidato anterior deberán revisarse de nuevo.'
          : `No se pudo aplicar: ${rechazo[0]?.message ?? 'el lote fue rechazado.'}`,
      );
      return;
    }

    // El candidato desaparecia sin decir nada, y desde el panel no se ve el
    // lienzo entero: quedaba la duda de si se habia aplicado o descartado.
    setAplicado(`Aplicado: ${resumen.length} ${resumen.length === 1 ? 'cambio' : 'cambios'}.`);
    setCandidato(null);
    setFuente(null);
  }

  function actualizarComando(commandId: string, editar: (command: Command) => Command): void {
    setCandidato((actual) => {
      if (actual === null || (actual.kind !== 'BATCH' && actual.kind !== 'CONFIRMATION')) {
        return actual;
      }
      return {
        ...actual,
        batch: {
          ...actual.batch,
          commands: actual.batch.commands.map((command) =>
            command.commandId === commandId ? editar(command) : command,
          ),
        },
      };
    });
  }

  return (
    <section className="importacion" data-testid="importacion">
      <h3>Importar y exportar</h3>

      <label className="modo">
        <span>Al importar</span>
        <select
          value={modo}
          disabled={!canWrite || pendiente || candidato !== null}
          data-testid="modo-importacion"
          onChange={(evento) => setModo(evento.target.value as Modo)}
        >
          <option value="ADD">Añadir a lo que hay</option>
          <option value="REPLACE">Reemplazar el contenido</option>
        </select>
      </label>

      <div className="acciones">
        <button
          type="button"
          disabled={!canWrite || pendiente}
          data-testid="importar-imagen"
          onClick={() => imagenRef.current?.click()}
        >
          {pendiente ? 'Leyendo…' : 'Subir foto'}
        </button>

        <button
          type="button"
          disabled={!canWrite || pendiente}
          data-testid="abrir-camara"
          onClick={() => setCamaraAbierta(true)}
        >
          Tomar foto
        </button>

        <button
          type="button"
          disabled={!canWrite || pendiente}
          data-testid="importar-xmi"
          onClick={() => xmiRef.current?.click()}
        >
          Importar XMI
        </button>

        <button type="button" data-testid="exportar-xmi" onClick={() => setNombreExport(boardName)}>
          Exportar XMI
        </button>
      </div>

      <ExportImage boardName={boardName} empty={state.semantic.classes.length === 0} />

      <input
        ref={imagenRef}
        type="file"
        accept="image/png,image/jpeg,image/webp,image/gif"
        hidden
        data-testid="archivo-imagen"
        onChange={(evento) => {
          const archivo = evento.target.files?.[0];
          evento.target.value = '';
          if (archivo !== undefined) void importarImagen(archivo);
        }}
      />

      <input
        ref={xmiRef}
        type="file"
        accept=".xmi,.xml,text/xml,application/xml"
        hidden
        data-testid="archivo-xmi"
        onChange={(evento) => {
          const archivo = evento.target.files?.[0];
          evento.target.value = '';
          if (archivo !== undefined) void importarXmi(archivo);
        }}
      />

      {nombreExport !== null && (
        <form
          ref={exportRef}
          className="nombre-export"
          data-testid="nombre-export"
          onSubmit={(evento) => {
            evento.preventDefault();
            void exportar();
          }}
        >
          <label>
            <span>Nombre del archivo</span>
            <input
              value={nombreExport}
              autoFocus
              data-testid="campo-nombre-export"
              onChange={(evento) => setNombreExport(evento.target.value)}
            />
          </label>
          <label>
            <span>Formato XMI</span>
            <select
              value={formatoExport}
              onChange={(evento) =>
                setFormatoExport(evento.target.value === 'UML_251' ? 'UML_251' : 'EA_21')
              }
            >
              <option value="EA_21">Enterprise Architect 15 — XMI 2.1</option>
              <option value="UML_251">UML 2.5.1 — XMI 2.5.1</option>
            </select>
          </label>
          <p className="pista">
            Se guardará como <code>{nombreDeArchivo(nombreExport, '.xmi')}</code>
          </p>
          <div className="acciones">
            <button type="submit" data-testid="confirmar-export">
              Guardar
            </button>
            <button type="button" className="secundario" onClick={() => setNombreExport(null)}>
              Cancelar
            </button>
          </div>
        </form>
      )}

      {camaraAbierta && (
        <CapturaCamara
          onCerrar={() => setCamaraAbierta(false)}
          onCaptura={(archivo) => {
            setCamaraAbierta(false);
            void importarImagen(archivo);
          }}
        />
      )}

      {error !== null && (
        <p className="error" data-testid="error-importacion">
          {error}
        </p>
      )}

      {aplicado !== null && (
        <p className="aplicada" data-testid="importacion-aplicada">
          {aplicado}
        </p>
      )}

      {candidato !== null && (
        <div ref={candidateRef} className="candidato" data-testid="candidato">
          <div className="candidato-cabecera">
            <strong>Antes de aplicar</strong>
            {fuente !== null && <span title={fuente.name}>{fuente.name}</span>}
          </div>

          {candidato.rationale !== null && <p className="derivados">{candidato.rationale}</p>}

          {/* Abierto: aqui viene lo que la lectura omitio o supuso, y un candidato
              con avisos plegados se aplica sin leerlos. */}
          {candidato.warnings.length > 0 && (
            <details className="bloque-avisos" open>
              <summary>
                {candidato.warnings.length} aviso{candidato.warnings.length === 1 ? '' : 's'}{' '}
                {fuente?.kind === 'IMAGE' ? 'de la lectura' : 'del archivo'}
              </summary>
              <ul className="avisos-importacion" data-testid="avisos-importacion">
                {candidato.warnings.map((aviso, indice) => (
                  <li key={indice}>
                    <strong>{aviso.element}</strong>: {aviso.reason}
                  </li>
                ))}
              </ul>
            </details>
          )}

          {(candidato.kind === 'BATCH' || candidato.kind === 'CONFIRMATION') && (
            <>
              {candidato.kind === 'CONFIRMATION' && (
                <p className="advertencia">{candidato.question}</p>
              )}

              <p className="pista">
                Corrige lo que haga falta. Nada entra al diagrama hasta que apliques.
              </p>

              <CandidateEditor
                batch={candidato.batch}
                state={state}
                onChange={actualizarComando}
                onRemove={(commandId) =>
                  setCandidato((current) =>
                    current !== null && 'batch' in current
                      ? { ...current, batch: removeCandidateCommand(current.batch, commandId) }
                      : current,
                  )
                }
              />
              {preview !== null && preview.issues.length > 0 && (
                <div
                  className="validacion-candidato"
                  data-testid="validacion-candidato"
                  aria-live="polite"
                >
                  <strong>
                    {preview.applied
                      ? 'Revisa estos hallazgos antes de generar código'
                      : 'Corrige estos errores para aplicar'}
                  </strong>
                  <ul>
                    {preview.issues.map((issue, i) => (
                      <li key={`${issue.code}-${i}`}>{issue.message}</li>
                    ))}
                  </ul>
                </div>
              )}

              <details className="resumen-tecnico">
                <summary>Ver resumen de {resumen.length} operaciones</summary>
                <ul className="resumen">
                  {resumen.slice(0, 20).map((linea, indice) => (
                    <li key={indice}>{linea}</li>
                  ))}
                  {resumen.length > 20 && <li className="pista">y {resumen.length - 20} más…</li>}
                </ul>
              </details>

              <div className="acciones">
                <button
                  type="button"
                  className="principal"
                  disabled={
                    !canWrite || obsoleto || preview?.applied === false || resumen.length === 0
                  }
                  data-testid="aplicar-candidato"
                  onClick={() => aplicar(candidato.batch, resumen)}
                >
                  Aplicar {resumen.length} cambio
                  {resumen.length === 1 ? '' : 's'}
                </button>
                {obsoleto && fuente !== null && baseCandidato !== null && (
                  <button
                    type="button"
                    disabled={!canWrite || pendiente}
                    data-testid="repreparar-importacion"
                    onClick={() => void importarFuente(fuente, baseCandidato.modo)}
                  >
                    Volver a preparar
                  </button>
                )}
                <button type="button" onClick={() => setCandidato(null)}>
                  Descartar
                </button>
              </div>
            </>
          )}

          {candidato.kind === 'NO_CHANGES' && (
            <>
              <p className="estado-vacio">✓ {candidato.message}</p>
              <div className="acciones">
                {fuente !== null && (
                  <button
                    type="button"
                    className="principal"
                    disabled={pendiente}
                    onClick={() => void reintentarReemplazando()}
                  >
                    Reemplazar con este archivo
                  </button>
                )}
                <button type="button" onClick={() => setCandidato(null)}>
                  Cerrar
                </button>
              </div>
            </>
          )}

          {candidato.kind === 'QUESTION' && (
            <>
              <p className="advertencia">{candidato.question}</p>
              {candidato.options !== undefined && candidato.options.length > 0 && (
                <p className="pista">Coincidencias: {candidato.options.join(', ')}</p>
              )}
              {/* Sin lote no hay nada que aplicar, y repetir la lectura cuesta otra
                  llamada al proveedor: se explica y se deja a la persona decidir si
                  sube otra foto o corrige la pizarra antes. */}
              <p className="pista">
                La lectura no produjo ningún cambio que preparar. Puedes subir otra foto o ajustar
                la pizarra y volver a intentarlo.
              </p>
              <div className="acciones">
                <button type="button" onClick={() => setCandidato(null)}>
                  Cerrar
                </button>
              </div>
            </>
          )}

          {candidato.kind === 'REJECTED' && (
            <>
              <p className="error">
                {candidato.issues.map((hallazgo) => hallazgo.message).join(' ')}
              </p>
              <div className="acciones">
                <button type="button" onClick={() => setCandidato(null)}>
                  Cerrar
                </button>
              </div>
            </>
          )}
        </div>
      )}
    </section>
  );
}

/**
 * Trae a la vista lo que acaba de abrirse dentro del panel que se desplaza.
 *
 * `dentro` apunta a la parte que de verdad hay que ver cuando el bloque entero
 * no cabe; si no existe, se usa el bloque.
 */
function useAparecerALaVista<T extends HTMLElement>(
  abierto: boolean,
  bloque: React.RefObject<T | null>,
  block: ScrollLogicalPosition,
  dentro?: string,
): void {
  useLayoutEffect(() => {
    if (!abierto) return;
    const mostrar = (): void => {
      const raiz = bloque.current;
      if (raiz === null) return;
      const destino = dentro === undefined ? raiz : (raiz.querySelector(dentro) ?? raiz);
      destino.scrollIntoView({ block });
    };
    mostrar();
    const cuadro = requestAnimationFrame(mostrar);
    return () => cancelAnimationFrame(cuadro);
  }, [abierto, bloque, block, dentro]);
}

/** El servidor recibe la imagen en base64: no hay multipart en esta API. */
async function leerBase64(archivo: File): Promise<string> {
  const bytes = new Uint8Array(await archivo.arrayBuffer());
  let binario = '';

  // Por trozos: `String.fromCharCode(...bytes)` con una foto de varios megas
  // desborda la pila de argumentos.
  const TROZO = 8192;
  for (let indice = 0; indice < bytes.length; indice += TROZO) {
    binario += String.fromCharCode(...bytes.subarray(indice, indice + TROZO));
  }

  return btoa(binario);
}
```

---

### `frontend/src/features/import/candidate.ts`

```ts
import type { CommandBatch } from '@uml/contracts';

/** Quitar una clase del archivo quita también los atributos, geometría y
 * enlaces que dependen de ella. Las eliminaciones del modo reemplazo quedan
 * explícitas para que la persona pueda conservar o retirar cada una. */
export function removeCandidateCommand(batch: CommandBatch, commandId: string): CommandBatch {
  const removed = batch.commands.find((c) => c.commandId === commandId);
  const classId = removed?.type === 'CREATE_CLASS' ? removed.payload.classId : null;
  return {
    ...batch,
    commands: batch.commands.filter((c) => {
      if (c.commandId === commandId) return false;
      if (classId === null || c.type === 'DELETE_CLASS') return true;
      const p = c.payload;
      return (
        !('classId' in p && p.classId === classId) &&
        !('sourceClassId' in p && p.sourceClassId === classId) &&
        !('targetClassId' in p && p.targetClassId === classId)
      );
    }),
  };
}
```

---

### `frontend/src/features/projects/ProjectMembers.tsx`

```tsx
import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router';
import { IconoChevron } from '../../components/icons.js';
import { api, ApiError, type ProjectMember, type ProjectInvite } from '../../lib/api.js';

export function ProjectMembers({
  projectId,
  userId,
  owner,
  invitation,
  onRefresh,
  onRevoke,
}: {
  projectId: string;
  userId: string;
  owner: boolean;
  invitation: string | null;
  onRefresh(): Promise<void>;
  onRevoke(code: string): void;
}): React.JSX.Element {
  const [members, setMembers] = useState<ProjectMember[]>([]);
  const [invites, setInvites] = useState<ProjectInvite[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [loaded, setLoaded] = useState(false);
  const [expanded, setExpanded] = useState(false);
  useEffect(() => {
    if (invitation !== null) setExpanded(true);
  }, [invitation]);
  const navigate = useNavigate();
  const refresh = useCallback(async () => {
    const [users, links] = await Promise.all([
      api.listMembers(projectId),
      owner ? api.listInvites(projectId) : Promise.resolve([]),
    ]);
    setMembers(users);
    setInvites(links);
    setLoaded(true);
  }, [projectId, owner]);
  useEffect(() => {
    let active = true;
    let running = false;
    const load = async (): Promise<void> => {
      if (running) return;
      running = true;
      try {
        await refresh();
        if (active) setError(null);
      } catch (cause) {
        if (active && cause instanceof ApiError && (cause.status === 403 || cause.status === 404)) {
          navigate('/proyectos', { replace: true });
          return;
        }
        if (active)
          setError(cause instanceof Error ? cause.message : 'No se pudo cargar la colaboración.');
      } finally {
        running = false;
      }
    };
    void load();
    const timer = window.setInterval(() => {
      if (document.visibilityState === 'visible') {
        void load();
        void onRefresh().catch(() => undefined);
      }
    }, 5000);
    const focus = (): void => {
      void load();
      void onRefresh().catch(() => undefined);
    };
    window.addEventListener('focus', focus);
    return () => {
      active = false;
      window.clearInterval(timer);
      window.removeEventListener('focus', focus);
    };
  }, [refresh, invitation, onRefresh, navigate]);
  async function change(action: () => Promise<unknown>, message: string): Promise<void> {
    setBusy(true);
    setError(null);
    setNotice(null);
    try {
      await action();
      await refresh();
      await onRefresh();
      setNotice(message);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'No se pudo completar la acción.');
    } finally {
      setBusy(false);
    }
  }
  return (
    <section
      className="colaboradores-proyecto"
      aria-labelledby="colaboradores-titulo"
      data-testid="miembros-proyecto"
    >
      <h2 id="colaboradores-titulo">
        <button
          type="button"
          className="resumen-colaboradores"
          data-testid="alternar-colaboradores"
          aria-expanded={expanded}
          aria-controls="detalle-colaboradores"
          onClick={() => setExpanded((value) => !value)}
        >
          <span>Colaboradores</span>
          {loaded && (
            <span className="conteo-colaboradores">
              {members.length} {members.length === 1 ? 'miembro' : 'miembros'}
              {owner &&
                invites.length > 0 &&
                ` · ${invites.length} ${invites.length === 1 ? 'invitación' : 'invitaciones'}`}
            </span>
          )}
          <span className="flecha-colaboradores" aria-hidden="true">
            <IconoChevron size={16} />
          </span>
        </button>
      </h2>
      {error !== null && (
        <p role="alert" className="aviso-error">
          {error}
        </p>
      )}
      {notice !== null && <p role="status">{notice}</p>}
      <div id="detalle-colaboradores" className="detalle-colaboradores" hidden={!expanded}>
        <p className="pista">
          Editores: pueden modificar las pizarras. Lectores: pueden verlas y exportarlas.
        </p>
        {!loaded && error === null && <p role="status">Cargando participantes…</p>}
        <ul className="lista-colaboradores">
          {members.map((member) => (
            <li key={member.id} data-testid={`miembro-${member.id}`}>
              <span>
                <strong>
                  {member.displayName}
                  {member.id === userId ? ' (tú)' : ''}
                </strong>
                <small>{member.email}</small>
              </span>
              {owner && member.role !== 'OWNER' ? (
                <>
                  <select
                    aria-label={`Rol de ${member.email}`}
                    value={member.role}
                    disabled={busy}
                    onChange={(e) =>
                      void change(
                        () =>
                          api.changeMemberRole(
                            projectId,
                            member.id,
                            e.target.value as 'EDITOR' | 'VIEWER',
                          ),
                        'Permiso actualizado.',
                      )
                    }
                  >
                    <option value="EDITOR">Editor</option>
                    <option value="VIEWER">Lector</option>
                  </select>
                  <button
                    type="button"
                    className="peligro"
                    disabled={busy}
                    aria-label={`Retirar a ${member.email}`}
                    onClick={() => {
                      if (
                        window.confirm(
                          `¿Retirar a ${member.displayName} del proyecto? Perderá acceso a todas sus pizarras.`,
                        )
                      )
                        void change(
                          () => api.removeMember(projectId, member.id),
                          'Participante retirado.',
                        );
                    }}
                  >
                    Retirar
                  </button>
                </>
              ) : (
                <span className="insignia-rol">
                  {member.role === 'OWNER'
                    ? 'Propietario'
                    : member.role === 'EDITOR'
                      ? 'Editor'
                      : 'Lector'}
                </span>
              )}
            </li>
          ))}
        </ul>
        {!owner && (
          <button
            type="button"
            className="peligro"
            disabled={busy}
            onClick={() => {
              if (
                window.confirm('¿Salir de este proyecto? Necesitarás otra invitación para volver.')
              ) {
                setBusy(true);
                void api
                  .removeMember(projectId, userId)
                  .then(() => navigate('/proyectos'))
                  .catch((cause: unknown) => {
                    setError(cause instanceof Error ? cause.message : 'No se pudo salir.');
                    setBusy(false);
                  });
              }
            }}
          >
            Salir del proyecto
          </button>
        )}
        {owner && (
          <>
            <h3>Invitaciones</h3>
            {invites.length > 0 && (
              <p className="pista">
                Revocar un código impide que se unan más personas. Los miembros actuales conservan
                su acceso.
              </p>
            )}
            {loaded && invites.length === 0 && <p>No hay invitaciones activas.</p>}
            <ul className="lista-colaboradores">
              {invites.map((invite) => (
                <li key={invite.id}>
                  <span>
                    <code>{invite.code}</code>
                    <small>
                      {invite.role === 'EDITOR' ? 'Editor' : 'Lector'} ·{' '}
                      {new Date(invite.expiresAt).getTime() <= Date.now()
                        ? 'Caducada'
                        : `Vence ${new Date(invite.expiresAt).toLocaleString()}`}
                    </small>
                  </span>
                  <button
                    type="button"
                    disabled={busy}
                    aria-label={`Revocar invitación ${invite.code}`}
                    onClick={() =>
                      void change(async () => {
                        await api.revokeInvite(projectId, invite.id);
                        onRevoke(invite.code);
                      }, 'Invitación revocada.')
                    }
                  >
                    Revocar
                  </button>
                </li>
              ))}
            </ul>
          </>
        )}
      </div>
    </section>
  );
}
```

---

### `frontend/src/features/projects/ProjectsPage.tsx`

```tsx
import { useCallback, useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router';
import { AppBar } from '../../components/AppBar.js';
import {
  IconoInvitar,
  IconoLlave,
  IconoMas,
  IconoMiembros,
  IconoPapelera,
  IconoPizarra,
  IconoProyecto,
  IconoLapiz,
  IconoVolver,
} from '../../components/icons.js';
import { api, type ProjectDetail, type ProjectSummary } from '../../lib/api.js';
import { useAsyncAction, useSession } from '../auth/session.js';
import { ProjectMembers } from './ProjectMembers.js';

const ROLE_LABEL = { OWNER: 'Propietario', EDITOR: 'Editor', VIEWER: 'Lector' } as const;

/** Lista de proyectos y creación (RF-001, RF-A04). */
export function ProjectsPage(): React.JSX.Element {
  const { user, logout, offline } = useSession();
  const { error, pending, run } = useAsyncAction();
  const [proyectos, setProyectos] = useState<readonly ProjectSummary[]>([]);
  const [nombre, setNombre] = useState('');
  const [codigoInvitacion, setCodigoInvitacion] = useState('');
  const navegar = useNavigate();

  const recargar = useCallback(async () => {
    setProyectos(await api.listProjects());
  }, []);

  useEffect(() => {
    if (!offline) void run(recargar);
  }, [recargar, run, offline]);

  return (
    <div className="marco">
      <AppBar displayName={user?.displayName} userId={user?.id} onLogout={() => void logout()} />

      <main className="pagina">
        <header className="encabezado-pagina">
          <div>
            <h1>Mis proyectos</h1>
            <p className="subtitulo">Tus diagramas y proyectos compartidos.</p>
          </div>
        </header>

        {/* Crear y unirse son dos cosas distintas y antes eran dos campos
            gigantes seguidos, indistinguibles. Ahora la accion principal va
            primero y unirse queda a un lado, con su propio icono. */}
        <section className="barra-acciones">
          <form
            className="accion-principal"
            onSubmit={(evento) => {
              evento.preventDefault();
              void run(async () => {
                const creado = await api.createProject(nombre.trim());
                setNombre('');
                await recargar();
                void navegar(`/proyectos/${creado.id}`);
              });
            }}
          >
            <label>
              <span>Nuevo proyecto</span>
              <input
                required
                placeholder="Sistema de ventas"
                data-testid="nombre-proyecto"
                value={nombre}
                onChange={(evento) => setNombre(evento.target.value)}
              />
            </label>
            <button
              type="submit"
              className="principal"
              disabled={pending}
              data-testid="crear-proyecto"
            >
              <IconoMas size={15} />
              {pending ? 'Creando…' : 'Crear proyecto'}
            </button>
          </form>

          <form
            className="accion-secundaria"
            onSubmit={(evento) => {
              evento.preventDefault();
              void run(async () => {
                const aceptada = await api.acceptInvite(codigoInvitacion.trim());
                setCodigoInvitacion('');
                await recargar();
                void navegar(`/proyectos/${aceptada.projectId}`);
              });
            }}
          >
            <label>
              <span>Unirme con un código</span>
              <input
                required
                placeholder="Código de invitación"
                data-testid="codigo-invitacion"
                value={codigoInvitacion}
                onChange={(evento) => setCodigoInvitacion(evento.target.value)}
              />
            </label>
            <button type="submit" disabled={pending} data-testid="aceptar-invitacion">
              <IconoLlave size={15} />
              Unirme
            </button>
          </form>
        </section>

        {error !== null && (
          <p className="aviso-error" role="alert">
            {error}
          </p>
        )}

        <ul className="rejilla-tarjetas" data-testid="lista-proyectos">
          {proyectos.length === 0 && (
            <li className="estado-vacio-panel">
              <span className="icono-vacio" aria-hidden="true">
                <IconoProyecto size={22} />
              </span>
              <h2>Aún no tienes proyectos</h2>
              <p>Crea un proyecto o únete con un código de invitación.</p>
            </li>
          )}

          {proyectos.map((proyecto) => (
            <li key={proyecto.id} className="tarjeta-recurso">
              <Link to={`/proyectos/${proyecto.id}`} className="cuerpo-tarjeta">
                <span className="icono-recurso" aria-hidden="true">
                  <IconoProyecto size={17} />
                </span>
                <strong>{proyecto.displayName}</strong>
              </Link>

              <div className="pie-tarjeta">
                <span className="dato-tarjeta">
                  <IconoPizarra size={14} />
                  {proyecto.boardCount} {proyecto.boardCount === 1 ? 'pizarra' : 'pizarras'}
                </span>
                <span className="dato-tarjeta">
                  <IconoMiembros size={14} />
                  {proyecto.memberCount} {proyecto.memberCount === 1 ? 'miembro' : 'miembros'}
                </span>
                <span className={`insignia-rol rol-${proyecto.role.toLowerCase()}`}>
                  {ROLE_LABEL[proyecto.role]}
                </span>

                {/* RF-001: solo el propietario borra, y borrar un proyecto se
                    lleva sus pizarras por delante. Por eso se confirma con el
                    nombre escrito: un dialogo de «¿seguro?» se acepta sin
                    leerlo. El boton es discreto —icono, sin relleno— porque una
                    accion destructiva no debe competir por la atencion. */}
                {proyecto.role === 'OWNER' && (
                  <button
                    type="button"
                    className="icono peligro accion-tarjeta"
                    disabled={pending}
                    data-testid={`eliminar-proyecto-${proyecto.displayName}`}
                    aria-label={`Eliminar el proyecto ${proyecto.displayName}`}
                    title="Eliminar el proyecto y todas sus pizarras"
                    onClick={() => {
                      const escrito = window.prompt(
                        `Esto elimina «${proyecto.displayName}» y sus ${proyecto.boardCount} pizarra(s), ` +
                          'para todos sus miembros. Escribe el nombre del proyecto para confirmar:',
                      );
                      if (escrito?.trim() !== proyecto.displayName) return;

                      void run(async () => {
                        await api.deleteProject(proyecto.id);
                        await recargar();
                      });
                    }}
                  >
                    <IconoPapelera size={15} />
                  </button>
                )}
              </div>
            </li>
          ))}
        </ul>
      </main>
    </div>
  );
}

/** Pizarras del proyecto e invitaciones (RF-002, RF-A05). */
export function ProjectPage(): React.JSX.Element {
  const { projectId } = useParams<{ projectId: string }>();
  // Una ruta nueva necesita su propio estado: una respuesta o invitacion del
  // proyecto anterior no debe aparecer ni operar bajo la nueva direccion.
  return <ProjectSession key={projectId} projectId={projectId} />;
}

function ProjectSession({
  projectId,
}: {
  readonly projectId: string | undefined;
}): React.JSX.Element {
  const { user, logout, offline } = useSession();
  const { error, pending, run } = useAsyncAction();
  const [proyecto, setProyecto] = useState<ProjectDetail | null>(null);
  const [nombre, setNombre] = useState('');
  const [invitacion, setInvitacion] = useState<string | null>(null);

  const recargar = useCallback(async () => {
    if (projectId === undefined) return;
    setProyecto(await api.getProject(projectId));
  }, [projectId]);

  useEffect(() => {
    if (!offline) void run(recargar);
  }, [recargar, run, offline]);

  if (proyecto === null) {
    return (
      <div className="marco">
        <AppBar displayName={user?.displayName} userId={user?.id} onLogout={() => void logout()} />
        <main className="centrado">
          <div className="estado-ruta" role={error === null ? 'status' : 'alert'}>
            {error === null ? (
              <>
                <div className="girando" aria-hidden="true" />
                <p>Cargando el proyecto…</p>
              </>
            ) : (
              <>
                <p>{error}</p>
                <Link to="/proyectos">Volver a mis proyectos</Link>
                <button type="button" disabled={pending} onClick={() => void run(recargar)}>
                  Reintentar
                </button>
              </>
            )}
          </div>
        </main>
      </div>
    );
  }

  const puedeEscribir = proyecto.role !== 'VIEWER';

  return (
    <div className="marco">
      <AppBar displayName={user?.displayName} userId={user?.id} onLogout={() => void logout()} />

      <main className="pagina">
        <header className="encabezado-pagina">
          <Link to="/proyectos" className="volver" aria-label="Volver a mis proyectos">
            <IconoVolver size={18} />
          </Link>
          <div>
            <h1>{proyecto.displayName}</h1>
            <p className="subtitulo">
              {proyecto.boards.length} {proyecto.boards.length === 1 ? 'pizarra' : 'pizarras'} en
              este proyecto
            </p>
          </div>
          <span className={`insignia-rol rol-${proyecto.role.toLowerCase()}`}>
            {ROLE_LABEL[proyecto.role]}
          </span>
        </header>

        <section className="barra-acciones">
          <form
            className="accion-principal"
            onSubmit={(evento) => {
              evento.preventDefault();
              void run(async () => {
                await api.createBoard(proyecto.id, nombre.trim());
                setNombre('');
                await recargar();
              });
            }}
          >
            <label>
              <span>Nueva pizarra</span>
              <input
                required
                placeholder="Diagrama de clases"
                data-testid="nombre-pizarra"
                value={nombre}
                onChange={(evento) => setNombre(evento.target.value)}
                disabled={!puedeEscribir}
              />
            </label>
            <button
              type="submit"
              className="principal"
              disabled={pending || !puedeEscribir}
              data-testid="crear-pizarra"
              title={
                puedeEscribir ? 'Crear una pizarra en este proyecto' : 'Tu rol es de solo lectura'
              }
            >
              <IconoMas size={15} />
              {pending ? 'Creando…' : 'Nueva pizarra'}
            </button>
          </form>

          {proyecto.role === 'OWNER' && (
            <div className="accion-secundaria invitaciones">
              <span className="etiqueta-bloque">Invitar al proyecto</span>
              <div className="botones-invitar">
                <button
                  type="button"
                  disabled={pending}
                  data-testid="invitar-editor"
                  title="Genera un código para alguien que va a dibujar"
                  onClick={() =>
                    void run(async () => {
                      const creada = await api.createInvite(proyecto.id, 'EDITOR');
                      setInvitacion(creada.code);
                    })
                  }
                >
                  <IconoInvitar size={15} />
                  Editor
                </button>
                <button
                  type="button"
                  disabled={pending}
                  data-testid="invitar-lector"
                  title="Genera un código para alguien que solo va a mirar"
                  onClick={() =>
                    void run(async () => {
                      const creada = await api.createInvite(proyecto.id, 'VIEWER');
                      setInvitacion(creada.code);
                    })
                  }
                >
                  <IconoInvitar size={15} />
                  Lector
                </button>
              </div>
              {invitacion !== null && (
                <code className="codigo" data-testid="codigo-generado" title="Cópialo y compártelo">
                  {invitacion}
                </code>
              )}
            </div>
          )}
        </section>

        {error !== null && (
          <p className="aviso-error" role="alert">
            {error}
          </p>
        )}

        {user !== null && (
          <ProjectMembers
            key={proyecto.id}
            projectId={proyecto.id}
            userId={user.id}
            owner={proyecto.role === 'OWNER'}
            invitation={invitacion}
            onRevoke={(code) => setInvitacion((current) => (current === code ? null : current))}
            onRefresh={recargar}
          />
        )}

        <ul className="rejilla-tarjetas" data-testid="lista-pizarras">
          {proyecto.boards.length === 0 && (
            <li className="estado-vacio-panel">
              <span className="icono-vacio" aria-hidden="true">
                <IconoPizarra size={22} />
              </span>
              <h2>Este proyecto no tiene pizarras</h2>
              <p>
                {puedeEscribir
                  ? 'Crea la primera para empezar a dibujar el diagrama de clases.'
                  : 'Cuando alguien cree una, aparecerá aquí.'}
              </p>
            </li>
          )}

          {proyecto.boards.map((pizarra) => (
            <li key={pizarra.id} className="tarjeta-recurso">
              {/* El nombre accesible del enlace es exactamente el de la pizarra:
                  nada mas dentro, para que quien navega con lector de pantalla
                  oiga «Ventas, enlace» y no una frase con relleno. */}
              <Link to={`/pizarras/${pizarra.id}`} className="cuerpo-tarjeta">
                <span className="icono-recurso" aria-hidden="true">
                  <IconoPizarra size={17} />
                </span>
                <strong>{pizarra.displayName}</strong>
              </Link>

              <div className="pie-tarjeta">
                <span className="dato-tarjeta">Abrir el editor</span>

                {/* RF-003: renombrar y eliminar. Las rutas existian desde la
                    fase 3 y estaban probadas, pero no habia forma de llegar a
                    ellas desde la interfaz. */}
                {puedeEscribir && (
                  <>
                    <button
                      type="button"
                      className="icono accion-tarjeta"
                      disabled={pending}
                      title="Cambiar el nombre de la pizarra"
                      aria-label={`Renombrar la pizarra ${pizarra.displayName}`}
                      data-testid={`renombrar-${pizarra.displayName}`}
                      onClick={() => {
                        const nuevoNombre = window.prompt('Nuevo nombre', pizarra.displayName);
                        if (nuevoNombre === null || nuevoNombre.trim() === '') return;
                        if (nuevoNombre.trim() === pizarra.displayName) return;

                        void run(async () => {
                          await api.renameBoard(pizarra.id, nuevoNombre.trim());
                          await recargar();
                        });
                      }}
                    >
                      <IconoLapiz size={15} />
                    </button>
                    <button
                      type="button"
                      className="icono peligro"
                      disabled={pending}
                      title="Eliminar la pizarra y su diagrama, para todos"
                      aria-label={`Eliminar la pizarra ${pizarra.displayName}`}
                      data-testid={`eliminar-pizarra-${pizarra.displayName}`}
                      onClick={() => {
                        // El diagrama se pierde y no hay papelera. Se pide
                        // escribir el nombre en lugar de un «¿seguro?», que se
                        // acepta sin leerlo.
                        const escrito = window.prompt(
                          `Esto elimina la pizarra «${pizarra.displayName}» y su diagrama, ` +
                            'para todos. Escribe su nombre para confirmar:',
                        );
                        if (escrito?.trim() !== pizarra.displayName) return;

                        void run(async () => {
                          await api.deleteBoard(pizarra.id);
                          await recargar();
                        });
                      }}
                    >
                      <IconoPapelera size={15} />
                    </button>
                  </>
                )}
              </div>
            </li>
          ))}
        </ul>
      </main>
    </div>
  );
}
```

---

### `frontend/src/lib/api.ts`

```ts
import { commandBatchSchema, type CommandBatch } from '@uml/contracts';
import { forgetUser, markLogout } from './offline.js';

/**
 * Cliente HTTP de la plataforma.
 *
 * El token de acceso vive **en memoria**, no en `localStorage`: cualquier script
 * que se cuele en la pagina puede leer el almacenamiento local, y ahi el token
 * sobreviviria a la pestana. El de refresco viaja en cookie de solo HTTP, que el
 * JavaScript de la pagina no ve.
 *
 * El precio es que recargar pierde el token de acceso. Se recupera al arrancar
 * llamando a `/auth/refresh`, que es justamente para lo que existe.
 */

export interface SessionUser {
  readonly id: string;
  readonly email: string;
  readonly displayName: string;
}

export class ApiError extends Error {
  public constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/**
 * El servidor no llego a contestar.
 *
 * No es un `ApiError`: no hay respuesta ni codigo que interpretar, y quien
 * distingue «el servidor rechazo esto» de «no hubo servidor» necesita que los
 * dos casos no compartan tipo. `fetch` lo senala con un `TypeError`, el mismo
 * que produciria un error de programacion en esta capa, asi que se traduce en el
 * unico sitio que sabe que venia de la red.
 */
export class NetworkError extends Error {
  public constructor(cause: unknown) {
    super('No se pudo contactar al servidor.', { cause });
    this.name = 'NetworkError';
  }
}

let accessToken: string | null = null;
let sessionUserId: string | null = null;
let sessionRevision = 0;
let refreshInFlight: Promise<boolean> | null = null;
let signingOut = false;
let logoutInFlight: Promise<void> | null = null;
let refreshFailure: unknown = null;

/** A failed network/server request must not be mistaken for rejected credentials. */
export function sessionRefreshUnavailable(): boolean {
  return refreshFailure !== null;
}

export function isConnectionUnavailable(error: unknown): boolean {
  return (
    error instanceof NetworkError ||
    (error instanceof ApiError && error.status >= 500) ||
    (error instanceof Error && error.name === 'TimeoutError')
  );
}
const AUDIT_QUEUE_KEY = 'uml_audit_queue_v1';
let auditFlushInFlight: Promise<void> | null = null;

export function currentAccessToken(): string | null {
  return accessToken;
}

export function setAccessToken(token: string | null): void {
  accessToken = token;
  sessionRevision += 1;
  if (token === null) sessionUserId = null;
}

interface RequestOptions {
  readonly signal?: AbortSignal;
  readonly method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  readonly body?: unknown;
  /** Interno: evita reintentar en bucle si la propia renovacion devuelve 401. */
  readonly skipRefresh?: boolean;
  /** Evita reenviar un cambio pendiente con la cuenta de otra pestaña. */
  readonly expectedUserId?: string;
}

export async function apiRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  return requestWithSession(path, options, leer<T>);
}

async function requestWithSession<T>(
  path: string,
  options: RequestOptions,
  read: (response: Response) => Promise<T>,
): Promise<T> {
  // Una peticion pertenece a la sesion que la inicio. Un 401 tardio no puede
  // repetir una escritura con la cuenta que haya entrado mientras esperaba.
  const revision = sessionRevision;
  const comprobarSesion = (): void => {
    options.signal?.throwIfAborted();
    if (revision !== sessionRevision) {
      throw new ApiError(401, 'session_changed', 'La cuenta de la sesión cambió.');
    }
  };
  let respuesta = await enviar(path, options);
  comprobarSesion();

  // Una sola renovacion por peticion: si el token acaba de expirar se renueva y
  // se repite, y si eso tampoco vale, la sesion se acabo de verdad.
  if (respuesta.status === 401 && options.skipRefresh !== true) {
    const renovado = await refreshSession();
    comprobarSesion();
    if (renovado) {
      respuesta = await enviar(path, options);
      comprobarSesion();
    } else if (refreshFailure !== null) {
      // El 401 pertenecía al acceso vencido. La renovación no pudo comprobar
      // la sesión: conserva su causa para permitir la copia local y el reintento.
      throw refreshFailure;
    }
  }

  const result = await read(respuesta);
  // Tambien puede cambiar la cuenta mientras se descarga el cuerpo del ZIP/JSON.
  comprobarSesion();
  return result;
}

async function enviar(path: string, options: RequestOptions): Promise<Response> {
  options.signal?.throwIfAborted();
  if (options.expectedUserId !== undefined && options.expectedUserId !== sessionUserId) {
    throw new ApiError(401, 'session_changed', 'La cuenta de la sesión cambió.');
  }
  const headers: Record<string, string> = { accept: 'application/json' };
  if (accessToken !== null) headers['authorization'] = `Bearer ${accessToken}`;
  if (options.body !== undefined) headers['content-type'] = 'application/json';

  // Fuera del `try`: serializar un cuerpo imposible tambien lanza `TypeError`, y
  // eso es un error de programacion, no una red caida.
  const peticion: RequestInit = {
    method: options.method ?? 'GET',
    headers,
    // Sin esto la cookie de refresco no viaja y la sesion se pierde al recargar.
    credentials: 'include',
    ...(options.signal === undefined ? {} : { signal: options.signal }),
    ...(options.body === undefined ? {} : { body: JSON.stringify(options.body) }),
  };

  try {
    return await fetch(`/api${path}`, peticion);
  } catch (error) {
    // Un aborto o un plazo vencido son decisiones nuestras: los distingue su
    // propio nombre y suben tal cual.
    if (error instanceof TypeError) throw new NetworkError(error);
    throw error;
  }
}

async function leer<T>(respuesta: Response): Promise<T> {
  if (respuesta.status === 204) return undefined as T;

  const cuerpo: unknown = await respuesta.json().catch(() => null);

  if (!respuesta.ok) {
    const error = (cuerpo as { error?: { code?: string; message?: string; details?: unknown } })
      ?.error;
    throw new ApiError(
      respuesta.status,
      error?.code ?? 'unknown',
      error?.message ?? `Error ${respuesta.status}`,
      error?.details,
    );
  }

  return cuerpo as T;
}

interface SessionResponse {
  readonly accessToken: string;
  readonly user: SessionUser;
}

export async function login(email: string, password: string): Promise<SessionUser> {
  // Offline logout immediately shows login. Its delayed response must not clear
  // the token/cookie of a new login started from that screen.
  await logoutInFlight;
  // The promise above only coordinates this tab. The cookie is shared by every
  // tab, so login must use the same browser lock as logout and token refresh.
  return withSessionLock(async () => {
    const sesion = await apiRequest<SessionResponse>('/auth/login', {
      method: 'POST',
      body: { email, password },
      skipRefresh: true,
    });
    setAccessToken(sesion.accessToken);
    sessionUserId = sesion.user.id;
    markLogout(false);
    return sesion.user;
  });
}

export interface RegistrationResponse {
  readonly verificationRequired: true;
  readonly emailSent: boolean;
}

export async function register(
  email: string,
  displayName: string,
  password: string,
): Promise<RegistrationResponse> {
  return apiRequest<RegistrationResponse>('/auth/register', {
    method: 'POST',
    body: { email, displayName, password },
    skipRefresh: true,
  });
}

export const verification = {
  resend: (email: string) =>
    apiRequest<{ sent: true }>('/auth/verification/resend', {
      method: 'POST',
      body: { email },
      skipRefresh: true,
    }),
  confirm: (token: string) =>
    apiRequest<{ verified: true }>('/auth/verification/confirm', {
      method: 'POST',
      body: { token },
      skipRefresh: true,
    }),
};

export function logout(): Promise<void> {
  logoutInFlight ??= performLogout().finally(() => {
    logoutInFlight = null;
  });
  return logoutInFlight;
}

async function performLogout(): Promise<void> {
  signingOut = true;
  markLogout(true);
  forgetUser();
  // Una renovacion que ya estaba en vuelo no debe resucitar esta sesion.
  setAccessToken(null);
  // Esperar tambien su Set-Cookie permite revocar la cookie rotada, incluso
  // cuando la respuesta de refresh llega despues de pulsar Salir.
  await refreshInFlight;
  await withSessionLock(() =>
    apiRequest<void>('/auth/logout', {
      method: 'POST',
      skipRefresh: true,
      signal: AbortSignal.timeout(8000),
    }),
  )
    .then(() => markLogout(false))
    .catch(() => undefined);
  setAccessToken(null);
  signingOut = false;
}

/** Devuelve `true` si habia una sesion viva que renovar. */
export function refreshSession(): Promise<boolean> {
  if (signingOut) return Promise.resolve(false);
  // Varias peticiones pueden descubrir a la vez que el token de acceso expiro.
  // El token de refresco es de un solo uso, asi que todas deben compartir una
  // unica rotacion en lugar de competir por consumirlo.
  refreshInFlight ??= withSessionLock(performRefresh).finally(() => {
    refreshInFlight = null;
  });

  return refreshInFlight;
}

async function performRefresh(): Promise<boolean> {
  if (signingOut) return false;
  refreshFailure = null;
  const revision = sessionRevision;
  const previousUserId = sessionUserId;
  try {
    const sesion = await apiRequest<SessionResponse>('/auth/refresh', {
      method: 'POST',
      skipRefresh: true,
      signal: AbortSignal.timeout(8000),
    });
    if (revision !== sessionRevision) return false;
    if (previousUserId !== null && previousUserId !== sesion.user.id) {
      setAccessToken(null);
      return false;
    }
    accessToken = sesion.accessToken;
    sessionUserId = sesion.user.id;
    void flushAuditQueue().catch(() => undefined);
    return true;
  } catch (error) {
    refreshFailure = isConnectionUnavailable(error) ? error : null;
    if (revision === sessionRevision) accessToken = null;
    return false;
  }
}

async function withSessionLock<T>(action: () => Promise<T>): Promise<T> {
  if (typeof navigator === 'undefined' || navigator.locks === undefined) return action();

  // `await` y no `return` a secas: la firma de `request` resuelve al valor que
  // devuelve la funcion, y como la nuestra devuelve una promesa el tipo saldria
  // como `Promise<Promise<T>>`. Esperarlo aqui lo aplana y evita el `as`.
  return await navigator.locks.request('uml-refresh-session', action);
}

export async function fetchMe(signal?: AbortSignal): Promise<SessionUser> {
  return apiRequest<SessionUser>('/auth/me', signal === undefined ? {} : { signal });
}

// ---------------------------------------------------------------------------
// Perfil y contrasena (RF-A10 y RF-A11)
// ---------------------------------------------------------------------------

/**
 * La foto se pide por su URL, no en el JSON del perfil.
 *
 * Asi el navegador la cachea como cualquier imagen y no viaja en base64 en cada
 * lectura del perfil. `v` cambia al subir una nueva para saltarse esa cache.
 */
export function avatarUrl(userId: string, version = 0): string {
  return `/api/auth/users/${userId}/avatar?v=${version}`;
}

export const perfil = {
  actualizar: (displayName: string) =>
    apiRequest<SessionUser>('/auth/me', { method: 'PATCH', body: { displayName } }),

  subirAvatar: (image: string, mediaType: string) =>
    apiRequest<{ hasAvatar: boolean; bytes: number }>('/auth/me/avatar', {
      method: 'PUT',
      body: { image, mediaType },
    }),

  quitarAvatar: () => apiRequest<void>('/auth/me/avatar', { method: 'DELETE' }),

  cambiarPassword: (currentPassword: string, newPassword: string) =>
    apiRequest<{ changed: boolean }>('/auth/me/password', {
      method: 'POST',
      body: { currentPassword, newPassword },
    }),

  /** Siempre responde igual, exista o no la cuenta: no revela quien esta registrado. */
  pedirRecuperacion: (email: string) =>
    apiRequest<{ sent: boolean }>('/auth/password/forgot', {
      method: 'POST',
      body: { email },
      skipRefresh: true,
    }),

  restablecer: (token: string, newPassword: string) =>
    apiRequest<{ reset: boolean }>('/auth/password/reset', {
      method: 'POST',
      body: { token, newPassword },
      skipRefresh: true,
    }),
};

// ---------------------------------------------------------------------------
// Proyectos y pizarras
// ---------------------------------------------------------------------------

export type ProjectRole = 'OWNER' | 'EDITOR' | 'VIEWER';

export interface ProjectSummary {
  readonly id: string;
  readonly displayName: string;
  readonly role: ProjectRole;
  readonly boardCount: number;
  readonly memberCount: number;
}

export interface BoardSummary {
  readonly id: string;
  readonly projectId: string;
  readonly displayName: string;
  readonly room: string;
}

export interface ProjectDetail {
  readonly id: string;
  readonly displayName: string;
  readonly role: ProjectRole;
  readonly boards: readonly { id: string; displayName: string }[];
}

/** Estado de la emision del artefacto (ADR-018). */
export type GenerationStatus = 'CREATING' | 'READY' | 'FAILED';

export interface GenerationSummary {
  readonly id: string;
  readonly snapshotVersion: number;
  readonly createdAt: string;
  readonly status: GenerationStatus;
  /** Nombre con el que se genero, no el actual de la pizarra. */
  readonly projectName: string;
  readonly basePackage: string;
  readonly templatesHash: string;
  readonly springSha256: string | null;
  readonly mobileSha256?: string | null;
  readonly error: string | null;
  readonly author: { id: string; displayName: string; email: string };
}

export interface GenerationResult {
  readonly id: string;
  readonly boardId: string;
  readonly snapshotVersion: number;
  readonly createdAt: string;
  readonly status: GenerationStatus;
  readonly artifactName: string;
  readonly basePackage: string;
  readonly entities: number;
  readonly sha256: { spring: string };
}

export interface ProjectMember {
  readonly id: string;
  readonly email: string;
  readonly displayName: string;
  readonly role: ProjectRole;
}

export interface ProjectInvite {
  readonly id: string;
  readonly code: string;
  readonly role: 'EDITOR' | 'VIEWER';
  readonly expiresAt: string;
}

export const api = {
  listProjects: () => apiRequest<ProjectSummary[]>('/projects'),

  createProject: (displayName: string) =>
    apiRequest<{ id: string }>('/projects', { method: 'POST', body: { displayName } }),

  getProject: (projectId: string) => apiRequest<ProjectDetail>(`/projects/${projectId}`),

  deleteProject: (projectId: string) =>
    apiRequest<void>(`/projects/${projectId}`, { method: 'DELETE' }),

  listMembers: (projectId: string) => apiRequest<ProjectMember[]>(`/projects/${projectId}/members`),
  changeMemberRole: (projectId: string, userId: string, role: 'EDITOR' | 'VIEWER') =>
    apiRequest(`/projects/${projectId}/members/${userId}`, { method: 'PATCH', body: { role } }),
  removeMember: (projectId: string, userId: string) =>
    apiRequest<void>(`/projects/${projectId}/members/${userId}`, { method: 'DELETE' }),
  listInvites: (projectId: string) => apiRequest<ProjectInvite[]>(`/projects/${projectId}/invites`),
  revokeInvite: (projectId: string, inviteId: string) =>
    apiRequest<void>(`/projects/${projectId}/invites/${inviteId}`, { method: 'DELETE' }),

  createInvite: (projectId: string, role: 'EDITOR' | 'VIEWER') =>
    apiRequest<{ code: string }>(`/projects/${projectId}/invites`, {
      method: 'POST',
      body: { role },
    }),

  acceptInvite: (code: string) =>
    apiRequest<{ projectId: string; role: ProjectRole }>(`/invites/${code}/accept`, {
      method: 'POST',
    }),

  listBoards: (projectId: string) => apiRequest<BoardSummary[]>(`/projects/${projectId}/boards`),

  createBoard: (projectId: string, displayName: string) =>
    apiRequest<BoardSummary>(`/projects/${projectId}/boards`, {
      method: 'POST',
      body: { displayName },
    }),

  getBoard: (boardId: string, signal?: AbortSignal) =>
    apiRequest<BoardSummary & { role: ProjectRole }>(
      `/boards/${boardId}`,
      signal === undefined ? {} : { signal },
    ),

  renameBoard: (boardId: string, displayName: string) =>
    apiRequest<BoardSummary>(`/boards/${boardId}`, { method: 'PATCH', body: { displayName } }),

  deleteBoard: (boardId: string) => apiRequest<void>(`/boards/${boardId}`, { method: 'DELETE' }),

  // -------------------------------------------------------------------------
  // Generacion (RF-060 a RF-072)
  // -------------------------------------------------------------------------

  generate: (boardId: string, basePackage?: string, includeMobile = false) =>
    apiRequest<GenerationResult>(`/boards/${boardId}/generations`, {
      method: 'POST',
      body: {
        includeMobile,
        ...(basePackage === undefined || basePackage.trim() === '' ? {} : { basePackage }),
      },
    }),

  listGenerations: (boardId: string) =>
    apiRequest<GenerationSummary[]>(`/boards/${boardId}/generations`),

  /**
   * Quita una generacion del historial y libera su version congelada en el
   * servidor. No hay ningun ZIP que borrar: se regenera al descargar.
   */
  deleteGeneration: (generationId: string) =>
    apiRequest<void>(`/generations/${generationId}`, { method: 'DELETE' }),

  /**
   * Registra el lote para auditoria (RF-A09).
   *
   * No se espera la respuesta en el camino de edicion: el lote ya se aplico en
   * el documento cuando esto se llama, y un fallo al registrar no puede deshacer
   * lo que el usuario ya ve en pantalla. Se avisa por consola y se sigue.
   */
  recordBatch: recordBatchReliable,
};

interface PendingAudit {
  readonly boardId: string;
  readonly batch: CommandBatch;
}

const auditQueueListeners = new Set<(count: number) => void>();

/**
 * Guarda el lote antes de enviarlo. Si la API o la red fallan, `online`, una
 * renovacion de sesion o el siguiente cambio vuelven a intentar la cola. El
 * servidor es idempotente por boardId+batchId, asi que repetir es seguro.
 */
async function recordBatchReliable(
  boardId: string,
  batch: CommandBatch,
): Promise<{ batchId: string }> {
  const cola = readAuditQueue();
  if (!cola.some((item) => item.boardId === boardId && item.batch.batchId === batch.batchId)) {
    writeAuditQueue([...cola, { boardId, batch }]);
  }

  // Navegacion privada o una politica corporativa pueden deshabilitar storage.
  // En ese caso no fingimos que se encolo: se conserva el envio inmediato.
  if (
    !readAuditQueue().some(
      (item) => item.boardId === boardId && item.batch.batchId === batch.batchId,
    )
  ) {
    return apiRequest<{ batchId: string }>(`/boards/${boardId}/audit`, {
      method: 'POST',
      body: batch,
      expectedUserId: batch.actorId,
    });
  }

  await flushAuditQueue();
  return { batchId: batch.batchId };
}

export function flushAuditQueue(): Promise<void> {
  auditFlushInFlight ??= performAuditFlush().finally(() => {
    auditFlushInFlight = null;
  });
  return auditFlushInFlight;
}

export function pendingAuditCount(userId: string | null = sessionUserId): number {
  return readAuditQueue().filter((item) => item.batch.actorId === userId).length;
}

export function subscribeAuditQueue(listener: (count: number) => void): () => void {
  auditQueueListeners.add(listener);
  return () => auditQueueListeners.delete(listener);
}

async function performAuditFlush(): Promise<void> {
  // Conservamos lotes rechazados para recuperarlos, pero no bloquean las otras
  // pizarras. Cada pasada intenta cada lote como maximo una vez.
  const attempted = new Set<string>();
  for (;;) {
    const item = readAuditQueue().find(
      (pending) =>
        pending.batch.actorId === sessionUserId &&
        !attempted.has(`${pending.boardId}:${pending.batch.batchId}`),
    );
    if (item === undefined) return;
    attempted.add(`${item.boardId}:${item.batch.batchId}`);
    try {
      await apiRequest<{ batchId: string }>(`/boards/${item.boardId}/audit`, {
        method: 'POST',
        body: item.batch,
        expectedUserId: item.batch.actorId,
      });
    } catch (error) {
      if (error instanceof ApiError && [400, 403, 404, 409, 422].includes(error.status)) continue;
      throw error;
    }
    writeAuditQueue(
      readAuditQueue().filter(
        (pending) =>
          pending.boardId !== item.boardId || pending.batch.batchId !== item.batch.batchId,
      ),
    );
  }
}

function readAuditQueue(): PendingAudit[] {
  try {
    // El propio getter puede lanzar SecurityError cuando el navegador bloquea storage.
    if (typeof localStorage === 'undefined') return [];
    const parsed: unknown = JSON.parse(localStorage.getItem(AUDIT_QUEUE_KEY) ?? '[]');
    if (!Array.isArray(parsed)) return [];

    return parsed.flatMap((item): PendingAudit[] => {
      if (typeof item !== 'object' || item === null || !('boardId' in item) || !('batch' in item)) {
        return [];
      }
      const boardId = item.boardId;
      const batch = commandBatchSchema.safeParse(item.batch);
      return typeof boardId === 'string' && batch.success ? [{ boardId, batch: batch.data }] : [];
    });
  } catch {
    return [];
  }
}

function writeAuditQueue(items: readonly PendingAudit[]): void {
  try {
    if (typeof localStorage === 'undefined') return;
    localStorage.setItem(AUDIT_QUEUE_KEY, JSON.stringify(items));
    for (const listener of auditQueueListeners) listener(pendingAuditCount());
  } catch {
    // Si el almacenamiento esta deshabilitado, la peticion inmediata aun se
    // intenta; el error vuelve al llamante y se muestra en consola.
  }
}

/** Exporta XMI con la misma renovacion de sesion que el resto del cliente. */
export async function downloadXmi(
  boardId: string,
  model: unknown,
  layout?: unknown,
  format: 'EA_21' | 'UML_251' = 'EA_21',
): Promise<{ blob: Blob; fileName: string }> {
  return requestWithSession(
    `/boards/${boardId}/export/xmi`,
    { method: 'POST', body: { model, format, ...(layout === undefined ? {} : { layout }) } },
    (respuesta) => readDownload(respuesta, 'pizarra.xmi'),
  );
}

/**
 * Descarga un artefacto generado.
 *
 * No usa `apiRequest` porque la respuesta no es JSON: son los bytes de un ZIP.
 * El token va en la cabecera igual, y el nombre del archivo sale de
 * `content-disposition` para que el navegador guarde el nombre que decidio el
 * servidor y no uno inventado aqui.
 */
export async function downloadGeneration(
  generationId: string,
  target: 'spring' | 'mobile',
): Promise<{ blob: Blob; fileName: string }> {
  return requestWithSession(
    `/generations/${generationId}/download?target=${target}`,
    {},
    (respuesta) => readDownload(respuesta, `generacion-${target}.zip`),
  );
}

async function readDownload(
  respuesta: Response,
  fallback: string,
): Promise<{ blob: Blob; fileName: string }> {
  if (!respuesta.ok) await throwApiError(respuesta);
  return {
    blob: await respuesta.blob(),
    fileName: filenameFrom(respuesta, fallback),
  };
}

async function throwApiError(respuesta: Response): Promise<never> {
  const cuerpo: unknown = await respuesta.json().catch(() => null);
  const error = (cuerpo as { error?: { code?: string; message?: string; details?: unknown } })
    ?.error;
  throw new ApiError(
    respuesta.status,
    error?.code ?? 'unknown',
    error?.message ?? `Error ${respuesta.status}`,
    error?.details,
  );
}

function filenameFrom(respuesta: Response, fallback: string): string {
  const disposicion = respuesta.headers.get('content-disposition') ?? '';
  return /filename="([^"]+)"/.exec(disposicion)?.[1] ?? fallback;
}
```

---

### `frontend/src/lib/guardar-archivo.ts`

```ts
/**
 * Descarga un blob con el nombre que se le indique.
 *
 * El nombre lo pide la aplicación antes de llamar aquí, con un campo propio, y
 * no `showSaveFilePicker`. El selector nativo es más completo —deja elegir
 * también la carpeta— pero en un Chromium sin interfaz **no lanza error: se
 * queda colgado**, y el botón de exportar se quedaría girando para siempre sin
 * que nada lo explique. Un campo de texto propio funciona en todos los
 * navegadores, se puede probar de extremo a extremo y no tiene ese modo de
 * fallo.
 */
export function descargarBlob(blob: Blob, nombre: string): void {
  const enlace = document.createElement('a');
  enlace.href = URL.createObjectURL(blob);
  enlace.download = nombre;
  enlace.click();
  URL.revokeObjectURL(enlace.href);
}

/**
 * Deja el nombre en condiciones de ser un archivo.
 *
 * Quita lo que ningún sistema admite en un nombre y asegura la extensión: si
 * alguien escribe «Ventas» el archivo tiene que abrirse igual en Enterprise
 * Architect, y sin `.xmi` no lo ofrece siquiera en su diálogo.
 */
export function nombreDeArchivo(escrito: string, extension: string): string {
  const limpio = escrito
    .replace(/[\\/:*?"<>|]/g, '')
    .trim()
    .replace(/\.+$/, '');

  const base = limpio.length === 0 ? 'diagrama' : limpio;
  return base.toLowerCase().endsWith(extension) ? base : `${base}${extension}`;
}
```

---

### `frontend/src/lib/offline.ts`

```ts
import type { BoardSummary, ProjectRole, SessionUser } from './api.js';

// No credentials: this profile only identifies whose local copies may be opened.
export const OFFLINE_USER_KEY = 'uml_offline_user_v1';
const LOGOUT_KEY = 'uml_offline_logout_v1';
const BOARD_PREFIX = 'uml_offline_board_v1:';
export type OfflineBoard = BoardSummary & { role: ProjectRole };

function read(key: string): unknown {
  try {
    return JSON.parse(localStorage.getItem(key) ?? 'null');
  } catch {
    return null;
  }
}

function record(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

export function offlineUser(): SessionUser | null {
  if (logoutPending()) return null;
  const value = read(OFFLINE_USER_KEY);
  return record(value) &&
    typeof value['id'] === 'string' &&
    typeof value['email'] === 'string' &&
    typeof value['displayName'] === 'string'
    ? { id: value['id'], email: value['email'], displayName: value['displayName'] }
    : null;
}

export function rememberUser(user: SessionUser): void {
  try {
    const { id, email, displayName } = user;
    localStorage.setItem(OFFLINE_USER_KEY, JSON.stringify({ id, email, displayName }));
  } catch {
    /* Online use remains possible when storage is disabled. */
  }
}

export function forgetUser(): void {
  try {
    localStorage.removeItem(OFFLINE_USER_KEY);
  } catch {
    /* Unavailable storage. */
  }
}

export function logoutPending(): boolean {
  return read(LOGOUT_KEY) === true;
}

export function markLogout(pending: boolean): void {
  try {
    if (pending) localStorage.setItem(LOGOUT_KEY, 'true');
    else localStorage.removeItem(LOGOUT_KEY);
  } catch {
    /* Unavailable storage. */
  }
}

function boardKey(userId: string, boardId: string): string {
  return `${BOARD_PREFIX}${encodeURIComponent(userId)}:${encodeURIComponent(boardId)}`;
}

export function cachedBoard(userId: string, boardId: string): OfflineBoard | null {
  const value = read(boardKey(userId, boardId));
  if (
    !record(value) ||
    value['id'] !== boardId ||
    typeof value['projectId'] !== 'string' ||
    typeof value['displayName'] !== 'string' ||
    typeof value['room'] !== 'string' ||
    !['OWNER', 'EDITOR', 'VIEWER'].includes(String(value['role']))
  )
    return null;
  return value as unknown as OfflineBoard;
}

/**
 * Call only after saving a server-synchronized document and verifying its scope.
 *
 * Unlike the profile helpers this one lets a storage failure through on purpose:
 * the caller advertises the board as available offline, and it may only do so
 * once the entry is really on disk.
 */
export function rememberBoard(userId: string, board: OfflineBoard): void {
  localStorage.setItem(boardKey(userId, board.id), JSON.stringify(board));
}

/**
 * Keeps an authorized copy openable, without its former write permission.
 *
 * Losing write access does not invalidate the local document — it is still the
 * server's — so the entry survives as read-only instead of being removed. Only a
 * revoked board justifies `forgetBoard`.
 */
export function downgradeBoard(userId: string, boardId: string): void {
  const board = cachedBoard(userId, boardId);
  if (board === null || board.role === 'VIEWER') return;
  try {
    localStorage.setItem(boardKey(userId, boardId), JSON.stringify({ ...board, role: 'VIEWER' }));
  } catch {
    // Sin espacio para reescribirla, la entrada anterior no puede quedarse: su
    // rol permitiria editar una copia que ya no se puede publicar.
    forgetBoard(userId, boardId);
  }
}

export function forgetBoard(userId: string, boardId: string): void {
  try {
    localStorage.removeItem(boardKey(userId, boardId));
  } catch {
    /* Keep drafts. */
  }
}

export function cachedBoards(userId: string): OfflineBoard[] {
  const result: OfflineBoard[] = [];
  try {
    const prefix = `${BOARD_PREFIX}${encodeURIComponent(userId)}:`;
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (!key?.startsWith(prefix)) continue;
      const board = cachedBoard(userId, decodeURIComponent(key.slice(prefix.length)));
      if (board !== null) result.push(board);
    }
  } catch {
    /* Return only readable entries. */
  }
  return result.sort((a, b) => a.displayName.localeCompare(b.displayName));
}
```

---

## Recursos publicos

Las tipografias y los iconos se listan pero no se vuelcan.

### Estructura

```text
frontend/public/
|-- fonts/
|   |-- OFL-Plex-Sans.txt
|   |-- OFL-Plex-Serif.txt
|   |-- plex-sans-regular.ttf
|   |-- plex-sans-semibold.ttf
|   `-- plex-serif-medium.ttf
|-- apple-touch-icon.png
|-- favicon-32.png
|-- favicon.svg
`-- theme.js
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/public/theme.js` | 20 |
| `frontend/public/fonts/OFL-Plex-Sans.txt` | 94 |
| `frontend/public/fonts/OFL-Plex-Serif.txt` | 94 |

Binarios presentes, no volcados: `frontend/public/apple-touch-icon.png`, `frontend/public/favicon-32.png`, `frontend/public/favicon.svg`, `frontend/public/fonts/plex-sans-regular.ttf`, `frontend/public/fonts/plex-sans-semibold.ttf`, `frontend/public/fonts/plex-serif-medium.ttf`.

---

### `frontend/public/theme.js`

```js
/* global localStorage, window, document */
// Se ejecuta antes del primer dibujo para evitar un destello del tema opuesto.
(() => {
  let preference = 'system';
  try {
    const saved = localStorage.getItem('umlforge.theme');
    if (saved === 'light' || saved === 'dark') preference = saved;
  } catch {
    /* El almacenamiento puede estar restringido. */
  }
  const theme =
    preference === 'system'
      ? window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light'
      : preference;
  document.documentElement.dataset.theme = theme;
  document.documentElement.style.colorScheme = theme;
})();
```

---

### `frontend/public/fonts/OFL-Plex-Sans.txt`

```text
Copyright © 2017 IBM Corp. with Reserved Font Name "Plex"

This Font Software is licensed under the SIL Open Font License, Version 1.1.

This license is copied below, and is also available with a FAQ at: http://scripts.sil.org/OFL


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded, 
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.
```

---

### `frontend/public/fonts/OFL-Plex-Serif.txt`

```text
Copyright © 2017 IBM Corp. with Reserved Font Name "Plex"

This Font Software is licensed under the SIL Open Font License, Version 1.1.

This license is copied below, and is also available with a FAQ at: http://scripts.sil.org/OFL


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded, 
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.
```

---

## Modo sin conexion

El complemento de Vite que emite el service worker y el service worker mismo: la cache de pizarras visitadas y la cola de sincronizacion al reconectar.

### Estructura

```text
frontend/tooling/
|-- offline-plugin.ts
`-- service-worker.js
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/tooling/offline-plugin.ts` | 44 |
| `frontend/tooling/service-worker.js` | 41 |

---

### `frontend/tooling/offline-plugin.ts`

```ts
import { createHash } from 'node:crypto';
import { readFileSync, readdirSync } from 'node:fs';
import { resolve } from 'node:path';
import type { Plugin } from 'vite';

/** Precache a complete production build, including the lazy editor and fonts. */
export function offlinePlugin(): Plugin {
  let publicDir: string;
  return {
    name: 'uml-offline-shell',
    apply: 'build',
    enforce: 'post',
    configResolved(config) {
      publicDir = config.publicDir;
    },
    generateBundle(_options, bundle) {
      const files = Object.keys(bundle).filter((file) =>
        /\.(?:html|js|css|woff2?|ttf|svg|png)$/.test(file),
      );
      const hash = createHash('sha256');
      for (const file of files.sort()) {
        const item = bundle[file]!;
        hash.update(item.type === 'chunk' ? item.code : item.source);
      }
      for (const entry of readdirSync(publicDir, { recursive: true, withFileTypes: true })) {
        if (!entry.isFile()) continue;
        const absolute = resolve(entry.parentPath, entry.name);
        const relative = absolute.slice(publicDir.length + 1).replaceAll('\\', '/');
        files.push(relative);
        hash.update(readFileSync(absolute));
      }
      const template = readFileSync(new URL('./service-worker.js', import.meta.url), 'utf8');
      const version = hash.update(template).digest('hex').slice(0, 20);
      this.emitFile({
        type: 'asset',
        fileName: 'sw.js',
        source: template
          .replace('= __CACHE_NAME__;', `= ${JSON.stringify(`uml-shell-v1-${version}`)};`)
          .replace('= __ASSETS__;', `= ${JSON.stringify(files.map((file) => `/${file}`))};`),
      });
    },
  };
}
```

---

### `frontend/tooling/service-worker.js`

```js
/* global self, caches, fetch, URL, __CACHE_NAME__, __ASSETS__ */
const CACHE = __CACHE_NAME__;
const ASSETS = __ASSETS__;

self.addEventListener('install', (event) => {
  // A partial download cannot replace a working build. Updates wait until all
  // old tabs close, so an active editor never mixes incompatible asset versions.
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(ASSETS)));
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      for (const key of await caches.keys()) {
        if (key.startsWith('uml-shell-v1-') && key !== CACHE) await caches.delete(key);
      }
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin) return;
  // Never cache identities, tokens, API responses, or collaboration traffic.
  if (/^\/(?:api|collab)(?:\/|$)/.test(url.pathname)) return;
  const appRoute =
    request.mode === 'navigate' &&
    /^\/(?:$|index\.html$|entrar\/?$|activar\/?$|restablecer\/?$|cuenta\/?$|sin-conexion\/?$|proyectos(?:\/[^/]+)?\/?$|pizarras\/[^/]+\/?$)/.test(
      url.pathname,
    );
  if (!appRoute && !ASSETS.includes(url.pathname)) return;
  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE);
      return (await cache.match(appRoute ? '/index.html' : url.pathname)) ?? fetch(request);
    })(),
  );
});
```

---

## Uso, requisitos y limites del editor sin conexion

### Estructura

```text
frontend/OFFLINE.md
`-- OFFLINE.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/OFFLINE.md` | 48 |

---

### `frontend/OFFLINE.md`

```markdown
# Uso del editor web sin conexión

El editor permite abrir y recargar pizarras visitadas previamente, continuar editando y sincronizar con Yjs al recuperar conexión. La aplicación Flutter generada mantiene su mecanismo independiente de SQLite y cola de operaciones.

## Uso

1. Abre la versión compilada de la web mediante HTTPS o `http://localhost`. Inicia sesión con conexión.
2. Abre cada pizarra que quieras usar offline y espera el indicador **Disponible sin conexión**. Este aparece cuando tanto la interfaz como la copia de la pizarra están guardadas.
3. Puedes desconectarte, editar, recargar la página o cerrar y volver a abrir la pestaña en el mismo navegador. **Ver pizarras guardadas** permite navegar entre las copias de esa cuenta.
4. Al reconectar se renueva la sesión, se consulta el acceso actual y después se recuperan los borradores sobre el documento del servidor. También se reintenta cada cinco segundos cuando el navegador indica conectividad, y al volver a enfocar la ventana.

Si la sesión ya no es válida, inicia sesión con la misma cuenta para recuperar los pendientes. Si el permiso cambió a lector, se abre el documento del servidor sin enviar el borrador y la entrada offline pasa a solo lectura. Solo la revocación del acceso a la pizarra retira su entrada; que caduque el token de acceso, que ocurre cada quince minutos con una pizarra abierta, no la toca. Los borradores se conservan para una recuperación posterior si se vuelve a autorizar la edición.

Si la renovación del token falla por red o por un error temporal del servidor, el editor pasa a la copia local y reintenta sin exigir una recarga, incluso si el navegador sigue indicando conexión. El permiso de lectura se guarda al autenticar, antes de completar la sincronización.

Si la sesión se recupera pero el servicio de pizarras sigue sin responder, la copia local continúa editable y se reintenta la consulta. Un error de permisos no activa este respaldo. El indicador de disponibilidad se retira si falla el guardado de la instantánea, y el contador de cambios por auditar usa la cuenta local incluso después de recargar sin red.

Si el servidor restablece el permiso de edición mientras la pizarra sigue abierta como lector, los borradores se recuperan automáticamente sobre el documento sincronizado, sin necesitar una recarga.

## Límites

- El primer inicio de sesión y las pizarras nunca visitadas necesitan conexión. Crear proyectos, gestionar miembros, el asistente, importar mediante el servidor, exportar XMI y generar código también la requieren. La exportación PNG se realiza en el navegador.
- La caché de la interfaz se genera con `npm run build --workspace @uml/web`. El servidor de desarrollo Vite no instala un service worker. En HTTP sobre una IP de la red local el navegador no permite instalarlo: usa HTTPS o localhost. Véase [la documentación del navegador](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers).
- Los datos se guardan por origen, cuenta y pizarra, en este navegador. Borrar sus datos, cambiar de navegador o usar una sesión privada que se cierre puede eliminar las copias. No sustituyen una copia de seguridad.
- Se conserva el almacenamiento local del editor existente (`localStorage`). Si se agota la cuota, no se acepta una edición que no pueda guardarse; se muestra un aviso. La actualización de la copia para apertura offline también informa sus errores.
- Los permisos guardados permiten editar únicamente la copia local mientras no hay red. Los permisos vigentes del servidor siguen controlando las escrituras remotas. Una revocación desconocida no puede detectarse sin conexión.
- La sincronización necesita la aplicación abierta. No se ejecuta un proceso de sincronización con todas las pestañas cerradas.

## Implementación

El service worker precarga únicamente los archivos estáticos de una compilación completa, incluidos los módulos diferidos del editor y las fuentes. No intercepta la API ni WebSocket. Cada compilación tiene su propia caché; una actualización espera a que se cierren las pestañas de la versión anterior antes de activarse.

La identidad recordada contiene únicamente ID, correo y nombre. Los tokens de acceso siguen en memoria y el refresh token en su cookie HTTP-only. Salir borra la identidad recordada y, si no se pudo contactar al servidor, deja pendiente la revocación para impedir que una recarga restaure la sesión cerrada. Los cambios pendientes permanecen separados por cuenta.

Inicio de sesión, cierre y renovación comparten un bloqueo del navegador para evitar que una respuesta pendiente de otra pestaña sobrescriba la cookie de una sesión nueva.

Las instantáneas permiten abrir también documentos vacíos o visitados solo como lector. Se reescriben cuando la pizarra deja de recibir cambios durante un segundo, al ocultar la pestaña y al cerrarla, en lugar de en cada actualización del documento. Los borradores guardan los cambios antes de aplicarlos. Al reconectar se crea otra réplica de Yjs: no se conecta la réplica offline antes de verificar permisos; solo se mezclan borradores después de autenticación con escritura y sincronización inicial. El cambio de réplica no remonta el editor: la conversación del asistente y el candidato de importación en curso sobreviven a un corte de red.

Quedarse sin conexión se confirma antes de pasar a la copia local: el evento del navegador también se dispara al cambiar de red. El editor marca «Sin conexión» de inmediato por su cuenta y sigue guardando cada cambio. Las otras páginas permanecen montadas incluso durante cortes prolongados y muestran un aviso; los formularios conservan lo escrito al reconectar. El enlace **Ver pizarras guardadas** abre el catálogo en `/sin-conexion` sin sustituir automáticamente la página actual.

Abrir una copia local no escribe ni unifica las ranuras de borrador, aunque haya varias o no quede cuota. Cada editor conserva su ranura al reintentar la conexión; las ranuras se unifican al restaurarlas en una conexión autorizada.

## Verificación

`npm run test:offline` compila la versión de producción y ejecuta Chromium contra un servidor Hocuspocus real y una API de prueba aislada, sin Docker ni PostgreSQL. Cubre recarga y reapertura sin red, cambios concurrentes, pizarras no visitadas, lectores, permisos retirados, cierre de sesión, recuperación de una sesión vencida, caducidad del token de acceso con renovación fallida y un parpadeo de red con trabajo abierto en los paneles. No sustituye `npm run test:e2e`, que verifica el backend completo con PostgreSQL.

Las pruebas unitarias de `frontend/tests/board-drafts.test.ts`, `offline.test.ts` y `api.test.ts` cubren persistencia, separación de cuentas, corrupción, falta de almacenamiento y renovación de sesión.
```

---

## Punto de entrada HTML

### Estructura

```text
frontend/index.html
`-- index.html
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/index.html` | 27 |

---

### `frontend/index.html`

```html
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>UMLFORGE AI</title>
    <meta
      name="description"
      content="Diagramas de clases UML en equipo y en tiempo real, con asistente por texto y voz, y generación del backend Spring Boot con PostgreSQL."
    />

    <!-- SVG primero: escala sin bordes sucios en pantallas densas. El PNG de 32
         queda como respaldo para los navegadores que aún no lo aceptan. -->
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32.png" />
    <link rel="apple-touch-icon" href="/apple-touch-icon.png" />

    <!-- El color de la barra del navegador en móvil, igual que el acento. -->
    <meta name="theme-color" content="#f5f4f0" />
    <script src="/theme.js"></script>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

---

## Configuracion de Vite

### Estructura

```text
frontend/vite.config.ts
`-- vite.config.ts
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/vite.config.ts` | 29 |

---

### `frontend/vite.config.ts`

```ts
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';
import { offlinePlugin } from './tooling/offline-plugin.js';

export default defineConfig({
  plugins: [react(), offlinePlugin()],
  server: {
    host: true,
    port: 5173,
    // El navegador habla siempre con un solo origen. En desarrollo lo resuelve
    // este proxy; en la demostracion lo resuelve el servicio `proxy` de la
    // composicion (plan maestro 4.3).
    proxy: {
      '/api': {
        target: process.env['VITE_API_TARGET'] ?? 'http://localhost:3001',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api(?=\/|$)/, '') || '/',
      },
      '/collab': {
        target: process.env['VITE_COLLAB_TARGET'] ?? 'http://localhost:3002',
        changeOrigin: true,
        ws: true,
        rewrite: (path) => path.replace(/^\/collab(?=\/|$)/, '') || '/',
      },
    },
  },
  build: { outDir: 'dist', sourcemap: true },
});
```

---

## Dependencias del paquete web

### Estructura

```text
frontend/package.json
`-- package.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/package.json` | 34 |

---

### `frontend/package.json`

```json
{
  "name": "@uml/web",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "description": "Aplicacion web React: editor, proyectos, sesion, asistente e importacion.",
  "scripts": {
    "build": "tsc --build && vite build",
    "clean": "tsc --build --clean && rimraf dist",
    "dev": "vite",
    "preview": "vite preview"
  },
  "dependencies": {
    "@hocuspocus/provider": "^4.6.0",
    "@uml/contracts": "*",
    "@uml/domain-core": "*",
    "@uml/yjs-adapter": "*",
    "@xyflow/react": "^12.11.5",
    "html-to-image": "1.11.11",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router": "^7.18.3",
    "yjs": "^13.6.32",
    "zustand": "^5.0.15"
  },
  "devDependencies": {
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "@vitejs/plugin-react": "^4.3.0",
    "rimraf": "^6.0.0",
    "vite": "^6.0.0"
  }
}
```

---

## TypeScript del paquete web

### Estructura

```text
frontend/tsconfig.json
`-- tsconfig.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `frontend/tsconfig.json` | 27 |

---

### `frontend/tsconfig.json`

```json
{
  "extends": "../config/tsconfig.base.json",
  "compilerOptions": {
    "lib": ["ES2023", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "types": ["vite/client"],
    "jsx": "react-jsx",
    "rootDir": "src",
    "outDir": "dist-types",
    "emitDeclarationOnly": true,
    "noEmit": false
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"],
  "references": [
    {
      "path": "../shared/contracts"
    },
    {
      "path": "../shared/domain-core"
    },
    {
      "path": "../shared/yjs-adapter"
    }
  ]
}
```

