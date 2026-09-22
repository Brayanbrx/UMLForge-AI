"""Contexto de las plantillas: el codigo que se entrega al usuario final."""

from nucleo import Documento, Objetivo, ejecutar

DOCUMENTO = Documento(
    nombre="plantillas.md",
    titulo="Plantillas de generacion",
    descripcion=(
        "Estas plantillas no son codigo de la plataforma: son el codigo que la "
        "plataforma **produce** a partir de un diagrama. `spring` genera el "
        "proyecto Spring Boot con PostgreSQL; `flutter`, `mobile-backend` y "
        "`mobile-package` componen la variante Android con backend protegido, "
        "sincronizacion y los guiones `apk.bat` / `apk.sh`."
    ),
    objetivos=(
        Objetivo(
            ruta="templates/spring",
            titulo="Spring Boot",
            nota=(
                "Entidades, DTO planos, repositorios, servicios, controladores, "
                "manejo de errores, `pom.xml`, Docker y Compose. Las extensiones "
                "`.hbs` se resaltan por su lenguaje interno: `entity.java.hbs` "
                "aparece como Java."
            ),
        ),
        Objetivo(
            ruta="templates/flutter",
            titulo="Aplicacion Flutter",
            nota="Cliente Android con almacenamiento local y asistente empotrado.",
        ),
        Objetivo(
            ruta="templates/mobile-backend",
            titulo="Backend movil",
            nota="Contrato, seguridad, sesiones y sincronizacion del cliente movil.",
        ),
        Objetivo(
            ruta="templates/mobile-package",
            titulo="Empaquetado movil",
            nota="`apk.bat`, `apk.sh` y el `COMANDOS.md` que acompana cada ZIP.",
        ),
    ),
    # Las plantillas traen sus propias pruebas y conviene verlas.
    pruebas_por_defecto=True,
)

if __name__ == "__main__":
    ejecutar(DOCUMENTO)
