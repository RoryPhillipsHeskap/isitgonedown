@echo off
echo START %DATE% %TIME% > "C:\Users\Rory\Documents\GitHub\isitgonedown\restart-chrome-log.txt"
taskkill /IM chrome.exe /F >> "C:\Users\Rory\Documents\GitHub\isitgonedown\restart-chrome-log.txt" 2>&1
echo KILLED >> "C:\Users\Rory\Documents\GitHub\isitgonedown\restart-chrome-log.txt"
timeout /t 3 /nobreak > nul
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe"
echo STARTED >> "C:\Users\Rory\Documents\GitHub\isitgonedown\restart-chrome-log.txt"
echo END %DATE% %TIME% >> "C:\Users\Rory\Documents\GitHub\isitgonedown\restart-chrome-log.txt"
