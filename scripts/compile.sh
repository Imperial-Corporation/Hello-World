#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

OS_NAME=""
ARCH=""
TARGET=""

while IFS='=' read -r key value; do
    case "$key" in
        OS) OS_NAME="$value" ;;
        ARCH) ARCH="$value" ;;
        TARGET) TARGET="$value" ;;
    esac
done < <(bash "$ROOT/scripts/arch.sh")

if [[ -z "$ARCH" || -z "$TARGET" || -z "$OS_NAME" ]]; then
    echo "ERROR: Could not detect OS/architecture." >&2
    exit 1
fi

case "${OS_NAME,,}" in
    *linux*) PLATFORM="Linux"; EXT="" ;;
    *windows*|*mingw*|*msys*) PLATFORM="Windows"; EXT=".exe" ;;
    *)
        echo "ERROR: Unsupported OS: $OS_NAME" >&2
        exit 1
        ;;
esac

case "${ARCH,,}" in
    x86_64|amd64|x64) ARCH="x86_64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

DIST="$ROOT/dist"
WORK="$ROOT/.build-tmp"

rm -rf "$DIST" "$WORK"
mkdir -p "$DIST" "$WORK"

echo "Hello-World compiler"
echo "OS: $PLATFORM"
echo "Architecture: $ARCH"
echo "Target: $TARGET"

count=0

for lang_dir in "$ROOT"/hello/*/*; do
    [[ -d "$lang_dir" ]] || continue

    category="$(basename "$(dirname "$lang_dir")")"
    language="$(basename "$lang_dir")"

    if [[ ! -d "$lang_dir/$ARCH" ]]; then
        echo "SKIP: $category/$language ($ARCH not supported)"
        continue
    fi

    if [[ ! -f "$lang_dir/build.sh" ]]; then
        echo "ERROR: Missing build.sh in $lang_dir" >&2
        exit 1
    fi

    BUILD_DIR="$WORK/$category/$language"
    mkdir -p "$BUILD_DIR"
    export DIST_DIR="$BUILD_DIR"

    echo
    echo "Building $category/$language"

    pushd "$lang_dir" >/dev/null

    if [[ -f install.sh ]]; then
        bash ./install.sh
    fi

    bash ./build.sh

    popd >/dev/null

    # Only collect native executable files, not object files or sources.
    mapfile -t outputs < <(
        find "$BUILD_DIR" -maxdepth 1 -type f -executable \
            ! -name '*.o' \
            ! -name '*.obj' \
            ! -name '*.sh' \
            ! -name '*.py' \
            ! -name '*.rs' \
            ! -name '*.c' \
            ! -name '*.d' \
            ! -name '*.sha256' \
            ! -name '*.spec' \
            -print
    )

    if [[ "${#outputs[@]}" -ne 1 ]]; then
        echo "ERROR: Expected exactly one executable for $language; found ${#outputs[@]}." >&2
        find "$BUILD_DIR" -maxdepth 2 -type f -print >&2
        exit 1
    fi

    output_name="hello-${language}-${ARCH}-${PLATFORM}${EXT}"
    cp -- "${outputs[0]}" "$DIST/$output_name"
    chmod +x "$DIST/$output_name"

    echo "Created: $output_name"
    count=$((count + 1))
done

if [[ "$count" -eq 0 ]]; then
    echo "ERROR: No compatible language found for $ARCH." >&2
    exit 1
fi

rm -rf "$WORK"

echo
echo "Compilation complete: $count executable(s)."
echo "Release files: $DIST/"
