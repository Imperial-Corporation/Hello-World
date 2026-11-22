#!/usr/bin/env bash
set -Eeuo pipefail

if command -v rustc >/dev/null 2>&1; then
    rustc --version
    exit 0
fi

if [[ -x "$HOME/.cargo/bin/rustc" ]]; then
    "$HOME/.cargo/bin/rustc" --version
    exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required to install Rust." >&2
    exit 1
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
    sh -s -- -y --profile minimal

if [[ ! -x "$HOME/.cargo/bin/rustc" ]]; then
    echo "ERROR: Rust installation failed." >&2
    exit 1
fi

"$HOME/.cargo/bin/rustc" --version
