"""Contexto de infraestructura: Docker, despliegue, integracion continua y raiz."""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="infraestructura.md",
    titulo="Infraestructura y despliegue",
    descripcion=(
        "Todo lo que rodea al codigo: contenedores, orquestacion, servidor web, "
        "certificados, copias de seguridad, unidades de systemd, integracion "
        "continua y la configuracion de la raiz del monorepo."
    ),
    objetivos=(
        Objetivo(
            ruta="infra",
            titulo="Infraestructura",
            nota=(
                "Dockerfiles de los tres procesos, Compose local y de produccion, "
                "Caddy y nginx, copias a S3, unidades de systemd, plantillas de "
                "entorno y las guias de despliegue en Markdown. Los `.env` reales "
                "nunca se versionan; solo aparecen los `.example`."
            ),
        ),
        Objetivo(
            ruta=".github",
            titulo="Integracion continua",
            nota="Flujos de trabajo que ejecutan formato, lint, tipos y pruebas.",
        ),
        Objetivo(
            ruta="config",
            titulo="Configuracion compartida",
            nota="Bases de TypeScript y configuracion de las pruebas de integracion.",
        ),
        Objetivo(ruta="package.json", titulo="Raiz del monorepo"),
        Objetivo(ruta="tsconfig.json", titulo="TypeScript raiz"),
        Objetivo(ruta="vitest.config.ts", titulo="Vitest"),
        Objetivo(ruta="eslint.config.js", titulo="ESLint"),
        Objetivo(ruta=".prettierrc.json", titulo="Prettier"),
        Objetivo(ruta=".dockerignore", titulo="Exclusiones de Docker"),
        Objetivo(ruta=".gitignore", titulo="Exclusiones de Git"),
        Objetivo(ruta=".gitattributes", titulo="Atributos de Git"),
        Objetivo(ruta=".prettierignore", titulo="Exclusiones de Prettier"),
        Objetivo(ruta=".nvmrc", titulo="Version de Node"),
        Objetivo(ruta=".editorconfig", titulo="EditorConfig"),
        Objetivo(ruta="README.md", titulo="README del proyecto"),
    ),
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
