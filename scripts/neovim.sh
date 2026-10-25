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

install_tree_sitter() {
  export PATH="$HOME/.local/bin:$PATH"
  if tool_has_version tree-sitter 0.26.1; then
    echo "Tree-sitter $(tool_version tree-sitter) is already compatible."
    return 0
  fi

  (
    set -e
    local arch work checksum
    arch="$(linux_tool_arch)" || exit 1
    case "$arch" in
      x64) checksum=d01042f94ba3d6827ddc9788e235f75d8366431be42bdf90ade534d960c98b7d ;;
      arm64) checksum=404be5d54a4955571c4067c21d4699660eab3a534cefb0659341b207f7139ec5 ;;
    esac
    work="$(mktemp -d)" || exit 1
    trap 'rm -rf -- "$work"' EXIT
    curl -fsSL --retry 3 \
      "https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.1/tree-sitter-linux-$arch.gz" \
      -o "$work/tree-sitter.gz" || exit 1
    printf '%s  tree-sitter.gz\n' "$checksum" > "$work/selected.sha256" || exit 1
    (cd "$work" && sha256sum -c selected.sha256) || exit 1
    gzip -dc "$work/tree-sitter.gz" > "$work/tree-sitter" || exit 1
    chmod 0755 "$work/tree-sitter" || exit 1
    # Validate the downloaded executable before replacing the installed one.
    tool_has_version "$work/tree-sitter" 0.26.1 || exit 1
    mkdir -p "$HOME/.local/bin" || exit 1
    # mv replaces a prior npm symlink rather than writing through it.
    mv -f -- "$work/tree-sitter" "$HOME/.local/bin/tree-sitter" || exit 1
    tool_has_version tree-sitter 0.26.1
  )
}
