#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
OMARCHY_DIR="$SCRIPT_DIR/omarchy"

if [ "$EUID" -eq 0 ]; then
  echo "Do not run as root"
  exit 1
fi

# Install an omarchy module
install_module() {
  local module_dir="$1"

  if [ -f "$module_dir/install.sh" ]; then
    echo "Installing $(basename $module_dir)..."
    cd "$module_dir"
    bash install.sh
    cd - >/dev/null
  fi
}

# Main installation
main() {
  echo "Starting Omarchy customization setup..."

  if [ $# -eq 0 ]; then
    echo "Installing all Omarchy customizations..."

    for module in $(ls -1 "$OMARCHY_DIR"); do
      if [ -d "$OMARCHY_DIR/$module" ]; then
        install_module "$OMARCHY_DIR/$module"
      fi
    done
  else
    echo "Installing requested module: $1"
    install_module "$1"
  fi

  echo ""
  echo "Omarchy customizations installed successfully!"
  echo ""
  echo "Note: You may need to reload Hyprland for changes to take effect:"
  echo "  Press Super+Esc -> Relaunch"
}

main "$@"
