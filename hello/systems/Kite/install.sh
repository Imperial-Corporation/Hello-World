#!/usr/bin/env bash
set -Eeuo pipefail

# Kite (https://github.com/kite-language/kite) compiles to LLVM IR and needs clang.
#
# 1. The official installer is used first (https://kite-lang.pages.dev/install.sh).
# 2. The installed compiler is then tested for real by building a tiny program. If it
#    does not work (or the installer failed), the compiler is built from the sources
#    of the repository with cargo, and the default pieces (std.*) are installed too.
# 3. The language is skipped (exit code 77) when nothing works.

BIN_DIR="$HOME/.local/bin"
KITE_HOME_DIR="${KITE_HOME:-$HOME/.kite}"
export PATH="$BIN_DIR:$HOME/.cargo/bin:$PATH"

# Builds and runs a tiny program: proves that kite, its pieces and clang work together.
kite_works() {
    command -v kite >/dev/null 2>&1 || return 1
    command -v clang >/dev/null 2>&1 || return 1

    local dir out
    dir="$(mktemp -d)"
    mkdir -p "$dir/probe/src"
    printf 'make main():\n    print("probe")\n' > "$dir/probe/src/main.ki"
    cat > "$dir/probe/kite.toml" <<'TOML'
[package]
name = "probe"
version = "0.1.0"
edition = "2026"
TOML

    out="$(cd "$dir/probe" && kite build --release >&2 && ./target/probe 2>/dev/null)" || {
        rm -rf "$dir"
        return 1
    }
    rm -rf "$dir"
    [[ "$out" == "probe" ]]
}

if kite_works; then
    echo "Kite toolchain is already available: $(kite --version)"
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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Trying the official Kite installer..."
if curl -fsSL -o "$TMP/install.sh" https://kite-lang.pages.dev/install.sh \
    && sh "$TMP/install.sh" --no-modify-path; then
    :
else
    echo "Official installer failed." >&2
fi

if ! kite_works; then
    echo "The installed Kite does not work (or is missing): building it from source..." >&2

    if command -v cargo >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
        if git clone --depth 1 https://github.com/kite-language/kite.git "$TMP/kite" \
            && (cd "$TMP/kite/archive/rust-stage0" && cargo build --release --bin kite); then
            mkdir -p "$BIN_DIR" "$KITE_HOME_DIR"
            cp "$TMP/kite/archive/rust-stage0/target/release/kite" "$BIN_DIR/kite"
            rm -rf "$KITE_HOME_DIR/pieces"
            cp -R "$TMP/kite/pieces" "$KITE_HOME_DIR/pieces"
        else
            echo "Building Kite from source failed." >&2
        fi
    else
        echo "cargo and git are required to build Kite from source." >&2
    fi
fi

if ! kite_works; then
    echo "SKIP: the Kite compiler is still unusable after installation." >&2
    exit 77
fi

echo "Kite installation complete: $(kite --version)"
