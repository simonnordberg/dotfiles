## Project

Dotfiles repo managed by a simple bash-based installer. Each service is a self-contained directory under `services/` with an `install.sh` script.

## Structure

- `install.sh` — top-level entry point, runs `bash install.sh services/<name>` for each service
- `services/<name>/install.sh` — installs one service (packages, config files, etc.)
- Config files live alongside their service install script and get copied to `$HOME`

## Services

- `shell` — zsh + zinit + starship prompt
- `claude-code` — claude code CLI + user-level settings
- `ghostty` — terminal emulator config
- `nvm` — node version manager
- `pyenv` — python version manager

## Conventions

- Install scripts use `dnf` (Fedora)
- Config files are copied, not symlinked
- Keep services independent — no cross-service dependencies
- Shell config is a single `.zshrc` file, no framework
