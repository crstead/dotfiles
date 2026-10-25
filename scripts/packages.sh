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

    # Node and npm are installed from official Node binaries below.

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
    xz-utils
    gzip

    htop
    network-manager-gnome
    # Waybar actions use htop and nm-connection-editor.

    xdg-utils
    # Desktop integration utilities (xdg-open, default applications, MIME associations)


    # Desktop applications

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
  export PATH="$HOME/.local/bin:$PATH"
  if tool_has_version node 22.0.0 && command -v npm >/dev/null 2>&1; then
    echo "Node $(tool_version node) and npm are already available."
    return 0
  fi

  # Use the newest official Node 22 patch release, including security updates.
  # Work in a subshell so the temporary-directory trap does not leak out.
  (
    set -e
    local arch work archive checksum name distribution
    arch="$(linux_tool_arch)" || exit 1
    work="$(mktemp -d)" || exit 1
    trap 'rm -rf -- "$work"' EXIT
    curl -fsSL --retry 3 https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt \
      -o "$work/SHASUMS256.txt" || exit 1
    archive=""
    while read -r checksum name; do
      if [[ "$name" =~ ^node-v22\.[0-9]+\.[0-9]+-linux-$arch\.tar\.xz$ ]]; then
        archive="$name"
        printf '%s  %s\n' "$checksum" "$archive" > "$work/selected.sha256" || exit 1
        break
      fi
    done < "$work/SHASUMS256.txt"
    [[ -n "$archive" ]] || { echo "ERROR: Node archive missing from checksums." >&2; exit 1; }
    curl -fsSL --retry 3 "https://nodejs.org/dist/latest-v22.x/$archive" -o "$work/$archive" || exit 1
    (cd "$work" && sha256sum -c selected.sha256) || exit 1
    tar -xJf "$work/$archive" -C "$work" || exit 1
    distribution="${archive%.tar.xz}"
    mkdir -p "$HOME/.local/share" "$HOME/.local/bin" || exit 1
    # Replace only this installer's versioned distribution directory.
    rm -rf -- "$HOME/.local/share/$distribution" || exit 1
    mv -- "$work/$distribution" "$HOME/.local/share/$distribution" || exit 1
    for name in node npm npx; do
      ln -sfn -- "$HOME/.local/share/$distribution/bin/$name" "$HOME/.local/bin/$name" || exit 1
    done
    tool_has_version node 22.0.0 || exit 1
    npm --version
  )
}
