$ErrorActionPreference = 'Stop'

# ========= CONFIG =========
$fromAddr  = 'admin@isitgonedown.com'
$toAddr    = 'roryphillips@heskap.com'
$smtpHost  = 'smtp.gmail.com'
$smtpPort  = 587
$credFile  = 'C:\Users\Rory\Documents\GitHub\isitgonedown\smtp-creds.xml'
$blotKey   = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU='
$logFile   = 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-daily-log.txt'

function Write-Log { param([string]$Msg) "$([DateTime]::Now.ToString('HH:mm:ss')) $Msg" | Out-File -FilePath $logFile -Append -Encoding utf8 }

"===== RUN $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Out-File -FilePath $logFile -Append -Encoding utf8

try {
    # --- Fetch Blotato schedules ---
    $headers = @{ 'blotato-api-key' = $blotKey }
    $allItems = @()
    $cursor = $null
    do {
        $url = 'https://backend.blotato.com/v2/schedules?limit=100'
        if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }
        $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        if ($resp.items) { $allItems += $resp.items }
        $cursor = $resp.cursor
    } while ($cursor)

    $today = (Get-Date).ToString('yyyy-MM-dd')
    $todayPosts = @($allItems | Where-Object { $_.scheduledTime -like "$today*" })
    Write-Log "Fetched $($allItems.Count) total schedules, $($todayPosts.Count) for today ($today)"

    # --- Build status ---
    $platforms = @('twitter','linkedin','facebook','instagram')
    $statusMap = @{}
    foreach ($plat in $platforms) { $statusMap[$plat] = 'missing' }
    foreach ($p in $todayPosts) {
        $plat = $p.draft.content.platform
        if ($plat) { $statusMap[$plat] = $p.status }
    }

    # --- Count + summary ---
    $published = 0
    $bodyLines = @("Today's IsItGoneDown social posts (9 AM schedule check):",'')
    foreach ($plat in $platforms) {
        $s = $statusMap[$plat]
        $icon = switch ($s) {
            'published' { $published++; '✅' }
            'failed'    { '❌' }
            'missing'   { '⚠️' }
            default     { '⏳' }
        }
        $bodyLines += "$icon $plat — $s"
    }
    $bodyLines += ''
    $bodyLines += "$published/4 posts confirmed published."
    $bodyLines += ''
    if ($published -lt 4) {
        $bodyLines += 'Note: missing/failed items may have already published and dropped from the schedules endpoint. Verify at https://app.blotato.com if in doubt.'
    }
    $body = $bodyLines -join "`r`n"

    $subject = if ($published -eq 4) {
        "✅ IsItGoneDown — All 4 posts sent $today"
    } else {
        "⚠️ IsItGoneDown — $published/4 posts sent $today"
    }

    # --- Load credentials ---
    if (-not (Test-Path $credFile)) {
        throw "Credentials file not found at $credFile. Run setup-smtp-creds.ps1 first."
    }
    $cred = Import-Clixml -Path $credFile
    Write-Log "Loaded SMTP credentials for $($cred.UserName)"

    # --- Send via Gmail SMTP (STARTTLS on 587) ---
    $mailParams = @{
        From       = $fromAddr
        To         = $toAddr
        Subject    = $subject
        Body       = $body
        SmtpServer = $smtpHost
        Port       = $smtpPort
        UseSsl     = $true
        Credential = $cred
        Encoding   = [System.Text.Encoding]::UTF8
    }
    Send-MailMessage @mailParams
    Write-Log "SENT: $subject"
    "OK $published/4 $today" | Out-File -FilePath 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-daily-result.txt' -Encoding utf8
}
catch {
    Write-Log "ERROR: $_"
    "ERROR: $_" | Out-File -FilePath 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-daily-result.txt' -Encoding utf8
    throw
}
