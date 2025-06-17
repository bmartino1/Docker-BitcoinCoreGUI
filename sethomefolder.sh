#!/bin/bash
set -e

CONFIG_BITCOIN="/config/.bitcoin"

# Ensure base config path exists
mkdir -p "$CONFIG_BITCOIN"
chown -R app:app "$CONFIG_BITCOIN"

# Ensure bitcoin.conf exists
CONF_FILE="$CONFIG_BITCOIN/bitcoin.conf"
if [ ! -f "$CONF_FILE" ]; then
    echo "Creating default bitcoin.conf at $CONF_FILE"
    touch "$CONF_FILE"
    chown app:app "$CONF_FILE"
else
    echo "bitcoin.conf already exists at $CONF_FILE"
fi

# Target all expected home dirs for symlink: root's actual home, home/root, and app
declare -a TARGET_PATHS=(
    "/root/.bitcoin"         # Actual root home
    "/home/root/.bitcoin"    # Sometimes misconfigured root home
    "/home/app/.bitcoin"     # debain gui docker user
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
