#!/usr/bin/env bash

stow_dotfiles() {
  local dotfiles_dir
  local stow_dir

  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  stow_dir="$dotfiles_dir/stow"

  echo
  echo "== Stowing dotfiles =="

  local home_packages=(
    git
    zsh
  )

  for package in "${home_packages[@]}"; do
    echo "Stowing $package -> $HOME"

    stow \
      --dir="$stow_dir" \
      --target="$HOME" \
      --restow \
      "$package"
  done

  local config_packages=(
    kitty
    nvim
    sway
    swaylock
    waybar
    zathura
  )

  for package in "${config_packages[@]}"; do
    local target="$HOME/.config/$package"

    mkdir -p "$target"

    echo "Stowing $package -> $target"

    stow \
      --dir="$stow_dir" \
      --target="$target" \
      --restow \
      "$package"
  done
}
