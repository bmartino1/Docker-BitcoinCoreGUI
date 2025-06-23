#!/bin/bash
set -ex

export HOME=/config

# Ensure app user owns config
sudo chown -R nobody:users /config || true
sudo chmod -R 777 /config || true

# Run update
sudo /build.sh

# Start Bitcoin Knots GUI
exec /config/bitcoin/bin/bitcoin-qt -datadir=/config/.bitcoin
