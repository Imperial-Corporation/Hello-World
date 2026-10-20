@echo off
setlocal EnableExtensions

echo Updating Windows...

where winget >nul 2>&1
if errorlevel 1 (
    echo winget is not installed. Installing App Installer...

    where curl >nul 2>&1
    if errorlevel 1 (
        echo ERROR: curl is not installed. Cannot download App Installer.
        exit /b 1
    )

    set "WINGET_URL=https://aka.ms/getwinget"
    set "WINGET_PACKAGE=%TEMP%\Microsoft.DesktopAppInstaller.msixbundle"

    curl -fSL "%WINGET_URL%" -o "%TEMP%\Microsoft.DesktopAppInstaller.msixbundle"
    if errorlevel 1 (
        echo ERROR: Failed to download App Installer.
        exit /b 1
    )

    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -Path '%TEMP%\Microsoft.DesktopAppInstaller.msixbundle'"
    if errorlevel 1 (
        echo ERROR: Failed to install App Installer.
        exit /b 1
    )

    set "PATH=%PATH%;%LOCALAPPDATA%\Microsoft\WindowsApps"
)

where winget >nul 2>&1
if errorlevel 1 (
    echo ERROR: winget is still unavailable after installation.
    exit /b 1
)

echo Checking build scripts...

if not exist "%~dp0compile.bat" (
    echo ERROR: scripts\compile.bat is missing.
    exit /b 1
)

winget source update
if errorlevel 1 (
    echo ERROR: Failed to update package sources.
    exit /b 1
)

winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
    echo WARNING: Some packages could not be updated.
)

echo Windows update completed.
exit /b 0
