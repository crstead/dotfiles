#!/usr/bin/env bash

# Read-only checks: do not source installer modules or launch configured apps.
check_installation() {
  local errors=0 skipped=0 file tool
  local tools=(apt sudo git stow zsh node npm go cc make cmake ninja gettext
    curl tar unzip python3 nvim tree-sitter sway swayidle swaylock waybar
    fuzzel wlsunset mako brightnessctl grim slurp pactl kitty zathura vlc
    firefox galculator okular pavucontrol thunar file-roller)
  local profile="$HOME/.profile"
  local managed_profile="$DOTFILES_DIR/stow/.profile"
  local stow_args=(--no --verbose --no-folding
    "--dir=$DOTFILES_DIR" "--target=$HOME" --restow)

  echo "== Checking installer configuration (read-only) =="

  for file in install.sh scripts/packages.sh scripts/firefox.sh scripts/neovim.sh \
    scripts/zsh.sh scripts/stow.sh scripts/check.sh scripts/add-stow-config.sh \
    stow/.profile stow/.zprofile stow/.zshenv stow/.zshrc \
    stow/.gitconfig stow/.stow-local-ignore stow/.config/nvim/init.lua \
    system/firefox/policies.json system/90-clamshell.conf; do
    if [[ ! -r "$DOTFILES_DIR/$file" || ! -f "$DOTFILES_DIR/$file" ]]; then
      echo "ERROR: Missing or unreadable source: $file"
      errors=$((errors + 1))
    fi
  done

  for file in "$DOTFILES_DIR/install.sh" "$DOTFILES_DIR"/scripts/*.sh \
    "$managed_profile"; do
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
  echo "== Local dependencies (presence only) =="
  for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "FOUND: $tool"
    else
      echo "MISSING: $tool (may be provided during installation)"
    fi
  done
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
  if [[ -e "$profile" || -L "$profile" ]] && [[ ! "$profile" -ef "$managed_profile" ]]; then
    if [[ -d "$profile" && ! -L "$profile" ]]; then
      echo "ERROR: ~/.profile is a directory; the installer cannot back it up."
      errors=$((errors + 1))
    else
      echo "NOTE: The installer will back up ~/.profile and replace it with a link."
    fi
    # The real installer removes this expected conflict before running Stow.
    stow_args+=(--ignore='^\.profile$')
  fi
  if [[ ! -d "$DOTFILES_DIR/stow" || ! -d "$HOME" ]]; then
    echo "ERROR: Stow package directory or target home directory is missing."
    errors=$((errors + 1))
  elif command -v stow >/dev/null 2>&1; then
    if ! stow "${stow_args[@]}" stow; then
      echo "ERROR: Stow detected conflicts or could not complete its simulation."
      errors=$((errors + 1))
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
