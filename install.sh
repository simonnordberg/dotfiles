#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SERVICES_DIR="$SCRIPT_DIR/services"

if [ "$EUID" -eq 0 ]; then
  echo "Do not run as root"
  exit 1
fi

# Logging function
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo "$msg"
}

# Install a service
install_service() {
  local service_dir="$1"

  if [ -f "$service_dir/install.sh" ]; then
    log "Installing $service_dir..."
    cd "$service_dir"
    # bash install.sh
    cd - >/dev/null
  fi
}

# Main installation
main() {
  log "Starting server setup..."

  if [ $# -eq 0 ]; then
    log "No service specified. Installing all services..."
    # Find and sort services by numeric prefix
    for service_dir in $(find "$SERVICES_DIR" -maxdepth 1 -type d | sort); do
      install_service "$service_dir"
    done
  else
    log "Installing requested service: $1"
    install_service "$1"
  fi

  log "Setup completed successfully!"
}

main "$@"
