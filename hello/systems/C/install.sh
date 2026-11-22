#!/usr/bin/env bash
set -Eeuo pipefail

OS="$(uname -s)"

case "$OS" in
    Linux)
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y build-essential
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y gcc
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm gcc
        else
            echo "No supported C compiler installation method." >&2
            exit 1
        fi
        ;;
    Darwin)
        if ! command -v clang >/dev/null 2>&1; then
            xcode-select --install || true
            echo "Install Xcode Command Line Tools if clang is unavailable."
        fi
        ;;
    *)
        echo "Unsupported OS: $OS" >&2
        exit 1
        ;;
esac
