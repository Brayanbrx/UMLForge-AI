"""Contexto de la documentacion escrita: ADR, auditorias y plan maestro.

La carpeta `docs/` esta borrada en el arbol de trabajo. Si se recupera con
`git restore docs`, este script la vuelca sin tocar nada mas.
"""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="documentacion.md",
    titulo="Documentacion del proyecto",
    descripcion=(
        "El porque de cada decision. Los ADR numerados justifican el monolito "
        "modular, el CRDT para colaboracion, el modelo canonico con comandos por "
        "lotes, la IA tras puertos, la ausencia de event sourcing y la "
        "generalizacion tabla por clase. El codigo los cita por numero "
        "(`RA-04`, `RA-06`, `RA-13`, `RM-02`, `RTM-02`), asi que sin ellos las "
        "referencias de los comentarios quedan sueltas."
    ),
    objetivos=(
        Objetivo(
            ruta="docs/adr",
            titulo="Decisiones de arquitectura",
            nota="ADR-001 a ADR-020, cada uno con contexto, decision y consecuencias.",
        ),
        Objetivo(ruta="docs/architecture", titulo="Arquitectura"),
        Objetivo(ruta="docs/requirements", titulo="Requisitos"),
        Objetivo(ruta="docs/referencia", titulo="Plan maestro"),
        Objetivo(ruta="docs/examen", titulo="Material de defensa"),
        Objetivo(
            ruta="docs",
            titulo="Notas sueltas",
            nota="Auditorias, revisiones y guias por fecha.",
            # Sin bajar a las subcarpetas: ya tienen su propia seccion arriba.
            recursivo=False,
        ),
    ),
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
