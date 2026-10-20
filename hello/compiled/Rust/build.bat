@echo off
setlocal EnableExtensions

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"

set "ARCH="
for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
)

if /I "%ARCH%"=="AMD64" set "ARCH=x86_64"
if /I "%ARCH%"=="X64" set "ARCH=x86_64"
if /I "%ARCH%"=="AARCH64" set "ARCH=arm64"
if /I "%ARCH%"=="ARM64" set "ARCH=arm64"

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "SRC=%ARCH%\src\hello.rs"
if not exist "%SRC%" (
    echo ERROR: Missing Rust source: %SRC%
    exit /b 1
)

set "RUSTC="
where rustc >nul 2>&1
if not errorlevel 1 set "RUSTC=rustc"

if not defined RUSTC if exist "%USERPROFILE%\.cargo\bin\rustc.exe" (
    set "RUSTC=%USERPROFILE%\.cargo\bin\rustc.exe"
)

if not defined RUSTC (
    echo ERROR: rustc not found. Run install.bat first.
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

"%RUSTC%" --edition=2021 -C opt-level=2 "%SRC%" -o "%DIST_DIR%\hello.exe"
if errorlevel 1 (
    echo ERROR: Rust compilation failed.
    exit /b 1
)

echo Rust build complete.
exit /b 0
