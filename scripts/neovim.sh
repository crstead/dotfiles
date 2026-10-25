#!/usr/bin/env bash

install_neovim() {
  local neovim_dir="$HOME/tmp/neovim"
  local state_dir="$HOME/.local/state/dotfiles"
  local stamp="$state_dir/neovim-commit"
  local stable_commit
  local installed_commit=""

  echo
  echo "== Installing Neovim from source =="

  mkdir -p "$HOME/tmp" "$state_dir"

  # Clone the source repository if necessary.
  if [[ ! -d "$neovim_dir/.git" ]]; then
    echo "Cloning Neovim..."
    git clone https://github.com/neovim/neovim \
      "$neovim_dir" || return 1
  fi

  # Update tags, including the moving stable tag.
  echo "Fetching Neovim releases..."
  git -C "$neovim_dir" fetch --tags --force origin ||
    return 1

  stable_commit="$(
    git -C "$neovim_dir" rev-parse \
      'refs/tags/stable^{commit}'
  )" || return 1

  if [[ -f "$stamp" ]]; then
    installed_commit="$(cat "$stamp")"
  fi

  # Skip rebuilding if this installer has already
  # installed the current stable commit.
  if [[ "$installed_commit" == "$stable_commit" ]] &&
     command -v nvim >/dev/null 2>&1; then
    echo "Neovim is already up to date."
  else
    echo "Checking out stable release..."
    git -C "$neovim_dir" checkout --detach "$stable_commit" || return 1

    echo "Building Neovim..."
    make -C "$neovim_dir" \
      CMAKE_BUILD_TYPE=RelWithDebInfo || return 1

    echo "Installing Neovim..."
    sudo make -C "$neovim_dir" install || return 1

    # Record only successful installations.
    printf '%s\n' "$stable_commit" > "$stamp" ||
      return 1

    echo "Neovim installed successfully."
  fi

  echo
  echo "Installed Neovim version:"
  nvim --version | sed -n '1p'

  echo
  echo "== Checking Tree-sitter CLI =="
  install_tree_sitter || return 1

  echo
  echo "Neovim setup complete."
}
