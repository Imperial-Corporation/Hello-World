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

: "${DIST_DIR:?DIST_DIR must be set}"

SRC="$ARCH/src/hello.rs"
if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Rust source: $SRC" >&2
    exit 1
fi

RUSTC="$(command -v rustc || true)"
if [[ -z "$RUSTC" && -x "$HOME/.cargo/bin/rustc" ]]; then
    RUSTC="$HOME/.cargo/bin/rustc"
fi

if [[ -z "$RUSTC" ]]; then
    echo "ERROR: rustc not found. Run install.sh first." >&2
    exit 1
fi

mkdir -p "$DIST_DIR"
"$RUSTC" --edition=2021 -C opt-level=2 "$SRC" -o "$DIST_DIR/hello"

echo "Rust build complete."
