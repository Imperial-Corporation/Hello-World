@echo off
setlocal EnableExtensions

set "BUN_EXE=%USERPROFILE%\.bun\bin\bun.exe"

where bun >nul 2>&1
if not errorlevel 1 (
    bun --version
    exit /b %errorlevel%
)

if exist "%BUN_EXE%" (
    "%BUN_EXE%" --version
    exit /b %errorlevel%
)

where powershell >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell is required to install Bun.
    exit /b 1
)

echo Installing Bun...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
if errorlevel 1 (
    echo ERROR: Bun installation failed.
    exit /b 1
)

if not exist "%BUN_EXE%" (
    echo ERROR: Bun executable not found after installation.
    exit /b 1
)

"%BUN_EXE%" --version
if errorlevel 1 exit /b 1

exit /b 0