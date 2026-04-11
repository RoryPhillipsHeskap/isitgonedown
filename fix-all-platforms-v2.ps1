# Fix all platforms v2 - fetches captions from Google Sheet, adds mediaUrls + Facebook pageId
Add-Type -AssemblyName System.Windows.Forms

$apiKey      = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl     = "https://backend.blotato.com/v2"
$sheetId     = "1vDlC6JLZiHUspvoIED7i_RfAbcsnglI1ptkIzvF0Oig"
$fbPageId    = "61574740391585"
$imageBase   = "https://isitgonedown.com/social-images/instagram"

# ── Step 1: Fetch Google Sheet as CSV ─────────────────────────────────────────
$csvUrl = "https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv&gid=0"
try {
    $csvRaw = Invoke-WebRequest -Uri $csvUrl -UseBasicParsing -ErrorAction Stop
    $csvText = [System.Text.Encoding]::UTF8.GetString($csvRaw.Content)
} catch {
    [System.Windows.Forms.MessageBox]::Show("FAILED to fetch Google Sheet: $_", "Error") | Out-Null
    exit
}

# Parse CSV
$rows = $csvText -split "`n" | ForEach-Object { $_.Trim("`r") }
$headers = $rows[0] -split ","
# Find column indices
$colDay      = 0
$colDate     = -1
$colTwitter  = -1
$colLinkedIn = -1
$colFacebook = -1
for ($i = 0; $i -lt $headers.Count; $i++) {
    $h = $headers[$i].Trim('"').ToLower()
    if ($h -eq "day")       { $colDay      = $i }
    if ($h -eq "post date") { $colDate     = $i }
    if ($h -like "*twitter*") { $colTwitter  = $i }
    if ($h -like "*linkedin*") { $colLinkedIn = $i }
    if ($h -like "*facebook*") { $colFacebook  = $i }
}

# Build day data map: dayNumber -> { date, twitter, linkedin, facebook }
$dayData = @{}
for ($r = 1; $r -lt $rows.Count; $r++) {
    if ($rows[$r].Trim() -eq "") { continue }
    # Simple CSV split (handles basic quoting)
    $cols = @()
    $inQuote = $false
    $cur = ""
    foreach ($ch in $rows[$r].ToCharArray()) {
        if ($ch -eq '"') { $inQuote = -not $inQuote }
        elseif ($ch -eq ',' -and -not $inQuote) { $cols += $cur; $cur = "" }
        else { $cur += $ch }
    }
    $cols += $cur

    $dayNum = 0
    try { $dayNum = [int]($cols[$colDay].Trim()) } catch { continue }
    if ($dayNum -lt 6 -or $dayNum -gt 30) { continue }

    $postDate = ""
    if ($colDate -ge 0 -and $cols.Count -gt $colDate) { $postDate = $cols[$colDate].Trim().Trim('"') }

    $tw = if ($colTwitter  -ge 0 -and $cols.Count -gt $colTwitter)  { $cols[$colTwitter].Trim().Trim('"')  } else { "" }
    $li = if ($colLinkedIn -ge 0 -and $cols.Count -gt $colLinkedIn) { $cols[$colLinkedIn].Trim().Trim('"') } else { "" }
    $fb = if ($colFacebook -ge 0 -and $cols.Count -gt $colFacebook) { $cols[$colFacebook].Trim().Trim('"')  } else { "" }

    # Parse date to ISO (expect YYYY-MM-DD in sheet)
    $isoTime = ""
    try {
        $dt = [datetime]::Parse($postDate)
        $isoTime = $dt.ToString("yyyy-MM-dd") + "T09:00:00.000Z"
    } catch { $isoTime = "" }

    $dayData[$dayNum] = @{ date = $isoTime; twitter = $tw; linkedin = $li; facebook = $fb }
}

$colMsg = "Columns found — Day:$colDay Date:$colDate Twitter:$colTwitter LinkedIn:$colLinkedIn Facebook:$colFacebook`n"
$colMsg += "Days parsed: $($dayData.Count) (days 6-30 expected: 25)"
[System.Windows.Forms.MessageBox]::Show($colMsg, "Sheet Parse Check") | Out-Null

if ($dayData.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("No day data parsed. Check sheet format.", "Error") | Out-Null
    exit
}

# ── Step 2: Create posts ───────────────────────────────────────────────────────
$headers_get  = @{ "blotato-api-key" = $apiKey }
$headers_post = @{ "blotato-api-key" = $apiKey; "Content-Type" = "application/json" }

$platformConfig = @(
    @{ name = "facebook"; accountId = "25818"; platField = "facebook"; targetType = "facebook"; needsPageId = $true }
    @{ name = "twitter";  accountId = "15712"; platField = "twitter";  targetType = "twitter";  needsPageId = $false }
    @{ name = "linkedin"; accountId = "17133"; platField = "linkedin"; targetType = "linkedin"; needsPageId = $false }
)

$results = ""
$totalOk  = 0
$totalFail = 0

foreach ($cfg in $platformConfig) {
    $okCount   = 0
    $failCount = 0
    $firstErr  = ""

    foreach ($day in ($dayData.Keys | Sort-Object)) {
        $d = $dayData[$day]
        if ($d.date -eq "") { continue }

        # Get caption for this platform
        $caption = switch ($cfg.name) {
            "facebook" { $d.facebook }
            "twitter"  { $d.twitter  }
            "linkedin" { $d.linkedin }
        }
        if ($caption -eq "") { $caption = "Check if your favourite site is down at IsItGoneDown.com" }

        $imgUrl = "$imageBase/day-$day.jpg"

        # Build target object
        $targetObj = @{ targetType = $cfg.targetType }
        if ($cfg.needsPageId) { $targetObj["pageId"] = $fbPageId }

        $bodyObj = @{
            post = @{
                accountId = $cfg.accountId
                content   = @{
                    text      = $caption
                    mediaUrls = @($imgUrl)
                    platform  = $cfg.platField
                }
                target = $targetObj
            }
            scheduledTime = $d.date
        }
        $bodyJson = $bodyObj | ConvertTo-Json -Depth 10

        $delay = if ($cfg.name -eq "twitter") { 4 } else { 1 }
        Start-Sleep -Seconds $delay

        try {
            $resp = Invoke-RestMethod -Uri "$baseUrl/posts" -Method Post -Headers $headers_post -Body $bodyJson
            $okCount++
            $totalOk++
        } catch {
            $failCount++
            $totalFail++
            if ($firstErr -eq "") {
                $sc = 0; try { $sc = $_.Exception.Response.StatusCode.value__ } catch {}
                $eb = $_.ErrorDetails.Message
                if (-not $eb) {
                    try {
                        $stream = $_.Exception.Response.GetResponseStream()
                        $reader = New-Object System.IO.StreamReader($stream)
                        $eb = $reader.ReadToEnd()
                    } catch { $eb = "(unreadable)" }
                }
                $firstErr = "Day $day FAIL $sc`: $eb"
            }
        }
    }

    $results += "$($cfg.name.ToUpper()): $okCount OK, $failCount FAIL"
    if ($firstErr -ne "") { $results += "`n  First error: $firstErr" }
    $results += "`n"
}

$results += "`nTOTAL: $totalOk OK, $totalFail FAIL"
[System.Windows.Forms.MessageBox]::Show($results, "Fix All Platforms v2 - Results") | Out-Null
