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

set "SRC=%ARCH%\src\hello.py"
if not exist "%SRC%" (
    echo ERROR: Missing source: %SRC%
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

py -3 -m PyInstaller ^
    --onefile ^
    --clean ^
    --noconfirm ^
    --name hello ^
    --distpath "%DIST_DIR%" ^
    --workpath "%TEMP%\hello-pyinstaller-work" ^
    --specpath "%TEMP%\hello-pyinstaller-spec" ^
    "%SRC%"

if errorlevel 1 exit /b 1

echo Python executable built successfully.
exit /b 0
