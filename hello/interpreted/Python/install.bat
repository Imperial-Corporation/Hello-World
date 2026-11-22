@echo off
setlocal

where py >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python launcher not found.
    exit /b 1
)

py -3 -m pip install --upgrade pyinstaller
if errorlevel 1 exit /b 1

echo PyInstaller installed successfully.
exit /b 0
