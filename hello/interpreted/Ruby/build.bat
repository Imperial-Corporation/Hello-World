@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by the central compile script.
    exit /b 1
)

set "ROOT=%~dp0"
set "GEM_HOME=%DIST_DIR%\.gems"
set "GEM_PATH=%GEM_HOME%"
set "PATH=%GEM_HOME%\bin;%PATH%"

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

where ocran >nul 2>&1
if errorlevel 1 (
    echo ERROR: OCRAN not found. Run install.bat first.
    exit /b 1
)

ocran "%SOURCE%" --output "%DIST_DIR%\hello.exe"
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