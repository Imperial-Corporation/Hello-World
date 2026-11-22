#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.f90"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Fortran-Free source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v gfortran >/dev/null 2>&1 || {
    echo "ERROR: gfortran not found. Run install.sh first." >&2
    exit 1
}

gfortran -ffree-form -O2 -static-libgfortran -static-libgcc -o "$OUTPUT" "$SRC"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Fortran-Free artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Fortran Free!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Fortran-Free build complete: $OUTPUT"
