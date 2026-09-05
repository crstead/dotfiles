#!/usr/bin/env bash

stow_dotfiles() {
  local stow_dir="$DOTFILES_DIR/stow"

  echo
  echo "== Stowing dotfiles =="

  # Packages whose contents belong directly under $HOME.
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

  # Every other package is assumed to belong under ~/.config/<package>.
  for package_dir in "$stow_dir"/*; do
    [[ -d "$package_dir" ]] || continue

    local package
    package="$(basename "$package_dir")"

    case "$package" in
    git | zsh)
      continue
      ;;
    esac

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
