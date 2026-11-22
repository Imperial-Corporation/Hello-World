#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.ml"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing OCaml source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v ocamlopt >/dev/null 2>&1 || {
    echo "ERROR: ocamlopt not found. Run install.sh first." >&2
    exit 1
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp -- "$SRC" "$WORK/hello.ml"
ocamlopt -o "$OUTPUT" "$WORK/hello.ml"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: OCaml artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from OCaml!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "OCaml build complete: $OUTPUT"
