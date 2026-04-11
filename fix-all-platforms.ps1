# Fix all text platforms: Facebook, Twitter, LinkedIn
# 1. Read all existing posts for each platform, keep best caption per date
# 2. Delete all existing
# 3. Recreate 1 clean post per date with correct JSON structure

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$logFile = "C:\Users\Rory\Documents\GitHub\isitgonedown\fix-all-platforms-log.txt"

$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

function Log {
    param([string]$msg)
    $line = "$(Get-Date -Format 'HH:mm:ss'): $msg"
    Write-Host $line
    $line | Out-File -FilePath $logFile -Encoding UTF8 -Append
}

"=== All Platforms Fix - $(Get-Date) ===" | Out-File -FilePath $logFile -Encoding UTF8

# Platform config
$platformConfig = @{
    "facebook" = @{ accountId = "25818"; targetType = "facebook" }
    "twitter"  = @{ accountId = "15712"; targetType = "twitter" }
    "linkedin" = @{ accountId = "17133"; targetType = "linkedin" }
}

# ============================================================
# STEP 1: Collect all schedules, group by platform+date
# ============================================================
Log "STEP 1: Collecting all schedules..."

$allIds = @()
$bestCaption = @{}   # key = "platform|date" -> caption text
$allByPlatform = @{ "facebook"=@(); "twitter"=@(); "linkedin"=@() }

$cursor = $null
do {
    $url = "$baseUrl/schedules?limit=100"
    if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }
    $r = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    foreach ($item in $r.items) {
        $plat = $item.draft.content.platform
        if ($plat -notin @("facebook","twitter","linkedin")) { continue }
        $allIds += $item.id
        $allByPlatform[$plat] += $item.id
        # Store caption for this platform+date (use first non-empty one)
        $dateKey = "$plat|$($item.scheduledAt.Substring(0,10))"
        if (-not $bestCaption[$dateKey] -and $item.draft.content.text) {
            $bestCaption[$dateKey] = $item.draft.content.text
        }
    }
    $cursor = $r.cursor
} while ($cursor)

foreach ($plat in @("facebook","twitter","linkedin")) {
    Log "  $plat`: $($allByPlatform[$plat].Count) schedules found"
}

# ============================================================
# STEP 2: Delete all
# ============================================================
Log ""
Log "STEP 2: Deleting $($allIds.Count) schedules..."
$deleted = 0; $deleteFailed = 0

foreach ($id in $allIds) {
    try {
        Invoke-WebRequest -Uri "$baseUrl/schedules/$($id)" -Method Delete -Headers $headers -UseBasicParsing | Out-Null
        Log "  DELETE $($id): OK"
        $deleted++
    } catch {
        $sc = $_.Exception.Response.StatusCode.value__
        $eb = ""
        try { $s=$_.Exception.Response.GetResponseStream(); $sr=New-Object System.IO.StreamReader($s); $eb=$sr.ReadToEnd() } catch {}
        Log "  DELETE $($id) FAILED ($sc): $eb"
        $deleteFailed++
    }
}
Log "Deletes: $deleted OK, $deleteFailed failed"

# ============================================================
# STEP 3: Recreate — 25 posts per platform (Days 6–30)
# ============================================================
Log ""
Log "STEP 3: Creating 25 posts per platform..."

# Days 6-30: April 12 - May 6 2026
$dates = @(
    "2026-04-12","2026-04-13","2026-04-14","2026-04-15","2026-04-16",
    "2026-04-17","2026-04-18","2026-04-19","2026-04-20","2026-04-21",
    "2026-04-22","2026-04-23","2026-04-24","2026-04-25","2026-04-26",
    "2026-04-27","2026-04-28","2026-04-29","2026-04-30",
    "2026-05-01","2026-05-02","2026-05-03","2026-05-04","2026-05-05","2026-05-06"
)

$created = 0; $createFailed = 0

foreach ($plat in @("facebook","twitter","linkedin")) {
    $cfg = $platformConfig[$plat]
    Log ""
    Log "  -- $plat (accountId=$($cfg.accountId)) --"

    foreach ($date in $dates) {
        $scheduledTime = "${date}T09:00:00.000Z"
        $captionKey = "$plat|$date"
        $caption = $bestCaption[$captionKey]

        if (-not $caption) {
            Log "  WARNING: No caption found for $captionKey - skipping"
            $createFailed++
            continue
        }

        $bodyObj = @{
            post = @{
                accountId = $cfg.accountId
                content   = @{
                    text     = $caption
                    platform = $plat
                }
                target    = @{
                    targetType = $cfg.targetType
                }
            }
            scheduledTime = $scheduledTime
        }
        $bodyJson = $bodyObj | ConvertTo-Json -Depth 10

        try {
            $resp = Invoke-RestMethod -Uri "$baseUrl/posts" -Method Post -Headers $headers -Body $bodyJson -ContentType "application/json"
            Log "  $plat $date`: OK (submissionId=$($resp.postSubmissionId))"
            $created++
        } catch {
            $sc = $_.Exception.Response.StatusCode.value__
            $eb = ""
            try { $s=$_.Exception.Response.GetResponseStream(); $sr=New-Object System.IO.StreamReader($s); $eb=$sr.ReadToEnd() } catch {}
            Log "  $plat $date FAILED ($sc): $eb"
            $createFailed++
        }
        Start-Sleep -Milliseconds 500
    }
}

Log ""
Log "=== DONE: $created created, $createFailed failed ==="
