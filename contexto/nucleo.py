"""Motor compartido de los generadores de contexto.

Recorre una o varias carpetas del repositorio y produce un unico archivo
Markdown con el arbol de directorios y el contenido integro de cada archivo de
codigo. Los scripts hermanos de esta carpeta solo declaran que incluir; toda la
logica vive aqui.

No forma parte del proyecto: la carpeta `contexto/` esta excluida del control de
versiones.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable, Sequence

# Raiz del repositorio: el padre de `contexto/`.
RAIZ = Path(__file__).resolve().parent.parent
SALIDA_POR_DEFECTO = Path(__file__).resolve().parent / "salida"

# --------------------------------------------------------------------------- #
# Filtros
# --------------------------------------------------------------------------- #

# Carpetas que nunca se recorren, esten donde esten.
DIRECTORIOS_IGNORADOS = {
    ".git",
    ".idea",
    ".vscode",
    ".vite",
    ".cache",
    ".turbo",
    "node_modules",
    "dist",
    "dist-types",
    "build",
    "out",
    "coverage",
    "reports",
    "playwright-report",
    "blob-report",
    "test-results",
    "__pycache__",
    "target",
    ".gradle",
    "logs",
}

# Carpetas de pruebas: se omiten salvo que se pida --con-pruebas.
DIRECTORIOS_DE_PRUEBAS = {"tests", "test", "__tests__", "specs", "e2e"}

# Extensiones que se vuelcan como texto.
EXTENSIONES_DE_TEXTO = {
    ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs",
    ".json", ".jsonc",
    ".css", ".scss", ".html",
    ".prisma", ".sql",
    ".hbs", ".tpl",
    ".java", ".kt", ".dart", ".gradle",
    ".yml", ".yaml", ".toml", ".ini", ".conf", ".properties",
    ".sh", ".bash", ".bat", ".ps1",
    ".md", ".txt",
    ".xml", ".xmi",
    ".env", ".example", ".production",
    ".service", ".timer",
    ".dockerfile", ".dockerignore",
    ".editorconfig", ".gitattributes", ".gitignore", ".nvmrc",
    ".prettierrc", ".prettierignore",
    ".py",
}

# Archivos de texto que Python no reconoce por la extension.
#
# Los nombres que empiezan por punto y no tienen otro punto (`.gitignore`,
# `.nvmrc`) devuelven un sufijo vacio, asi que hay que nombrarlos uno a uno o
# acaban clasificados como binarios.
NOMBRES_DE_TEXTO = {
    "Dockerfile",
    "Caddyfile",
    "Makefile",
    "LICENSE",
    ".env",
    ".env.example",
    ".nvmrc",
    ".editorconfig",
    ".dockerignore",
    ".gitignore",
    ".gitattributes",
    ".prettierignore",
    ".prettierrc",
    ".prettierrc.json",
    ".npmrc",
    ".eslintignore",
    ".babelrc",
}

# Archivos que aportan ruido y no contexto.
NOMBRES_IGNORADOS = {
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "composer.lock",
    ".DS_Store",
    "Thumbs.db",
    ".gitkeep",
}

SUFIJOS_IGNORADOS = (
    ".tsbuildinfo",
    ".log",
    ".map",
    ".min.js",
    ".min.css",
)

# Binarios conocidos: se listan en el arbol pero no se vuelcan.
EXTENSIONES_BINARIAS = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".svg",
    ".ttf", ".otf", ".woff", ".woff2", ".eot",
    ".pdf", ".zip", ".gz", ".tar", ".jar", ".apk",
    ".keystore", ".jks", ".pem", ".p12",
    ".mp4", ".mp3", ".wav",
}

# Lenguaje del bloque de codigo segun la extension.
LENGUAJES = {
    ".ts": "ts", ".tsx": "tsx", ".js": "js", ".jsx": "jsx",
    ".mjs": "js", ".cjs": "js",
    ".json": "json", ".jsonc": "json",
    ".css": "css", ".scss": "scss", ".html": "html",
    ".prisma": "prisma", ".sql": "sql",
    ".java": "java", ".kt": "kotlin", ".dart": "dart",
    ".gradle": "groovy",
    ".yml": "yaml", ".yaml": "yaml", ".toml": "toml",
    ".ini": "ini", ".conf": "nginx", ".properties": "properties",
    ".sh": "bash", ".bash": "bash", ".bat": "bat", ".ps1": "powershell",
    ".md": "markdown", ".txt": "text",
    ".xml": "xml", ".xmi": "xml",
    ".py": "python",
    ".hbs": "handlebars",
    ".service": "ini", ".timer": "ini",
    ".env": "bash", ".example": "bash", ".production": "bash",
    ".dockerfile": "dockerfile",
}

# Tamano maximo por archivo antes de truncar (en KiB).
MAX_KIB_POR_DEFECTO = 160


# --------------------------------------------------------------------------- #
# Configuracion de cada generador
# --------------------------------------------------------------------------- #

@dataclass
class Objetivo:
    """Una carpeta o archivo suelto a incluir en el documento."""

    ruta: str
    titulo: str = ""
    nota: str = ""
    #: Con False solo se toman los archivos sueltos de la carpeta, sin bajar a
    #: las subcarpetas. Sirve para que una carpeta contenedora no repita lo que
    #: ya recogen las secciones de sus subcarpetas.
    recursivo: bool = True


@dataclass
class Documento:
    """Declaracion completa de un archivo Markdown a generar."""

    nombre: str
    titulo: str
    descripcion: str
    objetivos: Sequence[Objetivo]
    #: Rutas relativas a la raiz que se excluyen aunque caigan dentro de un objetivo.
    excluir: Sequence[str] = field(default_factory=tuple)
    #: Si es cierto, las carpetas de pruebas se incluyen sin pedir --con-pruebas.
    pruebas_por_defecto: bool = False


# --------------------------------------------------------------------------- #
# Utilidades
# --------------------------------------------------------------------------- #

def _relativa(ruta: Path) -> str:
    """Ruta con barras normales relativa a la raiz del repositorio."""
    try:
        return ruta.resolve().relative_to(RAIZ).as_posix()
    except ValueError:
        return ruta.as_posix()


def _lenguaje(ruta: Path) -> str:
    """Lenguaje del bloque de codigo.

    Las plantillas llevan el lenguaje real en la extension interna:
    `entity.java.hbs` es Java y `apk.bat.tpl` es un archivo por lotes.
    """
    sufijos = [s.lower() for s in ruta.suffixes]
    if sufijos and sufijos[-1] in (".hbs", ".tpl") and len(sufijos) >= 2:
        interno = LENGUAJES.get(sufijos[-2])
        if interno:
            return interno
    if ruta.name == "Dockerfile" or ruta.name.endswith(".Dockerfile"):
        return "dockerfile"
    if ruta.name == "Caddyfile":
        return "nginx"
    return LENGUAJES.get(ruta.suffix.lower(), "")


def _es_binario(ruta: Path) -> bool:
    return ruta.suffix.lower() in EXTENSIONES_BINARIAS


def _es_texto(ruta: Path) -> bool:
    if ruta.name in NOMBRES_DE_TEXTO:
        return True
    if ruta.name == "Dockerfile" or ruta.name.endswith(".Dockerfile"):
        return True
    return ruta.suffix.lower() in EXTENSIONES_DE_TEXTO


def _ignorado(ruta: Path) -> bool:
    if ruta.name in NOMBRES_IGNORADOS:
        return True
    return any(ruta.name.endswith(s) for s in SUFIJOS_IGNORADOS)


def _valla(contenido: str) -> str:
    """Valla de apertura suficientemente larga para envolver el contenido.

    Sin esto, un archivo que ya contiene ``` (las plantillas de README lo hacen)
    rompe el Markdown resultante.
    """
    maximo = 0
    actual = 0
    for caracter in contenido:
        if caracter == "`":
            actual += 1
            maximo = max(maximo, actual)
        else:
            actual = 0
    return "`" * max(3, maximo + 1)


