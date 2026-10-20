#!/usr/bin/env bash
set -Eeuo pipefail

if command -v clang >/dev/null 2>&1; then
    clang --version
elif command -v gcc >/dev/null 2>&1; then
    gcc --version
else
    echo "ERROR: Install Clang or GCC with Objective-C support." >&2
    exit 1
fi

echo "Checking Objective-C runtime..."

if command -v clang >/dev/null 2>&1; then
    if printf 'int main(void) { return 0; }\n' |
        clang -x objective-c -fsyntax-only - >/dev/null 2>&1; then
        echo "Objective-C compiler is ready."
        exit 0
    fi
fi

if command -v gcc >/dev/null 2>&1; then
    if printf 'int main(void) { return 0; }\n' |
        gcc -x objective-c -fsyntax-only - >/dev/null 2>&1; then
        echo "Objective-C compiler is ready."
        exit 0
    fi
fi

echo "ERROR: No working Objective-C compiler found." >&2
exit 1
