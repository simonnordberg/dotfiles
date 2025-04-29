sudo dnf install -y fira-code-fonts

if [ -d "$HOME/.local/share/fonts" ]; then
    rm -rf "$HOME/.local/share/fonts"
    echo "Deleted fonts dir: $HOME/.local/share/fonts"
fi

mkdir -p $HOME/.local/share/fonts
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz | tar -xJ -C $HOME/.local/share/fonts
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz | tar -xJ -C $FONTS
fc-cache -fv
