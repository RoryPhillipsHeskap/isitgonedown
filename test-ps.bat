@echo off
powershell -ExecutionPolicy Bypass -File "C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-instagram-reschedule.ps1" 2>&1 > "C:\Users\Rory\Documents\GitHub\isitgonedown\ps-output.txt"
echo EXITCODE=%ERRORLEVEL% >> "C:\Users\Rory\Documents\GitHub\isitgonedown\ps-output.txt"
pause
