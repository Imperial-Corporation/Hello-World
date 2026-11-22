#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.ki"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Kite source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

command -v kite >/dev/null 2>&1 || {
    echo "ERROR: kite not found. Run install.sh first." >&2
    exit 1
}
command -v clang >/dev/null 2>&1 || {
    echo "ERROR: clang not found (Kite compiles through LLVM IR and needs clang)." >&2
    exit 1
}

# kite builds projects: create a tiny one around the source file.
mkdir -p "$WORK/hello/src"
cp -- "$SRC" "$WORK/hello/src/main.ki"
cat > "$WORK/hello/kite.toml" <<'EOF'
[package]
name = "hello"
version = "0.1.0"
edition = "2026"

[build]
opt_level = 2
EOF

kite --version
clang --version | head -n1

(cd "$WORK/hello" && kite build --release)

# The output location depends on the Kite version: look for the executable.
BUILT=""
for candidate in "$WORK/hello/target/hello" "$WORK/hello/target/release/hello"; do
    if [[ -f "$candidate" && -x "$candidate" ]]; then
        BUILT="$candidate"
        break
    fi
done

if [[ -z "$BUILT" ]]; then
    echo "ERROR: kite did not produce the executable. Files under target/:" >&2
    find "$WORK/hello/target" -maxdepth 3 -print >&2 || true
    exit 1
fi

cp -- "$BUILT" "$OUTPUT"
chmod +x "$OUTPUT"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: Kite artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$("$OUTPUT")" != "Hello from Kite!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "Kite build complete: $OUTPUT"
