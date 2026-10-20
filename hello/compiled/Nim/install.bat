@echo off
setlocal EnableExtensions

echo Checking Nim installation...

where nim >nul 2>&1
if not errorlevel 1 (
    nim --version
    exit /b 0
)

set "NIM_VERSION=2.2.12"
set "NIM_DIR=%LOCALAPPDATA%\Nim"
set "NIM_ZIP=%TEMP%\nim-windows.zip"
set "NIM_URL=https://nim-lang.org/download/nim-2.2.12_x64.zip"

echo Downloading Nim %NIM_VERSION%...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference = 'Stop';" ^
    "$ProgressPreference = 'SilentlyContinue';" ^
    "Invoke-WebRequest -Uri '%NIM_URL%' -OutFile '%NIM_ZIP%';" ^
    "if (Test-Path '%NIM_DIR%') { Remove-Item '%NIM_DIR%' -Recurse -Force };" ^
    "New-Item -ItemType Directory -Path '%NIM_DIR%' -Force | Out-Null;" ^
    "Expand-Archive -LiteralPath '%NIM_ZIP%' -DestinationPath '%NIM_DIR%' -Force"

if errorlevel 1 (
    echo ERROR: Failed to download or extract Nim.
    exit /b 1
)

del "%NIM_ZIP%" >nul 2>&1

rem Locate nim.exe in the extracted archive.
set "NIM_BIN="
for /r "%NIM_DIR%" %%F in (nim.exe) do (
    set "NIM_BIN=%%~dpF"
    goto :nim_found
)

:nim_found
if not defined NIM_BIN (
    echo ERROR: nim.exe was not found in %NIM_DIR%.
    exit /b 1
)

rem Add Nim and Nimble to PATH.
set "PATH=%NIM_BIN%;%NIM_DIR%\nimble\bin;%PATH%"

rem Verify the executable directly, independently of PATH lookup.
if not exist "%NIM_BIN%nim.exe" (
    echo ERROR: Nim executable does not exist: %NIM_BIN%nim.exe
    exit /b 1
)

"%NIM_BIN%nim.exe" --version
if errorlevel 1 (
    echo ERROR: Nim executable failed to run.
    exit /b 1
)

echo Nim installation completed successfully.
exit /b 0