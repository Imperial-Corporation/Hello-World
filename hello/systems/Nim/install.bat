@echo off
setlocal EnableExtensions
setlocal EnableExtensions EnableDelayedExpansion

set "NIM_VERSION=2.2.12"
set "NIM_ROOT=%LOCALAPPDATA%\Nim"
set "NIM_URL=https://nim-lang.org/download/nim-2.2.12_x64.zip"
set "NIM_ARCHIVE=%TEMP%\nim-%NIM_VERSION%-x64.zip"

echo Checking Nim installation...

rem Reuse an existing installation if available.
if exist "%NIM_ROOT%" (
    for /f "delims=" %%F in ('where /r "%NIM_ROOT%" nim.exe 2^>nul') do (
        echo Found Nim: %%F
        "%%F" --version
        exit /b !errorlevel!
    )
)

echo Downloading Nim %NIM_VERSION%...

if not exist "%NIM_ROOT%" mkdir "%NIM_ROOT%"
if errorlevel 1 exit /b 1

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference = 'Stop'; Invoke-WebRequest -Uri '%NIM_URL%' -OutFile '%NIM_ARCHIVE%'; Expand-Archive -LiteralPath '%NIM_ARCHIVE%' -DestinationPath '%NIM_ROOT%' -Force"

if errorlevel 1 (
    echo ERROR: Failed to download or extract Nim.
    exit /b 1
)

del /q "%NIM_ARCHIVE%" 2>nul

set "NIM_EXE="
for /f "delims=" %%F in ('where /r "%NIM_ROOT%" nim.exe 2^>nul') do (
    set "NIM_EXE=%%F"
    goto :verify
)

echo ERROR: nim.exe was not found after extraction.
echo Installation directory: "%NIM_ROOT%"
exit /b 1

:verify
echo Found Nim: "%NIM_EXE%"
"%NIM_EXE%" --version
if errorlevel 1 (
    echo ERROR: Nim failed to start.
    exit /b 1
)

echo Nim installation completed successfully.
exit /b 0