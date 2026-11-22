#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.pas"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Pascal source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v fpc >/dev/null 2>&1 || {
    echo "ERROR: fpc not found. Run install.sh first." >&2
    exit 1
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Units and object files go to a temporary directory so that only the
# executable ends up in DIST_DIR.
fpc -O2 -Xs -FU"$WORK" -FE"$DIST_DIR" -ohello "$SRC"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Pascal artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Pascal!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Pascal build complete: $OUTPUT"
