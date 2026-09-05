#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export DOTFILES_DIR

source "$DOTFILES_DIR/scripts/packages.sh"
source "$DOTFILES_DIR/scripts/neovim.sh"
source "$DOTFILES_DIR/scripts/stow.sh"
source "$DOTFILES_DIR/scripts/manual.sh"

INSTALL_EXTRAS=false

for arg in "$@"; do
  case "$arg" in
  --extras)
    INSTALL_EXTRAS=true
    ;;
  *)
    echo "Unknown option: $arg"
    echo "Usage: $0 [--extras]"
    exit 1
    ;;
  esac
done

install_packages "$INSTALL_EXTRAS"
install_neovim
stow_dotfiles
print_manual_install_notes

echo
echo "== Installation complete =="

if [[ "$INSTALL_EXTRAS" != true ]]; then
  echo
  echo "Optional applications were not installed."
  echo "Run with --extras to install:"
  echo "  galculator, okular, pavucontrol, thunar"
fi
