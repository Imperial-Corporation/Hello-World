#!/usr/bin/env bash
set -Eeuo pipefail

have_toolchain() {
    command -v php >/dev/null 2>&1 || return 1
    php -r 'exit(class_exists("Phar") ? 0 : 1);' || return 1
    return 0
}

if have_toolchain; then
    echo "PHP toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends php-cli
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y php-cli
else
    echo "ERROR: Unsupported package manager. Please install: PHP CLI" >&2
    exit 1
fi

if ! have_toolchain; then
    echo "ERROR: PHP toolchain is still unavailable after installation." >&2
    exit 1
fi

echo "PHP installation complete."
