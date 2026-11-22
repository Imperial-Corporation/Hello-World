#!/usr/bin/env bash
set -Eeuo pipefail

have_toolchain() {
    command -v gnatmake >/dev/null 2>&1 || return 1
    return 0
}

if have_toolchain; then
    echo "Ada toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends gnat
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y gcc-gnat
else
    echo "ERROR: Unsupported package manager. Please install: GNAT (Ada)" >&2
    exit 1
fi

if ! have_toolchain; then
    echo "ERROR: Ada toolchain is still unavailable after installation." >&2
    exit 1
fi

echo "Ada installation complete."
