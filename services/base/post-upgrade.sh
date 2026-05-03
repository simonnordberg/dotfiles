#!/bin/bash
set -euo pipefail

# Post-upgrade checklist for Fedora major version upgrades.
# Run after the system-upgrade reboot completes.
# Usage: bash post-upgrade.sh <expected-version>

if [[ $# -ne 1 ]]; then
  echo "Usage: bash post-upgrade.sh <expected-version>"
  echo "Example: bash post-upgrade.sh 44"
  exit 1
fi

EXPECTED_VERSION="$1"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "\n${GREEN}==> $1${NC}"; }
warn() { echo -e "${YELLOW}    ⚠ $1${NC}"; }
info() { echo -e "    $1"; }

# 1. Verify upgrade
step "Verifying Fedora version"
source /etc/os-release
if [[ "$VERSION_ID" != "$EXPECTED_VERSION" ]]; then
  echo -e "${RED}ERROR: Expected Fedora $EXPECTED_VERSION, got $VERSION_ID. Upgrade may not have completed.${NC}"
  exit 1
fi
info "Fedora $VERSION_ID confirmed"

# 2. Distro-sync
step "Running distro-sync"
sudo dnf5 distro-sync -y

# 3. Handle changed config files (.rpmnew / .rpmsave)
step "Installing rpmconf and checking for config conflicts"
sudo dnf5 install -y rpmconf
info "Running rpmconf (press enter to keep your version, or choose interactively)..."
sudo rpmconf -a || warn "rpmconf exited non-zero — review manually"

# 4. Remove retired/orphaned packages
step "Removing orphaned packages"
sudo dnf5 autoremove -y

# 5. Check for broken symlinks
step "Checking for broken symlinks in /etc and /usr"
BROKEN=$(sudo symlinks -r /etc /usr 2>/dev/null | grep "^dangling" | head -20 || true)
if [[ -n "$BROKEN" ]]; then
  warn "Found broken symlinks (showing first 20):"
  echo "$BROKEN"
else
  info "No broken symlinks found"
fi

# 6. Update package groups
step "Updating core package group"
sudo dnf5 group upgrade -y core || warn "Group upgrade failed — check manually"

# 7. Rebuild RPM database
step "Rebuilding RPM database"
sudo rpm --rebuilddb

# 8. Verify COPR repos
step "Checking COPR repos"
for repo in $(dnf5 copr list 2>/dev/null); do
  info "Active: $repo"
done
warn "Verify above repos have F$EXPECTED_VERSION packages: sudo dnf5 repolist -v"

# 9. Verify third-party repos
step "Checking third-party repos"
sudo dnf5 repolist | grep -E "docker|hashicorp" || warn "Docker/HashiCorp repos not found — re-run dotfiles installer"

# 10. Clean up caches
step "Cleaning up caches"
sudo dnf5 clean all

# 11. Check SELinux
step "Checking SELinux"
if command -v getenforce &>/dev/null; then
  SELINUX_STATUS=$(getenforce)
  info "SELinux: $SELINUX_STATUS"
  if [[ "$SELINUX_STATUS" == "Enforcing" ]]; then
    info "Consider a relabel if you see denials: sudo fixfiles -F onboot && sudo reboot"
  fi
fi

# 12. Reinstall dotfiles
step "Reinstalling dotfiles"
DOTFILES_DIR="$HOME/code/dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
  cd "$DOTFILES_DIR"
  bash install.sh
  info "Dotfiles installed"
else
  warn "Dotfiles directory not found at $DOTFILES_DIR"
fi

# 13. Flatpak updates
step "Updating Flatpaks"
if command -v flatpak &>/dev/null; then
  flatpak update -y
  flatpak uninstall --unused -y || true
  info "Flatpaks updated"
else
  info "Flatpak not installed, skipping"
fi

echo -e "\n${GREEN}=== Post-upgrade complete ===${NC}"
echo "Recommended manual checks:"
echo "  - Reboot once more to confirm clean boot"
echo "  - Test Niri/Wayland session"
echo "  - Verify Docker: docker run hello-world"
echo "  - Verify 1Password unlock"
echo "  - Verify fingerprint reader"
echo "  - Check hibernation still works"
