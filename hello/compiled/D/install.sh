#!/usr/bin/env bash
set -Eeuo pipefail

case "$(uname -s)" in
    Linux)
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y ldc
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y ldc
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm ldc
        else
            echo "Unsupported package manager for LDC." >&2
            exit 1
        fi
        ;;
    Darwin)
        command -v brew >/dev/null 2>&1 || {
            echo "Homebrew is required to install LDC." >&2
            exit 1
        }
        brew install ldc
        ;;
    *)
        echo "Unsupported OS." >&2
        exit 1
        ;;
esac
