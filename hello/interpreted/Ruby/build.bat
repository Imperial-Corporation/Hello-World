@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "ROOT=%~dp0"

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

ruby -e "require 'rubygems'; puts Gem::Specification.find_by_name('ocran').full_gem_path"
if errorlevel 1 (
    echo ERROR: OCRAN is not installed in the active Ruby environment.
    exit /b 1
)

ruby -S ocran "%SOURCE%" --output "%DIST_DIR%\hello.exe"
if errorlevel 1 (
    echo ERROR: OCRAN compilation failed.
    exit /b 1
)

if not exist "%DIST_DIR%\hello.exe" (
    echo ERROR: Expected executable was not created.
    exit /b 1
)

echo Built Ruby executable: %DIST_DIR%\hello.exe
exit /b 0