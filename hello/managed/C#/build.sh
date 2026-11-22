#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${DIST_DIR:-}" ]]; then
    echo "ERROR: DIST_DIR is not set." >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64|amd64) ARCH="x86_64"; RID="linux-x64" ;;
    aarch64|arm64) ARCH="arm64"; RID="linux-arm64" ;;
    *)
        echo "ERROR: Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

SRC="${LANG_DIR}/${ARCH}/src"
OUTPUT="${DIST_DIR}/hello"

if ! command -v dotnet >/dev/null 2>&1; then
    if [[ -x "${HOME}/.dotnet/dotnet" ]]; then
        export DOTNET_ROOT="${HOME}/.dotnet"
        export PATH="${DOTNET_ROOT}:${PATH}"
    else
        echo "ERROR: .NET SDK not found. Run install.sh first." >&2
        exit 1
    fi
fi

dotnet publish "$SRC/hello.csproj" \
    --configuration Release \
    --runtime "$RID" \
    --self-contained true \
    -p:UseAppHost=true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=false \
    --output "$OUTPUT.publish"

mkdir -p "$DIST_DIR"
cp "$OUTPUT.publish/hello" "$OUTPUT"
chmod +x "$OUTPUT"
rm -rf "$OUTPUT.publish"

echo "C# build complete: $OUTPUT"
