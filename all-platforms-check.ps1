# Check all platforms currently scheduled in Blotato
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

$counts = @{}
$cursor = $null
$total = 0

do {
    $url = "$baseUrl/schedules?limit=100"
    if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }
    $r = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    foreach ($item in $r.items) {
        $plat = $item.draft.content.platform
        if (-not $plat) { $plat = "(unknown)" }
        if (-not $counts[$plat]) { $counts[$plat] = @{ total=0; withMedia=0; noMedia=0 } }
        $counts[$plat].total++
        $total++
        $media = $item.draft.content.mediaUrls
        if ($media -and $media.Count -gt 0) {
            $counts[$plat].withMedia++
        } else {
            $counts[$plat].noMedia++
        }
    }
    $cursor = $r.cursor
} while ($cursor)

$msg = "Total scheduled posts: $total`n`n"
foreach ($plat in ($counts.Keys | Sort-Object)) {
    $c = $counts[$plat]
    $msg += "$plat`: $($c.total) total  ($($c.withMedia) with image, $($c.noMedia) without image)`n"
}

[System.Windows.Forms.MessageBox]::Show($msg, "All Platforms Check") | Out-Null
