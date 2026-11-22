#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="${HOME}/.nimble/bin:${PATH}"

if command -v nim >/dev/null 2>&1; then
    nim --version
    exit 0
fi

echo "Nim not found. Installing Nim..."

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: apt-get is unavailable." >&2
    exit 1
fi

# Repair an interrupted package configuration without upgrading the system.
if [[ "$(id -u)" -eq 0 ]]; then
    dpkg --configure -a || true
    apt-get install -y --no-upgrade nim gcc
elif command -v sudo >/dev/null 2>&1; then
    sudo dpkg --configure -a || true
    sudo apt-get install -y --no-upgrade nim gcc
else
    echo "ERROR: Root privileges are required." >&2
    exit 1
fi

export PATH="${HOME}/.nimble/bin:${PATH}"

if ! command -v nim >/dev/null 2>&1; then
    echo "ERROR: Nim is still unavailable after installation." >&2
    exit 1
fi

nim --version
echo "Nim installation complete."