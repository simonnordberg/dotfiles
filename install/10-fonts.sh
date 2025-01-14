FONTS=$HOME/.local/share/fonts

sudo dnf install -y fira-code-fonts
[ -d $FONTS ] && rm -rf $FONTS && echo "Deleted fonts dir: $FONTS"
mkdir -p $FONTS
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz | tar -xJ -C $FONTS
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz | tar -xJ -C $FONTS
fc-cache -fv
