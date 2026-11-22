#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.lisp"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing LISP source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v sbcl >/dev/null 2>&1 || {
    echo "ERROR: sbcl not found. Run install.sh first." >&2
    exit 1
}

# Load the program, then dump the Lisp image as a standalone executable.
sbcl --noinform --non-interactive --no-sysinit --no-userinit \
    --load "$SRC" \
    --eval "(sb-ext:save-lisp-and-die \"$OUTPUT\" :executable t :toplevel (function main))"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: LISP artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from LISP!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "LISP build complete: $OUTPUT"
