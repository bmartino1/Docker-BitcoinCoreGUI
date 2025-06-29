#!/bin/bash
set -e

CONFIG_BITCOIN="/config/.bitcoin"
CONF_FILE="$CONFIG_BITCOIN/bitcoin.conf"

# Ensure base config dir exists
mkdir -p "$CONFIG_BITCOIN"

# Attempt to chown if user exists
if id "app" &>/dev/null; then
    chown -R app:app "$CONFIG_BITCOIN"
else
    echo "[sethomefolder.sh] Skipping chown: user 'app' not found."
fi

# Ensure bitcoin.conf exists
if [ ! -f "$CONF_FILE" ]; then
    echo "[sethomefolder.sh] Creating default bitcoin.conf at $CONF_FILE"
    touch "$CONF_FILE"
    if id "app" &>/dev/null; then
        chown app:app "$CONF_FILE"
    fi
else
    echo "[sethomefolder.sh] bitcoin.conf already exists."
fi

# Symlink to ~/.bitcoin for known user home paths
TARGET_PATHS=(
    "/root/.bitcoin"
    "/home/root/.bitcoin"
    "/home/app/.bitcoin"
)

echo "[sethomefolder.sh] Ensuring ~/.bitcoin symlinks are in place..."

for path in "${TARGET_PATHS[@]}"; do
    parent_dir="$(dirname "$path")"

    # Skip if parent doesn't exist
    if [ ! -d "$parent_dir" ]; then
        echo "[sethomefolder.sh] Skipping: $parent_dir does not exist."
        continue
    fi

    if [ -L "$path" ]; then
        echo "[sethomefolder.sh] $path already symlinked."
    elif [ -e "$path" ]; then
        echo "[sethomefolder.sh] Found existing file or dir at $path — skipping."
    else
        ln -s "$CONFIG_BITCOIN" "$path"
        echo "[sethomefolder.sh] Linked $path → $CONFIG_BITCOIN"
    fi
done

# Remove bitcoin.conf at the end to allow application to generate defaults we want syms only for applicaiotn not a blank file to pre-exisit...
if [ -f "$CONF_FILE" ]; then
    echo "[sethomefolder.sh] Removing existing bitcoin.conf to allow auto-generation..."
    rm -f "$CONF_FILE"
else
    echo "[sethomefolder.sh] No bitcoin.conf present — skipping removal."
fi
