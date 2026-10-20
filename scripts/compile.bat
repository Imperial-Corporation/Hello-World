@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "ROOT=%%~fI"

set "ARCH="
set "TARGET="

for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
    if /I "%%A"=="TARGET" set "TARGET=%%B"
)

if /I "%ARCH%"=="AMD64" set "ARCH=x86_64"
if /I "%ARCH%"=="X64" set "ARCH=x86_64"
if /I "%ARCH%"=="AARCH64" set "ARCH=arm64"
if /I "%ARCH%"=="ARM64" set "ARCH=arm64"

if not defined ARCH (
    echo ERROR: Could not detect architecture.
    exit /b 1
)

if /I not "%ARCH%"=="x86_64" if /I not "%ARCH%"=="arm64" (
    echo ERROR: Unsupported architecture: %ARCH%
    exit /b 1
)

set "DIST=%ROOT%\dist"
set "WORK=%ROOT%\.build-tmp"

if exist "%DIST%" rmdir /s /q "%DIST%"
if exist "%WORK%" rmdir /s /q "%WORK%"
mkdir "%DIST%"
if errorlevel 1 exit /b 1
mkdir "%WORK%"
if errorlevel 1 exit /b 1

echo Hello-World compiler
echo OS: Windows
echo Architecture: %ARCH%
echo Target: %TARGET%

set /a COUNT=0

for /d %%C in ("%ROOT%\hello\*") do (
    for /d %%L in ("%%C\*") do (
        if exist "%%L\%ARCH%\" (
            if not exist "%%L\build.bat" (
                echo ERROR: Missing build.bat in %%L
                exit /b 1
            )

            set "BUILD_DIR=%WORK%\%%~nxC\%%~nxL"
            if not exist "!BUILD_DIR!" mkdir "!BUILD_DIR!"
            if errorlevel 1 exit /b 1
            set "DIST_DIR=!BUILD_DIR!"

            echo.
            echo Building %%~nxC/%%~nxL

            pushd "%%L"

            if exist install.bat (
                call install.bat
                if errorlevel 1 (
                    echo ERROR: Installation failed for %%~nxL
                    popd
                    exit /b 1
                )
            )

            call build.bat
            if errorlevel 1 (
                echo ERROR: Build failed for %%~nxL
                popd
                exit /b 1
            )

            popd

            rem Count every regular file directly inside BUILD_DIR.
            rem Directories such as Java's classes folder are ignored.
            set /a ARTIFACT_COUNT=0
            set "ARTIFACT="

            for %%F in ("!BUILD_DIR!\*") do (
                if exist "%%~fF" if not exist "%%~fF\NUL" (
                    set /a ARTIFACT_COUNT+=1
                    set "ARTIFACT=%%~fF"
                    set "ARTIFACT_NAME=%%~nxF"
                    set "ARTIFACT_EXT=%%~xF"
                )
            )

            if not "!ARTIFACT_COUNT!"=="1" (
                echo ERROR: Expected exactly one artifact for %%~nxL, found !ARTIFACT_COUNT!.
                dir /s /b "!BUILD_DIR!"
                exit /b 1
            )

            set "OUTPUT_NAME=hello-%%~nxL-%ARCH%-Windows!ARTIFACT_EXT!"

            copy /y "!ARTIFACT!" "%DIST%\!OUTPUT_NAME!" >nul
            if errorlevel 1 (
                echo ERROR: Failed to copy artifact for %%~nxL
                exit /b 1
            )

            echo Created: !OUTPUT_NAME!
            set /a COUNT+=1
        ) else (
            echo SKIP: %%~nxC/%%~nxL - architecture not supported
        )
    )
)

if "%COUNT%"=="0" (
    echo ERROR: No compatible language found for %ARCH%.
    exit /b 1
)

rmdir /s /q "%WORK%"

echo.
echo Compilation complete: %COUNT% artifact(s).
echo Release files: %DIST%
exit /b 0
