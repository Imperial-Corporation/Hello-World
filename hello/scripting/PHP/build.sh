#!/usr/bin/env bash
set -Eeuo pipefail

LANG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$LANG_DIR/../../.." && pwd)"

: "${DIST_DIR:?ERROR: DIST_DIR must be set by scripts/compile.sh}"

ARCH="${ARCH:-$(bash "$ROOT/scripts/arch.sh" | sed -n 's/^ARCH=//p')}"

SRC="$LANG_DIR/$ARCH/src/hello.php"
OUTPUT="$DIST_DIR/hello.phar"

if [[ ! -f "$SRC" ]]; then
    echo "ERROR: Missing PHP source: $SRC" >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

command -v php >/dev/null 2>&1 || {
    echo "ERROR: php not found. Run install.sh first." >&2
    exit 1
}

# Package the script into a self-contained, executable PHAR archive.
php -d phar.readonly=0 -r '
$source = $argv[1];
$output = $argv[2];

if (file_exists($output)) {
    unlink($output);
}

$phar = new Phar($output);
$phar->startBuffering();
$phar->addFile($source, "hello.php");
$phar->setStub(
    "#!/usr/bin/env php\n<?php\n" .
    "Phar::mapPhar(\"hello.phar\");\n" .
    "require \"phar://hello.phar/hello.php\";\n" .
    "__HALT_COMPILER();\n"
);
$phar->stopBuffering();
' -- "$SRC" "$OUTPUT"

chmod +x "$OUTPUT"

if [[ ! -f "$OUTPUT" ]]; then
    echo "ERROR: PHP artifact was not created: $OUTPUT" >&2
    exit 1
fi
if [[ "$(php "$OUTPUT")" != "Hello from PHP!" ]]; then
    echo "ERROR: Unexpected output from $OUTPUT" >&2
    exit 1
fi

echo "PHP build complete: $OUTPUT"
