@echo off
setlocal EnableExtensions

if not defined DIST_DIR (
    echo ERROR: DIST_DIR must be set by the central compile script.
    exit /b 1
)

where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is required to install V.
    exit /b 1
)

set "V_DIR=%DIST_DIR%\.vlang"

if not exist "%V_DIR%\v.exe" (
    if exist "%V_DIR%" rmdir /s /q "%V_DIR%"

    git clone --depth=1 https://github.com/vlang/v.git "%V_DIR%"
    if errorlevel 1 (
        echo ERROR: Could not download V.
        exit /b 1
    )

    pushd "%V_DIR%"
    call makev.bat
    set "BUILD_ERROR=%ERRORLEVEL%"
    popd

    if not "%BUILD_ERROR%"=="0" (
        echo ERROR: Could not compile the V compiler.
        exit /b 1
    )
)

if not exist "%V_DIR%\v.exe" (
    echo ERROR: V compiler was not created.
    exit /b 1
)

"%V_DIR%\v.exe" version
if errorlevel 1 exit /b 1

exit /b 0