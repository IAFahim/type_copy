@echo off
REM Type Copy - Windows Batch Launcher
REM This file makes it easy to run the Type Copy script on Windows

cd /d "%~dp0"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo.
    echo Please install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

REM Check if pyperclip is installed
python -c "import pyperclip" >nul 2>&1
if errorlevel 1 (
    echo ERROR: pyperclip is not installed
    echo.
    echo Installing pyperclip...
    python -m pip install pyperclip
    if errorlevel 1 (
        echo.
        echo Failed to install pyperclip. Please run manually:
        echo pip install pyperclip
        echo.
        pause
        exit /b 1
    )
    echo.
    echo pyperclip installed successfully!
    echo.
)

REM Run the script with all arguments passed through
python copy.cs.md.py.py %*

REM Check if script succeeded
if errorlevel 1 (
    echo.
    echo ERROR: Script failed to run
    echo Check the error message above for details
    echo.
    pause
    exit /b 1
)

REM Don't pause if running in non-interactive mode
if not "%1"=="" exit /b 0
