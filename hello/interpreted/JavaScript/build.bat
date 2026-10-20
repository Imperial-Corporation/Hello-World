@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by the central compile script.
    exit /b 1
)

set "ROOT=%~dp0"
set "BUN_EXE=%USERPROFILE%\.bun\bin\bun.exe"

if /I "%ARCH%"=="arm64" (
    set "SRC_DIR=%ROOT%arm64\src"
    set "BUN_TARGET=bun-windows-arm64"
) else if /I "%ARCH%"=="aarch64" (
    set "SRC_DIR=%ROOT%arm64\src"
    set "BUN_TARGET=bun-windows-arm64"
) else (
    set "SRC_DIR=%ROOT%x86_64\src"
    set "BUN_TARGET=bun-windows-x64"
)

if not exist "%SRC_DIR%\hello.js" (
    echo ERROR: Source file not found: "%SRC_DIR%\hello.js"
    exit /b 1
)

where bun >nul 2>&1
if not errorlevel 1 (
    set "BUN_EXE=bun"
) else if not exist "%BUN_EXE%" (
    echo ERROR: Bun not found. Run install.bat first.
    exit /b 1
)

"%BUN_EXE%" build --compile --minify --target=%BUN_TARGET% "%SRC_DIR%\hello.js" --outfile "%DIST_DIR%\hello.exe"
if errorlevel 1 (
    echo ERROR: Bun compilation failed.
    exit /b 1
)

if not exist "%DIST_DIR%\hello.exe" (
    echo ERROR: Compiled executable was not created.
    exit /b 1
)

echo Built standalone executable: %DIST_DIR%\hello.exe
exit /b 0