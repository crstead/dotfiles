#!/usr/bin/env bash

# Package setup for Ubuntu 24.04 LTS (Noble).
# Review package names and defaults before using on a newer Ubuntu release.

install_packages() {
  local packages=(
    # ───────────────────────────────────────────
    # Dotfiles / development
    # ───────────────────────────────────────────

    zsh
    # Shell

    # Node and npm are installed through nvm below.

    python3-venv
    # Mason creates virtual environments for Python tools such as black.
    
    git
    # Version control. Used to manage this dotfiles repository.

    stow
    # Symlink manager. Maps packages under ~/dotfiles/stow into $HOME.

    build-essential
    # GCC, g++, make and other standard compilation/build tools.

    curl
    # Command-line HTTP client used by various development/install tools.

    tree
    # Displays directory structures as a tree. Useful for inspecting dotfiles.

    ripgrep
    # Provides rg for Telescope live_grep, grep_string and file searches.

    # ───────────────────────────────────────────
    # Go
    # ───────────────────────────────────────────

    golang-go
    # Go compiler and standard toolchain.

    # ───────────────────────────────────────────
    # Neovim build dependencies
    # ───────────────────────────────────────────

    ninja-build
    # Fast build system used when compiling Neovim.

    gettext
    # Internationalisation tooling required by the Neovim build.

    cmake
    # Build-system generator used to compile Neovim.

    # ───────────────────────────────────────────
    # Sway / Wayland desktop
    # ───────────────────────────────────────────

    sway
    # Wayland compositor and tiling window manager.

    swaybg
    # Displays wallpapers/background images under Sway.

    swayidle
    # Handles idle behaviour such as locking and turning displays off.

    swaylock
    # Locks the Sway/Wayland session.

    waybar
    # Status bar for Sway and other Wayland compositors.

    fuzzel
    # Lightweight Wayland application launcher.

    wlsunset
    # Adjusts display colour temperature according to time of day.

    mako-notifier
    # Notification daemon for Wayland. The executable is `mako`.

    brightnessctl
    # Controls display/backlight brightness, typically from Sway keybindings.

    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    # Wayland desktop integration

    # ───────────────────────────────────────────
    # Screenshots
    # ───────────────────────────────────────────

    grim
    # Screenshot utility for Wayland.

    slurp
    # Interactive screen-region selector, commonly paired with grim.

    # ───────────────────────────────────────────
    # Audio
    # ───────────────────────────────────────────

    pipewire-audio
    # Recommended desktop PipeWire audio stack.
    # Includes PulseAudio compatibility and WirePlumber.

    pulseaudio-utils
    # Provides PulseAudio-compatible CLI tools such as pactl.

    alsa-utils
    # Low-level ALSA tools such as alsamixer, aplay and speaker-test.

    # ───────────────────────────────────────────
    # Applications and utilities
    # ───────────────────────────────────────────

    kitty
    # Terminal emulator.

    zathura
    # Lightweight keyboard-driven document/PDF viewer.

    vlc
    # Media player. Configuration is managed under stow/.config/vlc.

    unzip
    xz-utils
    gzip

    htop
    network-manager-gnome
    # Waybar actions use htop and nm-connection-editor.

    xdg-utils
    # Desktop integration utilities (xdg-open, default applications, MIME associations)

    firefox
    # Web browser

    thunar-archive-plugin
    file-roller
    # File manager integration

    galculator
    # Lightweight desktop calculator.

    okular
    # KDE document/PDF viewer.

    pavucontrol
    # GUI for controlling audio devices, streams and volume.

    thunar
    # XFCE file manager, usable independently of the XFCE desktop.
  )

  echo "== Updating apt package lists =="
  sudo apt update

  echo
  echo "== Installing packages =="
  sudo apt install -y "${packages[@]}"

}

install_node() {
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    # Stow owns shell configuration; do not let nvm edit profile files.
    curl -fsSL --retry 3 https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh |
      PROFILE=/dev/null bash || return 1
  fi

  source "$NVM_DIR/nvm.sh" --no-use || return 1
  nvm install --lts || return 1
  nvm alias default 'lts/*' || return 1
  nvm use --lts || return 1

  # Remove only links created by the previous dotfiles Node installer.
  local name target
  for name in node npm npx; do
    target="$HOME/.local/bin/$name"
    if [[ -L "$target" ]]; then
      case "$(readlink "$target")" in
        "$HOME"/.local/share/node-v*-linux-*/bin/"$name") rm -- "$target" || return 1 ;;
      esac
    fi
  done
}
