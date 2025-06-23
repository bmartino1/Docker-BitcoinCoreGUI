#!/bin/bash
set -e

CONFIG_BITCOIN="/config/.bitcoin"
CONF_FILE="$CONFIG_BITCOIN/bitcoin.conf"

# Ensure base config dir exists
mkdir -p "$CONFIG_BITCOIN"

# Check if 'app' user exists
if id app &>/dev/null; then
    chown -R app:app "$CONFIG_BITCOIN"
else
    echo "[sethomefolder.sh] 'app' user not found, skipping chown"
fi

# Ensure bitcoin.conf exists
if [ ! -f "$CONF_FILE" ]; then
    echo "Creating default bitcoin.conf at $CONF_FILE"
    touch "$CONF_FILE"
    [ -n "$(id -u app 2>/dev/null)" ] && chown app:app "$CONF_FILE"
else
    echo "bitcoin.conf already exists at $CONF_FILE"
fi

# List of known user home paths (can be empty)
declare -a TARGET_PATHS=(
    "/root/.bitcoin"
    "/home/root/.bitcoin"
    "/home/app/.bitcoin"
)

echo "Ensuring ~/.bitcoin is linked correctly for known users..."

for path in "${TARGET_PATHS[@]}"; do
    parent_dir="$(dirname "$path")"

    # Skip if user home doesn't exist
    if [ ! -d "$parent_dir" ]; then
        echo "Skipping missing parent directory: $parent_dir"
        continue
    fi

    if [ -L "$path" ]; then
        echo "$path is already a symlink"
    elif [ -d "$path" ] || [ -f "$path" ]; then
        echo "Found real file or dir at $path — not modifying"
    else
        ln -s "$CONFIG_BITCOIN" "$path"
        echo "Linked $path -> $CONFIG_BITCOIN"
    fi
done
