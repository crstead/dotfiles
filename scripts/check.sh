#!/usr/bin/env bash

# Read-only checks. The shared Stow module only defines functions.
check_installation() {
  local errors=0 skipped=0 file tool
  local tools=(apt sudo git stow zsh node npm go cc make cmake ninja gettext
    curl tar unzip xz gzip sha256sum python3 nvim tree-sitter sway swayidle swaylock waybar
    fuzzel wlsunset mako brightnessctl grim slurp pactl kitty zathura vlc
    firefox galculator okular pavucontrol thunar file-roller htop nm-connection-editor)

  echo "== Checking installer configuration (read-only) =="

  for file in install.sh scripts/packages.sh scripts/firefox.sh scripts/neovim.sh \
    scripts/zsh.sh scripts/stow.sh scripts/tools.sh scripts/check.sh scripts/add-stow-config.sh \
    stow/.profile stow/.zprofile stow/.zshenv stow/.zshrc \
    stow/.gitconfig stow/.stow-local-ignore stow/.config/nvim/init.lua \
    system/firefox/policies.json system/90-clamshell.conf; do
    if [[ ! -r "$DOTFILES_DIR/$file" || ! -f "$DOTFILES_DIR/$file" ]]; then
      echo "ERROR: Missing or unreadable source: $file"
      errors=$((errors + 1))
    fi
  done

  for file in "$DOTFILES_DIR/install.sh" "$DOTFILES_DIR"/scripts/*.sh \
    "$DOTFILES_DIR/stow/.profile"; do
    [[ -f "$file" ]] || continue
    if ! bash -n "$file"; then
      echo "ERROR: Invalid Bash syntax: $file"
      errors=$((errors + 1))
    fi
  done

  if command -v zsh >/dev/null 2>&1; then
    for file in .zshenv .zprofile .zshrc; do
      [[ -f "$DOTFILES_DIR/stow/$file" ]] || continue
      if ! zsh -f -n "$DOTFILES_DIR/stow/$file"; then
        echo "ERROR: Invalid Zsh syntax: $file"
        errors=$((errors + 1))
      fi
    done
  else
    echo "SKIP: Zsh syntax validation requires zsh."
    skipped=$((skipped + 1))
  fi

  if command -v python3 >/dev/null 2>&1; then
    if [[ -f "$DOTFILES_DIR/system/firefox/policies.json" ]] &&
      ! python3 -B -m json.tool "$DOTFILES_DIR/system/firefox/policies.json" >/dev/null; then
      echo "ERROR: Invalid Firefox policy JSON."
      errors=$((errors + 1))
    fi
  else
    echo "SKIP: JSON validation requires python3."
    skipped=$((skipped + 1))
  fi

  echo
  echo "== Local dependencies and tool versions =="
  for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "FOUND: $tool"
    else
      echo "MISSING: $tool (may be provided during installation)"
    fi
  done
  if bash -n "$DOTFILES_DIR/scripts/tools.sh"; then
    source "$DOTFILES_DIR/scripts/tools.sh"
    for tool in node tree-sitter; do
      if command -v "$tool" >/dev/null 2>&1; then
        local minimum=22.0.0
        [[ "$tool" != tree-sitter ]] || minimum=0.26.1
        if tool_has_version "$tool" "$minimum"; then
          echo "VERSION OK: $tool $(tool_version "$tool")"
        else
          echo "UPDATE: $tool requires $minimum or newer; the installer will provide it."
        fi
      fi
    done
  fi
  if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    echo "FOUND: Oh My Zsh"
  elif [[ -e "$HOME/.oh-my-zsh" || -L "$HOME/.oh-my-zsh" ]]; then
    echo "ERROR: Existing incomplete Oh My Zsh directory."
    errors=$((errors + 1))
  else
    echo "MISSING: Oh My Zsh (installed by the installer)"
  fi

  echo
  echo "== Stow conflict check =="
  if command -v stow >/dev/null 2>&1; then
    if bash -n "$DOTFILES_DIR/scripts/stow.sh"; then
      source "$DOTFILES_DIR/scripts/stow.sh"
      if ! check_stow_dotfiles; then
        echo "ERROR: Stow detected conflicts or could not complete its simulation."
        errors=$((errors + 1))
      fi
    else
      echo "SKIP: Stow validation requires a valid scripts/stow.sh."
      skipped=$((skipped + 1))
    fi
  else
    echo "SKIP: Install stow to check symlink conflicts."
    skipped=$((skipped + 1))
  fi

  echo
  echo "Checks complete: $errors error(s), $skipped skipped check(s). No changes made."
  echo "Downloads, package availability, builds, and privileged operations were not tested."
  [[ "$errors" -eq 0 ]]
}
