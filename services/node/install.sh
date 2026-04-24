# Install fnm (Fast Node Manager) — replaces nvm
if ! command -v fnm &>/dev/null; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# Install latest LTS Node
fnm install --lts

mkdir -p "$HOME/.zsh/completions"
fnm completions --shell zsh > "$HOME/.zsh/completions/_fnm"

# Remove nvm if present
if [[ -d "$HOME/.nvm" ]]; then
  echo "Removing legacy nvm installation..."
  rm -rf "$HOME/.nvm"
fi
