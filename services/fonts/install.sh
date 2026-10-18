SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
FONT_DIR="$HOME/.local/share/fonts"

# JetBrains Mono (via dnf)
sudo dnf install -y jetbrains-mono-fonts

# Familjen Grotesk (from Google Fonts GitHub)
FAMILJEN_URL="https://raw.githubusercontent.com/google/fonts/main/ofl/familjengrotesk/FamiljenGrotesk%5Bwght%5D.ttf"
mkdir -p "$FONT_DIR"
curl -sL -o "$FONT_DIR/FamiljenGrotesk[wght].ttf" "$FAMILJEN_URL"

# Rebuild font cache
fc-cache -f
