@echo off
setlocal EnableExtensions

where ldc2 >nul 2>&1
if not errorlevel 1 (
    echo LDC is already available.
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

REM Refresh PATH in the current process.
call refreshenv >nul 2>&1

where ldc2 >nul 2>&1
if not errorlevel 1 (
    echo LDC is available.
    exit /b 0
)

REM Locate LDC directly because PATH changes may not persist.
for /d %%D in ("C:\tools\ldc2-*-windows-multilib") do (
    if exist "%%~D\bin\ldc2.exe" (
        set "PATH=%%~D\bin;%PATH%"
        where ldc2 >nul 2>&1
        if not errorlevel 1 (
            echo LDC found at %%~D\bin
            exit /b 0
        )
    )
)

echo ERROR: LDC was installed but ldc2.exe could not be found.
exit /b 1