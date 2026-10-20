@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "VERSION=0.15.2"
set "LANG_DIR=%~dp0"
set "ZIG_ROOT=%LOCALAPPDATA%\Hello-World\Zig\%VERSION%"
set "ZIG_EXE="

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "ARCH="
if /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x86_64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"

if not defined ARCH (
    echo ERROR: Unsupported Windows architecture: %PROCESSOR_ARCHITECTURE%
    exit /b 1
)

set "SRC=%LANG_DIR%%ARCH%\src\hello.zig"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Source file not found: "%SRC%"
    exit /b 1
)

rem Find the compiler installed by install.bat.
if exist "%ZIG_ROOT%" (
    for /f "delims=" %%F in ('where /r "%ZIG_ROOT%" zig.exe 2^>nul') do (
        set "ZIG_EXE=%%F"
        goto :found
    )
)

rem Fall back to a compiler already available on PATH.
for /f "delims=" %%F in ('where zig.exe 2^>nul') do (
    set "ZIG_EXE=%%F"
    goto :found
)

echo ERROR: Zig was not found. Run install.bat first.
exit /b 1

:found
echo Using Zig: "%ZIG_EXE%"
"%ZIG_EXE%" version
if errorlevel 1 exit /b 1

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

echo Source: "%SRC%"
echo Output: "%OUTPUT%"

"%ZIG_EXE%" build-exe "%SRC%" -O ReleaseFast "-femit-bin=%OUTPUT%"
if errorlevel 1 (
    echo ERROR: Zig compilation failed.
    exit /b 1
)

if not exist "%OUTPUT%" (
    echo ERROR: Executable was not created: "%OUTPUT%"
    exit /b 1
)

echo Zig build complete: "%OUTPUT%"
exit /b 0
