#!/usr/bin/env bash
set -Eeuo pipefail

# Kite (https://github.com/kite-language/kite) compiles to LLVM IR and needs clang.
# 1. the official installer is tried first;
# 2. if it fails (no release for this platform, network...), the compiler is built
#    from the sources of the repository with cargo.

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

have_kite() {
    command -v kite >/dev/null 2>&1 && command -v clang >/dev/null 2>&1
}

if have_kite; then
    echo "Kite toolchain is already available."
    exit 0
fi

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if ! command -v clang >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update || true
        $SUDO apt-get install -y --no-install-recommends clang libc6-dev || true
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y clang || true
    fi
fi

if ! command -v clang >/dev/null 2>&1; then
    echo "SKIP: clang is unavailable, Kite cannot produce executables." >&2
    exit 77
fi

if ! command -v kite >/dev/null 2>&1; then
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    echo "Trying the official Kite installer..."
    if curl -fsSL -o "$TMP/install.sh" https://kite-lang.pages.dev/install.sh \
        && sh "$TMP/install.sh"; then
        :
    else
        echo "Official installer failed."
    fi
fi

if ! command -v kite >/dev/null 2>&1; then
    echo "Building Kite from source..."
    if command -v cargo >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
        SRC_DIR="$TMP/kite"
        git clone --depth 1 https://github.com/kite-language/kite.git "$SRC_DIR"
        (cd "$SRC_DIR/archive/rust-stage0" && cargo build --release --bin kite)
        mkdir -p "$HOME/.local/bin"
        cp "$SRC_DIR/archive/rust-stage0/target/release/kite" "$HOME/.local/bin/kite"
    else
        echo "cargo and git are required to build Kite from source." >&2
    fi
fi

if ! have_kite; then
    echo "SKIP: the Kite compiler is still unavailable after installation." >&2
    exit 77
fi

echo "Kite installation complete: $(kite --version)"
