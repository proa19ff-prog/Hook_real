@echo off
rem Complete the interrupted VS Build Tools update that left the instance
rem flagged isComplete=false (which blocks Flutter Windows builds).
"C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" update --installPath "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools" --passive --norestart > C:\Hook\vs_update_out.log 2>&1
echo exitcode=%ERRORLEVEL% >> C:\Hook\vs_update_out.log
