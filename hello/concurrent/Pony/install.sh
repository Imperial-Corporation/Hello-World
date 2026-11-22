#!/usr/bin/env bash
set -Eeuo pipefail

# Pony: ponyc comes from the distribution when available, otherwise from ponyup,
# the official toolchain installer. The language is skipped when neither works.

export PATH="$HOME/.local/share/ponyup/bin:$PATH"

if command -v ponyc >/dev/null 2>&1; then
    echo "Pony toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update || true
    $SUDO apt-get install -y --no-install-recommends ponyc || true
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y ponyc || true
fi

if ! command -v ponyc >/dev/null 2>&1; then
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    echo "Installing ponyc with ponyup..."
    if curl --proto '=https' --tlsv1.2 -fsSL \
        https://raw.githubusercontent.com/ponylang/ponyup/latest-release/ponyup-init.sh \
        -o "$TMP/ponyup-init.sh" \
        && sh "$TMP/ponyup-init.sh"; then
        ponyup update ponyc release || true
    fi
fi

if ! command -v ponyc >/dev/null 2>&1; then
    echo "SKIP: ponyc is unavailable on this runner." >&2
    exit 77
fi

echo "Pony installation complete."
