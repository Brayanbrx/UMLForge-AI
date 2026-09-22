"""Contexto de los paquetes compartidos: el nucleo del producto."""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="shared.md",
    titulo="Paquetes compartidos",
    descripcion=(
        "El nucleo del producto, consumido por backend y frontend por igual. "
        "`contracts` define el modelo canonico y el vocabulario cerrado de "
        "comandos; `domain-core` las reglas que los aplican y validan; "
        "`generation-ir` traduce el modelo conceptual a decisiones de "
        "persistencia; `generator-backend` renderiza las plantillas y arma el "
        "ZIP; `yjs-adapter` puentea el modelo con el CRDT; `xmi` importa y "
        "exporta diagramas; `ai` encapsula los proveedores tras puertos."
    ),
    objetivos=(
        Objetivo(
            ruta="shared/contracts",
            titulo="contracts --- modelo y comandos",
            nota=(
                "Punto de partida para leer el proyecto. `model.ts` dice que es un "
                "diagrama y `commands.ts` que es un cambio; ese esquema es tambien "
                "el formato de salida obligatorio del modelo de lenguaje."
            ),
        ),
        Objetivo(
            ruta="shared/domain-core",
            titulo="domain-core --- reglas del dominio",
            nota=(
                "Aplicacion de comandos, validacion, normalizacion de los tres "
                "nombres por elemento, herencia, claves primarias y palabras "
                "reservadas de Java."
            ),
        ),
        Objetivo(
            ruta="shared/generation-ir",
            titulo="generation-ir --- representacion intermedia",
            nota=(
                "La bisagra: aqui se decide dueno de la relacion, columnas de union "
                "y correspondencia de tipos conceptuales con Java y PostgreSQL. "
                "El modelo canonico deliberadamente no sabe nada de esto."
            ),
        ),
        Objetivo(
            ruta="shared/generator-backend",
            titulo="generator-backend --- generacion de artefactos",
            nota="Vista de plantilla, renderizado, huella y empaquetado ZIP.",
        ),
        Objetivo(
            ruta="shared/yjs-adapter",
            titulo="yjs-adapter --- colaboracion",
            nota="Traduccion entre el modelo canonico y el documento CRDT de Yjs.",
        ),
        Objetivo(
            ruta="shared/xmi",
            titulo="xmi --- importacion y exportacion",
            nota=(
                "Incluye el dialecto de Enterprise Architect. Lo importado entra "
                "como propuesta editable, nunca se aplica a ciegas."
            ),
        ),
        Objetivo(
            ruta="shared/ai",
            titulo="ai --- proveedores de lenguaje",
            nota=(
                "Puertos y adaptadores, cadena de respaldo entre proveedores, "
                "construccion de indicaciones y propuestas revisables por el usuario."
            ),
        ),
    ),
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
