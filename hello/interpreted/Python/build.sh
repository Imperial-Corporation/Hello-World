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

SRC="$ARCH/src/hello.py"
: "${DIST_DIR:?DIST_DIR must be set by scripts/compile.sh}"

mkdir -p "$DIST_DIR"

if [[ ! -f "$SRC" ]]; then
    echo "Unsupported architecture or missing source: $SRC" >&2
    exit 1
fi

python3 -m PyInstaller \
    --onefile \
    --clean \
    --noconfirm \
    --name hello \
    --distpath "$DIST_DIR" \
    --workpath "$(mktemp -d)" \
    --specpath "$(mktemp -d)" \
    "$SRC"

echo "Python executable built in: $DIST_DIR"
