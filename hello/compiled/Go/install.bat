@echo off
setlocal EnableExtensions

where go >nul 2>&1
if not errorlevel 1 (
    go version
    exit /b 0
)

echo ERROR: Go is not installed or not in PATH.
echo Install Go from https://go.dev/dl/
exit /b 1
