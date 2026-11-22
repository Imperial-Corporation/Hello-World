#!/usr/bin/env bash
set -Eeuo pipefail

for cmd in javac jar java; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: $cmd not found. Install a JDK 25 or compatible JDK." >&2
        exit 1
    fi
done

echo "Java toolchain found:"
java -version
javac -version