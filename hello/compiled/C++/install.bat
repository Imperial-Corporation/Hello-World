@echo off
setlocal EnableExtensions

where clang++ >nul 2>&1
if not errorlevel 1 (
    clang++ --version
    exit /b %ERRORLEVEL%
)

where g++ >nul 2>&1
if not errorlevel 1 (
    g++ --version
    exit /b %ERRORLEVEL%
)

echo ERROR: No C++ compiler found.
echo Install LLVM/Clang or a MinGW-w64 GCC toolchain and add it to PATH.
exit /b 1
