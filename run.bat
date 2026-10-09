@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1
title BrowserShift

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "VENV_DIR=%SCRIPT_DIR%.venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"

cls
echo.
echo             BrowserShift Launcher
echo.

if exist "%VENV_PY%" (
    echo   [OK] Virtual environment found.
    goto :launch
)

call :find_python
if not defined PYEXE (
    echo   [!] Python not found. Downloading Python 3.11...
    call :install_python
    if not defined PYEXE (
        echo   [X] Failed to install Python. Aborting.
        pause
        exit /b 1
    )
)

echo   [OK] Using Python: %PYEXE%
echo   [*] Creating virtual environment...
"%PYEXE%" -m venv "%VENV_DIR%" >nul 2>&1
if not exist "%VENV_PY%" (
    echo   [X] Failed to create virtual environment.
    pause
    exit /b 1
)

echo   [*] Upgrading pip...
"%VENV_PY%" -m pip install --upgrade pip --quiet

echo   [*] Installing BrowserShift and dependencies...
"%VENV_PY%" -m pip install -e "%SCRIPT_DIR%." --quiet
if errorlevel 1 (
    echo   [X] Failed to install dependencies.
    pause
    exit /b 1
)

echo   [OK] Setup complete.
echo.

:launch
echo   [*] Starting BrowserShift...
echo.
"%VENV_PY%" -m browsershift.main
set "EXITCODE=%errorlevel%"
echo.
if %EXITCODE% neq 0 (
    echo   [!] BrowserShift exited with code %EXITCODE%.
    pause
)
endlocal
exit /b %EXITCODE%

:find_python
set "PYEXE="
call :try_py 3.13
if defined PYEXE goto :eof
call :try_py 3.12
if defined PYEXE goto :eof
call :try_py 3.11
if defined PYEXE goto :eof
call :try_plain_python
goto :eof

:try_py
py -%1 -c "import sys; sys.exit(0)" >nul 2>&1
if errorlevel 1 goto :eof
for /f "delims=" %%P in ('py -%1 -c "import sys; print(sys.executable)" 2^>nul') do set "PYEXE=%%P"
goto :eof

:try_plain_python
python -c "import sys; sys.exit(0)" >nul 2>&1
if errorlevel 1 goto :eof
for /f "delims=" %%P in ('python -c "import sys; print(sys.executable)" 2^>nul') do set "PYEXE=%%P"
goto :eof

:install_python
set "PYVER=3.11.9"
set "PYFILE=python-%PYVER%-amd64.exe"
set "PYURL=https://www.python.org/ftp/python/%PYVER%/%PYFILE%"
set "PYTMP=%TEMP%\%PYFILE%"

echo   [*] Downloading %PYFILE%...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PYURL%' -OutFile '%PYTMP%' -UseBasicParsing } catch { exit 1 }"

if not exist "%PYTMP%" (
    echo   [X] Download failed.
    goto :eof
)

echo   [*] Running silent install...
"%PYTMP%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_launcher=1 SimpleInstall=1
timeout /t 10 /nobreak >nul

set "PYCANDIDATE=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
if exist "%PYCANDIDATE%" (
    set "PYEXE=%PYCANDIDATE%"
    goto :eof
)

call :try_py 3.11
goto :eof