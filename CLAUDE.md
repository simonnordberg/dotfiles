## Project

Dotfiles repo managed by a simple bash-based installer. Each service is a self-contained directory under `services/` with an `install.sh` script.

## Structure

- `install.sh` — top-level entry point, runs `bash install.sh services/<name>` for each service
- `services/<name>/install.sh` — installs one service (packages, config files, etc.)
- Config files live alongside their service install script and get copied to `$HOME`

## Services

Base (installed first): `base`, `shell`

Default: `1password`, `chromium`, `claude-code`, `desktop`, `discord`, `dms`, `docker`, `fingerprint`, `flatpak`, `fnm`, `ghostty`, `git`, `neovim`, `niri`, `obsidian`, `signal`, `slack`, `spotify`, `ssh`, `steam`, `syncthing`, `tailscale`

Optional: `audio`, `bin`, `calibre`, `code`, `flatseal`, `github`, `golang`, `lazygit`, `printing`, `pyenv`, `rust`, `tmux`, `tracker`, `yazi`

## Conventions

- Install scripts use `dnf` (Fedora)
- Config files are copied, not symlinked
- Keep services independent — no cross-service dependencies
- Shell config is a single `.zshrc` file, no framework
