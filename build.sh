#!/bin/bash
set -e

export HOME=/config
BTC_DIR="/config/bitcoin"
BTC_BIN="${BTC_DIR}/bin"
BTC_VERSION_FILE="${BTC_DIR}/.btc_version"

mkdir -p "$BTC_BIN"
mkdir -p "$(dirname "$BTC_VERSION_FILE")"
mkdir -p /tmp

echo "Checking for latest Bitcoin Core..."

LATEST_VERSION=$(curl -s https://bitcoincore.org/en/download/ | \
    grep -Eo 'bitcoin-core-[0-9]+\.[0-9]+' | \
    sed 's/bitcoin-core-//' | \
    sort -V | tail -1)

echo "Latest version is: $LATEST_VERSION"

CURRENT_VERSION=""
[ -f "$BTC_VERSION_FILE" ] && CURRENT_VERSION=$(cat "$BTC_VERSION_FILE")

if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "Updating to Bitcoin Core $LATEST_VERSION"
    cd /tmp
    FILE="bitcoin-${LATEST_VERSION}-x86_64-linux-gnu.tar.gz"
    URL="https://bitcoincore.org/bin/bitcoin-core-${LATEST_VERSION}/${FILE}"

    curl -LO "$URL"
    tar -xf "$FILE"

    cp -a "bitcoin-${LATEST_VERSION}/bin/"* "$BTC_BIN/"
    chmod +x "$BTC_BIN/bitcoin-qt"

    echo "$LATEST_VERSION" > "$BTC_VERSION_FILE"
    echo "Update complete"
else
    echo "Already running the latest version: $CURRENT_VERSION"
fi
