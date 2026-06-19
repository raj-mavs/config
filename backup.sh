#!/usr/bin/env bash

# Define output directory``
BACKUP_DIR="./system-packages"
mkdir -p "$BACKUP_DIR"

# Export package lists
pacman -Qen >"$BACKUP_DIR/requirements.txt"
pacman -Qem >"$BACKUP_DIR/aur_requirements.txt"

echo "Package lists successfully updated in $BACKUP_DIR"
