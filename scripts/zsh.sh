#!/usr/bin/env bash

install_zsh_config() {
  echo
  echo "== Configuring Zsh dependencies =="

  local omz_dir="$HOME/.oh-my-zsh"

  if [[ -f "$omz_dir/oh-my-zsh.sh" ]]; then
    echo "Oh My Zsh is already installed."
    return 0
  fi

  if [[ -e "$omz_dir" ]]; then
    echo "ERROR: Existing incomplete Oh My Zsh directory."
    return 1
  fi

  git clone --depth=1 \
    https://github.com/ohmyzsh/ohmyzsh.git \
    "$omz_dir" || return 1

  echo "Oh My Zsh installed."
}
