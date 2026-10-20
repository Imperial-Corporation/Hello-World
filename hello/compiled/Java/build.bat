@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by the central compile script.
    exit /b 1
)

set "ROOT=%~dp0"

if /I "%ARCH%"=="arm64" (
    set "SRC_DIR=%ROOT%arm64\src"
) else (
    set "SRC_DIR=%ROOT%x86_64\src"
)

if not exist "%SRC_DIR%\Hello.java" (
    echo ERROR: Java source not found.
    exit /b 1
)

where javac >nul 2>&1 || (
    echo ERROR: javac not found.
    exit /b 1
)

where jar >nul 2>&1 || (
    echo ERROR: jar not found.
    exit /b 1
)

if not exist "%DIST_DIR%\classes" mkdir "%DIST_DIR%\classes"
if errorlevel 1 exit /b 1

javac -d "%DIST_DIR%\classes" "%SRC_DIR%\Hello.java"
if errorlevel 1 exit /b 1

pushd "%DIST_DIR%\classes"
jar --create --file "%DIST_DIR%\hello-java.jar" --main-class Hello .
if errorlevel 1 (
    popd
    exit /b 1
)
popd

echo Built: %DIST_DIR%\hello-java.jar
exit /b 0