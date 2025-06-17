#!/bin/bash
set -ex

export HOME=/config

# Check for update
/build.sh

# Launch bitcoin-qt from persistent path
exec /config/bitcoin/bin/bitcoin-qt
