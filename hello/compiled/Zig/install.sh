#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="0.15.2"
MACHINE="$(uname -m)"

case "$MACHINE" in
    x86_64|amd64)
        ARCH="x86_64"
        ;;
    aarch64|arm64)
        ARCH="aarch64"
        ;;
    *)
        echo "ERROR: Unsupported Linux architecture: $MACHINE" >&2
        exit 1
        ;;
esac

BASE_DIR="${HOME}/.cache/hello-world/zig/${VERSION}"
INSTALL_DIR="${BASE_DIR}/${ARCH}"
ARCHIVE="${BASE_DIR}/zig-${ARCH}-linux-${VERSION}.tar.xz"
URL="https://ziglang.org/download/${VERSION}/zig-${ARCH}-linux-${VERSION}.tar.xz"

mkdir -p "$BASE_DIR"

if [[ -x "${INSTALL_DIR}/zig" ]]; then
    "${INSTALL_DIR}/zig" version
    exit 0
fi

for command in curl tar; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $command" >&2
        exit 1
    fi
done

echo "Downloading Zig ${VERSION} for Linux ${ARCH}..."
curl --fail --location --retry 3 "$URL" --output "$ARCHIVE"

TEMP_DIR="$(mktemp -d "${BASE_DIR}/extract.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

tar -xJf "$ARCHIVE" -C "$TEMP_DIR"

EXTRACTED_DIR="${TEMP_DIR}/zig-${ARCH}-linux-${VERSION}"
if [[ ! -x "${EXTRACTED_DIR}/zig" ]]; then
    echo "ERROR: zig executable not found in downloaded archive." >&2
    exit 1
fi

mkdir -p "$INSTALL_DIR"
cp -a "${EXTRACTED_DIR}/." "$INSTALL_DIR/"
rm -f "$ARCHIVE"

"${INSTALL_DIR}/zig" version
echo "Zig installation completed: ${INSTALL_DIR}"
