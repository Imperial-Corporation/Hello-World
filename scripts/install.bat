@echo off
setlocal EnableExtensions

echo Checking Windows environment...

if not exist "%~dp0compile.bat" (
    echo ERROR: scripts\compile.bat is missing.
    exit /b 1
)

echo Skipping system package updates.
echo Language-specific scripts will install required dependencies.

echo Windows setup completed.
exit /b 0
