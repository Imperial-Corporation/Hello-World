@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by the central compile script.
    exit /b 1
)

where ruby >nul 2>&1
if errorlevel 1 (
    echo ERROR: Ruby is not installed on this runner.
    exit /b 1
)

where gem >nul 2>&1
if errorlevel 1 (
    echo ERROR: RubyGems is not installed.
    exit /b 1
)

ruby --version
if errorlevel 1 exit /b 1

gem --version
if errorlevel 1 exit /b 1

if not exist "%DIST_DIR%\.gems" mkdir "%DIST_DIR%\.gems"

gem install ocran --no-document --install-dir "%DIST_DIR%\.gems"
if errorlevel 1 (
    echo ERROR: OCRAN installation failed.
    exit /b 1
)

echo OCRAN installed successfully.
exit /b 0