@echo off
setlocal EnableExtensions

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"

set "ARCH="
set "OS="

for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
    if /I "%%A"=="OS" set "OS=%%B"
)

if not defined ARCH (
    echo ERROR: Could not detect architecture.
    exit /b 1
)

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "SRC=%~dp0%ARCH%\src\hello.go"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Missing Go source: %SRC%
    exit /b 1
)

where go >nul 2>&1
if errorlevel 1 (
    echo ERROR: Go is not installed or not in PATH.
    exit /b 1
)

if /I "%ARCH%"=="x86_64" set "GOARCH=amd64"
if /I "%ARCH%"=="x86" set "GOARCH=386"
if /I "%ARCH%"=="arm64" set "GOARCH=arm64"
if /I "%ARCH%"=="armv7" set "GOARCH=arm"

if not defined GOARCH (
    echo ERROR: Unsupported architecture: %ARCH%
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

set "GOOS=windows"
set "CGO_ENABLED=0"

go build -trimpath -ldflags="-s -w" -o "%OUTPUT%" "%SRC%"
if errorlevel 1 exit /b 1

echo Go build complete: %OUTPUT%
exit /b 0
