#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="0.15.2"
LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "${LANG_DIR}/../../.." && pwd)"

if [[ -z "${DIST_DIR:-}" ]]; then
    echo "ERROR: DIST_DIR is not set." >&2
    exit 1
fi

MACHINE="$(uname -m)"
case "$MACHINE" in
    x86_64|amd64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)
        echo "ERROR: Unsupported Linux architecture: $MACHINE" >&2
        exit 1
        ;;
esac

SRC="${LANG_DIR}/${ARCH}/src/hello.zig"
ZIG="${HOME}/.cache/hello-world/zig/${VERSION}/$( [[ "$ARCH" == "arm64" ]] && echo aarch64 || echo x86_64 )/zig"
OUTPUT="${DIST_DIR}/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Source file not found: $SRC" >&2
    exit 1
fi

if [[ ! -x "$ZIG" ]]; then
    if command -v zig >/dev/null 2>&1; then
        ZIG="$(command -v zig)"
    else
        echo "ERROR: Zig ${VERSION} not found. Run install.sh first." >&2
        exit 1
    fi
fi

mkdir -p "$DIST_DIR"

echo "Using Zig: $("$ZIG" version)"
echo "Source: $SRC"
echo "Output: $OUTPUT"

"$ZIG" build-exe "$SRC" -O ReleaseFast -femit-bin="$OUTPUT"

if [[ ! -x "$OUTPUT" ]]; then
    echo "ERROR: Executable was not created: $OUTPUT" >&2
    exit 1
fi

echo "Zig build complete: $OUTPUT"
