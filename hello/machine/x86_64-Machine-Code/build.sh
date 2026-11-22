#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

if [[ "$ARCH" != "x86_64" ]]; then
    echo "SKIP: x86_64-Machine-Code is only available on x86_64 (current: $ARCH)." >&2
    exit 77
fi

SRC="$LANG_DIR/$ARCH/src/hello.mc"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing x86_64-Machine-Code source: $SRC" >&2
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

# Minimal ELF64 wrapper: ELF header (64 bytes) + one program header (56 bytes).
BASE=$((0x400000))
HEADERS=120
FILESZ=$((HEADERS + ${#CODE[@]}))

{
    printf '\x7fELF'
    byte 2; byte 1; byte 1; byte 0       # 64-bit, little endian, version 1, System V
    le 0 8                               # padding
    le 2 2                               # e_type: ET_EXEC
    le 62 2                              # e_machine: EM_X86_64
    le 1 4                               # e_version
    le $((BASE + HEADERS)) 8             # e_entry
    le 64 8                              # e_phoff
    le 0 8                               # e_shoff
    le 0 4                               # e_flags
    le 64 2                              # e_ehsize
    le 56 2                              # e_phentsize
    le 1 2                               # e_phnum
    le 0 2; le 0 2; le 0 2               # section header fields (unused)
    le 1 4                               # p_type: PT_LOAD
    le 5 4                               # p_flags: R + X
    le 0 8                               # p_offset
    le "$BASE" 8                         # p_vaddr
    le "$BASE" 8                         # p_paddr
    le "$FILESZ" 8                       # p_filesz
    le "$FILESZ" 8                       # p_memsz
    le 4096 8                            # p_align
    raw "${CODE[@]}"
} > "$OUTPUT"

chmod +x "$OUTPUT"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: x86_64-Machine-Code artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from x86_64 Machine Code!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "x86_64-Machine-Code build complete: $OUTPUT"
