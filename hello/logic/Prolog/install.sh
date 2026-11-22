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
    $SUDO apt-get update || true
    $SUDO apt-get install -y --no-install-recommends gcc libc6-dev gprolog || true
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y gcc gprolog || true
else
    echo "SKIP: Unsupported package manager. Please install: GNU Prolog (gplc)" >&2
    exit 77
fi

if ! have_toolchain; then
    echo "SKIP: Prolog toolchain is still unavailable after installation." >&2
    exit 77
fi

echo "Prolog installation complete."
