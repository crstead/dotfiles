#!/usr/bin/env bash

install_firefox_policy() {
  echo
  echo "== Configuring Firefox extensions =="

  local source="$DOTFILES_DIR/system/firefox/policies.json"
  local target="/etc/firefox/policies/policies.json"

  if [[ ! -f "$source" ]]; then
    echo "ERROR: Firefox policies file not found: $source"
    return 1
  fi

  # Validate JSON before installing.
  if ! python3 -m json.tool "$source" >/dev/null; then
    echo "ERROR: Invalid Firefox policies JSON."
    return 1
  fi

  # Skip if the installed policy is identical.
  if sudo test -f "$target" &&
     sudo cmp -s "$source" "$target"; then
    echo "Firefox extension policy is already up to date."
    return 0
  fi

  # Install or update the system-wide Firefox policy.
  sudo install -D -m 0644 "$source" "$target" || return 1

  echo "Firefox extension policy installed."
  echo "Restart Firefox to apply the configuration."
}
