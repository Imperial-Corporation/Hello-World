@echo off
setlocal EnableExtensions

set "LDC_BIN="

where ldc2 >nul 2>&1
if not errorlevel 1 (
    echo LDC is already available.
    exit /b 0
)

REM Check whether LDC is already installed outside PATH.
for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do (
    if exist "%%~D\bin\ldc2.exe" (
        set "LDC_BIN=%%~D\bin"
    )
)

if defined LDC_BIN (
    set "PATH=%LDC_BIN%;%PATH%"
    where ldc2 >nul 2>&1
    if not errorlevel 1 (
        echo LDC found in %LDC_BIN%.
        exit /b 0
    )
)

REM Install LDC if necessary.
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

REM Find the installed compiler independently of PATH.
set "LDC_BIN="
for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do (
    if exist "%%~D\bin\ldc2.exe" (
        set "LDC_BIN=%%~D\bin"
    )
)

if not defined LDC_BIN (
    echo ERROR: ldc2.exe was not found after installation.
    exit /b 1
)

set "PATH=%LDC_BIN%;%PATH%"

where ldc2 >nul 2>&1
if errorlevel 1 (
    echo ERROR: LDC was installed but cannot be executed.
    exit /b 1
)

echo LDC installation completed successfully.
ldc2 --version
exit /b 0