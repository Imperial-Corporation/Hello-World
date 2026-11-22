#!/usr/bin/env bash
set -Eeuo pipefail

have_toolchain() {
    command -v gplc >/dev/null 2>&1 || return 1
    return 0
}

if have_toolchain; then
    echo "Prolog toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends gcc libc6-dev gprolog
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y gcc gprolog
else
    echo "ERROR: Unsupported package manager. Please install: GNU Prolog (gplc)" >&2
    exit 1
fi

if ! have_toolchain; then
    echo "ERROR: Prolog toolchain is still unavailable after installation." >&2
    exit 1
fi

echo "Prolog installation complete."
