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

SRC="$ARCH/src/hello.d"
: "${DIST_DIR:?DIST_DIR must be set by scripts/compile.sh}"

mkdir -p "$DIST_DIR"

if [[ ! -f "$SRC" ]]; then
    echo "Unsupported architecture or missing source: $SRC" >&2
    exit 1
fi

command -v ldc2 >/dev/null 2>&1 || {
    echo "LDC compiler (ldc2) not found." >&2
    exit 1
}

ldc2 -O2 -of="$DIST_DIR/hello" "$SRC"

echo "D build complete: $DIST_DIR/hello"
