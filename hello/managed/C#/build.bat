@echo off
setlocal EnableExtensions

set "LANG_DIR=%~dp0"
set "DOTNET_EXE=dotnet.exe"

if not defined DIST_DIR (
    echo ERROR: DIST_DIR is not set.
    exit /b 1
)

set "ARCH="
set "RID="

if /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "ARCH=x86_64"
    set "RID=win-x64"
)
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "ARCH=arm64"
    set "RID=win-arm64"
)

if not defined ARCH (
    echo ERROR: Unsupported Windows architecture: %PROCESSOR_ARCHITECTURE%
    exit /b 1
)

where dotnet.exe >nul 2>&1
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\dotnet\dotnet.exe" (
        set "DOTNET_EXE=%LOCALAPPDATA%\dotnet\dotnet.exe"
    ) else (
        echo ERROR: .NET SDK not found. Run install.bat first.
        exit /b 1
    )
)

set "SRC=%LANG_DIR%%ARCH%\src\hello.csproj"
set "OUTPUT=%DIST_DIR%\hello.exe"
set "TEMP_OUT=%DIST_DIR%\publish-temp"

if not exist "%SRC%" (
    echo ERROR: Project not found: "%SRC%"
    exit /b 1
)

"%DOTNET_EXE%" publish "%SRC%" ^
    --configuration Release ^
    --runtime %RID% ^
    --self-contained true ^
    -p:UseAppHost=true ^
    -p:PublishSingleFile=true ^
    -p:PublishTrimmed=false ^
    --output "%TEMP_OUT%"

if errorlevel 1 (
    echo ERROR: .NET publish failed.
    exit /b 1
)

if not exist "%TEMP_OUT%\hello.exe" (
    echo ERROR: Published executable not found.
    exit /b 1
)

move /y "%TEMP_OUT%\hello.exe" "%OUTPUT%" >nul
if errorlevel 1 exit /b 1

rmdir /s /q "%TEMP_OUT%" 2>nul

echo C# build complete: "%OUTPUT%"
exit /b 0
