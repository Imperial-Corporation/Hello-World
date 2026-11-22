#!/usr/bin/env bash
set -Eeuo pipefail

have_toolchain() {
    command -v sbcl >/dev/null 2>&1 || return 1
    return 0
}

if have_toolchain; then
    echo "LISP toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends sbcl
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y sbcl
else
    echo "ERROR: Unsupported package manager. Please install: SBCL (Common Lisp)" >&2
    exit 1
fi

if ! have_toolchain; then
    echo "ERROR: LISP toolchain is still unavailable after installation." >&2
    exit 1
fi

echo "LISP installation complete."
