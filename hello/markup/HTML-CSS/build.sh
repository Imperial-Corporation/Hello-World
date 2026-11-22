#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.html"
OUTPUT="$DIST_DIR/hello.html"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing HTML-CSS source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"


if ! grep -q '<h1>Hello from HTML/CSS!</h1>' "$OUTPUT"; then
    echo "ERROR: Unexpected content in $OUTPUT" >&2
    exit 1
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: HTML-CSS artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "HTML-CSS build complete: $OUTPUT"
