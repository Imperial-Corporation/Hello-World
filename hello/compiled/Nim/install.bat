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

winget install --id Nim.Nim --exact --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
    echo ERROR: Failed to install Nim using WinGet.
    exit /b 1
)

rem Refresh PATH for the current process if WinGet installed Nim in a standard location.
if exist "%LOCALAPPDATA%\Programs\Nim\bin" (
    set "PATH=%LOCALAPPDATA%\Programs\Nim\bin;%PATH%"
)

where nim >nul 2>&1
if errorlevel 1 (
    echo ERROR: Nim was installed, but is not available in PATH.
    echo Restart the terminal or update PATH, then retry.
    exit /b 1
)

nim --version
if errorlevel 1 exit /b 1

echo Nim installation complete.
exit /b 0
