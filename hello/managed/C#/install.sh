#!/usr/bin/env bash
set -Eeuo pipefail

if command -v dotnet >/dev/null 2>&1; then
    dotnet --version
    exit 0
fi

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "ERROR: Automatic installation is supported only on Linux." >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required." >&2
    exit 1
fi

INSTALL_DIR="${HOME}/.dotnet"
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
bash /tmp/dotnet-install.sh --channel 10.0 --install-dir "$INSTALL_DIR"

export DOTNET_ROOT="$INSTALL_DIR"
export PATH="$INSTALL_DIR:$PATH"

dotnet --version
