#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.sh"
OUTPUT="$DIST_DIR/hello.sh"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Shell source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"

chmod +x "$OUTPUT"

if [[ "$(sh "$OUTPUT")" != "Hello from Shell!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Shell artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "Shell build complete: $OUTPUT"
