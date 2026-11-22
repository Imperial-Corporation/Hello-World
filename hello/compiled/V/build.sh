#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

V_DIR="$DIST_DIR/.vlang"
OUTPUT="$DIST_DIR/hello"

case "${ARCH:-x86_64}" in
    x86_64|amd64)
        SOURCE="$ROOT/x86_64/src/hello.v"
        ;;
    arm64|aarch64)
        SOURCE="$ROOT/arm64/src/hello.v"
        ;;
    *)
        echo "ERROR: Unsupported architecture: ${ARCH:-unknown}" >&2
        exit 1
        ;;
esac

if [[ ! -x "$V_DIR/v" ]]; then
    echo "ERROR: V compiler not found. Run install.sh first." >&2
    exit 1
fi

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source file not found: $SOURCE" >&2
    exit 1
fi

"$V_DIR/v" -o "$OUTPUT" "$SOURCE"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: V executable was not created." >&2
    exit 1
fi

chmod +x "$OUTPUT"
echo "Built V executable: $OUTPUT"