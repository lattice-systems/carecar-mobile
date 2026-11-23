#!/usr/bin/env python3
"""Genera los íconos de los flavors `desarrollo` y `pruebas` (V2-T01.04).

Parte del ícono de producción (el de siempre) y le pone una banda de color con
la etiqueta abajo, para distinguir de un vistazo qué versión está instalada. No
inventa arte nuevo: `produccion` conserva el ícono original.

Uso (desde la raíz del repo; requiere Pillow):

    python3 tool/generar_iconos_flavor.py

Android: android/app/src/<flavor>/res/mipmap-*/ic_launcher.png
iOS:     ios/Runner/Assets.xcassets/AppIcon-<flavor>.appiconset/
"""

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

RAIZ = Path(__file__).resolve().parent.parent
FLAVORS = {
    "desarrollo": ("DEV", (230, 126, 34)),
    "pruebas": ("PRUEBAS", (41, 128, 185)),
}
FUENTES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
]


def con_banda(origen: Path, destino: Path, etiqueta: str, color) -> None:
    im = Image.open(origen).convert("RGB")
    ancho, alto = im.size
    banda = round(alto * 0.26)
    dibujo = ImageDraw.Draw(im)
    dibujo.rectangle([0, alto - banda, ancho, alto], fill=color)
    tamano = max(6, round(banda * 0.62))
    fuente = None
    for ruta in FUENTES:
        if Path(ruta).exists():
            fuente = ImageFont.truetype(ruta, tamano)
            break
    if fuente is None:
        fuente = ImageFont.load_default(size=tamano)
    caja = dibujo.textbbox((0, 0), etiqueta, font=fuente)
    x = (ancho - (caja[2] - caja[0])) / 2 - caja[0]
    y = alto - banda + (banda - (caja[3] - caja[1])) / 2 - caja[1]
    dibujo.text((x, y), etiqueta, font=fuente, fill=(255, 255, 255))
    destino.parent.mkdir(parents=True, exist_ok=True)
    im.save(destino, "PNG")


def main() -> None:
    res = RAIZ / "android/app/src/main/res"
    catalogo = RAIZ / "ios/Runner/Assets.xcassets"
    base_ios = catalogo / "AppIcon.appiconset"
    for flavor, (etiqueta, color) in FLAVORS.items():
        for densidad in ["mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"]:
            con_banda(
                res / f"mipmap-{densidad}/ic_launcher.png",
                RAIZ / f"android/app/src/{flavor}/res/mipmap-{densidad}/ic_launcher.png",
                etiqueta,
                color,
            )
        destino = catalogo / f"AppIcon-{flavor}.appiconset"
        destino.mkdir(exist_ok=True)
        shutil.copy(base_ios / "Contents.json", destino / "Contents.json")
        for png in base_ios.glob("*.png"):
            con_banda(png, destino / png.name, etiqueta, color)


if __name__ == "__main__":
    main()
