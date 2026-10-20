#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

export PATH="${HOME}/.nimble/bin:${PATH}"

: "${DIST_DIR:?DIST_DIR must be set by scripts/compile.sh}"

ARCH="$(
    bash "$ROOT/scripts/arch.sh" |
    sed -n 's/^ARCH=//p'
)"

SRC="$LANG_DIR/$ARCH/src/hello.nim"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Nim source: $SRC" >&2
    exit 1
fi

if ! command -v nim >/dev/null 2>&1; then
    echo "ERROR: Nim is not installed or not in PATH." >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

nim c \
    --hints:off \
    --warnings:off \
    --opt:speed \
    --out:"$OUTPUT" \
    "$SRC"

echo "Nim build complete: $OUTPUT"
