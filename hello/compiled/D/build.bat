@echo off
setlocal EnableExtensions

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"

set "ARCH="
for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
)

if not defined ARCH (
    echo ERROR: Could not detect architecture.
    exit /b 1
)

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "SRC=%ARCH%\src\hello.d"
if not exist "%SRC%" (
    echo ERROR: Missing source: %SRC%
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

where ldc2 >nul 2>&1
if errorlevel 1 (
    echo ERROR: LDC compiler not found.
    exit /b 1
)

ldc2 -O2 -of="%DIST_DIR%\hello.exe" "%SRC%"
if errorlevel 1 exit /b 1

echo D build complete.
exit /b 0
