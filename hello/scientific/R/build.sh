#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.R"
OUTPUT="$DIST_DIR/hello.R"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing R source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

cp -- "$SRC" "$OUTPUT"

chmod +x "$OUTPUT"

# The script is the deliverable; run it when R is available to make sure it works.
if command -v Rscript >/dev/null 2>&1; then
    if [[ "$(Rscript "$OUTPUT")" != "Hello from R!" ]]; then
        echo "ERROR: Unexpected output from $OUTPUT" >&2
        exit 1
    fi
fi

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: R artifact was not created: $OUTPUT" >&2
    exit 1
fi

echo "R build complete: $OUTPUT"
