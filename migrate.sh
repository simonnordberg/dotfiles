#!/usr/bin/env bash

CURRENT_DIR=$(pwd)

set -e

mkdir -p $CURRENT_DIR/services

for service in $(ls $CURRENT_DIR/install/*.sh); do
  echo "Migrating $service"
  # Get the filename without the extension and the initial number prefix
  BASENAME=$(basename $service)
  BASENAME=${BASENAME%.sh}
  BASENAME=${BASENAME#??-}

  mkdir -p $CURRENT_DIR/services/$BASENAME

  git mv $service $CURRENT_DIR/services/$BASENAME/install.sh
done
