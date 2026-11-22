#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v bun >/dev/null 2>&1 && [[ ! -x "$HOME/.bun/bin/bun" ]]; then
    command -v curl >/dev/null 2>&1 || {
        echo "ERROR: curl is required to install Bun." >&2
        exit 1
    }

    echo "Installing Bun..."
    curl -fsSL https://bun.com/install | bash
fi

export PATH="$HOME/.bun/bin:$PATH"

command -v bun >/dev/null 2>&1 || {
    echo "ERROR: Bun installation failed." >&2
    exit 1
}

bun --version