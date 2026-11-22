#!/usr/bin/env bash
set -Eeuo pipefail

have_toolchain() {
    command -v valac >/dev/null 2>&1 || return 1
    command -v gcc >/dev/null 2>&1 || return 1
    return 0
}

if have_toolchain; then
    echo "Vala toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update || true
    $SUDO apt-get install -y --no-install-recommends gcc libc6-dev valac libglib2.0-dev || true
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y gcc vala glib2-devel || true
else
    echo "SKIP: Unsupported package manager. Please install: Vala (valac) and GLib development files" >&2
    exit 77
fi

if ! have_toolchain; then
    echo "SKIP: Vala toolchain is still unavailable after installation." >&2
    exit 77
fi

echo "Vala installation complete."
