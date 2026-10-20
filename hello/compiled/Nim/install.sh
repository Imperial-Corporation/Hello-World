#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="${HOME}/.nimble/bin:${PATH}"

if command -v nim >/dev/null 2>&1; then
    nim --version
    exit 0
fi

echo "Nim not found. Installing dependencies..."

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: Automatic installation supports Debian/Ubuntu only." >&2
    exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
    apt-get update
    apt-get install -y curl ca-certificates gcc
elif command -v sudo >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y curl ca-certificates gcc
else
    echo "ERROR: Root privileges are required." >&2
    exit 1
fi

export CHOOSENIM_NO_ANALYTICS=1

curl --fail --silent --show-error --location \
    https://nim-lang.org/choosenim/init.sh |
    sh -s -- -y

export PATH="${HOME}/.nimble/bin:${PATH}"

if ! command -v nim >/dev/null 2>&1; then
    echo "ERROR: Nim installation failed or is not in PATH." >&2
    exit 1
fi

nim --version
echo "Nim installation complete."
