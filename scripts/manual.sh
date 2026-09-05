#!/usr/bin/env bash

print_manual_install_notes() {
  echo
  echo "== Separately managed software =="
  echo
  echo "Google Chrome"
  echo "  Browser installed separately from Google's package/repository."
  echo
  echo "ZSA Keymapp"
  echo "  GUI used to configure ZSA keyboards."
  echo
  echo "ZSA Wally"
  echo "  Utility used to flash firmware onto ZSA keyboards."
  echo
  echo "Node.js / npm"
  echo "  Managed separately rather than through apt."
  echo "  Required for npm-installed tools such as tree-sitter-cli."
}
