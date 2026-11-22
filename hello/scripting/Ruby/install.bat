@echo off
setlocal EnableExtensions

where ruby >nul 2>&1
if errorlevel 1 (
    echo ERROR: Ruby is not installed.
    exit /b 1
)

where gem >nul 2>&1
if errorlevel 1 (
    echo ERROR: RubyGems is not installed.
    exit /b 1
)

ruby --version
gem --version

gem install ocran --no-document
if errorlevel 1 (
    echo ERROR: OCRAN installation failed.
    exit /b 1
)

ruby -e "require 'rubygems'; puts Gem::Specification.find_by_name('ocran').full_gem_path"
if errorlevel 1 (
    echo ERROR: OCRAN cannot be found after installation.
    exit /b 1
)

echo OCRAN installation verified.
exit /b 0