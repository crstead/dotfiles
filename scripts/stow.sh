
#!/usr/bin/env bash

stow_dotfiles() {
  echo
  echo "== Stowing dotfiles =="

  local source="$DOTFILES_DIR/stow/.profile"
  local target="$HOME/.profile"
  local backup_dir

  # Ubuntu creates ~/.profile by default.
  # Preserve it if it conflicts with our dotfiles.
  if [[ -e "$source" ]] &&
     [[ -e "$target" || -L "$target" ]] &&
     [[ ! "$target" -ef "$source" ]]; then

    if [[ -d "$target" && ! -L "$target" ]]; then
      echo "ERROR: ~/.profile is a directory."
      return 1
    fi

    backup_dir="$(mktemp -d "$HOME/dotfiles-backup.XXXXXXXX")" ||
      return 1

    mv -- "$target" "$backup_dir/.profile" || return 1
    echo "Backed up existing .profile to $backup_dir"
  fi

  stow \
    --dir="$DOTFILES_DIR" \
    --target="$HOME" \
    --restow \
    stow || return 1

  echo "Dotfiles successfully stowed."
}
