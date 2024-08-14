#!/usr/bin/env bash

BASE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

set -e

if [ "$EUID" -eq 0 ]; then
  echo "Please don't run as root"
  exit
fi

for script in install/*.sh; do
  echo ">>> $script"
  source $script
done

echo "All done!"
