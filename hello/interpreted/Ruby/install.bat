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

set "GEM_HOME=%DIST_DIR%\.gems"
set "GEM_PATH=%GEM_HOME%"
set "GEM_BIN=%GEM_HOME%\bin"

if not exist "%GEM_BIN%" mkdir "%GEM_BIN%"

ruby --version
gem --version

gem install ocran --no-document --install-dir "%GEM_HOME%" --bindir "%GEM_BIN%"
if errorlevel 1 (
    echo ERROR: OCRAN installation failed.
    exit /b 1
)

gem list --local ocran

if not exist "%GEM_HOME%\gems\ocran-*" (
    echo ERROR: OCRAN gem files were not found.
    exit /b 1
)

echo Installed executables:
dir "%GEM_BIN%"

echo OCRAN installation successful.
exit /b 0