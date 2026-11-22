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

gplc --version 2>&1 | head -n 2 || true

if ! gplc -o "$OUTPUT" "$SRC"; then
    echo "ERROR: gplc failed on $ARCH." >&2
    if [[ "$ARCH" == "arm64" ]]; then
        # The GNU Prolog packaged by some distributions cannot compile natively on arm64.
        echo "SKIP: Prolog is not available on arm64 with this GNU Prolog." >&2
        exit 77
    fi
    exit 1
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Prolog artifact was not created: $OUTPUT" >&2
    exit 1
fi
ACTUAL="$(timeout 30 "$OUTPUT" </dev/null 2>&1 || true)"
if [[ "$ACTUAL" != "Hello from Prolog!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT: $ACTUAL" >&2
    if [[ "$ARCH" == "arm64" ]]; then
        echo "SKIP: Prolog does not run correctly on arm64 with this GNU Prolog." >&2
        exit 77
    fi
    exit 1
fi

echo "Prolog build complete: $OUTPUT"
