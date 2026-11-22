#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.adb"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Ada source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v gnatmake >/dev/null 2>&1 || {
    echo "ERROR: gnatmake not found. Run install.sh first." >&2
    exit 1
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp -- "$SRC" "$WORK/hello.adb"
(cd "$WORK" && gnatmake -q -O2 -o "$OUTPUT" hello.adb)

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Ada artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Ada!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Ada build complete: $OUTPUT"
