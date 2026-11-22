#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

if [[ "$ARCH" != "x86_64" ]]; then
    echo "SKIP: x86_64-Assembly is only available on x86_64 (current: $ARCH)." >&2
    exit 77
fi

SRC="$LANG_DIR/$ARCH/src/hello.asm"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing x86_64-Assembly source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v nasm >/dev/null 2>&1 || {
    echo "ERROR: nasm not found. Run install.sh first." >&2
    exit 1
}

command -v ld >/dev/null 2>&1 || {
    echo "ERROR: ld not found. Run install.sh first." >&2
    exit 1
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

nasm -f elf64 -o "$WORK/hello.o" "$SRC"
ld -o "$OUTPUT" "$WORK/hello.o"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: x86_64-Assembly artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from x86_64 Assembly!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "x86_64-Assembly build complete: $OUTPUT"
