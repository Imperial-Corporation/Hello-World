#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.mod"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Modula-2 source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v gm2 >/dev/null 2>&1 || {
    echo "ERROR: gm2 not found. Run install.sh first." >&2
    exit 1
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp -- "$SRC" "$WORK/hello.mod"
(cd "$WORK" && gm2 -O2 -o "$OUTPUT" hello.mod)

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Modula-2 artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Modula-2!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Modula-2 build complete: $OUTPUT"
