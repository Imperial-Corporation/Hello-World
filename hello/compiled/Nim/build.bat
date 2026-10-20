@echo off
setlocal EnableExtensions

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"
set "LANG_DIR=%~dp0"

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "ARCH="
for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
)

if not defined ARCH (
    echo ERROR: Could not detect architecture.
    exit /b 1
)

set "SRC=%LANG_DIR%%ARCH%\src\hello.nim"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Missing Nim source: %SRC%
    exit /b 1
)

where nim >nul 2>&1
if errorlevel 1 (
    echo ERROR: Nim is not installed or not in PATH.
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

nim c --hints:off --warnings:off --opt:speed --out:"%OUTPUT%" "%SRC%"
if errorlevel 1 exit /b 1

echo Nim build complete: %OUTPUT%
exit /b 0
