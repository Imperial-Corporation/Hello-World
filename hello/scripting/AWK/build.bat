@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "ROOT=%~dp0"

if /I "%ARCH%"=="arm64" (
    set "SOURCE=%ROOT%arm64\src\hello.awk"
) else if /I "%ARCH%"=="aarch64" (
    set "SOURCE=%ROOT%arm64\src\hello.awk"
) else (
    set "SOURCE=%ROOT%x86_64\src\hello.awk"
)

if not exist "%SOURCE%" (
    echo ERROR: Source not found: "%SOURCE%"
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

copy /y "%SOURCE%" "%DIST_DIR%\hello.awk" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy the AWK script source file.
    exit /b 1
)

echo Built AWK script file: %DIST_DIR%\hello.awk
exit /b 0
