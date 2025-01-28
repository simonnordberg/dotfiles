#!/usr/bin/env bash

BASE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

set -e

if [ "$EUID" -eq 0 ]; then
  echo "Please don't run as root"
  exit
fi

SOURCE_FILES="install/*.sh"

if [ $# -gt 0 ]; then
    SOURCE_FILES="$@"
fi

for script in $SOURCE_FILES; do
  echo ">>> $script"
  source $script
done

echo "All done!"
