@echo off
setlocal EnableExtensions

where ldc2 >nul 2>&1
if not errorlevel 1 (
    echo LDC is already available.
    exit /b 0
)

REM Check for an existing installation.
for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do (
    if exist "%%~D\bin\ldc2.exe" (
        set "PATH=%%~D\bin;%PATH%"
    )
)

where ldc2 >nul 2>&1
if not errorlevel 1 (
    echo LDC is available.
    exit /b 0
)

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

REM Add the installed compiler to this process PATH.
for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do (
    if exist "%%~D\bin\ldc2.exe" (
        set "PATH=%%~D\bin;%PATH%"
    )
)

where ldc2 >nul 2>&1
if errorlevel 1 (
    echo ERROR: LDC was installed but ldc2.exe was not found in PATH.
    exit /b 1
)

echo LDC installation completed successfully.
ldc2 --version
exit /b 0