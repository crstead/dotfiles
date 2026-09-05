#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <app>"
  echo
  echo "Example:"
  echo "  $0 mako"
  echo
  echo "This migrates:"
  echo "  ~/.config/<app>/"
  echo "to:"
  echo "  ~/dotfiles/stow/<app>/"
  exit 1
fi

APP="$1"

# Only support simple ~/.config/<app> directory names.
if [[ "$APP" == */* || "$APP" == "." || "$APP" == ".." ]]; then
  echo "ERROR: app must be a simple directory name."
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"

SOURCE_DIR="$HOME/.config/$APP"
PACKAGE_DIR="$STOW_DIR/$APP"
BACKUP_DIR="$HOME/.config/.${APP}.stow-backup.$$"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "ERROR: config directory does not exist:"
  echo "  $SOURCE_DIR"
  exit 1
fi

if [[ -L "$SOURCE_DIR" ]]; then
  echo "ERROR: $SOURCE_DIR is already a symlink."
  exit 1
fi

if [[ -e "$PACKAGE_DIR" ]]; then
  echo "ERROR: Stow package already exists:"
  echo "  $PACKAGE_DIR"
  exit 1
fi

rollback() {
  local exit_code=$?

  echo
  echo "Migration failed. Restoring original config..."

  rm -rf "$SOURCE_DIR"

  if [[ -d "$BACKUP_DIR" ]]; then
    mv "$BACKUP_DIR" "$SOURCE_DIR"
  fi

  rm -rf "$PACKAGE_DIR"

  exit "$exit_code"
}

trap rollback ERR

echo "== Adding $APP to dotfiles =="

echo
echo "Moving original config aside..."
mv "$SOURCE_DIR" "$BACKUP_DIR"

echo "Copying config into dotfiles..."
mkdir -p "$PACKAGE_DIR"
cp -a "$BACKUP_DIR/." "$PACKAGE_DIR/"

echo "Creating Stow target..."
mkdir -p "$SOURCE_DIR"

echo
echo "== Stow dry run =="

stow \
  --no \
  --verbose \
  --dir="$STOW_DIR" \
  --target="$SOURCE_DIR" \
  "$APP"

echo
echo "== Stowing $APP =="

stow \
  --verbose \
  --dir="$STOW_DIR" \
  --target="$SOURCE_DIR" \
  "$APP"

# Migration succeeded, so rollback is no longer required.
trap - ERR

rm -rf "$BACKUP_DIR"

echo
echo "== Done =="
echo
echo "Config:"
echo "  $SOURCE_DIR"
echo
echo "Canonical dotfiles:"
echo "  $PACKAGE_DIR"
echo
echo "Verify with:"
echo "  find \"$SOURCE_DIR\" -maxdepth 1 -type l -ls"
echo
echo "Git:"
echo "  cd \"$DOTFILES_DIR\""
echo "  git add \"stow/$APP\""
echo "  git commit -m \"Add $APP config\""
