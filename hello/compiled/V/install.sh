#!/usr/bin/env bash
set -Eeuo pipefail

: "${DIST_DIR:?ERROR: DIST_DIR must be set by the central compile script}"

V_DIR="$DIST_DIR/.vlang"

command -v git >/dev/null 2>&1 || {
    echo "ERROR: git is required to install V." >&2
    exit 1
}

command -v make >/dev/null 2>&1 || {
    echo "ERROR: make is required to install V." >&2
    exit 1
}

if [[ ! -x "$V_DIR/v" ]]; then
    rm -rf "$V_DIR"
    git clone --depth=1 https://github.com/vlang/v.git "$V_DIR"
    make -C "$V_DIR"
fi

if [[ ! -x "$V_DIR/v" ]]; then
    echo "ERROR: V compiler installation failed." >&2
    exit 1
fi

"$V_DIR/v" version