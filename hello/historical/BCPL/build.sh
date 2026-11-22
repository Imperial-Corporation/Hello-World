#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.b"
OUTPUT="$DIST_DIR/hello.b"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing BCPL source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"


if ! grep -q 'Hello from BCPL!' "$OUTPUT"; then
    echo "ERROR: Unexpected content in $OUTPUT" >&2
    exit 1
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: BCPL artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "BCPL build complete: $OUTPUT"
