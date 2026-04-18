@echo off
set GIT="C:\Users\Rory\AppData\Local\GitHubDesktop\app-3.5.7\resources\app\git\cmd\git.exe"
cd /d "C:\Users\Rory\Documents\GitHub\isitgonedown"
echo === git status === > _push.log
%GIT% status >> _push.log 2>&1
echo. >> _push.log
echo === git add === >> _push.log
%GIT% add index.html is-netflix-down.html >> _push.log 2>&1
echo. >> _push.log
echo === git commit === >> _push.log
%GIT% commit -m "Add Netflix landing page + hide dead VPN banner" >> _push.log 2>&1
echo. >> _push.log
echo === git push === >> _push.log
%GIT% push origin main >> _push.log 2>&1
echo. >> _push.log
echo === done === >> _push.log
