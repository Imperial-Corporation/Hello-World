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

rem Find the actual compiler path inside the extracted archive.
for /f "delims=" %%F in ('where /r "%NIM_DIR%" nim.exe 2^>nul') do (
    set "NIM_EXE=%%F"
    goto :nim_found
)

echo ERROR: nim.exe was not found after extraction.
dir "%NIM_DIR%" /s /b
exit /b 1

:nim_found
for %%F in ("%NIM_EXE%") do set "NIM_BIN=%%~dpF"
set "PATH=%NIM_BIN%;%PATH%"

echo Found Nim: %NIM_EXE%
"%NIM_EXE%" --version
if errorlevel 1 (
    echo ERROR: Nim failed to start.
    exit /b 1
)

echo Nim installation completed successfully.
exit /b 0