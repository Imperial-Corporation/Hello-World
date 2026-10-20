#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="${HOME}/.nimble/bin:${PATH}"

if command -v nim >/dev/null 2>&1; then
    nim --version
    exit 0
fi

echo "Nim not found. Installing Nim from Ubuntu packages..."

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: Automatic installation requires apt-get." >&2
    exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
    apt-get update
    apt-get install -y nim gcc
elif command -v sudo >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y nim gcc
else
    echo "ERROR: Root privileges are required to install Nim." >&2
    exit 1
fi

export PATH="${HOME}/.nimble/bin:${PATH}"

if ! command -v nim >/dev/null 2>&1; then
    echo "ERROR: Nim installation failed." >&2
    exit 1
fi

nim --version
echo "Nim installation complete."