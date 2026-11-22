#!/usr/bin/env bash
set -Eeuo pipefail

have_toolchain() {
    command -v gfortran >/dev/null 2>&1 || return 1
    return 0
}

if have_toolchain; then
    echo "Fortran-Fixed toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends gfortran
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y gcc-gfortran libgfortran-static
else
    echo "ERROR: Unsupported package manager. Please install: gfortran (with its static runtime)" >&2
    exit 1
fi

if ! have_toolchain; then
    echo "ERROR: Fortran-Fixed toolchain is still unavailable after installation." >&2
    exit 1
fi

echo "Fortran-Fixed installation complete."
