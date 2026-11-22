#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.a68"
OUTPUT="$DIST_DIR/hello.a68"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing ALGOL-68 source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"


if command -v a68g >/dev/null 2>&1; then
    if [[ "$(timeout 30 a68g "$OUTPUT" </dev/null 2>&1)" != *"Hello from ALGOL 68!"* ]]; then
        echo "ERROR: Unexpected output from $OUTPUT" >&2
        exit 1
    fi
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: ALGOL-68 artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "ALGOL-68 build complete: $OUTPUT"
