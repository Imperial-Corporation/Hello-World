#!/usr/bin/env bash
set -Eeuo pipefail

OS="$(uname -s)"
RAW_ARCH="$(uname -m)"

case "$OS" in
    Linux)  OS_NAME="linux" ;;
    Darwin) OS_NAME="macos" ;;
    *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

case "$RAW_ARCH" in
    x86_64|amd64)       ARCH="x86_64" ;;
    aarch64|arm64)      ARCH="arm64" ;;
    armv7l|armv7*)      ARCH="armv7" ;;
    i386|i486|i586|i686) ARCH="x86" ;;
    riscv64)            ARCH="riscv64" ;;
    ppc64le)            ARCH="ppc64le" ;;
    s390x)              ARCH="s390x" ;;
    *)
        echo "Unsupported architecture: $RAW_ARCH" >&2
        exit 1
        ;;
esac

echo "OS=$OS_NAME"
echo "ARCH=$ARCH"
echo "TARGET=$OS_NAME-$ARCH"
