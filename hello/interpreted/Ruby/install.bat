@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

where ruby >nul 2>&1
if errorlevel 1 (
    echo ERROR: Ruby is not installed.
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

gem install ocran --no-document --install-dir "%GEM_HOME%" --bindir "%GEM_BIN%" --verbose
if errorlevel 1 (
    echo ERROR: Failed to install OCRAN.
    exit /b 1
)

echo ==== Installed OCRAN gem ====
gem list --local

echo ==== Gem environment ====
gem env

echo ==== Gem files ====
dir "%GEM_HOME%"
dir "%GEM_BIN%"

ruby -e "require 'rubygems'; puts Gem::Specification.find_by_name('ocran').full_gem_path"
if errorlevel 1 (
    echo ERROR: RubyGems cannot locate OCRAN.
    exit /b 1
)

echo OCRAN installation verified.
exit /b 0