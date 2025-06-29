#!/bin/bash
set -ex

export HOME=/config

# Ensure app user owns config
mkdir -p /config/.bitcoin
sudo chown -R nobody:users /config/.bitcoin || true
sudo chmod -R 777 /config/.bitcoin || true

# Fix Permission for Build
mkdir -p /config/bitcoin
sudo chown -R nobody:users /config/bitcoin || true
sudo chmod -R 777 /config/bitcoin || true

# Conditionally run update if AUTOUPDATE=true
if [ "${AUTOUPDATE,,}" = "true" ]; then
    echo "AUTOUPDATE is true, running /build.sh to update the application..."
    sudo /build.sh
else
    echo "AUTOUPDATE is not true, skipping /build.sh"
fi

# Start Bitcoin Knots GUI
while true; do
    echo "Starting Bitcoin GUI..."
    /config/bitcoin/bin/bitcoin-qt -datadir=/config/.bitcoin
    echo "Bitcoin GUI closed. Restarting in 5 seconds..."
    sleep 5
done
