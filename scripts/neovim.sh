#!/usr/bin/env bash

install_neovim() {
  local neovim_dir="$HOME/tmp/neovim"

  echo
  echo "== Installing Neovim from source =="

  mkdir -p "$HOME/tmp"

  if [[ ! -d "$neovim_dir/.git" ]]; then
    echo "Cloning Neovim..."
    git clone https://github.com/neovim/neovim "$neovim_dir"
  fi

  cd "$neovim_dir"

  echo "Updating Neovim repository..."
  git fetch --tags

  echo "Checking out stable branch..."
  git checkout stable
  git pull --ff-only

  echo "Building Neovim..."
  make CMAKE_BUILD_TYPE=RelWithDebInfo

  echo "Installing Neovim..."
  sudo make install

  echo
  echo "Installed Neovim version:"
  nvim --version | head -n 1


  echo
  echo "== Installing tree-sitter CLI =="

  if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm is required to install tree-sitter-cli."
    return 1
  fi

  if ! command -v tree-sitter >/dev/null 2>&1; then
    sudo npm install -g tree-sitter-cli
  fi

  if ! command -v tree-sitter >/dev/null 2>&1; then
    echo "ERROR: tree-sitter CLI installation failed."
    return 1
  fi

  echo "Tree-sitter CLI: $(tree-sitter --version)"
}