def _leer(ruta: Path, max_bytes: int) -> tuple[str, bool]:
    """Devuelve el contenido y si hubo truncado."""
    datos = ruta.read_bytes()
    truncado = False
    if len(datos) > max_bytes:
        datos = datos[:max_bytes]
        truncado = True
    texto = datos.decode("utf-8", errors="replace")
    if truncado:
        # No cortar a mitad de linea.
        corte = texto.rfind("\n")
        if corte > 0:
            texto = texto[:corte]
    return texto.replace("\r\n", "\n").rstrip() + "\n", truncado


# --------------------------------------------------------------------------- #
# Recorrido
# --------------------------------------------------------------------------- #

@dataclass
class Archivo:
    ruta: Path
    relativa: str
    lineas: int = 0
    bytes: int = 0
    binario: bool = False


class Recolector:
    def __init__(self, con_pruebas: bool, excluir: Sequence[str]) -> None:
        self.con_pruebas = con_pruebas
        self.excluidos = {e.strip("/") for e in excluir}

    def _excluido(self, ruta: Path) -> bool:
        rel = _relativa(ruta)
        return any(rel == e or rel.startswith(e + "/") for e in self.excluidos)

    def _saltar_directorio(self, nombre: str, ruta: Path) -> bool:
        if nombre in DIRECTORIOS_IGNORADOS:
            return True
        if not self.con_pruebas and nombre in DIRECTORIOS_DE_PRUEBAS:
            return True
        return self._excluido(ruta)

    def recorrer(self, base: Path, recursivo: bool = True) -> list[Archivo]:
        """Archivos incluibles bajo `base`, ordenados de forma estable."""
        if base.is_file():
            return [] if self._excluido(base) else [self._describir(base)]

        encontrados: list[Archivo] = []
        for directorio, subdirectorios, nombres in os.walk(base):
            actual = Path(directorio)
            if recursivo:
                subdirectorios[:] = sorted(
                    d for d in subdirectorios if not self._saltar_directorio(d, actual / d)
                )
            else:
                subdirectorios[:] = []
            for nombre in sorted(nombres):
                ruta = actual / nombre
                if _ignorado(ruta) or self._excluido(ruta):
                    continue
                if not self.con_pruebas and (
                    ".test." in nombre or ".spec." in nombre
                ):
                    continue
                if not _es_texto(ruta) and not _es_binario(ruta):
                    continue
                encontrados.append(self._describir(ruta))
        return encontrados

    @staticmethod
    def _describir(ruta: Path) -> Archivo:
        binario = _es_binario(ruta) or not _es_texto(ruta)
        try:
            tamano = ruta.stat().st_size
        except OSError:
            tamano = 0
        archivo = Archivo(ruta=ruta, relativa=_relativa(ruta), bytes=tamano, binario=binario)
        if not binario:
            try:
                archivo.lineas = ruta.read_bytes().count(b"\n") + 1
            except OSError:
                archivo.lineas = 0
        return archivo


