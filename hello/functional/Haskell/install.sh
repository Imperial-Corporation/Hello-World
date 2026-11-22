#!/usr/bin/env bash
set -Eeuo pipefail

have_toolchain() {
    command -v ghc >/dev/null 2>&1 || return 1
    return 0
}

if have_toolchain; then
    echo "Haskell toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends ghc
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y ghc
else
    echo "ERROR: Unsupported package manager. Please install: GHC (Haskell)" >&2
    exit 1
fi

if ! have_toolchain; then
    echo "ERROR: Haskell toolchain is still unavailable after installation." >&2
    exit 1
fi

echo "Haskell installation complete."
