@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
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
    echo ERROR: Ruby source not found: "%SOURCE%"
    exit /b 1
)

echo ==== Checking OCRAN gem ====
ruby -e "require 'rubygems'; spec = Gem::Specification.find_by_name('ocran'); puts spec.full_gem_path"
if errorlevel 1 (
    echo ERROR: OCRAN is not available in GEM_HOME=%GEM_HOME%
    echo Run install.bat and inspect its log.
    exit /b 1
)

echo ==== Building standalone executable ====
ruby -e "require 'rubygems'; load Gem.bin_path('ocran', 'ocran')" -- "%SOURCE%" --output "%DIST_DIR%\hello.exe"
if errorlevel 1 (
    echo ERROR: OCRAN failed to build the executable.
    exit /b 1
)

if not exist "%DIST_DIR%\hello.exe" (
    echo ERROR: Expected executable was not created.
    dir "%DIST_DIR%"
    exit /b 1
)

echo Built Ruby executable: %DIST_DIR%\hello.exe
exit /b 0