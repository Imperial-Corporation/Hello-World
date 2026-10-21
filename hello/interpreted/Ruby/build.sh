#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

case "${ARCH:-x86_64}" in
    x86_64|amd64)
        SOURCE="$ROOT/x86_64/src/hello.rb"
        ;;
    arm64|aarch64)
        SOURCE="$ROOT/arm64/src/hello.rb"
        ;;
    *)
        echo "ERROR: Unsupported architecture: ${ARCH:-unknown}" >&2
        exit 1
        ;;
esac

GEM_BIN="$DIST_DIR/.gems/bin"
export GEM_HOME="$DIST_DIR/.gems"
export PATH="$GEM_BIN:$PATH"

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source not found: $SOURCE" >&2
    exit 1
fi

if ! command -v ocran >/dev/null 2>&1; then
    echo "ERROR: OCRAN not found. Run install.sh first." >&2
    exit 1
fi

OUTPUT="$DIST_DIR/hello"

ocran "$SOURCE" --output "$OUTPUT"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: OCRAN did not produce the expected executable: $OUTPUT" >&2
    exit 1
fi

chmod +x "$OUTPUT"
echo "Built Ruby executable: $OUTPUT"