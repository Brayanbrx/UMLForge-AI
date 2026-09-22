"""Contexto del backend: proceso HTTP, proceso de colaboracion y base de datos."""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="backend.md",
    titulo="Backend",
    descripcion=(
        "Los dos procesos de servidor y el esquema de datos. `api` es el servidor "
        "HTTP (Fastify, puerto 3001) con los modulos de autenticacion, proyectos, "
        "pizarras, IA, importacion, generacion y auditoria. `collab` es el servidor "
        "WebSocket (puerto 3002) que sostiene la edicion simultanea sobre el "
        "documento CRDT. `prisma` contiene el esquema de PostgreSQL y sus migraciones."
    ),
    objetivos=(
        Objetivo(
            ruta="backend/api",
            titulo="API HTTP",
            nota=(
                "`src/modules/` agrupa por area funcional y `src/plugins/` recoge lo "
                "transversal: autenticacion, cliente Prisma y cabeceras de seguridad."
            ),
        ),
        Objetivo(
            ruta="backend/collab",
            titulo="Servidor de colaboracion",
            nota=(
                "Autoriza por proyecto antes de abrir la sesion y persiste el estado "
                "del documento compartido."
            ),
        ),
        Objetivo(
            ruta="backend/prisma",
            titulo="Esquema y migraciones",
            nota="Fuente de verdad del modelo relacional de la plataforma.",
        ),
        Objetivo(
            ruta="prisma.config.ts",
            titulo="Configuracion de Prisma",
        ),
    ),
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
