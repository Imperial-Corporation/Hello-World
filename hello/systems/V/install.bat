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

rem The V toolchain lives outside DIST_DIR: DIST_DIR must contain only the final
rem executable, otherwise compile.bat counts the toolchain folder as an artifact.
if defined LOCALAPPDATA (
    set "V_DIR=%LOCALAPPDATA%\hello-world\v"
) else (
    set "V_DIR=%TEMP%\hello-world\v"
)

if not exist "%V_DIR%\v.exe" (
    if exist "%V_DIR%" rmdir /s /q "%V_DIR%"

    git clone --depth=1 https://github.com/vlang/v.git "%V_DIR%"
    if errorlevel 1 (
        echo ERROR: Could not download V.
        exit /b 1
    )

    pushd "%V_DIR%"
    call makev.bat
    popd

    rem Check the actual compiler output instead of relying
    rem only on makev.bat's exit code.
    if not exist "%V_DIR%\v.exe" (
        echo ERROR: V compiler was not created.
        exit /b 1
    )
)

if not exist "%V_DIR%\v.exe" (
    echo ERROR: V compiler not found after installation.
    exit /b 1
)

"%V_DIR%\v.exe" version
if errorlevel 1 (
    echo ERROR: V compiler cannot run.
    exit /b 1
)

echo V installation successful.
exit /b 0