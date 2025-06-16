#!/bin/sh
# Execute bitcoin update check
/build.sh

# Docker env
set -ex
export HOME=/config
exec bitcoin-qt
