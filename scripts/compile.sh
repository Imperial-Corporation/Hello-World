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
    *linux*) PLATFORM="Linux" ;;
    *windows*|*mingw*|*msys*) PLATFORM="Windows" ;;
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

is_intermediate() {
    case "${1,,}" in
        *.o|*.obj|*.pdb|*.ilk|*.exp|*.lib|*.map|*.tmp|*.class)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

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
    export ARCH

    echo
    echo "Building $category/$language"

    pushd "$lang_dir" >/dev/null
    if [[ -f install.sh ]]; then
        bash ./install.sh
    fi
    bash ./build.sh
    popd >/dev/null

    mapfile -d '' -t all_files < <(
        find "$BUILD_DIR" -mindepth 1 -maxdepth 1 -type f -print0
    )

    outputs=()
    for file in "${all_files[@]}"; do
        if ! is_intermediate "$(basename "$file")"; then
            outputs+=("$file")
        fi
    done

    # If every file has an intermediate extension, allow a sole file.
    if [[ "${#outputs[@]}" -eq 0 && "${#all_files[@]}" -eq 1 ]]; then
        outputs=("${all_files[0]}")
    fi

    if [[ "${#outputs[@]}" -ne 1 ]]; then
        echo "ERROR: Expected exactly one final artifact for $language; found ${#outputs[@]}." >&2
        find "$BUILD_DIR" -maxdepth 2 -type f -print >&2
        exit 1
    fi

    artifact="${outputs[0]}"
    filename="$(basename "$artifact")"
    extension=""

    if [[ "$filename" == *.* && "$filename" != .* ]]; then
        extension=".${filename##*.}"
    fi

    output_name="hello-${language}-${ARCH}-${PLATFORM}${extension}"
    cp -- "$artifact" "$DIST/$output_name"

    if [[ -z "$extension" ]]; then
        chmod +x "$DIST/$output_name"
    fi

    echo "Created: $output_name"
    count=$((count + 1))
done

if [[ "$count" -eq 0 ]]; then
    echo "ERROR: No compatible language found for $ARCH." >&2
    exit 1
fi

rm -rf "$WORK"

echo
echo "Compilation complete: $count artifact(s)."
echo "Release files: $DIST/"
