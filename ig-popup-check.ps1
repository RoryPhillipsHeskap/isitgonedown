# Quick popup check: count Instagram schedules currently in Blotato
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

$all = @(); $noMedia = @(); $withMedia = @(); $cursor = $null
do {
    $url = "$baseUrl/schedules?limit=100"
    if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }
    $r = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    foreach ($item in $r.items) {
        if ($item.draft.content.platform -eq "instagram") {
            $all += $item.id
            $media = $item.draft.content.mediaUrls
            if ($media -and $media.Count -gt 0) {
                $withMedia += "$($item.id)|$($item.scheduledAt)"
            } else {
                $noMedia += "$($item.id)|$($item.scheduledAt)"
            }
        }
    }
    $cursor = $r.cursor
} while ($cursor)

$msg = "Total Instagram: $($all.Count)`n`nWith images: $($withMedia.Count)`n"
foreach ($m in $withMedia) { $msg += "  $m`n" }
$msg += "`nWithout images: $($noMedia.Count)`n"
foreach ($m in $noMedia) { $msg += "  $m`n" }

[System.Windows.Forms.MessageBox]::Show($msg, "Blotato Instagram Check") | Out-Null
