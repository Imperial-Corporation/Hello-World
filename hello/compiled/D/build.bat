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

REM Locate LDC even when its directory is missing from PATH.
where ldc2 >nul 2>&1
if errorlevel 1 (
    for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do (
        if exist "%%~D\bin\ldc2.exe" (
            set "LDC_BIN=%%~D\bin"
        )
    )

    if defined LDC_BIN (
        set "PATH=%LDC_BIN%;%PATH%"
    )
)

where ldc2 >nul 2>&1
if errorlevel 1 (
    echo ERROR: LDC compiler not found.
    echo Checked PATH and C:\tools\ldc2-*-windows-multilib\bin.
    exit /b 1
)

echo Using LDC:
where ldc2

ldc2 -O2 -of="%DIST_DIR%\hello.exe" "%SRC%"
if errorlevel 1 (
    echo ERROR: D compilation failed.
    exit /b 1
)

echo D build complete.
exit /b 0