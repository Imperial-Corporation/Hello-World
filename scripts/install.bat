@echo off
setlocal EnableExtensions

echo Checking Windows environment...

if not exist "%~dp0compile.bat" (
    echo ERROR: scripts\compile.bat is missing.
    exit /b 1
)

where winget >nul 2>&1
if errorlevel 1 (
    echo WinGet not found. Installing App Installer...

    set "WINGET_DIR=%TEMP%\winget-install"
    if not exist "%TEMP%\winget-install" mkdir "%TEMP%\winget-install"

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$ErrorActionPreference = 'Stop';" ^
        "$ProgressPreference = 'SilentlyContinue';" ^
        "$dir = Join-Path $env:TEMP 'winget-install';" ^
        "$url = 'https://aka.ms/getwinget';" ^
        "$file = Join-Path $dir 'Microsoft.DesktopAppInstaller.msixbundle';" ^
        "Invoke-WebRequest -Uri $url -OutFile $file;" ^
        "Add-AppxPackage -Path $file"

    if errorlevel 1 (
        echo ERROR: Failed to download or install App Installer.
        exit /b 1
    )

    set "PATH=%LOCALAPPDATA%\Microsoft\WindowsApps;%PATH%"
)

where winget >nul 2>&1
if errorlevel 1 (
    echo ERROR: WinGet is still unavailable after installation.
    exit /b 1
)

echo WinGet is available.
winget --version

echo Skipping system package updates.
echo Language-specific scripts will install required dependencies.

echo Windows setup completed.
exit /b 0