# --------------------------------------------------------------------------- #
# Arbol
# --------------------------------------------------------------------------- #

def _arbol(base: Path, archivos: Iterable[Archivo]) -> list[str]:
    """Arbol ASCII de los archivos incluidos, colgando de `base`."""
    incluidos = sorted(a.relativa for a in archivos)
    prefijo_base = _relativa(base)

    # Estructura anidada: cada nodo es {nombre: hijos | None}.
    raiz: dict = {}
    for rel in incluidos:
        if base.is_file():
            partes = [Path(rel).name]
        else:
            resto = rel[len(prefijo_base):].lstrip("/") if rel.startswith(prefijo_base) else rel
            partes = resto.split("/")
        nodo = raiz
        for parte in partes[:-1]:
            nodo = nodo.setdefault(parte, {})
        nodo[partes[-1]] = None

    lineas = [f"{prefijo_base}/" if not base.is_file() else prefijo_base]

    def dibujar(nodo: dict, sangria: str) -> None:
        # Carpetas antes que archivos, cada grupo alfabetico.
        entradas = sorted(nodo.items(), key=lambda par: (par[1] is None, par[0].lower()))
        for indice, (nombre, hijos) in enumerate(entradas):
            ultimo = indice == len(entradas) - 1
            rama = "`-- " if ultimo else "|-- "
            sufijo = "/" if hijos is not None else ""
            lineas.append(f"{sangria}{rama}{nombre}{sufijo}")
            if hijos is not None:
                dibujar(hijos, sangria + ("    " if ultimo else "|   "))

    dibujar(raiz, "")
    return lineas


