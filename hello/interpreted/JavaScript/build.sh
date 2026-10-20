#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

export PATH="$HOME/.bun/bin:$PATH"

case "${ARCH:-x86_64}" in
    x86_64|amd64)
        SRC_DIR="$ROOT/x86_64/src"
        BUN_TARGET="bun-linux-x64"
        ;;
    arm64|aarch64)
        SRC_DIR="$ROOT/arm64/src"
        BUN_TARGET="bun-linux-arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: ${ARCH:-unknown}" >&2
        exit 1
        ;;
esac

SOURCE="$SRC_DIR/hello.js"

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source file not found: $SOURCE" >&2
    exit 1
fi

command -v bun >/dev/null 2>&1 || {
    echo "ERROR: Bun not found." >&2
    exit 1
}

bun build --compile --minify 
    --target="$BUN_TARGET" 
    "$SOURCE" 
    --outfile "$DIST_DIR/hello"

test -f "$DIST_DIR/hello" || {
    echo "ERROR: Compiled executable was not created." >&2
    exit 1
}

chmod +x "$DIST_DIR/hello"

echo "Built standalone executable: $DIST_DIR/hello"
