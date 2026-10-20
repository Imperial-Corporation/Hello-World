@echo off
setlocal EnableExtensions

set "LANG_DIR=%~dp0"
for %%I in ("%LANG_DIR%..\..\..") do set "ROOT=%%~fI"

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by scripts\compile.bat
    exit /b 1
)

rem Locate Nim in the default installation directory.
set "NIM_EXE="

where nim >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%F in ('where nim') do (
        set "NIM_EXE=%%F"
        goto :nim_found
    )
)

if exist "%LOCALAPPDATA%\Nim" (
    for /f "delims=" %%F in ('where /r "%LOCALAPPDATA%\Nim" nim.exe 2^>nul') do (
        set "NIM_EXE=%%F"
        goto :nim_found
    )
)

echo ERROR: Nim is not installed.
exit /b 1

:nim_found
echo Using Nim: %NIM_EXE%

rem Determine the target architecture.
for /f "tokens=2 delims==" %%A in ('call "%ROOT%\scripts\arch.bat" ^| findstr /b "ARCH="') do set "ARCH=%%A"

if not defined ARCH (
    echo ERROR: Unable to determine target architecture.
    exit /b 1
)

set "SRC=%LANG_DIR%%ARCH%\src\hello.nim"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Missing Nim source: %SRC%
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

"%NIM_EXE%" c --hints:off --warnings:off --opt:speed --out:"%OUTPUT%" "%SRC%"
if errorlevel 1 (
    echo ERROR: Nim compilation failed.
    exit /b 1
)

if not exist "%OUTPUT%" (
    echo ERROR: Nim did not produce the expected executable.
    exit /b 1
)

echo Nim build complete: %OUTPUT%
exit /b 0