# --------------------------------------------------------------------------- #
# Generacion
# --------------------------------------------------------------------------- #

def _kib(n: int) -> str:
    return f"{n / 1024:.1f} KiB"


def generar(documento: Documento, argumentos: argparse.Namespace) -> Path | None:
    """Escribe el Markdown del documento y devuelve la ruta creada.

    Devuelve None si no habia nada que volcar.
    """
    con_pruebas = argumentos.con_pruebas or documento.pruebas_por_defecto
    max_bytes = argumentos.max_kib * 1024
    recolector = Recolector(con_pruebas=con_pruebas, excluir=documento.excluir)

    secciones: list[tuple[Objetivo, Path, list[Archivo]]] = []
    ausentes: list[str] = []
    vacias: list[str] = []
    for objetivo in documento.objetivos:
        base = RAIZ / objetivo.ruta
        if not base.exists():
            ausentes.append(objetivo.ruta)
            continue
        archivos = recolector.recorrer(base, recursivo=objetivo.recursivo)
        if not archivos:
            # Tipico de una carpeta de pruebas sin `--con-pruebas`: mencionarla
            # en la cabecera es mas util que abrir una seccion vacia.
            vacias.append(objetivo.ruta)
            continue
        secciones.append((objetivo, base, archivos))

    if not secciones:
        # Nada que volcar: mejor no dejar un archivo vacio que confunda despues.
        faltan = ", ".join(ausentes + vacias) or "todos los objetivos"
        print(f"{documento.nombre}: omitido, sin contenido ({faltan}).")
        return None

    total_archivos = sum(len(a) for _, _, a in secciones)
    total_lineas = sum(f.lineas for _, _, a in secciones for f in a)
    total_bytes = sum(f.bytes for _, _, a in secciones for f in a if not f.binario)

    ahora = _dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    salida: list[str] = []
    w = salida.append

    w(f"# {documento.titulo}")
    w("")
    w(documento.descripcion)
    w("")
    w(f"> Generado el {ahora} por `contexto/{Path(sys.argv[0]).name}`.")
    w(f"> {total_archivos} archivos, {total_lineas:,} lineas, {_kib(total_bytes)} de codigo.")
    w(f"> Pruebas: {'incluidas' if con_pruebas else 'excluidas'}."
      f" Dependencias, compilados y binarios: siempre excluidos.")
    w("")
    if ausentes:
        w(f"> **Aviso:** no existen en el disco: {', '.join('`' + a + '`' for a in ausentes)}.")
        w("")
    if vacias:
        w(f"> Sin archivos con los filtros actuales: "
          f"{', '.join('`' + v + '`' for v in vacias)}."
          f"{'' if con_pruebas else ' Probar con `--con-pruebas`.'}")
        w("")

    # Indice de las secciones.
    if len(secciones) > 1:
        w("## Contenido")
        w("")
        for objetivo, _, archivos in secciones:
            titulo = objetivo.titulo or objetivo.ruta
            cuenta = len(archivos)
            w(f"- [{titulo}](#{_ancla(titulo)}) --- {cuenta} archivo{'' if cuenta == 1 else 's'}")
        w("")

    binarios_totales: list[Archivo] = []
    truncados: list[str] = []

    for objetivo, base, archivos in secciones:
        titulo = objetivo.titulo or objetivo.ruta
        w("---")
        w("")
        w(f"## {titulo}")
        w("")
        if objetivo.nota:
            w(objetivo.nota)
            w("")

        w("### Estructura")
        w("")
        w("```text")
        for linea in _arbol(base, archivos):
            w(linea)
        w("```")
        w("")

        textuales = [a for a in archivos if not a.binario]
        binarios = [a for a in archivos if a.binario]
        binarios_totales.extend(binarios)

        if textuales:
            w("### Archivos")
            w("")
            w("| Archivo | Lineas |")
            w("| --- | ---: |")
            for archivo in textuales:
                w(f"| `{archivo.relativa}` | {archivo.lineas} |")
            w("")

        if binarios:
            w("Binarios presentes, no volcados: "
              + ", ".join(f"`{b.relativa}`" for b in binarios)
              + ".")
            w("")

        for archivo in textuales:
            w("---")
            w("")
            w(f"### `{archivo.relativa}`")
            w("")
            try:
                contenido, truncado = _leer(archivo.ruta, max_bytes)
            except OSError as error:
                w(f"*No se pudo leer: {error}*")
                w("")
                continue
            if truncado:
                truncados.append(archivo.relativa)
                w(f"*Truncado a {argumentos.max_kib} KiB de {_kib(archivo.bytes)} totales.*")
                w("")
            valla = _valla(contenido)
            w(f"{valla}{_lenguaje(archivo.ruta)}")
            salida.append(contenido.rstrip("\n"))
            w(valla)
            w("")

    if truncados:
        w("---")
        w("")
        w("## Archivos truncados")
        w("")
        for relativa in truncados:
            w(f"- `{relativa}`")
        w("")

    destino = Path(argumentos.salida) / documento.nombre
    destino.parent.mkdir(parents=True, exist_ok=True)
    contenido = "\n".join(salida) + "\n"

    # Si solo cambiaria la fecha de generacion, no se toca el archivo: asi la
    # fecha de modificacion delata de verdad que documentos han cambiado.
    if destino.exists():
        try:
            anterior = destino.read_text(encoding="utf-8")
        except OSError:
            anterior = ""
        if _sin_sello(anterior) == _sin_sello(contenido):
            print(
                f"{documento.nombre}: sin cambios ({total_archivos} archivos, "
                f"{total_lineas:,} lineas)"
            )
            return destino

    destino.write_text(contenido, encoding="utf-8")
    print(
        f"{documento.nombre}: actualizado, {total_archivos} archivos, "
        f"{total_lineas:,} lineas, {_kib(destino.stat().st_size)}"
    )
    return destino


