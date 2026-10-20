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

if [[ -z "$ARCH" || -z "$TARGET" ]]; then
    echo "ERROR: Could not detect system architecture." >&2
    exit 1
fi

echo "========================================"
echo " Hello-World compiler"
echo " OS: $OS_NAME"
echo " Architecture: $ARCH"
echo " Target: $TARGET"
echo "========================================"

rm -rf "$ROOT/dist"
mkdir -p "$ROOT/dist"

count=0

for lang_dir in "$ROOT"/hello/*/*; do
    [[ -d "$lang_dir" ]] || continue

    category="$(basename "$(dirname "$lang_dir")")"
    language="$(basename "$lang_dir")"

    # Skip languages without a directory for this architecture.
    if [[ ! -d "$lang_dir/$ARCH" ]]; then
        echo "SKIP: $category/$language ($ARCH not supported)"
        continue
    fi

    if [[ ! -f "$lang_dir/build.sh" ]]; then
        echo "ERROR: Missing build.sh in $lang_dir" >&2
        exit 1
    fi

    export DIST_DIR="$ROOT/dist/$category/$language/$TARGET"
    mkdir -p "$DIST_DIR"

    echo
    echo "========================================"
    echo " Building: $category/$language"
    echo " Output: $DIST_DIR"
    echo "========================================"

    cd "$lang_dir"

    if [[ -f install.sh ]]; then
        bash ./install.sh
    fi

    bash ./build.sh

    count=$((count + 1))
done

if [[ "$count" -eq 0 ]]; then
    echo "ERROR: No compatible language was found for $ARCH." >&2
    exit 1
fi

echo
echo "Compilation complete: $count language(s) processed."
echo "Artifacts: $ROOT/dist/"
