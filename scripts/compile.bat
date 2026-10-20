@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "ROOT=%%~fI"

set "ARCH="
set "TARGET="

for /f "tokens=1,* delims==" %%A in ('call "%ROOT%\scripts\arch.bat"') do (
    if /I "%%A"=="ARCH" set "ARCH=%%B"
    if /I "%%A"=="TARGET" set "TARGET=%%B"
)

if not defined ARCH (
    echo ERROR: Could not detect system architecture.
    exit /b 1
)

echo ========================================
echo Hello-World compiler
echo Architecture: %ARCH%
echo Target: %TARGET%
echo ========================================

if exist "%ROOT%\dist" rmdir /s /q "%ROOT%\dist"
mkdir "%ROOT%\dist"

set /a COUNT=0

for /d %%C in ("%ROOT%\hello\*") do (
    for /d %%L in ("%%C\*") do (
        if exist "%%L\%ARCH%" (
            if not exist "%%L\build.bat" (
                echo ERROR: Missing build.bat in %%L
                exit /b 1
            )

            set "DIST_DIR=%ROOT%\dist\%%~nxC\%%~nxL\%TARGET%"
            if not exist "!DIST_DIR!" mkdir "!DIST_DIR!"

            echo.
            echo ========================================
            echo Building %%~nxC/%%~nxL
            echo Output: !DIST_DIR!
            echo ========================================

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
            set /a COUNT+=1
        ) else (
            echo Skipping %%~nxC/%%~nxL: architecture not supported
        )
    )
)

if "%COUNT%"=="0" (
    echo ERROR: No compatible language was found for %ARCH%.
    exit /b 1
)

echo.
echo Compilation complete: %COUNT% language(s) processed.
echo Artifacts: %ROOT%\dist\
exit /b 0
