#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

case "${ARCH:-x86_64}" in
    x86_64|amd64)
        SOURCE="$ROOT/x86_64/src/hello.rb"
        ;;
    arm64|aarch64)
        SOURCE="$ROOT/arm64/src/hello.rb"
        ;;
    *)
        echo "ERROR: Unsupported architecture: ${ARCH:-unknown}" >&2
        exit 1
        ;;
esac

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Ruby source not found: $SOURCE" >&2
    exit 1
fi

echo "Ruby version: $(ruby --version)"
echo "Ruby shared libraries:"
ldconfig -p | grep -E 'libruby' || true

echo "ERROR: OCRAN cannot locate the exact libruby version required by this runner."
echo "A compatible Ruby runtime/package is needed before building a standalone executable." >&2
exit 1