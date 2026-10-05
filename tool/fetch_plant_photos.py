#!/usr/bin/env python3
"""Download the lead Wikipedia photo of every catalog plant.

Photos come from Wikimedia Commons. Only freely licensed files are kept, and
their author and license are written to assets/images/plants/credits.json so
the app can show proper attribution.

Usage: python3 tool/fetch_plant_photos.py [--credits-only]
"""

import io
import json
import re
import sys
import urllib.parse
import urllib.request
from html import unescape
from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "images" / "plants"
SIZE = 720
USER_AGENT = "PandaiAssetFetcher/1.0 (https://github.com/khaichi11/Mobile-APP-Plant-Detection-Mobilenet)"
ALLOWED_LICENSES = ("cc0", "public domain", "pd", "cc by", "cc-by")

# Asset id -> Wikipedia article title, or "File:<name>" to pin a Commons file
# when the article photo is not freely licensed.
PLANTS = {
    "sunflower": "File:Sonnenblume Helianthus 1.JPG",
    "mango": "Mangifera indica",
    "coconut": "File:Coconut Tree.JPG",
    "papaya": "File:Carica papaya 14 7 2012.jpg",
    "hibiscus": "Hibiscus rosa-sinensis",
    "aloe_vera": "Aloe vera",
    "mimosa": "Mimosa pudica",
    "monstera": "Monstera deliciosa",
    "guava": "Psidium guajava",
    "frangipani": "Plumeria rubra",
    "lantana": "Lantana camara",
    "periwinkle": "Catharanthus roseus",
    "canna": "Canna indica",
    "chili": "File:Starr-110411-4986-Capsicum annuum-fruit-Hawea Pl Olinda-Maui (24451902974).jpg",
    "tomato": "Tomato",
    "mangrove": "File:Rhizophora mangle (prop roots).jpg",
    "poinsettia": "Poinsettia",
    "purslane": "Portulaca oleracea",
    "bird_of_paradise": "Strelitzia reginae",
    "cosmos": "Cosmos bipinnatus",
    "dandelion": "File:Taraxacum officinale-flower-yercaud-salem-India.JPG",
    "wild_carrot": "Daucus carota",
    "water_lily": "Nymphaea alba",
    "water_hyacinth": "Pontederia crassipes",
    "taro": "Taro",
    "flame_tree": "Delonix regia",
    "leadtree": "Leucaena leucocephala",
    "castor_bean": "Castor bean",
    "prickly_pear": "Opuntia ficus-indica",
    "water_lettuce": "Pistia",
    "crape_myrtle": "Lagerstroemia indica",
    "spanish_needles": "Bidens pilosa",
    "woodsorrel": "Oxalis corniculata",
    "beach_morning_glory": "Ipomoea pes-caprae",
    "strawberry": "File:Fragaria vesca (2484390688).jpg",
    "apple": "File:Red Apple.jpg",
    "nettle": "Urtica dioica",
    "yellow_bells": "Tecoma stans",
    "african_tulip": "Spathodea campanulata",
    "oleander": "Nerium",
}


def get_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def get_bytes(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def strip_html(text: str) -> str:
    return re.sub(r"\s+", " ", unescape(re.sub(r"<[^>]+>", "", text))).strip()


def lead_image(title: str) -> str | None:
    query = urllib.parse.urlencode({
        "action": "query", "format": "json", "prop": "pageimages",
        "piprop": "name", "titles": title, "redirects": 1,
    })
    pages = get_json(f"https://en.wikipedia.org/w/api.php?{query}")["query"]["pages"]
    page = next(iter(pages.values()))
    return page.get("pageimage")


def image_info(filename: str) -> dict:
    query = urllib.parse.urlencode({
        "action": "query", "format": "json", "prop": "imageinfo",
        "titles": f"File:{filename}", "iiprop": "url|extmetadata",
        "iiurlwidth": 1200,
    })
    pages = get_json(f"https://commons.wikimedia.org/w/api.php?{query}")["query"]["pages"]
    return next(iter(pages.values()))["imageinfo"][0]


def write_credits_markdown(credits: dict) -> None:
    lines = [
        "# Plant photo credits",
        "",
        "All plant photos come from Wikimedia Commons and are used under their",
        "free licenses. They were cropped to squares and resized by",
        "`tool/fetch_plant_photos.py`.",
        "",
        "| File | Author | License | Source |",
        "| --- | --- | --- | --- |",
    ]
    for asset_id in sorted(credits):
        c = credits[asset_id]
        author = c["author"].replace("|", "/")
        license_link = f"[{c['license']}]({c['license_url']})" if c["license_url"] else c["license"]
        lines.append(f"| `{asset_id}.jpg` | {author} | {license_link} | [Commons]({c['source']}) |")
    (OUT_DIR / "CREDITS.md").write_text("\n".join(lines) + "\n")


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    if "--credits-only" in sys.argv:
        write_credits_markdown(json.loads((OUT_DIR / "credits.json").read_text()))
        return 0
    credits = {}
    failures = []
    for asset_id, title in PLANTS.items():
        try:
            filename = title[5:] if title.startswith("File:") else lead_image(title)
            if not filename:
                raise RuntimeError("article has no lead image")
            info = image_info(filename)
            meta = info["extmetadata"]
            license_name = meta.get("LicenseShortName", {}).get("value", "")
            if not license_name.lower().startswith(ALLOWED_LICENSES):
                raise RuntimeError(f"license not allowed: {license_name}")
            data = get_bytes(info.get("thumburl") or info["url"])
            image = ImageOps.exif_transpose(Image.open(io.BytesIO(data))).convert("RGB")
            image = ImageOps.fit(image, (SIZE, SIZE), Image.LANCZOS)
            image.save(OUT_DIR / f"{asset_id}.jpg", quality=82, optimize=True, progressive=True)
            credits[asset_id] = {
                "title": title,
                "file": filename,
                "author": strip_html(meta.get("Artist", {}).get("value", "Unknown")),
                "license": license_name,
                "license_url": meta.get("LicenseUrl", {}).get("value", ""),
                "source": info["descriptionurl"],
            }
            print(f"ok   {asset_id:22} {license_name}")
        except Exception as error:  # noqa: BLE001 - report and continue
            failures.append(asset_id)
            print(f"FAIL {asset_id:22} {error}", file=sys.stderr)
    (OUT_DIR / "credits.json").write_text(json.dumps(credits, indent=2, ensure_ascii=False) + "\n")
    write_credits_markdown(credits)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
