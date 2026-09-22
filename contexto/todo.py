"""Ejecuta todos los generadores de contexto y escribe ademas un indice.

    python contexto/todo.py
    python contexto/todo.py --con-pruebas --max-kib 40
"""

from __future__ import annotations

import datetime as _dt
import sys
from pathlib import Path

import backend
import documentacion
import fixtures
import frontend
import herramientas
import infraestructura
import plantillas
import shared
from nucleo import Documento, argumentos, generar

DOCUMENTOS: tuple[Documento, ...] = (
    shared.DOCUMENTO,
    backend.DOCUMENTO,
    frontend.DOCUMENTO,
    plantillas.DOCUMENTO,
    fixtures.DOCUMENTO,
    herramientas.DOCUMENTO,
    infraestructura.DOCUMENTO,
    documentacion.DOCUMENTO,
)


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    opciones = argumentos("Genera todos los documentos de contexto.")
    generados: list[tuple[Documento, Path]] = []
    for documento in DOCUMENTOS:
        destino = generar(documento, opciones)
        if destino is not None:
            generados.append((documento, destino))

    ahora = _dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    lineas = [
        "# Contexto del proyecto",
        "",
        "Volcado del codigo esencial, una carpeta por documento.",
        "",
        f"> Generado el {ahora} por `contexto/todo.py`.",
        "",
        "| Documento | Contenido | Tamano |",
        "| --- | --- | ---: |",
    ]
    total = 0
    for documento, destino in generados:
        tamano = destino.stat().st_size
        total += tamano
        resumen = documento.descripcion.split(".")[0].strip() + "."
        lineas.append(f"| [{documento.titulo}]({destino.name}) | {resumen} | {tamano / 1024:.0f} KiB |")
    lineas.extend(["", f"Total: {total / 1024:.0f} KiB en {len(generados)} documentos.", ""])

    indice = Path(opciones.salida) / "indice.md"
    indice.write_text("\n".join(lineas), encoding="utf-8")
    print(f"\nindice.md -> {indice}")
    print(f"Total: {total / 1024:.0f} KiB en {len(generados)} documentos.")


if __name__ == "__main__":
    main()
