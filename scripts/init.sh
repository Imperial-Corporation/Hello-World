#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <language> <category>" >&2
    exit 1
fi

LANGUAGE="$1"
CATEGORY="$2"

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT/hello/$CATEGORY/$LANGUAGE"

if [[ ! "$LANGUAGE" =~ ^[A-Za-z0-9_+-]+$ ]]; then
    echo "ERROR: Invalid language name: $LANGUAGE" >&2
    exit 1
fi

if [[ ! "$CATEGORY" =~ ^[A-Za-z0-9_-]+$ ]]; then
    echo "ERROR: Invalid category: $CATEGORY" >&2
    exit 1
fi

if [[ -e "$TARGET" ]]; then
    echo "ERROR: Target already exists: $TARGET" >&2
    exit 1
fi

mkdir -p "$TARGET/x86_64/src" "$TARGET/arm64/src"

touch \
    "$TARGET/build.bat" \
    "$TARGET/build.sh" \
    "$TARGET/install.sh" \
    "$TARGET/install.bat"

chmod +x "$TARGET/build.sh" "$TARGET/install.sh"

echo "Initialized $LANGUAGE ($CATEGORY)"
echo "Location: $TARGET"
