#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"

eval "$(
    bash "$ROOT/scripts/arch.sh" |
    while IFS='=' read -r key value; do
        case "$key" in
            ARCH) printf 'export ARCH=%q\n' "$value" ;;
        esac
    done
)"

: "${DIST_DIR:?DIST_DIR must be set by scripts/compile.sh}"

SRC="$ARCH/src/hello.cpp"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing C++ source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

if command -v clang++ >/dev/null 2>&1; then
    CXX=clang++
elif command -v g++ >/dev/null 2>&1; then
    CXX=g++
else
    echo "ERROR: No C++ compiler found." >&2
    exit 1
fi

"$CXX" -std=c++17 -O2 -Wall -Wextra "$SRC" -o "$OUTPUT"

echo "C++ build complete: $OUTPUT"
