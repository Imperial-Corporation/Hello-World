@echo off
setlocal EnableExtensions

where java >nul 2>&1 || goto :missing
where javac >nul 2>&1 || goto :missing
where jar >nul 2>&1 || goto :missing

echo Java toolchain found:
java -version
javac -version
exit /b 0

:missing
echo ERROR: Java JDK not found.
echo Install JDK 25 or a compatible JDK:
echo https://learn.microsoft.com/en-us/java/openjdk/download
exit /b 1