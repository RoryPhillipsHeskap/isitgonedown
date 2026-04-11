# Quick check: count all Instagram schedules currently in Blotato
$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$out = "C:\Users\Rory\Documents\GitHub\isitgonedown\ig-check-out.txt"
$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

$all = @(); $cursor = $null
do {
    $url = "$baseUrl/schedules?limit=100"
    if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }
    $r = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    foreach ($item in $r.items) {
        if ($item.draft.content.platform -eq "instagram") {
            $all += "$($item.id)|$($item.scheduledAt)|$($item.draft.content.mediaUrls -join ',')"
        }
    }
    $cursor = $r.cursor
} while ($cursor)

"Total Instagram: $($all.Count)" | Set-Content -Path $out -Encoding UTF8
$all | Add-Content -Path $out -Encoding UTF8
Write-Host "Done. Found $($all.Count) Instagram schedules."
