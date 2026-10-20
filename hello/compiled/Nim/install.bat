@echo off
setlocal EnableExtensions

where nim >nul 2>&1
if not errorlevel 1 (
    nim --version
    exit /b 0
)

echo Nim not found. Installing Nim...

where winget >nul 2>&1
if errorlevel 1 (
    echo ERROR: WinGet is unavailable.
    echo Install Nim manually from https://nim-lang.org/install.html
    exit /b 1
)

winget install --id nim.nim --exact --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
if errorlevel 1 (
    echo ERROR: WinGet failed to install Nim.
    exit /b 1
)

rem Refresh PATH from common installation locations.
if exist "%LOCALAPPDATA%\Programs\Nim\bin\nim.exe" (
    set "PATH=%LOCALAPPDATA%\Programs\Nim\bin;%PATH%"
)

if exist "%USERPROFILE%\.nimble\bin\nim.exe" (
    set "PATH=%USERPROFILE%\.nimble\bin;%PATH%"
)

where nim >nul 2>&1
if errorlevel 1 (
    echo ERROR: Nim installation succeeded, but nim.exe is not in PATH.
    echo Check the installation directory and PATH.
    exit /b 1
)

nim --version
if errorlevel 1 exit /b 1

echo Nim installation complete.
exit /b 0
