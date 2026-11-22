@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "LANG_DIR=%~dp0"
set "ARCH="

if /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x86_64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"

if not defined ARCH (
    echo ERROR: Unsupported Windows architecture: %PROCESSOR_ARCHITECTURE%
    exit /b 1
)

set "SRC=%LANG_DIR%%ARCH%\src\hello.m"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Source not found: "%SRC%"
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

where clang.exe >nul 2>&1
if not errorlevel 1 (
    clang -x objective-c "%SRC%" -O2 -o "%OUTPUT%"
    if errorlevel 1 exit /b 1
    goto :verify
)

where gcc.exe >nul 2>&1
if not errorlevel 1 (
    gcc -x objective-c "%SRC%" -O2 -o "%OUTPUT%"
    if errorlevel 1 exit /b 1
    goto :verify
)

echo ERROR: Clang or GCC was not found in PATH.
exit /b 1

:verify
if not exist "%OUTPUT%" (
    echo ERROR: Executable was not created.
    exit /b 1
)

echo Objective-C build complete: "%OUTPUT%"
exit /b 0
