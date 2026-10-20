#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${DIST_DIR:-}" ]]; then
    echo "ERROR: DIST_DIR is not set." >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64|amd64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)
        echo "ERROR: Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

SRC="${LANG_DIR}/${ARCH}/src/hello.m"
OUTPUT="${DIST_DIR}/hello"

[[ -f "$SRC" ]] || {
    echo "ERROR: Source not found: $SRC" >&2
    exit 1
}

mkdir -p "$DIST_DIR"

if command -v clang >/dev/null 2>&1; then
    COMPILER="$(command -v clang)"
elif command -v gcc >/dev/null 2>&1; then
    COMPILER="$(command -v gcc)"
else
    echo "ERROR: Clang or GCC is required." >&2
    exit 1
fi

echo "Compiler: $COMPILER"
"$COMPILER" -x objective-c "$SRC" -O2 -o "$OUTPUT"

if [[ ! -x "$OUTPUT" ]]; then
    echo "ERROR: Executable was not created." >&2
    exit 1
fi

echo "Objective-C build complete: $OUTPUT"
