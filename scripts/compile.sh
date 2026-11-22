#!/usr/bin/env bash
set -Eeuo pipefail

# Compiles every language found in hello/<category>/<language> for the current
# platform and copies one artifact per language into dist/.
#
# Per-language conventions:
#   - <arch>/ directory  : the language supports that architecture.
#   - unsupported.txt    : optional list of "<os>-<arch>" targets (for example
#                          "windows-arm64") that must be skipped.
#   - exit code 77       : install.sh / build.sh may exit with 77 to ask for the
#                          language to be skipped on this runner.
#
# Environment:
#   HELLO_LANGUAGES  optional comma-separated list of language names to build
#                    (for example HELLO_LANGUAGES=C,Rust), handy for local tests.
#
# A failing language does not stop the run: every language is attempted and a
# summary of the failures is printed at the end (the exit code is then 1).

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

SKIP_CODE=77

OS_NAME=""
ARCH=""
TARGET=""

while IFS='=' read -r key value; do
    case "$key" in
        OS) OS_NAME="$value" ;;
        ARCH) ARCH="$value" ;;
        TARGET) TARGET="$value" ;;
    esac
done < <(bash "$ROOT/scripts/arch.sh")

if [[ -z "$ARCH" || -z "$TARGET" || -z "$OS_NAME" ]]; then
    echo "ERROR: Could not detect OS/architecture." >&2
    exit 1
fi

case "${OS_NAME,,}" in
    *linux*) PLATFORM="Linux" ;;
    *windows*|*mingw*|*msys*) PLATFORM="Windows" ;;
    *)
        echo "ERROR: Unsupported OS: $OS_NAME" >&2
        exit 1
        ;;
esac

case "${ARCH,,}" in
    x86_64|amd64|x64) ARCH="x86_64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

PLATFORM_ID="${PLATFORM,,}-$ARCH"

DIST="$ROOT/dist"
WORK="$ROOT/.build-tmp"

rm -rf "$DIST" "$WORK"
mkdir -p "$DIST" "$WORK"

echo "Hello-World compiler"
echo "OS: $PLATFORM"
echo "Architecture: $ARCH"
echo "Target: $TARGET"

if [[ -n "${HELLO_LANGUAGES:-}" ]]; then
    echo "Language filter: $HELLO_LANGUAGES"
fi

count=0
skipped=0
failed=()

is_intermediate() {
    case "${1,,}" in
        *.o|*.obj|*.pdb|*.ilk|*.exp|*.lib|*.map|*.tmp|*.class)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_selected() {
    local wanted="${HELLO_LANGUAGES:-}"
    local item

    [[ -n "$wanted" ]] || return 0

    local IFS=','
    for item in $wanted; do
        if [[ "${item,,}" == "${1,,}" ]]; then
            return 0
        fi
    done

    return 1
}

is_unsupported() {
    local list="$1/unsupported.txt"

    [[ -f "$list" ]] || return 1
    tr -d '\r' < "$list" | grep -qxF "$PLATFORM_ID"
}

# Builds one language. Returns 0 on success, $SKIP_CODE when the language asks
# to be skipped, and 1 on failure. Errors are handled explicitly because this
# function runs in a context where "set -e" is ignored.
build_one() {
    local lang_dir="$1" category="$2" language="$3"
    local build_dir="$WORK/$category/$language"
    local rc=0

    if [[ ! -f "$lang_dir/build.sh" ]]; then
        echo "ERROR: Missing build.sh in $lang_dir" >&2
        return 1
    fi

    mkdir -p "$build_dir" || return 1
    export DIST_DIR="$build_dir"
    export ARCH

    if [[ -f "$lang_dir/install.sh" ]]; then
        (cd "$lang_dir" && bash ./install.sh) || rc=$?
    fi

    if [[ "$rc" -eq 0 ]]; then
        (cd "$lang_dir" && bash ./build.sh) || rc=$?
    fi

    if [[ "$rc" -eq "$SKIP_CODE" ]]; then
        return "$SKIP_CODE"
    fi

    if [[ "$rc" -ne 0 ]]; then
        echo "ERROR: $category/$language failed (exit code $rc)." >&2
        return 1
    fi

    local all_files=()
    mapfile -d '' -t all_files < <(
        find "$build_dir" -mindepth 1 -maxdepth 1 -type f -print0
    )

    local outputs=()
    local file
    for file in ${all_files[@]+"${all_files[@]}"}; do
        if ! is_intermediate "$(basename "$file")"; then
            outputs+=("$file")
        fi
    done

    # If every file has an intermediate extension, allow a sole file.
    if [[ "${#outputs[@]}" -eq 0 && "${#all_files[@]}" -eq 1 ]]; then
        outputs=("${all_files[0]}")
    fi

    if [[ "${#outputs[@]}" -ne 1 ]]; then
        echo "ERROR: Expected exactly one final artifact for $language; found ${#outputs[@]}." >&2
        find "$build_dir" -maxdepth 2 -type f -print >&2
        return 1
    fi

    local artifact="${outputs[0]}"
    local filename
    local extension=""
    filename="$(basename "$artifact")"

    if [[ "$filename" == *.* && "$filename" != .* ]]; then
        extension=".${filename##*.}"
    fi

    local output_name="hello-${language}-${ARCH}-${PLATFORM}${extension}"
    cp -- "$artifact" "$DIST/$output_name" || return 1

    if [[ -z "$extension" ]]; then
        chmod +x "$DIST/$output_name" || return 1
    fi

    echo "Created: $output_name"
    return 0
}

for lang_dir in "$ROOT"/hello/*/*; do
    [[ -d "$lang_dir" ]] || continue

    category="$(basename "$(dirname "$lang_dir")")"
    language="$(basename "$lang_dir")"

    if ! is_selected "$language"; then
        continue
    fi

    if [[ ! -d "$lang_dir/$ARCH" ]]; then
        echo "SKIP: $category/$language ($ARCH not supported)"
        skipped=$((skipped + 1))
        continue
    fi

    if is_unsupported "$lang_dir"; then
        echo "SKIP: $category/$language ($PLATFORM_ID not supported)"
        skipped=$((skipped + 1))
        continue
    fi

    echo
    echo "Building $category/$language"

    status=0
    build_one "$lang_dir" "$category" "$language" || status=$?

    case "$status" in
        0)
            count=$((count + 1))
            ;;
        "$SKIP_CODE")
            echo "SKIP: $category/$language (skipped by its own scripts)"
            skipped=$((skipped + 1))
            ;;
        *)
            failed+=("$category/$language")
            ;;
    esac
done

echo
echo "Compilation finished: $count artifact(s), $skipped skipped, ${#failed[@]} failed."

if [[ "${#failed[@]}" -gt 0 ]]; then
    echo "Failed languages:" >&2
    printf '  - %s\n' "${failed[@]}" >&2
    echo "Work files kept in: $WORK" >&2
    exit 1
fi

if [[ "$count" -eq 0 ]]; then
    echo "ERROR: No compatible language found for $PLATFORM_ID." >&2
    exit 1
fi

rm -rf "$WORK"

echo "Release files: $DIST/"
