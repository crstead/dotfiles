#!/usr/bin/env bash

# Ubuntu's regular ~/.profile is the only expected fresh-install conflict.
# All other conflicts must be resolved before deleting it.
check_stow_dotfiles() {
  local source="$DOTFILES_DIR/stow/.profile"
  local target="$HOME/.profile"
  local stow_args=(--no --no-folding
    "--dir=$DOTFILES_DIR" "--target=$HOME" --restow)

  if [[ ! -f "$source" || ! -r "$source" ]]; then
    echo "ERROR: Missing or unreadable managed .profile: $source"
    return 1
  fi

  if [[ -e "$target" || -L "$target" ]] && [[ ! "$target" -ef "$source" ]]; then
    if [[ -L "$target" ]]; then
      echo "ERROR: ~/.profile links elsewhere; resolve it before installing."
      return 1
    elif [[ -d "$target" ]]; then
      echo "ERROR: ~/.profile is a directory."
      return 1
    elif [[ ! -f "$target" ]]; then
      echo "ERROR: ~/.profile is not a regular file."
      return 1
    fi
    echo "NOTE: The installer will replace ~/.profile with the managed version (no backup)."
    stow_args+=(--ignore='^\.profile$')
  fi

  stow "${stow_args[@]}" stow || return 1
}

stow_dotfiles() {
  echo
  echo "== Stowing dotfiles =="

  check_stow_dotfiles || return 1

  local source="$DOTFILES_DIR/stow/.profile"
  local target="$HOME/.profile"
  if [[ -f "$target" && ! -L "$target" && ! "$target" -ef "$source" ]]; then
    rm -- "$target" || return 1
  fi

  stow --no-folding --dir="$DOTFILES_DIR" --target="$HOME" --restow stow || return 1
  echo "Dotfiles successfully stowed."
}
