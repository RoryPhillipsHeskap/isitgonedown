# Full Instagram fix: delete all bad schedules + recreate Days 6-30 with permanent Netlify URLs
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$logFile = "C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-instagram-fix-log.txt"
$imageBase = "https://isitgonedown.com/social-images/instagram"
$instagramAccountId = "39553"

$headers = @{
    "blotato-api-key" = $apiKey
    "Accept"          = "*/*"
}
$headersPost = @{
    "blotato-api-key" = $apiKey
    "Accept"          = "*/*"
    "Content-Type"    = "application/json"
}

function Log {
    param([string]$msg)
    $line = "$(Get-Date -Format 'HH:mm:ss'): $msg"
    Write-Host $line
    $line | Out-File -FilePath $logFile -Encoding UTF8 -Append
}

"=== Instagram Fix Script - $(Get-Date) ===" | Out-File -FilePath $logFile -Encoding UTF8
Log "Script started"

# ============================================================
# STEP 1: Collect all Instagram schedule IDs
# ============================================================
Log "STEP 1: Collecting all Instagram schedule IDs..."
$instagramIds = [System.Collections.Generic.List[string]]::new()
$cursor = $null

do {
    $url = "$baseUrl/schedules?limit=100"
    if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }

    try {
        $resp = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        $count = if ($resp.items) { $resp.items.Count } else { 0 }
        Log "  Page: $count items"

        if ($resp.items) {
            foreach ($item in $resp.items) {
                $platform = $item.draft.content.platform
                if ($platform -eq "instagram") {
                    $instagramIds.Add($item.id)
                    $media = if ($item.draft.content.mediaUrls) { $item.draft.content.mediaUrls -join ", " } else { "(none)" }
                    Log "  Found Instagram ID=$($item.id) scheduledAt=$($item.scheduledAt) media=$media"
                }
            }
        }
        $cursor = $resp.cursor
    } catch {
        Log "  ERROR fetching page: $($_.Exception.Message)"
        break
    }
} while ($cursor)

Log "Total Instagram schedules found: $($instagramIds.Count)"

# ============================================================
# STEP 2: Delete all Instagram schedules
# ============================================================
Log ""
Log "STEP 2: Deleting $($instagramIds.Count) Instagram schedules..."
$deleted = 0; $deleteFailed = 0

foreach ($id in $instagramIds) {
    try {
        $delResp = Invoke-WebRequest -Uri "$baseUrl/schedules/$id" -Method Delete -Headers $headers -UseBasicParsing
        Log "  DELETE schedules/$($id): OK ($($delResp.StatusCode))"
        $deleted++
    } catch {
        $sc = $_.Exception.Response.StatusCode.value__
        $body = ""
        try {
            $s = $_.Exception.Response.GetResponseStream()
            $r = New-Object System.IO.StreamReader($s)
            $body = $r.ReadToEnd()
        } catch {}
        Log "  DELETE schedules/$($id) FAILED ($($sc)): $body"

        # Try posts endpoint
        try {
            $altResp = Invoke-WebRequest -Uri "$baseUrl/posts/$id" -Method Delete -Headers $headers -UseBasicParsing
            Log "  Alt DELETE posts/$($id): OK ($($altResp.StatusCode))"
            $deleted++
        } catch {
            $sc2 = $_.Exception.Response.StatusCode.value__
            $b2 = ""
            try {
                $s2 = $_.Exception.Response.GetResponseStream()
                $r2 = New-Object System.IO.StreamReader($s2)
                $b2 = $r2.ReadToEnd()
            } catch {}
            Log "  Alt DELETE posts/$($id) FAILED ($($sc2)): $b2"
            $deleteFailed++
        }
    }
}
Log "Deletes: $deleted OK, $deleteFailed failed"

# ============================================================
# STEP 3: Create new Instagram posts Days 6-30
# ============================================================
Log ""
Log "STEP 3: Creating Instagram posts Days 6-30..."

