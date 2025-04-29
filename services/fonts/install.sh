sudo dnf install -y fira-code-fonts

rm -rf "$HOME/.local/share/fonts"
mkdir -p $HOME/.local/share/fonts
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz | tar -xJ -C $HOME/.local/share/fonts
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz | tar -xJ -C $FONTS
fc-cache -fv
