# Sample a few posts from each platform to see content
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

$byPlatform = @{}
$cursor = $null

do {
    $url = "$baseUrl/schedules?limit=100"
    if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }
    $r = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    foreach ($item in $r.items) {
        $plat = $item.draft.content.platform
        if (-not $plat) { continue }
        if (-not $byPlatform[$plat]) { $byPlatform[$plat] = @() }
        $byPlatform[$plat] += $item
    }
    $cursor = $r.cursor
} while ($cursor)

$msg = ""
foreach ($plat in @("facebook","twitter","linkedin")) {
    $items = $byPlatform[$plat]
    if (-not $items) { $msg += "${plat}: none`n`n"; continue }
    # Sort by scheduledAt, take first 2
    $sorted = $items | Sort-Object { $_.scheduledAt } | Select-Object -First 2
    $msg += "${plat} (showing 2 of $($items.Count)):`n"
    foreach ($i in $sorted) {
        $text = $i.draft.content.text
        if ($text.Length -gt 80) { $text = $text.Substring(0,80) + "..." }
        $msg += "  ID=$($i.id) date=$($i.scheduledAt.Substring(0,10))`n"
        $msg += "  text: $text`n"
    }
    $msg += "`n"
}

[System.Windows.Forms.MessageBox]::Show($msg, "Platform Sample") | Out-Null
