#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.bas"
OUTPUT="$DIST_DIR/hello.bas"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing BASIC source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"


if command -v bwbasic >/dev/null 2>&1; then
    if [[ "$(timeout 30 bwbasic "$OUTPUT" </dev/null 2>&1)" != *"Hello from BASIC!"* ]]; then
        echo "ERROR: Unexpected output from $OUTPUT" >&2
        exit 1
    fi
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: BASIC artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "BASIC build complete: $OUTPUT"
