#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.tcl"
OUTPUT="$DIST_DIR/hello.tcl"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Tcl source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"

chmod +x "$OUTPUT"

if command -v tclsh >/dev/null 2>&1; then
    if [[ "$(timeout 30 tclsh "$OUTPUT" </dev/null 2>&1)" != *"Hello from Tcl!"* ]]; then
        echo "ERROR: Unexpected output from $OUTPUT" >&2
        exit 1
    fi
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Tcl artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "Tcl build complete: $OUTPUT"
