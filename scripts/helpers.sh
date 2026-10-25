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
