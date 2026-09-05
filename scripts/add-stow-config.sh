#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <app>"
  echo
  echo "Example:"
  echo "  $0 mako"
  exit 1
fi

APP="$1"

if [[ "$APP" == */* || "$APP" == "." || "$APP" == ".." ]]; then
  echo "ERROR: app must be a simple directory name."
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE_DIR="$HOME/.config/$APP"
DEST_DIR="$DOTFILES_DIR/stow/.config/$APP"
BACKUP_DIR="$HOME/.config/.${APP}.stow-backup.$$"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "ERROR: config directory does not exist:"
  echo "  $SOURCE_DIR"
  exit 1
fi

if [[ -e "$DEST_DIR" ]]; then
  echo "ERROR: config is already present in dotfiles:"
  echo "  $DEST_DIR"
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

  rm -rf "$DEST_DIR"

  exit "$exit_code"
}

trap rollback ERR

echo "== Adding $APP to dotfiles =="

mkdir -p "$DOTFILES_DIR/stow/.config"

echo "Moving original config aside..."
mv "$SOURCE_DIR" "$BACKUP_DIR"

echo "Copying config into dotfiles..."
mkdir -p "$DEST_DIR"
cp -a "$BACKUP_DIR/." "$DEST_DIR/"

echo
echo "== Stow dry run =="

stow \
  --no \
  --verbose \
  --dir="$DOTFILES_DIR" \
  --target="$HOME" \
  stow

echo
echo "== Restowing dotfiles =="

stow \
  --verbose \
  --dir="$DOTFILES_DIR" \
  --target="$HOME" \
  --restow \
  stow

trap - ERR

rm -rf "$BACKUP_DIR"

echo
echo "== Done =="
echo
echo "$SOURCE_DIR"
echo "  -> $DEST_DIR"
echo
echo "Commit with:"
echo "  cd \"$DOTFILES_DIR\""
echo "  git add \"stow/.config/$APP\""
echo "  git commit -m \"Add $APP config\""
