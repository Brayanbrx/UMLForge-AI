"""Comprueba que los documentos de contexto cubren todo el repositorio.

Recorre la raiz entera y resta lo que ya recogen los siete generadores. Lo que
sobra son archivos que existen en el disco pero no apareceran en ningun `.md`.

    python contexto/cobertura.py            # resumen y lista de huecos
    python contexto/cobertura.py --detalle  # ademas, que documento cubre cada carpeta

Devuelve codigo de salida 1 si hay huecos, para poder encadenarlo.
"""

from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from pathlib import Path

import nucleo
from nucleo import RAIZ, Archivo, Documento, Recolector

# Se importa aqui para reutilizar la lista unica de documentos.
import todo as _todo


def _cobertura() -> tuple[dict[str, list[str]], dict[str, Archivo]]:
    """Devuelve (documento -> rutas cubiertas) y (ruta -> archivo en disco)."""
    por_documento: dict[str, list[str]] = defaultdict(list)
    for documento in _todo.DOCUMENTOS:
        recolector = Recolector(con_pruebas=True, excluir=documento.excluir)
        for objetivo in documento.objetivos:
            base = RAIZ / objetivo.ruta
            if not base.exists():
                continue
            for archivo in recolector.recorrer(base):
                por_documento[documento.nombre].append(archivo.relativa)

    completo = Recolector(con_pruebas=True, excluir=("contexto",))
    en_disco = {a.relativa: a for a in completo.recorrer(RAIZ)}
    return por_documento, en_disco


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    analizador = argparse.ArgumentParser(description=__doc__)
    analizador.add_argument(
        "--detalle",
        action="store_true",
        help="mostrar cuantos archivos aporta cada documento",
    )
    opciones = analizador.parse_args()

    por_documento, en_disco = _cobertura()
    cubiertos = {ruta for rutas in por_documento.values() for ruta in rutas}

    # Un archivo puede estar cubierto por un documento y quedar fuera del
    # barrido general (o al reves) si los filtros no coinciden: interesan ambos.
    huecos = sorted(set(en_disco) - cubiertos)
    fantasmas = sorted(cubiertos - set(en_disco))

    print(f"En disco:  {len(en_disco)} archivos")
    print(f"Cubiertos: {len(cubiertos & set(en_disco))} archivos")
    print(f"Huecos:    {len(huecos)} archivos\n")

    if opciones.detalle:
        print("Aporte por documento")
        for documento in _todo.DOCUMENTOS:
            rutas = por_documento.get(documento.nombre, [])
            lineas = sum(en_disco[r].lineas for r in rutas if r in en_disco)
            print(f"  {documento.nombre:24s} {len(rutas):4d} archivos  {lineas:7,d} lineas")
        print()

    if fantasmas:
        print("Cubiertos pero fuera del barrido general (revisar filtros):")
        for ruta in fantasmas:
            print(f"  {ruta}")
        print()

    if not huecos:
        print("Sin huecos: todo el repositorio aparece en algun documento.")
        return 0

    print("Sin cubrir por ningun documento:")
    duplicados: dict[str, int] = defaultdict(int)
    for ruta in huecos:
        archivo = en_disco[ruta]
        marca = "[bin]" if archivo.binario else f"{archivo.lineas:5d}"
        print(f"  {marca}  {ruta}")
        duplicados[ruta.split("/")[0]] += 1

    print("\nPor carpeta de primer nivel:")
    for carpeta, cuenta in sorted(duplicados.items(), key=lambda p: -p[1]):
        print(f"  {cuenta:4d}  {carpeta}")
    print("\nAnade un Objetivo al script correspondiente para cerrarlos.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
