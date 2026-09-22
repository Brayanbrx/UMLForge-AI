"""Contexto de las utilidades de linea de ordenes y las pruebas de extremo a extremo."""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="herramientas.md",
    titulo="Utilidades y pruebas de extremo a extremo",
    descripcion=(
        "`scripts/` son las utilidades que se invocan desde npm: preparar el "
        "entorno, sembrar la demostracion, generar un backend de ejemplo y "
        "verificar produccion. `e2e/` son las pruebas de Playwright que recorren "
        "la aplicacion real: colaboracion simultanea, importacion, generacion, "
        "cuenta y accesibilidad."
    ),
    objetivos=(
        Objetivo(
            ruta="scripts",
            titulo="Utilidades",
            nota=(
                "`seed-demo.ts` crea las cuentas de prueba, `generate-demo-backend.ts` "
                "produce el ZIP de ejemplo y los `verify-*` comprueban despliegues."
            ),
        ),
        Objetivo(
            ruta="e2e",
            titulo="Pruebas de extremo a extremo",
            nota="Configuracion de Playwright, especificaciones y utilidades de apoyo.",
        ),
    ),
    # Estas carpetas *son* las pruebas: incluirlas siempre.
    pruebas_por_defecto=True,
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
