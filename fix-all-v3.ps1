# Fix all platforms v3 - top-level error trap + file log
$logFile = "C:\Users\Rory\Documents\GitHub\isitgonedown\fix-log.txt"
"Script started $(Get-Date)" | Out-File $logFile -Encoding utf8

try {
    Add-Type -AssemblyName System.Windows.Forms
    "Add-Type OK" | Add-Content $logFile

    $apiKey    = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
    $baseUrl   = "https://backend.blotato.com/v2"
    $sheetId   = "1vDlC6JLZiHUspvoIED7i_RfAbcsnglI1ptkIzvF0Oig"
    $fbPageId  = "61574740391585"
    $imageBase = "https://isitgonedown.com/social-images/instagram"

    # ── Step 1: Fetch Google Sheet ────────────────────────────────────────────
    "Fetching Google Sheet..." | Add-Content $logFile
    $csvUrl  = "https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv&gid=0"
    $csvResp = Invoke-WebRequest -Uri $csvUrl -UseBasicParsing -ErrorAction Stop
    $csvText = [System.Text.Encoding]::UTF8.GetString($csvResp.Content)
    "Sheet fetched, length=$($csvText.Length)" | Add-Content $logFile

    # Parse rows
    $rows    = $csvText -split "`n" | ForEach-Object { $_.Trim("`r") }
    $headers = ($rows[0] -split ",") | ForEach-Object { $_.Trim('"').ToLower() }
    "Headers: $($headers -join '|')" | Add-Content $logFile

    $colDay = $colDate = $colTw = $colLi = $colFb = -1
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $h = $headers[$i]
        if ($h -eq "day")           { $colDay  = $i }
        if ($h -like "*post*date*" -or $h -eq "post date") { $colDate  = $i }
        if ($h -like "*twitter*")   { $colTw   = $i }
        if ($h -like "*linkedin*")  { $colLi   = $i }
        if ($h -like "*facebook*")  { $colFb   = $i }
    }
    "Cols: day=$colDay date=$colDate twitter=$colTw linkedin=$colLi facebook=$colFb" | Add-Content $logFile

    # Simple CSV field splitter
    function Split-Csv($line) {
        $fields = @(); $inQ = $false; $cur = ""
        foreach ($ch in $line.ToCharArray()) {
            if ($ch -eq '"')                      { $inQ = -not $inQ }
            elseif ($ch -eq ',' -and -not $inQ)   { $fields += $cur; $cur = "" }
            else                                   { $cur += $ch }
        }
        $fields += $cur
        return $fields
    }

    $dayData = @{}
    for ($r = 1; $r -lt $rows.Count; $r++) {
        if ($rows[$r].Trim() -eq "") { continue }
        $c = Split-Csv $rows[$r]
        $dayNum = 0
        try { $dayNum = [int]($c[$colDay].Trim()) } catch { continue }
        if ($dayNum -lt 6 -or $dayNum -gt 30) { continue }
        $isoTime = ""
        if ($colDate -ge 0 -and $c.Count -gt $colDate) {
            try { $isoTime = ([datetime]::Parse($c[$colDate].Trim())).ToString("yyyy-MM-dd") + "T09:00:00.000Z" } catch {}
        }
        $dayData[$dayNum] = @{
            date     = $isoTime
            twitter  = if ($colTw -ge 0 -and $c.Count -gt $colTw)  { $c[$colTw].Trim()  } else { "" }
            linkedin = if ($colLi -ge 0 -and $c.Count -gt $colLi)  { $c[$colLi].Trim()  } else { "" }
            facebook = if ($colFb -ge 0 -and $c.Count -gt $colFb)  { $c[$colFb].Trim()  } else { "" }
        }
    }
    "Days parsed: $($dayData.Count)" | Add-Content $logFile

    $parseMsg = "Columns: day=$colDay date=$colDate twitter=$colTw linkedin=$colLi facebook=$colFb`nDays 6-30 found: $($dayData.Count)"
    [System.Windows.Forms.MessageBox]::Show($parseMsg, "Step 1: Sheet Parsed") | Out-Null

    if ($dayData.Count -eq 0) { throw "No day data found in sheet" }

    # ── Step 2: Create posts ──────────────────────────────────────────────────
    $hPost = @{ "blotato-api-key" = $apiKey; "Content-Type" = "application/json" }

    $platforms = @(
        @{ name="facebook"; acct="25818"; plat="facebook"; tt="facebook"; pageId=$fbPageId }
        @{ name="twitter";  acct="15712"; plat="twitter";  tt="twitter";  pageId=$null }
        @{ name="linkedin"; acct="17133"; plat="linkedin"; tt="linkedin"; pageId=$null }
    )

    $results = ""
    foreach ($cfg in $platforms) {
        $ok = 0; $fail = 0; $firstErr = ""
        "--- $($cfg.name) ---" | Add-Content $logFile

        foreach ($day in ($dayData.Keys | Sort-Object)) {
            $d = $dayData[$day]
            if ($d.date -eq "") { "Day $day skipped (no date)" | Add-Content $logFile; continue }

            $cap = switch ($cfg.name) {
                "facebook" { $d.facebook }
                "twitter"  { $d.twitter  }
                "linkedin" { $d.linkedin }
            }
            if ($cap -eq "") { $cap = "Check if your favourite website is down at IsItGoneDown.com" }

            $tgt = @{ targetType = $cfg.tt }
            if ($cfg.pageId) { $tgt["pageId"] = $cfg.pageId }

            $body = @{
                post = @{
                    accountId = $cfg.acct
                    content   = @{ text = $cap; mediaUrls = @("$imageBase/day-$day.jpg"); platform = $cfg.plat }
                    target    = $tgt
                }
                scheduledTime = $d.date
            } | ConvertTo-Json -Depth 10

            $delay = if ($cfg.name -eq "twitter") { 5 } else { 1 }
            Start-Sleep -Seconds $delay

            try {
                $r = Invoke-RestMethod -Uri "$baseUrl/posts" -Method Post -Headers $hPost -Body $body -ErrorAction Stop
                $ok++
                "Day $day OK id=$($r.postSubmissionId)" | Add-Content $logFile
            } catch {
                $fail++
                $sc = 0; try { $sc = $_.Exception.Response.StatusCode.value__ } catch {}
                $eb = $_.ErrorDetails.Message
                if (-not $eb) {
                    try { $stream=$_.Exception.Response.GetResponseStream(); $eb=(New-Object System.IO.StreamReader($stream)).ReadToEnd() } catch {}
                }
                "Day $day FAIL $sc $eb" | Add-Content $logFile
                if ($firstErr -eq "") { $firstErr = "Day $day ($sc): $eb" }
            }
        }
        $line = "$($cfg.name.ToUpper()): $ok OK, $fail FAIL"
        if ($firstErr) { $line += "`n  First err: $firstErr" }
        $results += $line + "`n"
        $results | Add-Content $logFile
    }

    [System.Windows.Forms.MessageBox]::Show($results, "Done - Results") | Out-Null

} catch {
    $msg = "CRASH: $_`n`nAt: $($_.InvocationInfo.PositionMessage)"
    $msg | Add-Content $logFile
    try { [System.Windows.Forms.MessageBox]::Show($msg, "Script Error") | Out-Null } catch {}
}

"Script ended $(Get-Date)" | Add-Content $logFile
