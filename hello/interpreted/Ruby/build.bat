@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by the central compile script.
    exit /b 1
)

set "ROOT=%~dp0"
set "GEM_HOME=%DIST_DIR%\.gems"
set "GEM_PATH=%GEM_HOME%"
set "GEM_BIN=%GEM_HOME%\bin"
set "PATH=%GEM_BIN%;%PATH%"

if /I "%ARCH%"=="arm64" (
    set "SOURCE=%ROOT%arm64\src\hello.rb"
) else if /I "%ARCH%"=="aarch64" (
    set "SOURCE=%ROOT%arm64\src\hello.rb"
) else (
    set "SOURCE=%ROOT%x86_64\src\hello.rb"
)

if not exist "%SOURCE%" (
    echo ERROR: Source not found: "%SOURCE%"
    exit /b 1
)

echo Checking OCRAN installation...
gem list --local ocran

ruby -e "require 'rubygems'; spec = Gem::Specification.find_by_name('ocran'); puts spec.full_gem_path"
if errorlevel 1 (
    echo ERROR: OCRAN is not installed in GEM_HOME=%GEM_HOME%
    exit /b 1
)

ruby -e "require 'rubygems'; spec = Gem::Specification.find_by_name('ocran'); load Gem.bin_path('ocran', 'ocran') " -- "%SOURCE%" --output "%DIST_DIR%\hello.exe"
if errorlevel 1 (
    echo ERROR: OCRAN compilation failed.
    exit /b 1
)

if not exist "%DIST_DIR%\hello.exe" (
    echo ERROR: Executable was not created.
    exit /b 1
)

echo Built Ruby executable: %DIST_DIR%\hello.exe
exit /b 0