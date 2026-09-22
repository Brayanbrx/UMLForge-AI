"""Contexto del frontend: la aplicacion web React."""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="frontend.md",
    titulo="Frontend",
    descripcion=(
        "Aplicacion web en React con Vite. `src/features/` agrupa por pantalla: "
        "autenticacion, proyectos, editor de la pizarra, asistente de IA, "
        "importacion, panel de generacion y ayuda. `src/components/` son piezas "
        "globales y `src/lib/` el cliente HTTP y la descarga de archivos."
    ),
    objetivos=(
        Objetivo(
            ruta="frontend/src",
            titulo="Codigo de la aplicacion",
            nota=(
                "`styles.css` es la hoja principal y es grande; si estorba, "
                "ejecutar con `--max-kib 20` para recortarla."
            ),
        ),
        Objetivo(
            ruta="frontend/public",
            titulo="Recursos publicos",
            nota="Las tipografias y los iconos se listan pero no se vuelcan.",
        ),
        Objetivo(
            ruta="frontend/tests",
            titulo="Pruebas unitarias",
            nota="Solo aparecen al ejecutar con `--con-pruebas`.",
        ),
        Objetivo(
            ruta="frontend/tooling",
            titulo="Modo sin conexion",
            nota=(
                "El complemento de Vite que emite el service worker y el service "
                "worker mismo: la cache de pizarras visitadas y la cola de "
                "sincronizacion al reconectar."
            ),
        ),
        Objetivo(
            ruta="frontend/OFFLINE.md",
            titulo="Uso, requisitos y limites del editor sin conexion",
        ),
        Objetivo(ruta="frontend/index.html", titulo="Punto de entrada HTML"),
        Objetivo(ruta="frontend/vite.config.ts", titulo="Configuracion de Vite"),
        Objetivo(ruta="frontend/package.json", titulo="Dependencias del paquete web"),
        Objetivo(ruta="frontend/tsconfig.json", titulo="TypeScript del paquete web"),
    ),
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
