@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by the central compile script.
    exit /b 1
)

set "ROOT=%~dp0"
set "V_EXE=%DIST_DIR%\.vlang\v.exe"
set "OUTPUT=%DIST_DIR%\hello.exe"

if /I "%ARCH%"=="arm64" (
    set "SOURCE=%ROOT%arm64\src\hello.v"
) else if /I "%ARCH%"=="aarch64" (
    set "SOURCE=%ROOT%arm64\src\hello.v"
) else (
    set "SOURCE=%ROOT%x86_64\src\hello.v"
)

if not exist "%V_EXE%" (
    echo ERROR: V compiler not found. Run install.bat first.
    exit /b 1
)

if not exist "%SOURCE%" (
    echo ERROR: Source file not found: "%SOURCE%"
    exit /b 1
)

"%V_EXE%" -o "%OUTPUT%" "%SOURCE%"
if errorlevel 1 (
    echo ERROR: V compilation failed.
    exit /b 1
)

if not exist "%OUTPUT%" (
    echo ERROR: V executable was not created.
    exit /b 1
)

echo Built V executable: %OUTPUT%
exit /b 0