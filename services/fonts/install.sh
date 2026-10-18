SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# JetBrains Mono (via dnf)
sudo dnf install -y jetbrains-mono-fonts

# JetBrains Mono aliased as "Jet Brains Mono Roman" for documents that use that name
pip install --user fonttools 2>/dev/null
for weight in Bold Medium; do
  python3 "$SCRIPT_DIR/rename_font.py" \
    "/usr/share/fonts/jetbrains-mono-fonts/JetBrainsMono-${weight}.otf" \
    "$FONT_DIR/JetBrainsMonoRoman-${weight}.otf" \
    "Jet Brains Mono Roman"
done

# Familjen Grotesk (from Google Fonts GitHub)
FAMILJEN_URL="https://raw.githubusercontent.com/google/fonts/main/ofl/familjengrotesk/FamiljenGrotesk%5Bwght%5D.ttf"
curl -sL -o "$FONT_DIR/FamiljenGrotesk[wght].ttf" "$FAMILJEN_URL"

# Rebuild font cache
fc-cache -f
