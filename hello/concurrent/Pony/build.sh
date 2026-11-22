#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.pony"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Pony source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export PATH="$HOME/.local/share/ponyup/bin:$PATH"

command -v ponyc >/dev/null 2>&1 || {
    echo "ERROR: ponyc not found. Run install.sh first." >&2
    exit 1
}

# ponyc compiles a directory: the executable is named after it.
mkdir -p "$WORK/hello"
cp -- "$SRC" "$WORK/hello/main.pony"
ponyc -o "$DIST_DIR" "$WORK/hello"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Pony artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Pony!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Pony build complete: $OUTPUT"
