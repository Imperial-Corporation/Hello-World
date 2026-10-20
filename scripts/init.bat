@echo off
setlocal EnableExtensions

if "%~1"=="" goto :usage
if "%~2"=="" goto :usage
if not "%~3"=="" goto :usage

set "LANGUAGE=%~1"
set "CATEGORY=%~2"

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "TARGET=%ROOT%\hello\%CATEGORY%\%LANGUAGE%"

if not "%LANGUAGE%"=="%LANGUAGE: =%" (
    echo ERROR: Language name cannot contain spaces.
    exit /b 1
)

if not "%CATEGORY%"=="%CATEGORY: =%" (
    echo ERROR: Category cannot contain spaces.
    exit /b 1
)

if exist "%TARGET%" (
    echo ERROR: Target already exists: "%TARGET%"
    exit /b 1
)

mkdir "%TARGET%\x86_64\src" || exit /b 1
mkdir "%TARGET%\arm64\src" || exit /b 1

type nul > "%TARGET%\build.bat"
type nul > "%TARGET%\build.sh"
type nul > "%TARGET%\install.sh"
type nul > "%TARGET%\install.bat"

echo Initialized %LANGUAGE% (%CATEGORY%)
echo Location: %TARGET%
exit /b 0

:usage
echo Usage: %~nx0 ^<language^> ^<category^>
exit /b 1
