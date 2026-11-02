@echo off
rem Build all Windows presets, then all WSL presets (every installed compiler version).
rem Usage: build-all.bat [wsl-distro] [wsl-filter-regex]
setlocal EnableDelayedExpansion
set "DISTRO=%~1"
set "FILTER=%~2"
if "%FILTER%"=="" set "FILTER=."
set "EXITCODE=0"
set "HERE=%~dp0"

for %%P in (x64-debug x64-release x86-debug x86-release) do (
  echo ===== Windows: %%P
  cmd /c ""%HERE%build-win.bat" %%P" || set "EXITCODE=1"
)

set "WSLARGS="
if not "%DISTRO%"=="" set "WSLARGS=-d %DISTRO%"
for /f "delims=" %%i in ('wsl %WSLARGS% wslpath -a "%HERE:~0,-1%"') do set "WSLDIR=%%i"
echo ===== WSL: !WSLDIR!
wsl %WSLARGS% bash -c "cd '!WSLDIR!' && tr -d '\r' < build-wsl-all.sh | bash -s -- '%FILTER%'" || set "EXITCODE=1"

echo.
if "%EXITCODE%"=="0" (echo ALL BUILDS OK) else (echo SOME BUILDS FAILED)
exit /b %EXITCODE%
