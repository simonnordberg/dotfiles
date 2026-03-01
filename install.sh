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
    for service_dir in "$SERVICES_DIR"/*/; do
      service=$(basename "$service_dir")
      case " $BASE_SERVICES " in
        *" $service "*) continue ;;
      esac
      install_service "$service_dir"
    done
  else
    for service_path in "$@"; do
      echo "Installing requested service: $service_path"
      install_service "$service_path"
    done
  fi

  echo "Setup completed successfully!"
}

main "$@"
