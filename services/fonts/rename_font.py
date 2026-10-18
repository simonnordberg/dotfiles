"""Rename a font's family name in the OpenType name table."""

import sys
from fontTools.ttLib import TTFont

FAMILY_NAME_IDS = {1, 4, 16, 21}

src, dest, new_family = sys.argv[1], sys.argv[2], sys.argv[3]
font = TTFont(src)

for record in font["name"].names:
    text = record.toUnicode()
    if record.nameID in FAMILY_NAME_IDS:
        font["name"].setName(
            text.replace("JetBrains Mono", new_family),
            record.nameID,
            record.platformID,
            record.platEncID,
            record.langID,
        )

font.save(dest)
