#!/bin/bash
set -ex

export HOME=/config

# Ensure app user owns config
mkdir -p /config/.bitcoin
sudo chown -R nobody:users /config/.bitcoin || true
sudo chmod -R 777 /config/.bitcoin || true

#Fix Permission for Build
mkdir -p /config/bitcoin
sudo chown -R nobody:users /config/bitcoin || true
sudo chmod -R 777 /config/bitcoin || true

# Run update
sudo /build.sh

# Start Bitcoin Knots GUI
exec /config/bitcoin/bin/bitcoin-qt -datadir=/config/.bitcoin