$posts = @(
    @{ day=6;  date="2026-04-12T09:00:00.000Z"; caption="Down for everyone, or just you? Find out in seconds at isitgonedown.com - the fastest way to check if any site is really down or if it's just on your end." },
    @{ day=7;  date="2026-04-13T09:00:00.000Z"; caption="Bookmark of the week: isitgonedown.com - so next time your favourite site goes dark, you're not sitting there wondering if it's just you." },
    @{ day=8;  date="2026-04-14T09:00:00.000Z"; caption="Is your favourite app down? Before you restart your router or blame your internet, check isitgonedown.com - real-time outage detection for any website." },
    @{ day=9;  date="2026-04-15T09:00:00.000Z"; caption="The site that tells you if a site is down. Simple, fast, free. isitgonedown.com" },
    @{ day=10; date="2026-04-16T09:00:00.000Z"; caption="Major outage alert system: isitgonedown.com tracks outages across hundreds of sites in real time. Bookmark it before you need it." },
    @{ day=11; date="2026-04-17T09:00:00.000Z"; caption="Weekend tip: bookmark isitgonedown.com. You'll thank yourself next time Netflix, Spotify, or your bank goes down." },
    @{ day=12; date="2026-04-18T09:00:00.000Z"; caption="Bookmark of the week: isitgonedown.com - so next time your favourite site goes dark, you're not sitting there wondering if it's just you." },
    @{ day=13; date="2026-04-19T09:00:00.000Z"; caption="Is Ryanair down right now? Is Revolut having issues? Check isitgonedown.com for instant answers - no sign-up, no fuss." },
    @{ day=14; date="2026-04-20T09:00:00.000Z"; caption="You check your phone when a site is slow. You ask Google if it's down. Or... you just go straight to isitgonedown.com" },
    @{ day=15; date="2026-04-21T09:00:00.000Z"; caption="Real-time outage detection. Community voting. Instant results. isitgonedown.com - your first stop when any website seems off." },
    @{ day=16; date="2026-04-22T09:00:00.000Z"; caption="Tech tip: isitgonedown.com uses community voting + automated checks to tell you if a site is really down - not just slow on your end." },
    @{ day=17; date="2026-04-23T09:00:00.000Z"; caption="Down for everyone, or just you? Stop guessing. isitgonedown.com gives you the answer instantly." },
    @{ day=18; date="2026-04-24T09:00:00.000Z"; caption="Is AIB online banking down? Is Ticketmaster having issues? isitgonedown.com covers Irish, UK, US and global sites. Check it now." },
    @{ day=19; date="2026-04-25T09:00:00.000Z"; caption="Before you spend 20 minutes troubleshooting your connection, spend 5 seconds at isitgonedown.com" },
    @{ day=20; date="2026-04-26T09:00:00.000Z"; caption="No app needed. No account needed. Just go to isitgonedown.com and find out if any website is down right now." },
    @{ day=21; date="2026-04-27T09:00:00.000Z"; caption="Community-powered outage detection. When thousands of users report the same issue, isitgonedown.com knows about it instantly." },
    @{ day=22; date="2026-04-28T09:00:00.000Z"; caption="Ever been in the middle of something important when a website goes down? isitgonedown.com is the tool that tells you it's not just you." },
    @{ day=23; date="2026-04-29T09:00:00.000Z"; caption="Global outage tracking. Irish sites. UK sites. US giants. European platforms. isitgonedown.com covers them all." },
    @{ day=24; date="2026-04-30T09:00:00.000Z"; caption="When WhatsApp goes down, the world panics. When you use isitgonedown.com, you just calmly check and wait." },
    @{ day=25; date="2026-05-01T09:00:00.000Z"; caption="Did you know? The biggest recorded outage in history was Facebook in 2021 - 6 hours down, affecting 3.5 billion users. isitgonedown.com would have caught it in seconds." },
    @{ day=26; date="2026-05-02T09:00:00.000Z"; caption="Pro tip: add isitgonedown.com to your browser's speed dial. When things break online, you'll want it there immediately." },
    @{ day=27; date="2026-05-03T09:00:00.000Z"; caption="Is Amazon down? Is Booking.com having issues? Is ChatGPT offline? isitgonedown.com has real-time status for all of them." },
    @{ day=28; date="2026-05-04T09:00:00.000Z"; caption="The internet goes down more than you think. isitgonedown.com tracks it so you don't have to." },
    @{ day=29; date="2026-05-05T09:00:00.000Z"; caption="30 days of helping you figure out what's down and what's just you. Thank you for following isitgonedown.com - the site that checks the sites." },
    @{ day=30; date="2026-05-06T09:00:00.000Z"; caption="From Netflix to your local bank - if it's online, isitgonedown.com can tell you if it's down. Real-time. Free. No sign-up." }
)

$created = 0; $createFailed = 0

foreach ($p in $posts) {
    $imgUrl = "$imageBase/day-$($p.day).jpg"

    $bodyObj = @{
        post = @{
            accountId = $instagramAccountId
            content   = @{
                text      = $p.caption
                mediaUrls = @($imgUrl)
                platform  = "instagram"
            }
            target    = @{
                targetType = "instagram"
            }
        }
        scheduledTime = $p.date
    }
    $bodyJson = $bodyObj | ConvertTo-Json -Depth 10

    try {
        $postResp = Invoke-WebRequest -Uri "$baseUrl/posts" -Method Post -Headers $headersPost -Body $bodyJson -UseBasicParsing
        Log "  Day $($p.day) ($($p.date)): $($postResp.StatusCode) - $($postResp.Content)"
        $created++
    } catch {
        $sc = $_.Exception.Response.StatusCode.value__
        $eb = ""
        try {
            $es = $_.Exception.Response.GetResponseStream()
            $er = New-Object System.IO.StreamReader($es)
            $eb = $er.ReadToEnd()
        } catch {}
        Log "  Day $($p.day) FAILED ($sc): $eb"
        $createFailed++
    }

    Start-Sleep -Milliseconds 400
}

Log ""
Log "=== SUMMARY ==="
Log "Instagram IDs found:   $($instagramIds.Count)"
Log "Deleted:               $deleted"
Log "Delete failed:         $deleteFailed"
Log "Created:               $created"
Log "Create failed:         $createFailed"
Log "Done at $(Get-Date)"
