#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export DOTFILES_DIR

CHECK_ONLY=false

usage() {
  echo "Usage: $0 [--check]"
  echo "  --check   Validate configuration without changes, sudo, or network access."
}

for arg in "$@"; do
  case "$arg" in
  --check)
    CHECK_ONLY=true
    ;;
  --help|-h)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $arg"
    usage
    exit 1
    ;;
  esac
done

if [[ "$CHECK_ONLY" == true ]]; then
  source "$DOTFILES_DIR/scripts/check.sh"
  check_installation
  exit $?
fi

source "$DOTFILES_DIR/scripts/packages.sh"
source "$DOTFILES_DIR/scripts/tools.sh"
source "$DOTFILES_DIR/scripts/firefox.sh"
source "$DOTFILES_DIR/scripts/neovim.sh"
source "$DOTFILES_DIR/scripts/zsh.sh"
source "$DOTFILES_DIR/scripts/stow.sh"

configure_default_shell() {
  echo
  echo "== Configuring default shell =="

  local zsh_path
  zsh_path="$(command -v zsh)" || return 1

  local current_shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"

  if [[ "$current_shell" == "$zsh_path" ]]; then
    echo "Zsh is already the default shell."
    return 0
  fi

  chsh -s "$zsh_path" || return 1

  echo "Default shell changed to Zsh."
  echo "Log out and back in to apply."
}

# Install system-wide configuration files.
install_system_config() {
  echo
  echo "== Installing system configuration =="

  local source="$DOTFILES_DIR/system/90-clamshell.conf"
  local target="/etc/systemd/logind.conf.d/90-clamshell.conf"

  if [[ ! -f "$source" ]]; then
    echo "ERROR: Missing system configuration: $source"
    return 1
  fi

  # Skip installation when the file is unchanged.
  if sudo test -f "$target" &&
     sudo cmp -s "$source" "$target"; then
    echo "Clamshell configuration is unchanged."
    return 0
  fi

  # Install the configuration with appropriate permissions.
  sudo install -D -m 0644 "$source" "$target" ||
    return 1

  echo "Clamshell configuration installed."
  echo "Reboot to apply the updated lid-switch settings."
}


# Main installation sequence
install_packages
# Stop on conflicts before downloading tools or building Neovim.
check_stow_dotfiles
install_node
install_zsh_config
configure_default_shell
install_neovim
stow_dotfiles
install_firefox_policy
install_system_config

echo
echo "== Installation complete =="
