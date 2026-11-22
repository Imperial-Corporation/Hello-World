#!/usr/bin/env bash
set -Eeuo pipefail

if command -v go >/dev/null 2>&1; then
    go version
    exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: Go is missing. Install Go using your system package manager." >&2
    exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
    apt-get update
    apt-get install -y golang-go
elif command -v sudo >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y golang-go
else
    echo "ERROR: Installing Go requires root privileges." >&2
    exit 1
fi

go version
