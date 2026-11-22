@echo off
setlocal EnableExtensions

for %%I in ("%~dp0..\..\..") do set "ROOT=%%~fI"

set "ARCH="
for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
)

if not defined ARCH (
    echo ERROR: Could not detect architecture.
    exit /b 1
)

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "SRC=%ARCH%\src\hello.cpp"
set "OUTPUT=%DIST_DIR%\hello.exe"

if not exist "%SRC%" (
    echo ERROR: Missing C++ source: %SRC%
    exit /b 1
)

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

where clang++ >nul 2>&1
if not errorlevel 1 (
    clang++ -std=c++17 -O2 -Wall -Wextra "%SRC%" -o "%OUTPUT%"
    if errorlevel 1 exit /b 1
    echo C++ build complete: %OUTPUT%
    exit /b 0
)

where g++ >nul 2>&1
if not errorlevel 1 (
    g++ -std=c++17 -O2 -Wall -Wextra "%SRC%" -o "%OUTPUT%"
    if errorlevel 1 exit /b 1
    echo C++ build complete: %OUTPUT%
    exit /b 0
)

echo ERROR: No C++ compiler found.
exit /b 1
