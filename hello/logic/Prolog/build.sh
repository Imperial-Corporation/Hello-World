#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.pl"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Prolog source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v gplc >/dev/null 2>&1 || {
    echo "ERROR: gplc not found. Run install.sh first." >&2
    exit 1
}

gplc -o "$OUTPUT" "$SRC"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Prolog artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Prolog!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Prolog build complete: $OUTPUT"
