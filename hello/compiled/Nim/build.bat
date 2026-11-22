@echo off
setlocal EnableExtensions

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"
set "LANG_DIR=%~dp0"
set "NIM_ROOT=%LOCALAPPDATA%\Nim"
set "NIM_EXE="

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "ARCH="
for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
)

if not defined ARCH (
    echo ERROR: Could not detect architecture.
    exit /b 1
)

set "SRC=%LANG_DIR%%ARCH%\src\hello.nim"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Missing Nim source: "%SRC%"
    exit /b 1
)

rem Search PATH first.
for /f "delims=" %%F in ('where nim.exe 2^>nul') do (
    set "NIM_EXE=%%F"
    goto :nim_found
)

rem Search the installation directory used by install.bat.
if exist "%NIM_ROOT%" (
    for /f "delims=" %%F in ('where /r "%NIM_ROOT%" nim.exe 2^>nul') do (
        set "NIM_EXE=%%F"
        goto :nim_found
    )
)

echo ERROR: Nim executable not found.
echo Searched PATH and "%NIM_ROOT%"
exit /b 1

:nim_found
echo Using Nim: "%NIM_EXE%"

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

"%NIM_EXE%" c --hints:off --warnings:off --opt:speed --out:"%OUTPUT%" "%SRC%"
if errorlevel 1 (
    echo ERROR: Nim compilation failed.
    exit /b 1
)

if not exist "%OUTPUT%" (
    echo ERROR: Nim did not produce "%OUTPUT%"
    exit /b 1
)

echo Nim build complete: "%OUTPUT%"
exit /b 0