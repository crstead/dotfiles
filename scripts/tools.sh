#!/usr/bin/env bash

# Compare stable semantic versions without depending on Node or Python.
version_at_least() {
  local actual="$1" minimum="$2" index
  local -a found required
  [[ "$actual" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  IFS=. read -r -a found <<< "$actual"
  IFS=. read -r -a required <<< "$minimum"
  for index in 0 1 2; do
    (( 10#${found[index]} > 10#${required[index]} )) && return 0
    (( 10#${found[index]} < 10#${required[index]} )) && return 1
  done
  return 0
}

tool_version() {
  local output
  output="$("$1" --version 2>/dev/null)" || return 1
  output="${output#tree-sitter }"
  output="${output#v}"
  printf '%s\n' "${output%% *}"
}

tool_has_version() {
  local actual
  actual="$(tool_version "$1")" || return 1
  version_at_least "$actual" "$2"
}

linux_tool_arch() {
  [[ "$(uname -s)" == Linux ]] || { echo "ERROR: Linux is required." >&2; return 1; }
  case "$(uname -m)" in
    x86_64) echo x64 ;;
    aarch64|arm64) echo arm64 ;;
    *) echo "ERROR: Unsupported CPU architecture: $(uname -m)" >&2; return 1 ;;
  esac
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
