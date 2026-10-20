@echo off
setlocal EnableExtensions

set "LANG_DIR=%~dp0"
set "NIM_ROOT=%LOCALAPPDATA%\Nim"
set "NIM_EXE="

echo Searching for Nim...

rem Check PATH first.
where nim.exe >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%F in ('where nim.exe') do (
        set "NIM_EXE=%%F"
        goto :found
    )
)

rem Search the directory used by install.bat.
if exist "%NIM_ROOT%" (
    for /f "delims=" %%F in ('where /r "%NIM_ROOT%" nim.exe 2^>nul') do (
        set "NIM_EXE=%%F"
        goto :found
    )
)

echo ERROR: Nim executable not found.
echo Searched PATH and "%NIM_ROOT%"
exit /b 1

:found
echo Found Nim: "%NIM_EXE%"

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

for %%I in ("%LANG_DIR%..\..\..") do set "ROOT=%%~fI"

for /f "tokens=2 delims==" %%A in ('call "%ROOT%\scripts\arch.bat" ^| findstr /b "ARCH="') do set "ARCH=%%A"

if not defined ARCH (
    echo ERROR: Could not determine architecture.
    exit /b 1
)

set "SRC=%LANG_DIR%%ARCH%\src\hello.nim"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Source file not found: "%SRC%"
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

"%NIM_EXE%" c --hints:off --warnings:off --opt:speed --out:"%OUTPUT%" "%SRC%"
if errorlevel 1 (
    echo ERROR: Nim compilation failed.
    exit /b 1
)

if not exist "%OUTPUT%" (
    echo ERROR: Output executable was not created.
    exit /b 1
)

echo Nim build complete: "%OUTPUT%"
exit /b 0