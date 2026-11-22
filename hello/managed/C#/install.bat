@echo off
setlocal EnableExtensions

where dotnet.exe >nul 2>&1
if not errorlevel 1 (
    dotnet --version
    exit /b %errorlevel%
)

set "INSTALLER=%TEMP%\dotnet-install.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='Stop'; Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -OutFile '%INSTALLER%'"

if errorlevel 1 (
    echo ERROR: Could not download the .NET installer.
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%INSTALLER%" -Channel 10.0 -InstallDir "%LOCALAPPDATA%\dotnet"

if errorlevel 1 (
    echo ERROR: .NET SDK installation failed.
    exit /b 1
)

del /q "%INSTALLER%" 2>nul

if not exist "%LOCALAPPDATA%\dotnet\dotnet.exe" (
    echo ERROR: dotnet.exe was not found after installation.
    exit /b 1
)

echo .NET SDK installed successfully.
exit /b 0
