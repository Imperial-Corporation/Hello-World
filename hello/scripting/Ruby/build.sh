#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

case "$ARCH" in
    x86_64|arm64) ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

SOURCE="$LANG_DIR/$ARCH/src/hello.rb"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Ruby source not found: $SOURCE" >&2
    exit 1
fi

if command -v "${CC:-cc}" >/dev/null 2>&1; then
    CC_BIN="${CC:-cc}"
elif command -v gcc >/dev/null 2>&1; then
    CC_BIN=gcc
elif command -v clang >/dev/null 2>&1; then
    CC_BIN=clang
else
    echo "ERROR: No C compiler found. Run install.sh first." >&2
    exit 1
fi

if ! command -v mrbc >/dev/null 2>&1; then
    echo "ERROR: mrbc not found. Run install.sh first." >&2
    exit 1
fi

LIBMRUBY="$("$CC_BIN" -print-file-name=libmruby.a)"
if [[ "$LIBMRUBY" != /* || ! -f "$LIBMRUBY" ]]; then
    echo "ERROR: libmruby.a not found. Run install.sh first." >&2
    exit 1
fi

# The library was built with optional features that must also be enabled here.
MRUBY_DEFINES=()
if command -v mruby-config >/dev/null 2>&1; then
    while IFS= read -r flag; do
        MRUBY_DEFINES+=("$flag")
    done < <(mruby-config --cflags | tr ' ' '\n' | grep -E '^-DMRB_' || true)
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$DIST_DIR"

mrbc -Bhello_irep -o "$WORK/hello_irep.c" "$SOURCE"

cat > "$WORK/main.c" <<'EOF'
#include <stdint.h>
#include <mruby.h>
#include <mruby/irep.h>

extern const uint8_t hello_irep[];

int main(void) {
    mrb_state *mrb = mrb_open();
    int status = 0;

    if (mrb == NULL) {
        return 1;
    }

    mrb_load_irep(mrb, hello_irep);
    if (mrb->exc) {
        status = 1;
    }

    mrb_close(mrb);
    return status;
}
EOF

"$CC_BIN" -O2 ${MRUBY_DEFINES[@]+"${MRUBY_DEFINES[@]}"} \
    "$WORK/main.c" "$WORK/hello_irep.c" "$LIBMRUBY" -lm \
    -o "$OUTPUT"

if [[ ! -x "$OUTPUT" ]]; then
    echo "ERROR: Ruby executable was not created: $OUTPUT" >&2
    exit 1
fi

"$OUTPUT" >/dev/null

echo "Built Ruby (mruby) executable: $OUTPUT"
