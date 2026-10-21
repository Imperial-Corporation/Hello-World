#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Setting executable permissions..."

find "$ROOT/scripts" "$ROOT/hello" \
    -type f -name '*.sh' -exec chmod +x {} +

echo "Updating system packages..."

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y

elif command -v dnf >/dev/null 2>&1; then
    sudo dnf upgrade --refresh -y

elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu --noconfirm

elif command -v zypper >/dev/null 2>&1; then
    sudo zypper refresh
    sudo zypper update -y

elif command -v brew >/dev/null 2>&1; then
    brew update
    brew upgrade

else
    echo "Unsupported package manager." >&2
    exit 1
fi

echo "System update completed successfully."
