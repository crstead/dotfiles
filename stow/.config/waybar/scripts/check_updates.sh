#!/usr/bin/env bash

# Read the local apt cache; refreshing package lists is a separate user action.
set -euo pipefail
updates="$(apt list --upgradable 2>/dev/null | sed '1d')"
printf '%s\n' "$updates" | awk 'NF {count++} END {print count+0}'
printf '%s\n' "$updates"
