$ErrorActionPreference = 'Continue'
$logFile = 'C:\Users\Rory\Documents\GitHub\isitgonedown\restart-chrome-log.txt'
"START $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $logFile -Encoding utf8

try {
    $procs = Get-Process chrome -ErrorAction SilentlyContinue
    "Found $($procs.Count) chrome processes before kill" | Out-File -FilePath $logFile -Append -Encoding utf8
    if ($procs) {
        Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
        "Killed chrome processes" | Out-File -FilePath $logFile -Append -Encoding utf8
    }
    Start-Sleep -Seconds 3
    $still = Get-Process chrome -ErrorAction SilentlyContinue
    "After kill: $($still.Count) chrome processes remain" | Out-File -FilePath $logFile -Append -Encoding utf8
    Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" -ErrorAction SilentlyContinue
    "Started Chrome" | Out-File -FilePath $logFile -Append -Encoding utf8
} catch {
    "ERROR: $_" | Out-File -FilePath $logFile -Append -Encoding utf8
}
"END $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $logFile -Append -Encoding utf8
