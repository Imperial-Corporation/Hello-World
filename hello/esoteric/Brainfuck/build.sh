#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.bf"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Brainfuck source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Brainfuck has 8 commands: translate each one to C, then compile the result.
CC_BIN="${CC:-cc}"
command -v "$CC_BIN" >/dev/null 2>&1 || CC_BIN=gcc

{
    echo '#include <stdio.h>'
    echo 'static unsigned char tape[30000];'
    echo 'int main(void) {'
    echo '    unsigned char *p = tape;'
    while IFS= read -r -n1 ch; do
        case "$ch" in
            '+') echo '    ++*p;' ;;
            '-') echo '    --*p;' ;;
            '>') echo '    ++p;' ;;
            '<') echo '    --p;' ;;
            '.') echo '    putchar(*p);' ;;
            ',') echo '    { int c = getchar(); if (c != EOF) *p = (unsigned char)c; }' ;;
            '[') echo '    while (*p) {' ;;
            ']') echo '    }' ;;
        esac
    done < "$SRC"
    echo '    return 0;'
    echo '}'
} > "$WORK/hello.c"

"$CC_BIN" -O2 -o "$OUTPUT" "$WORK/hello.c"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Brainfuck artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Brainfuck!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Brainfuck build complete: $OUTPUT"
