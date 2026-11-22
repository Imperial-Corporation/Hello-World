#!/usr/bin/env bash
set -Eeuo pipefail

# Linux builds use mruby: the script is compiled to bytecode, embedded in a tiny
# C program and linked statically against libmruby. The result is a standalone
# executable that does not need a Ruby runtime (Windows keeps using OCRAN).

CC_BIN="${CC:-cc}"

have_mruby() {
    command -v mrbc >/dev/null 2>&1 || return 1
    command -v "$CC_BIN" >/dev/null 2>&1 || return 1

    local lib
    lib="$("$CC_BIN" -print-file-name=libmruby.a 2>/dev/null || true)"
    [[ "$lib" == /* && -f "$lib" ]]
}

if have_mruby; then
    echo "mruby is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends gcc libc6-dev mruby libmruby-dev
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y gcc mruby mruby-devel
else
    echo "ERROR: Unsupported package manager. Install gcc, mruby and its development files." >&2
    exit 1
fi

if ! have_mruby; then
    echo "ERROR: mruby (mrbc and libmruby.a) is still unavailable after installation." >&2
    exit 1
fi

echo "mruby installation complete."
