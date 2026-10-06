#!/usr/bin/env python3
"""Generate Pandai launcher icons and the splash logo for Android and iOS.

Renders the traced Pandai mark from tool/pandai_mark.json (made by
tool/trace_logo.py) on a white background.
Usage: python3 tool/generate_icons.py
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
MARK = json.loads((ROOT / "tool/pandai_mark.json").read_text())
EMERALD = (30, 154, 112, 255)
DEEP = (64, 122, 88, 255)
SUPERSAMPLE = 4


def draw_mark(image, scale):
    """Draws the mark centred on a transparent RGBA image."""
    big = image.size[0]
    side = big * scale
    offset = (big - side) / 2

    def p(x, y):
        return (offset + x * side, offset + y * side)

    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    cx, cy, radius = MARK["circle"]
    inner, outer, gap_above, gap_below = MARK["ring"]

    ring = Image.new("L", image.size, 0)
    ring_draw = ImageDraw.Draw(ring)
    ring_draw.ellipse((p(cx - outer, cy - outer), p(cx + outer, cy + outer)), fill=255)
    ring_draw.ellipse((p(cx - inner, cy - inner), p(cx + inner, cy + inner)), fill=0)
    ring_draw.rectangle((p(-1, cy - gap_above), p(2, cy + gap_below)), fill=0)
    layer.paste(DEEP, mask=ring)
    draw.ellipse((p(cx - radius, cy - radius), p(cx + radius, cy + radius)), fill=EMERALD)

    for group, color in ((MARK["stems"], DEEP), (MARK["leaves"], EMERALD)):
        for shape in group:
            mask = Image.new("L", image.size, 0)
            mask_draw = ImageDraw.Draw(mask)
            mask_draw.polygon([p(*pt) for pt in shape[0]], fill=255)
            for hole in shape[1:]:
                mask_draw.polygon([p(*pt) for pt in hole], fill=0)
            layer.paste(color, mask=mask)
    image.alpha_composite(layer)


def render(size, *, background, rounded=False, scale=0.78):
    big = size * SUPERSAMPLE
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    if background:
        draw = ImageDraw.Draw(image)
        if rounded:
            draw.rounded_rectangle((0, 0, big - 1, big - 1), radius=0.22 * big, fill=(255, 255, 255, 255))
        else:
            draw.rectangle((0, 0, big, big), fill=(255, 255, 255, 255))
    draw_mark(image, scale)
    return image.resize((size, size), Image.LANCZOS)


def android():
    res = ROOT / "android/app/src/main/res"
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for name, factor in densities.items():
        folder = res / f"mipmap-{name}"
        folder.mkdir(parents=True, exist_ok=True)
        render(round(48 * factor), background=True, rounded=True).save(folder / "ic_launcher.png")
        # Adaptive icon: 108dp canvas, the mark stays inside the 66dp safe circle.
        render(round(108 * factor), background=False, scale=0.6).save(folder / "ic_launcher_foreground.png")
    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        "</adaptive-icon>\n"
    )
    (res / "values/colors.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        '    <color name="ic_launcher_background">#FFFFFF</color>\n'
        '    <color name="launch_background">#FFFFFF</color>\n'
        "</resources>\n"
    )
    nodpi = res / "drawable-nodpi"
    nodpi.mkdir(exist_ok=True)
    render(384, background=False, scale=1.0).save(nodpi / "launch_logo.png")


def ios():
    folder = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((folder / "Contents.json").read_text())
    for entry in contents["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        points = float(entry["size"].split("x")[0])
        scale = int(entry["scale"].rstrip("x"))
        icon = render(round(points * scale), background=True)
        icon.convert("RGB").save(folder / filename)  # iOS icons must be opaque.
    launch = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for name, size in (("LaunchImage.png", 128), ("LaunchImage@2x.png", 256), ("LaunchImage@3x.png", 384)):
        render(size, background=False, scale=1.0).save(launch / name)


if __name__ == "__main__":
    android()
    ios()
    print("Icons generated.")
