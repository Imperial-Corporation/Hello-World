#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.vala"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Vala source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v valac >/dev/null 2>&1 || {
    echo "ERROR: valac not found. Run install.sh first." >&2
    exit 1
}

command -v gcc >/dev/null 2>&1 || {
    echo "ERROR: gcc not found. Run install.sh first." >&2
    exit 1
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp -- "$SRC" "$WORK/hello.vala"
(cd "$WORK" && valac -o "$OUTPUT" hello.vala)

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Vala artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Vala!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Vala build complete: $OUTPUT"
