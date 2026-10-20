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

: "${DIST_DIR:?DIST_DIR must be set by scripts/compile.sh}"

SRC="$(dirname -- "${BASH_SOURCE[0]}")/$ARCH/src/hello.go"
OUTPUT="$DIST_DIR/hello"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing Go source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

GOOS="$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^OS=//p')"
case "$GOOS" in
    linux)  export GOOS=linux ;;
    macos)  export GOOS=darwin ;;
    windows) export GOOS=windows; OUTPUT="$DIST_DIR/hello.exe" ;;
    *) echo "ERROR: Unsupported OS: $GOOS" >&2; exit 1 ;;
esac

case "$ARCH" in
    x86_64) export GOARCH=amd64 ;;
    x86) export GOARCH=386 ;;
    arm64) export GOARCH=arm64 ;;
    armv7) export GOARCH=arm ;;
    riscv64) export GOARCH=riscv64 ;;
    ppc64le) export GOARCH=ppc64le ;;
    s390x) export GOARCH=s390x ;;
    *) echo "ERROR: Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o "$OUTPUT" "$SRC"

echo "Go build complete: $OUTPUT"
