@echo off
setlocal

where ldc2 >nul 2>&1
if not errorlevel 1 exit /b 0

where choco >nul 2>&1
if errorlevel 1 (
    echo ERROR: Install LDC manually or install Chocolatey.
    exit /b 1
)

choco install ldc -y
if errorlevel 1 exit /b 1

where ldc2 >nul 2>&1
if errorlevel 1 (
    echo ERROR: LDC is not available in PATH.
    exit /b 1
)

echo LDC installed successfully.
exit /b 0
