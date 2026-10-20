@echo off
setlocal EnableExtensions

echo Updating Windows...

where winget >nul 2>&1
if errorlevel 1 (
    echo ERROR: winget is not installed.
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
