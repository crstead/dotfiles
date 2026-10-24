#!/usr/bin/env bash

# Package setup for Ubuntu 24.04 LTS (Noble).
# Review package names and defaults before using on a newer Ubuntu release.

install_packages() {
  local install_extras="$1"

  local core_packages=(
    # ───────────────────────────────────────────
    # Dotfiles / development
    # ───────────────────────────────────────────

    zsh
    # Shell

    nodejs
    npm
    
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
    # Terminal / applications
    # ───────────────────────────────────────────

    kitty
    # Terminal emulator.

    zathura
    # Lightweight keyboard-driven document/PDF viewer.

    vlc
    # Media player. Configuration is managed under stow/.config/vlc.

    # ───────────────────────────────────────────
    # General utilities
    # ───────────────────────────────────────────

    unzip

    xdg-utils
    # Desktop integration utilities (xdg-open, default applications, MIME associations)

  )

  local extra_packages=(
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
  echo "== Installing core packages =="
  sudo apt install -y "${core_packages[@]}"

  if [[ "$install_extras" == true ]]; then
    echo
    echo "== Installing optional applications =="
    sudo apt install -y "${extra_packages[@]}"
  fi
}
