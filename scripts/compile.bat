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

set "DIST=%ROOT%\dist"
set "WORK=%ROOT%\.build-tmp"

if exist "%DIST%" rmdir /s /q "%DIST%"
if exist "%WORK%" rmdir /s /q "%WORK%"
mkdir "%DIST%"
mkdir "%WORK%"

echo Hello-World compiler
echo OS: Windows
echo Architecture: %ARCH%
echo Target: %TARGET%

set /a COUNT=0

for /d %%C in ("%ROOT%\hello\*") do (
    for /d %%L in ("%%C\*") do (
        if exist "%%L\%ARCH%" (
            if not exist "%%L\build.bat" (
                echo ERROR: Missing build.bat in %%L
                exit /b 1
            )

            set "BUILD_DIR=%WORK%\%%~nxC\%%~nxL"
            if not exist "!BUILD_DIR!" mkdir "!BUILD_DIR!"
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

            set /a EXE_COUNT=0
            for %%F in ("!BUILD_DIR!\*.exe") do (
                if exist "%%~fF" (
                    set /a EXE_COUNT+=1
                    set "EXE_FILE=%%~fF"
                )
            )

            if not "!EXE_COUNT!"=="1" (
                echo ERROR: Expected exactly one .exe for %%~nxL, found !EXE_COUNT!.
                dir /s /b "!BUILD_DIR!"
                exit /b 1
            )

            copy /y "!EXE_FILE!" "%DIST%\hello-%%~nxL-%ARCH%-Windows.exe" >nul
            if errorlevel 1 exit /b 1

            echo Created: hello-%%~nxL-%ARCH%-Windows.exe
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
echo Compilation complete: %COUNT% executable(s).
echo Release files: %DIST%
exit /b 0
