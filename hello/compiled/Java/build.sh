#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

if [[ "${ARCH:-x86_64}" == "arm64" ]]; then
    SRC_DIR="$ROOT/arm64/src"
else
    SRC_DIR="$ROOT/x86_64/src"
fi

SOURCE="$SRC_DIR/Hello.java"

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source file not found: $SOURCE" >&2
    exit 1
fi

command -v javac >/dev/null 2>&1 || {
    echo "ERROR: javac not found." >&2
    exit 1
}

command -v jar >/dev/null 2>&1 || {
    echo "ERROR: jar not found." >&2
    exit 1
}

mkdir -p "$DIST_DIR/classes"

javac -d "$DIST_DIR/classes" "$SOURCE"

(
    cd "$DIST_DIR/classes"
    jar --create \
        --file "$DIST_DIR/hello-java.jar" \
        --main-class Hello \
        .
)

echo "Built: $DIST_DIR/hello-java.jar"