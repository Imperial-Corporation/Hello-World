@echo off
setlocal EnableExtensions

where clang.exe >nul 2>&1
if not errorlevel 1 (
    clang --version
    if errorlevel 1 exit /b 1
    echo Clang is available.
    exit /b 0
)

where gcc.exe >nul 2>&1
if not errorlevel 1 (
    gcc --version
    if errorlevel 1 exit /b 1
    echo GCC is available.
    exit /b 0
)

echo ERROR: Clang or GCC was not found in PATH.
echo Install an Objective-C-capable toolchain first.
exit /b 1
