#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"

eval "$(
    bash "$ROOT/scripts/arch.sh" |
    while IFS='=' read -r key value; do
        case "$key" in
            ARCH|TARGET) printf 'export %s=%q\n' "$key" "$value" ;;
        esac
    done
)"

SRC="$ARCH/src/hello.c"
: "${DIST_DIR:?DIST_DIR must be set by scripts/compile.sh}"

mkdir -p "$DIST_DIR"

if [[ ! -f "$SRC" ]]; then
    echo "Unsupported architecture or missing source: $SRC" >&2
    exit 1
fi

if command -v clang >/dev/null 2>&1; then
    CC=clang
elif command -v gcc >/dev/null 2>&1; then
    CC=gcc
else
    echo "No C compiler found." >&2
    exit 1
fi

"$CC" "$SRC" -O2 -Wall -Wextra -o "$DIST_DIR/hello"
echo "C build complete: $DIST_DIR/hello"
