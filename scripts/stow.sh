#!/usr/bin/env bash

stow_dotfiles() {
  echo
  echo "== Stowing dotfiles =="

  local profile="$HOME/.profile"
  local managed_profile="$DOTFILES_DIR/stow/.profile"
  local backup_dir

  # Ubuntu creates a default ~/.profile during installation.
  # Back it up if it conflicts with our Stow-managed version.
  if [[ -e "$profile" || -L "$profile" ]]; then
    if [[ ! "$profile" -ef "$managed_profile" ]]; then
      if [[ -d "$profile" && ! -L "$profile" ]]; then
        echo "ERROR: ~/.profile is a directory."
        return 1
      fi

      backup_dir="$(mktemp -d "$HOME/dotfiles-backup.XXXXXXXX")" || return 1

      mv -- "$profile" "$backup_dir/.profile" || return 1
      echo "Backed up existing .profile to $backup_dir/.profile"
    fi
  fi

  stow \
    --dir="$DOTFILES_DIR" \
    --target="$HOME" \
    --restow \
    stow

  echo "Dotfiles symlinks updated."
}
