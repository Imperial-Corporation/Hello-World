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

REM Find LDC without modifying PATH.
set "LDC_EXE="

where ldc2 >nul 2>&1
if not errorlevel 1 set "LDC_EXE=ldc2"

if not defined LDC_EXE (
    for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do if exist "%%~D\bin\ldc2.exe" set "LDC_EXE=%%~D\bin\ldc2.exe"
)

if not defined LDC_EXE (
    echo ERROR: LDC compiler not found.
    exit /b 1
)

echo Using LDC:
"%LDC_EXE%" --version
if errorlevel 1 (
    echo ERROR: LDC could not be executed.
    exit /b 1
)

"%LDC_EXE%" -O2 -of="%DIST_DIR%\hello.exe" "%SRC%"
if errorlevel 1 (
    echo ERROR: D compilation failed.
    exit /b 1
)

echo D build complete.
exit /b 0