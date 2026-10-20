#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: Python 3 is required." >&2
    exit 1
fi

python3 -m pip install --upgrade pyinstaller
echo "PyInstaller installed successfully."
