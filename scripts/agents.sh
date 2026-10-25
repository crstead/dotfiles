#!/usr/bin/env bash

install_agent_clis() {
  echo
  echo "== Installing coding agent CLIs =="

  # Both native installers use ~/.local/bin, independent of nvm versions.
  export PATH="$HOME/.local/bin:$PATH"
  local tool url shell installer
  for tool in claude codex; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "$tool is already installed."
      continue
    fi

    case "$tool" in
      claude) url=https://claude.ai/install.sh; shell=bash ;;
      codex) url=https://chatgpt.com/codex/install.sh; shell=sh ;;
    esac
    installer="$(mktemp)" || return 1
    # Download completely before executing so a partial download cannot run.
    if ! curl -fsSL --retry 3 "$url" -o "$installer" ||
       ! "$shell" "$installer"; then
      rm -f -- "$installer"
      echo "ERROR: Failed to install $tool." >&2
      return 1
    fi
    rm -f -- "$installer"
    "$tool" --version || return 1
  done
}
