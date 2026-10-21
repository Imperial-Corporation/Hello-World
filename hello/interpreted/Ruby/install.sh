#!/usr/bin/env bash
set -Eeuo pipefail

: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

if ! command -v ruby >/dev/null 2>&1; then
    echo "ERROR: Ruby is not installed on this runner." >&2
    exit 1
fi

if ! command -v gem >/dev/null 2>&1; then
    echo "ERROR: RubyGems is not installed." >&2
    exit 1
fi

ruby --version
gem --version

mkdir -p "$DIST_DIR/.gems"

gem install ocran \
    --no-document \
    --install-dir "$DIST_DIR/.gems"

echo "OCRAN installed successfully."