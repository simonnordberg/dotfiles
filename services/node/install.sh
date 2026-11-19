# Install fnm (Fast Node Manager) — replaces nvm
if ! command -v fnm &>/dev/null; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# Install latest LTS Node
fnm install --lts

# pnpm as a standalone binary (it bundles its own runtime). Node 25+ no longer ships
# corepack, so a corepack-provided pnpm vanishes on every Node upgrade. Pinned to the
# version CI uses; bump it here when the projects move.
PNPM_VERSION=10.33.0
if [[ "$("$HOME/.local/bin/pnpm" --version 2>/dev/null)" != "$PNPM_VERSION" ]]; then
  mkdir -p "$HOME/.local/bin"
  curl -fsSL -o "$HOME/.local/bin/pnpm.tmp" \
    "https://github.com/pnpm/pnpm/releases/download/v${PNPM_VERSION}/pnpm-linux-x64"
  chmod +x "$HOME/.local/bin/pnpm.tmp"
  mv "$HOME/.local/bin/pnpm.tmp" "$HOME/.local/bin/pnpm"
fi

mkdir -p "$HOME/.zsh/completions"
fnm completions --shell zsh > "$HOME/.zsh/completions/_fnm"

# Remove nvm if present
if [[ -d "$HOME/.nvm" ]]; then
  echo "Removing legacy nvm installation..."
  rm -rf "$HOME/.nvm"
fi
