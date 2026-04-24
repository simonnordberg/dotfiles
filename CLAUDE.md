## Project

Dotfiles repo managed by a simple bash-based installer. Each service is a self-contained directory under `services/` with an `install.sh` script.

## Structure

- `install.sh` — top-level entry point, runs `bash install.sh services/<name>` for each service
- `services/<name>/install.sh` — installs one service (packages, config files, etc.)
- Config files live alongside their service install script and get copied to `$HOME`

## Services

Base (installed first): `base`, `shell`

Default: `1password`, `chromium`, `claude-code`, `discord`, `dms`, `docker`, `fingerprint`, `flatpak`, `gdm`, `ghostty`, `git`, `hibernate`, `neovim`, `niri`, `node`, `obsidian`, `signal`, `slack`, `spotify`, `ssh`, `steam`, `syncthing`, `tailscale`

Optional: `audio`, `calibre`, `flatseal`, `github`, `golang`, `lazygit`, `printing`, `pyenv`, `rust`, `scaleway`, `scripts`, `tmux`, `tracker`, `vscode`, `yazi`

## Conventions

- Install scripts use `dnf` (Fedora)
- Config files are copied, not symlinked
- Keep services independent — no cross-service dependencies
- Shell config is a single `.zshrc` file, no framework
