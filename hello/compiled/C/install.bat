@echo off
setlocal

where clang >nul 2>&1
if not errorlevel 1 exit /b 0

where gcc >nul 2>&1
if not errorlevel 1 exit /b 0

where choco >nul 2>&1
if errorlevel 1 (
    echo ERROR: Install LLVM/Clang or GCC before building C.
    exit /b 1
)

choco install llvm -y
if errorlevel 1 exit /b 1

echo C compiler installed.
exit /b 0
