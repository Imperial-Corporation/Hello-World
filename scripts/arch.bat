@echo off
setlocal

set "OS_NAME=windows"
set "RAW_ARCH=%PROCESSOR_ARCHITECTURE%"

if /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "RAW_ARCH=AMD64"
if /I "%PROCESSOR_ARCHITEW6432%"=="ARM64" set "RAW_ARCH=ARM64"

if /I "%RAW_ARCH%"=="AMD64" set "ARCH=x86_64"
if /I "%RAW_ARCH%"=="x86" set "ARCH=x86"
if /I "%RAW_ARCH%"=="ARM64" set "ARCH=arm64"
if /I "%RAW_ARCH%"=="ARM" set "ARCH=arm"

if not defined ARCH (
    echo Unsupported architecture: %RAW_ARCH% 1>&2
    exit /b 1
)

echo OS=%OS_NAME%
echo ARCH=%ARCH%
echo TARGET=%OS_NAME%-%ARCH%

endlocal
