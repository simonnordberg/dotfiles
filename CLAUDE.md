# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository that automates the setup of Linux (primarily Fedora) and macOS development environments. It uses a modular service-based architecture where each application or component is configured through self-contained service directories.

## Installation Commands

### Linux (Fedora)
```bash
# Install everything
bash install.sh

# Install specific service(s)
bash install.sh services/shell services/neovim
```

### macOS
```bash
bash install-macos.sh
```

## Architecture

### Service-Based Structure

Each service lives in `services/[service-name]/` and contains:
- `install.sh` - Installation script for that service
- Configuration files and directories for the service

### Installation Flow

1. **install.sh** (main installer):
   - Must NOT be run as root
   - First installs base services: `base` and `shell` (in that order)
   - Then installs all other services in `services/` directory
   - Can accept specific service paths as arguments for selective installation
   - Changes to service directory before running its install.sh

2. **Base Services**:
   - `services/base/install.sh`: Sets up RPM Fusion repos, extends LVM partition, installs core utilities (curl, git, htop, etc.)
   - `services/shell/install.sh`: Installs fish shell, starship prompt, and shell configurations

3. **Service Install Scripts**:
   - Run from within their own directory (install.sh changes to service_dir before executing)
   - Use `$SCRIPT_DIR` to reference their own files
   - Use `rsync -r --delete` for config file synchronization
   - Install to standard XDG paths: `~/.config/`, `~/.local/bin/`, etc.

### Common Patterns

**Package Installation**:
```bash
sudo dnf install -y [packages]  # Fedora/Linux
brew install [packages]          # macOS
```

**Config File Management**:
```bash
# Remove and sync entire directory
rm -rf $HOME/.config/[app]
rsync -r --delete $SCRIPT_DIR/[config]/ $HOME/.config/[app]/

# Copy single file
cp $SCRIPT_DIR/[file] $HOME/.config/[file]
```

**Script Directory Resolution**:
```bash
# Linux services
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# macOS script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

## Key Services

- **sway**: Wayland compositor with waybar, mako, rofi configs. Uses custom wrapper for session management
- **neovim**: LazyVim-based setup with custom plugins in `lua/plugins/`
- **ghostty**: Terminal emulator configuration
- **desktop**: Enables GDM and graphical.target for desktop environments
- **1password**, **github**, **git**: Authentication and development tools
- **docker**, **flatpak**: Container and package management

## Testing Changes

When modifying service install scripts:
1. Test the specific service: `bash install.sh services/[service-name]`
2. Verify it works from any directory (script uses absolute paths)
3. Check that config files are properly synced to home directory
4. For destructive changes, test in VM or on non-production system

## Important Notes

- All service install.sh scripts are run from their own directory by the main installer
- Use `rsync -r --delete` for config sync to ensure clean state
- macOS installation is a single monolithic script (install-macos.sh)
- The repository should be cloned to `$HOME/code/github/dotfiles` for consistency
- hatti.cfg is a game configuration file (ezQuake) and unrelated to system setup
