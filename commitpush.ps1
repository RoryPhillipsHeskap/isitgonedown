$git = "C:\Users\Rory\AppData\Local\GitHubDesktop\app-3.5.6\resources\app\git\cmd\git.exe"
$repo = "C:\Users\Rory\Documents\GitHub\isitgonedown"
$log = "$repo\gitlog.txt"

Set-Location $repo

# Clear any locks
Remove-Item "$repo\.git\HEAD.lock" -Force -ErrorAction SilentlyContinue
Remove-Item "$repo\.git\index.lock" -Force -ErrorAction SilentlyContinue

# Run git commands, capturing output
$out = @()
$out += & $git add "netlify/functions/schedule-blotato-background.js" 2>&1
$out += & $git status 2>&1
$out += & $git commit -m "Fix LinkedIn to post to IsItGoneDown company page" 2>&1
$out += & $git push origin main 2>&1
$out += "===DONE==="

$out | Out-File -FilePath $log -Encoding ascii
