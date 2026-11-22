#!/usr/bin/env bash
set -Eeuo pipefail

if command -v clang++ >/dev/null 2>&1; then
    clang++ --version
    exit 0
fi

if command -v g++ >/dev/null 2>&1; then
    g++ --version
    exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: No C++ compiler found. Install clang++ or g++." >&2
    exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
    apt-get update
    apt-get install -y g++
elif command -v sudo >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y g++
else
    echo "ERROR: Installing g++ requires root or sudo." >&2
    exit 1
fi

g++ --version
