@echo off
rem One-shot elevated repair of the incomplete VS Build Tools registration.
rem Flutter refuses to build while vswhere reports isComplete=false.
"C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" repair --installPath "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools" --passive --norestart
echo exitcode=%ERRORLEVEL% > C:\Hook\vs_repair_done.txt
