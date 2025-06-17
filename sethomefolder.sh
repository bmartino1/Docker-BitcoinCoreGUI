#!/bin/bash
set -e

CONFIG_BITCOIN="/config/.bitcoin"

# Ensure base config path exists
mkdir -p "$CONFIG_BITCOIN"
chown -R app:app "$CONFIG_BITCOIN"

# Target all expected home dirs for symlink: root's actual home, home/root, and app
declare -a TARGET_PATHS=(
    "/root/.bitcoin"         # Actual root home
    "/home/root/.bitcoin"    # Sometimes misconfigured root home
    "/home/app/.bitcoin"
)

echo "Ensuring ~/.bitcoin is linked correctly for known users..."

for path in "${TARGET_PATHS[@]}"; do
    parent_dir="$(dirname "$path")"
    mkdir -p "$parent_dir"

    if [ -L "$path" ]; then
        echo "$path is already a symlink"
    elif [ -d "$path" ] || [ -f "$path" ]; then
        echo "Found real file or dir at $path — not touching"
    else
        ln -s "$CONFIG_BITCOIN" "$path"
        echo "Linked $path -> $CONFIG_BITCOIN"
    fi
done
