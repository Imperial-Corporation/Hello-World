#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

if [[ "$ARCH" != "x86_64" ]]; then
    echo "SKIP: x86_64-Binary is only available on x86_64 (current: $ARCH)." >&2
    exit 77
fi

SRC="$LANG_DIR/$ARCH/src/hello.hex"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing x86_64-Binary source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

# Parse the annotated hex text: "#" starts a comment, every other word is a byte.
CODE=()
set -f
while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    for token in $line; do
        if [[ ! "$token" =~ ^[0-9A-Fa-f]{2}$ ]]; then
            echo "ERROR: Invalid hex byte '$token' in $SRC" >&2
            exit 1
        fi
        CODE+=("$token")
    done
done < "$SRC"
set +f

if [[ "${#CODE[@]}" -eq 0 ]]; then
    echo "ERROR: No bytes found in $SRC" >&2
    exit 1
fi

byte() { printf "\\x$(printf '%02x' "$1")"; }
le() {
    local value="$1" size="$2" i
    for ((i = 0; i < size; i++)); do
        byte $(( (value >> (8 * i)) & 0xff ))
    done
}
raw() {
    local b
    for b in "$@"; do
        printf "\\x$b"
    done
}

raw ${CODE[@]+"${CODE[@]}"} > "$OUTPUT"
chmod +x "$OUTPUT"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: x86_64-Binary artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from x86_64 Binary!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "x86_64-Binary build complete: $OUTPUT"
