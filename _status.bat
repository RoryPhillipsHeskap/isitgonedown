@echo off
set GIT="C:\Users\Rory\AppData\Local\GitHubDesktop\app-3.5.7\resources\app\git\cmd\git.exe"
cd /d "C:\Users\Rory\Documents\GitHub\isitgonedown"
echo === git log origin/main === > _status.log
%GIT% log origin/main --oneline -3 >> _status.log 2>&1
echo. >> _status.log
echo === local vs origin === >> _status.log
%GIT% rev-parse HEAD >> _status.log 2>&1
%GIT% rev-parse origin/main >> _status.log 2>&1
echo. >> _status.log
echo === fetch origin === >> _status.log
%GIT% fetch origin >> _status.log 2>&1
echo. >> _status.log
echo === git log origin/main after fetch === >> _status.log
%GIT% log origin/main --oneline -3 >> _status.log 2>&1
echo === done === >> _status.log
