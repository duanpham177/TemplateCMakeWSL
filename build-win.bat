@echo off
rem Usage: build-win.bat [preset]   (default: x64-debug)
setlocal EnableDelayedExpansion
set "PRESET=%~1"
if "%PRESET%"=="" set "PRESET=x64-debug"

set "ARCH=x64"
echo %PRESET% | findstr /b /c:"x86" >nul && set "ARCH=x86"

set "PF86=%ProgramFiles(x86)%"
if defined VSINSTALLDIR goto :build

pushd "!PF86!\Microsoft Visual Studio\Installer"
for /f "delims=" %%i in ('vswhere.exe -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath') do set "VSROOT=%%i"
popd
if not defined VSROOT echo Visual Studio with C++ tools not found& exit /b 1
call "!VSROOT!\VC\Auxiliary\Build\vcvarsall.bat" %ARCH% >nul || exit /b 1
set "PATH=!VSROOT!\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;!PATH!"

:build
cmake --preset %PRESET% || exit /b 1
cmake --build --preset %PRESET%
