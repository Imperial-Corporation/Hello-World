@echo off
setlocal EnableExtensions

set "ROOT="
for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"

set "ARCH="
for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
)

if /I "%ARCH%"=="AMD64" set "ARCH=x86_64"
if /I "%ARCH%"=="ARM64" set "ARCH=arm64"

if not defined ARCH (
    echo ERROR: Could not detect architecture.
    exit /b 1
)

where rustc >nul 2>&1
if not errorlevel 1 (
    rustc --version
    exit /b %errorlevel%
)

if exist "%USERPROFILE%\.cargo\bin\rustc.exe" (
    "%USERPROFILE%\.cargo\bin\rustc.exe" --version
    exit /b %errorlevel%
)

if /I "%ARCH%"=="x86_64" (
    set "RUSTUP_URL=https://win.rustup.rs/x86_64"
) else if /I "%ARCH%"=="arm64" (
    set "RUSTUP_URL=https://win.rustup.rs/aarch64"
) else (
    echo ERROR: Unsupported Rust architecture: %ARCH%
    exit /b 1
)

set "RUSTUP_EXE=%TEMP%\rustup-init-hello-world.exe"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest '%RUSTUP_URL%' -OutFile '%RUSTUP_EXE%'"

if errorlevel 1 (
    echo ERROR: Could not download the Rust installer.
    exit /b 1
)

"%RUSTUP_EXE%" -y --profile minimal
if errorlevel 1 (
    echo ERROR: Rust installation failed.
    exit /b 1
)

if not exist "%USERPROFILE%\.cargo\bin\rustc.exe" (
    echo ERROR: rustc.exe was not found after installation.
    exit /b 1
)

"%USERPROFILE%\.cargo\bin\rustc.exe" --version
exit /b %errorlevel%
