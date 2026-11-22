@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "VERSION=0.15.2"
set "ROOT=%LOCALAPPDATA%\Hello-World\Zig\%VERSION%"

set "ARCH="
if /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x86_64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=aarch64"

if not defined ARCH (
    echo ERROR: Unsupported Windows architecture: %PROCESSOR_ARCHITECTURE%
    exit /b 1
)

if exist "%ROOT%" (
    for /f "delims=" %%F in ('where /r "%ROOT%" zig.exe 2^>nul') do (
        echo Found Zig: %%F
        "%%F" version
        if errorlevel 1 exit /b 1
        exit /b 0
    )
)

set "ARCHIVE=%TEMP%\zig-%ARCH%-windows-%VERSION%.zip"
set "URL=https://ziglang.org/download/%VERSION%/zig-%ARCH%-windows-%VERSION%.zip"

echo Downloading Zig %VERSION% for Windows %ARCH%...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference = 'Stop'; Invoke-WebRequest -Uri '%URL%' -OutFile '%ARCHIVE%'; New-Item -ItemType Directory -Force -Path '%ROOT%' | Out-Null; Expand-Archive -LiteralPath '%ARCHIVE%' -DestinationPath '%ROOT%' -Force"

if errorlevel 1 (
    echo ERROR: Failed to download or extract Zig.
    exit /b 1
)

del /q "%ARCHIVE%" 2>nul

set "ZIG_EXE="
for /f "delims=" %%F in ('where /r "%ROOT%" zig.exe 2^>nul') do (
    set "ZIG_EXE=%%F"
    goto :verify
)

echo ERROR: zig.exe was not found after extraction.
echo Installation directory: "%ROOT%"
exit /b 1

:verify
echo Found Zig: "%ZIG_EXE%"
"%ZIG_EXE%" version
if errorlevel 1 (
    echo ERROR: Zig failed to start.
    exit /b 1
)

echo Zig installation completed successfully.
exit /b 0
