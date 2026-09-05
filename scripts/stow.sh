#!/usr/bin/env bash

stow_dotfiles() {
  echo
  echo "== Stowing dotfiles =="

  stow \
    --dir="$DOTFILES_DIR" \
    --target="$HOME" \
    --restow \
    stow
}
