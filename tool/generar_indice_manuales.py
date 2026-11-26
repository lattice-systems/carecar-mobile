#!/usr/bin/env python3
"""Genera el índice de texto por página de cada manual empaquetado (V2-M02.03).

La búsqueda del manual es offline y no suma un motor de PDF al app: en vez de
extraer el texto en el teléfono, aquí se extrae una sola vez con `pdftotext` y
se guarda un `indice.json` junto a cada PDF. La app lo lee y busca sobre él.

Uso (desde la raíz del repo, requiere `pdftotext` de poppler):

    python3 -I tool/generar_indice_manuales.py

Vuelve a correrse cuando cambie un manual empaquetado.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
MANUALES = RAIZ / "assets" / "Manuales"


def texto_por_pagina(pdf: Path) -> list[str]:
    """El texto de cada página, con los espacios colapsados."""
    salida = subprocess.run(
        ["pdftotext", "-enc", "UTF-8", str(pdf), "-"],
        capture_output=True,
        check=True,
        text=True,
    ).stdout
    # pdftotext separa las páginas con un salto de página (form feed).
    return [" ".join(pagina.split()) for pagina in salida.split("\f")]


def titulo(pdf: Path) -> str:
    """Marca, tipo y año desde la ruta assets/Manuales/<marca>/<tipo>/<año>/."""
    anio = pdf.parent.name
    tipo = pdf.parent.parent.name
    marca = pdf.parent.parent.parent.name
    return f"{marca} {tipo} {anio}"


def main() -> int:
    pdfs = sorted(MANUALES.rglob("*.pdf"))
    if not pdfs:
        print("No se encontraron manuales en", MANUALES, file=sys.stderr)
        return 1
    for pdf in pdfs:
        paginas = texto_por_pagina(pdf)
        indice = {
            "manual": titulo(pdf),
            "paginas": [
                {"p": numero, "t": texto}
                for numero, texto in enumerate(paginas, start=1)
                if texto
            ],
        }
        destino = pdf.parent / "indice.json"
        destino.write_text(
            json.dumps(indice, ensure_ascii=False, separators=(",", ":")),
            encoding="utf-8",
        )
        print(f"{destino.relative_to(RAIZ)}: {len(indice['paginas'])} páginas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
