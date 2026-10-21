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

LIBRUBY_NAME="$(ruby -rrbconfig -e 'print RbConfig::CONFIG["LIBRUBY_SO"]')"
EXPECTED="/usr/lib/$LIBRUBY_NAME"

if [[ ! -e "$EXPECTED" ]]; then
    LIBRUBY_PATH="$(ldconfig -p | awk -v name="$LIBRUBY_NAME" '
        index($0, name) { print $NF; exit }
    ')"

    if [[ -z "$LIBRUBY_PATH" || ! -e "$LIBRUBY_PATH" ]]; then
        echo "ERROR: Cannot locate $LIBRUBY_NAME." >&2
        ldconfig -p | grep libruby || true
        exit 1
    fi

    echo "Ruby library found at: $LIBRUBY_PATH"
    sudo ln -s "$LIBRUBY_PATH" "$EXPECTED"
fi

ocran "$SOURCE" --output "$OUTPUT"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: OCRAN did not produce the expected executable: $OUTPUT" >&2
    exit 1
fi

chmod +x "$OUTPUT"
echo "Built Ruby executable: $OUTPUT"