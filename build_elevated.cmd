@echo off
rem One-shot elevated Windows build (Developer Mode is off, so symlinks
rem need an administrator token). Logs land next to the project.
cd /d C:\Hook
call C:\flut\flutter\bin\flutter.bat build windows --release > C:\Hook\build_win.log 2>&1
echo exitcode=%ERRORLEVEL% >> C:\Hook\build_win.log
