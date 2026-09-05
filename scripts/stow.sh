#!/usr/bin/env bash

stow_dotfiles() {
  local dotfiles_dir
  local stow_dir

  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  stow_dir="$dotfiles_dir/stow"

  local packages=(
    git
    zsh
    nvim
    sway
    swaylock
    kitty
    waybar
    zathura
  )

  echo
  echo "== Stowing dotfiles =="

  for package in "${packages[@]}"; do
    if [[ -d "$stow_dir/$package" ]]; then
      echo "Stowing $package..."

      stow \
        --dir="$stow_dir" \
        --target="$HOME" \
        --restow \
        "$package"
    else
      echo "Skipping $package: package directory does not exist."
    fi
  done
}