def _sin_sello(texto: str) -> str:
    """El documento sin la linea de fecha, para comparar dos generaciones."""
    return "\n".join(
        linea for linea in texto.splitlines() if not linea.startswith("> Generado el ")
    )


def _ancla(titulo: str) -> str:
    limpio = "".join(c.lower() if c.isalnum() or c in " -" else "" for c in titulo)
    return limpio.strip().replace(" ", "-")


# --------------------------------------------------------------------------- #
# Linea de ordenes
# --------------------------------------------------------------------------- #

def argumentos(descripcion: str) -> argparse.Namespace:
    analizador = argparse.ArgumentParser(description=descripcion)
    analizador.add_argument(
        "--salida",
        default=str(SALIDA_POR_DEFECTO),
        help="carpeta donde escribir el Markdown (por defecto contexto/salida)",
    )
    analizador.add_argument(
        "--con-pruebas",
        action="store_true",
        help="incluir carpetas de pruebas y archivos .test/.spec",
    )
    analizador.add_argument(
        "--max-kib",
        type=int,
        default=MAX_KIB_POR_DEFECTO,
        help=f"truncar archivos por encima de este tamano (por defecto {MAX_KIB_POR_DEFECTO})",
    )
    return analizador.parse_args()


def ejecutar(documento: Documento) -> None:
    """Punto de entrada de cada script hermano."""
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    generar(documento, argumentos(documento.descripcion))
