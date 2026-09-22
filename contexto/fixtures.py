"""Contexto del banco de diagramas de referencia."""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="fixtures.md",
    titulo="Banco de diagramas",
    descripcion=(
        "Los diagramas de referencia T01 a T08 y los XMI de importacion. Es la "
        "evidencia de que el generador funciona sobre casos variados y no sobre "
        "un unico ejemplo favorable: `npm run test:bank` compila lo generado a "
        "partir de ellos."
    ),
    objetivos=(
        Objetivo(
            ruta="fixtures/src",
            titulo="Construccion del banco",
            nota="Definiciones, carga, serializacion y el informe de cobertura.",
        ),
        Objetivo(
            ruta="fixtures/uml",
            titulo="Diagramas T01 a T08",
            nota="Cada archivo es un modelo canonico completo en JSON.",
        ),
        Objetivo(
            ruta="fixtures/xmi",
            titulo="XMI de referencia",
            nota=(
                "Diagramas reales de Enterprise Architect usados para probar la "
                "importacion. Son grandes; se truncan si superan el limite."
            ),
        ),
        Objetivo(
            ruta="fixtures/tests",
            titulo="Pruebas del banco",
            nota="Solo aparecen al ejecutar con `--con-pruebas`.",
        ),
        Objetivo(ruta="fixtures/package.json", titulo="Paquete de fixtures"),
        Objetivo(ruta="fixtures/tsconfig.json", titulo="TypeScript del banco"),
    ),
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
