#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SERVICES_DIR="$SCRIPT_DIR/services"
BASE_SERVICES="base shell"

if [ "$EUID" -eq 0 ]; then
  echo "Do not run as root"
  exit 1
fi

# Install a service
install_service() {
  local service_dir="$1"

  if [ -f "$service_dir/install.sh" ]; then
    echo "Installing $service_dir"
    cd "$service_dir"
    bash install.sh
    cd - >/dev/null
  fi
}

# Main installation
main() {
  echo "Starting server setup..."

  if [ $# -eq 0 ]; then
    echo "No service specified. Installing all services..."

    echo "Installing base services..."
    for service in $BASE_SERVICES; do
      install_service "$SERVICES_DIR/$service"
    done

    echo "Installing other services..."
    for service in $(ls -1 "$SERVICES_DIR"); do
      if [[ " $BASE_SERVICES " =~ " $service " ]]; then
        continue
      fi
      install_service "$SERVICES_DIR/$service"
    done
  else
    echo "Installing requested service: $1"
    install_service "$1"
  fi

  echo "Setup completed successfully!"
}

main "$@"
