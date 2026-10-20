@echo off
setlocal EnableExtensions

set "LDC_EXE="

REM Check whether ldc2 is already available.
where ldc2 >nul 2>&1
if not errorlevel 1 set "LDC_EXE=ldc2"

if defined LDC_EXE goto :found

REM Search Chocolatey's default installation directory.
for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do if exist "%%~D\bin\ldc2.exe" set "LDC_EXE=%%~D\bin\ldc2.exe"

if defined LDC_EXE goto :found

REM Install LDC only if it is missing.
where choco >nul 2>&1
if errorlevel 1 (
    echo ERROR: Chocolatey is not installed.
    exit /b 1
)

echo Installing LDC...
choco install ldc -y
if errorlevel 1 (
    echo ERROR: Failed to install LDC.
    exit /b 1
)

REM Locate the installed compiler without modifying PATH.
for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do if exist "%%~D\bin\ldc2.exe" set "LDC_EXE=%%~D\bin\ldc2.exe"

if not defined LDC_EXE (
    echo ERROR: ldc2.exe was not found after installation.
    exit /b 1
)

:found
echo LDC installation check successful.
"%LDC_EXE%" --version
if errorlevel 1 (
    echo ERROR: LDC could not be executed.
    exit /b 1
)

exit /b 0