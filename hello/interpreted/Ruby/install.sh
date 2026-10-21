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

ruby -e '
  major, minor = RUBY_VERSION.split(".").map(&:to_i)
  abort "ERROR: Ruby 3.3 or newer is required; found #{RUBY_VERSION}" if
    major < 3 || (major == 3 && minor < 3)
'

gem install ocran --no-document --install-dir "$DIST_DIR/.gems"

echo "Ruby version: $(ruby --version)"
echo "OCRAN installed."