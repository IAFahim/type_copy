@echo off
REM ============================================================================
REM Type Copy - Automatic Python Setup and Installation Script
REM ============================================================================
REM This script will:
REM 1. Check if Python is installed
REM 2. If not, download and install Python automatically
REM 3. Add Python to PATH
REM 4. Install required packages (pyperclip)
REM 5. Run the Type Copy script
REM ============================================================================

setlocal EnableDelayedExpansion

echo.
echo ============================================================================
echo                    Type Copy - Auto Setup
echo ============================================================================
echo.

REM --- Check Administrator Rights ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Not running as Administrator
    echo Some features may require admin rights for PATH modification
    echo.
    echo Right-click this file and select "Run as administrator" for full setup
    echo.
    timeout /t 3 >nul
)

REM --- Step 1: Check if Python is installed ---
echo [1/5] Checking Python installation...
python --version >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Python is already installed
    python --version
    goto :check_path
)

echo [NOTICE] Python is not installed or not in PATH
echo.

REM --- Step 2: Download Python Installer ---
echo [2/5] Downloading Python installer...
echo.
echo This will download Python 3.12 (latest stable version)
echo Download size: ~25 MB
echo.

set PYTHON_VERSION=3.12.1
set PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe
set INSTALLER_PATH=%TEMP%\python-installer.exe

echo Downloading from: %PYTHON_URL%
echo.

REM Try with PowerShell (works on Windows 10+)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%INSTALLER_PATH%'}" 2>nul

if not exist "%INSTALLER_PATH%" (
    echo [ERROR] Failed to download Python installer
    echo.
    echo Please download Python manually from:
    echo https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)

echo [OK] Python installer downloaded
echo.

REM --- Step 3: Install Python ---
echo [3/5] Installing Python...
echo.
echo This will install Python with the following options:
echo - Add to PATH automatically
echo - Install pip (package manager)
echo - Install for current user
echo.
echo Please wait, this may take 2-3 minutes...
echo.

REM Install Python silently with all the right options
"%INSTALLER_PATH%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_pip=1 Include_launcher=1

REM Wait for installation
timeout /t 5 /nobreak >nul

REM Clean up installer
del "%INSTALLER_PATH%" >nul 2>&1

echo [OK] Python installation completed
echo.

REM Refresh environment variables
call :refresh_env

:check_path
REM --- Step 4: Verify Python in PATH ---
echo [4/5] Verifying Python PATH...

python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Python is installed but not in PATH
    echo Attempting to add Python to PATH...
    call :add_python_to_path
)

REM Try again after PATH modification
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python is not accessible
    echo.
    echo Please restart your computer and try again
    echo Or manually add Python to PATH
    echo.
    pause
    exit /b 1
)

echo [OK] Python is accessible
python --version
echo.

REM --- Step 5: Install Required Packages ---
echo [5/5] Installing required packages...
echo.

REM Check if pyperclip is already installed
python -c "import pyperclip" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] pyperclip is already installed
) else (
    echo Installing pyperclip...
    python -m pip install --quiet --upgrade pip
    python -m pip install --quiet pyperclip
    
    if !errorLevel! equ 0 (
        echo [OK] pyperclip installed successfully
    ) else (
        echo [ERROR] Failed to install pyperclip
        echo.
        echo Trying alternative installation method...
        pip install pyperclip
        
        if !errorLevel! neq 0 (
            echo [ERROR] Could not install pyperclip
            echo Please run manually: pip install pyperclip
            pause
            exit /b 1
        )
    )
)

echo.
echo ============================================================================
echo                    Setup Complete!
echo ============================================================================
echo.
echo Python and all dependencies are now installed and configured.
echo You can now use Type Copy!
echo.
echo Usage:
echo   python copy.cs.md.py.py                  - Copy all files
echo   python copy.cs.md.py.py --exclude test   - Exclude folders
echo   python copy.cs.md.py.py --help           - Show help
echo.
echo Press any key to run Type Copy now...
pause >nul

REM --- Run Type Copy ---
cd /d "%~dp0"
if exist "copy.cs.md.py.py" (
    python copy.cs.md.py.py %*
) else (
    echo [ERROR] copy.cs.md.py.py not found in current directory
    echo Please make sure this script is in the same folder as copy.cs.md.py.py
    pause
    exit /b 1
)

goto :eof

REM ============================================================================
REM                           Helper Functions
REM ============================================================================

:add_python_to_path
echo.
echo Searching for Python installation...

REM Common Python installation locations
set "PYTHON_LOCATIONS=%LOCALAPPDATA%\Programs\Python\Python3*"
set "PYTHON_LOCATIONS=%PYTHON_LOCATIONS%;%PROGRAMFILES%\Python3*"
set "PYTHON_LOCATIONS=%PYTHON_LOCATIONS%;%PROGRAMFILES(X86)%\Python3*"
set "PYTHON_LOCATIONS=%PYTHON_LOCATIONS%;C:\Python3*"

for %%L in (%PYTHON_LOCATIONS%) do (
    if exist "%%L\python.exe" (
        set "PYTHON_DIR=%%L"
        set "PYTHON_SCRIPTS=%%L\Scripts"
        echo Found Python at: !PYTHON_DIR!
        
        REM Add to PATH for current session
        set "PATH=!PYTHON_DIR!;!PYTHON_SCRIPTS!;%PATH%"
        
        REM Add to user PATH permanently
        setx PATH "!PYTHON_DIR!;!PYTHON_SCRIPTS!;%PATH%" >nul 2>&1
        
        if !errorLevel! equ 0 (
            echo [OK] Python added to PATH
        ) else (
            echo [WARNING] Could not modify PATH automatically
            echo Please add manually: !PYTHON_DIR!
        )
        goto :eof
    )
)

echo [WARNING] Could not locate Python installation
echo You may need to add Python to PATH manually
goto :eof

:refresh_env
REM Refresh environment variables without restarting
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYSTEM_PATH=%%b"
set "PATH=%SYSTEM_PATH%;%USER_PATH%"
goto :eof
