#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.lua"
OUTPUT="$DIST_DIR/hello.lua"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Lua source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"

chmod +x "$OUTPUT"

if command -v lua5.4 >/dev/null 2>&1; then
    if [[ "$(timeout 30 lua5.4 "$OUTPUT" </dev/null 2>&1)" != *"Hello from Lua!"* ]]; then
        echo "ERROR: Unexpected output from $OUTPUT" >&2
        exit 1
    fi
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Lua artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "Lua build complete: $OUTPUT"
