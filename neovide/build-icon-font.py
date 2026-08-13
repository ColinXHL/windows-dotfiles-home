from __future__ import annotations

import argparse
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont


FAMILY = "JetBrainsMono Nerd Icons"
STYLE = "Regular"
POSTSCRIPT_NAME = "JetBrainsMono-Nerd-Icons"


def rename_font(font: TTFont) -> None:
    names = {
        1: FAMILY,
        2: STYLE,
        3: f"1.000;NONE;{POSTSCRIPT_NAME}",
        4: f"{FAMILY} {STYLE}",
        6: POSTSCRIPT_NAME,
        16: FAMILY,
        17: STYLE,
        21: FAMILY,
        22: STYLE,
    }
    for record in font["name"].names:
        value = names.get(record.nameID)
        if value is not None:
            record.string = value.encode(record.getEncoding())


def main() -> None:
    parser = argparse.ArgumentParser(description="Build an icon-only Nerd Font fallback.")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    options = subset.Options()
    options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.name_legacy = True
    options.recommended_glyphs = True

    font = TTFont(args.input)
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(
        unicodes=subset.parse_unicodes("U+E000-F8FF,U+F0000-FFFFD")
    )
    subsetter.subset(font)
    rename_font(font)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    font.save(args.output)


if __name__ == "__main__":
    main()
