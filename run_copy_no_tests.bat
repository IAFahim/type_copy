@echo off
REM Type Copy - Exclude test and docs folders
REM Useful for copying only production code

cd /d "%~dp0"
python copy.cs.md.py.py --exclude test --exclude docs %*
pause
