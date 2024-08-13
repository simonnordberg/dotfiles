FONTS=$HOME/.local/share/fonts

mkdir -p $FONTS
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C $FONTS
fc-cache -fv
