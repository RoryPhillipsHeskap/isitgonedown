$ErrorActionPreference = 'Stop'
try {
    $headers = @{ 'api-key' = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU=' }
    $resp = Invoke-RestMethod -Uri 'https://backend.blotato.com/v2/schedules?limit=100' -Headers $headers -Method GET
    $items = $resp.items
    $today = $items | Where-Object { $_.scheduledTime -like '2026-04-12*' }
    $out = "Total items: $($items.Count)`r`nToday (Apr 12): $($today.Count)`r`n`r`n"
    foreach ($p in $today) {
        $platform = $p.draft.content.platform
        $status = $p.status
        $time = $p.scheduledTime
        $out += "$platform | $time | $status`r`n"
    }
    $out | Out-File -FilePath "$env:USERPROFILE\Desktop\blotato-check.txt" -Encoding utf8
    "SUCCESS: $($today.Count) posts found for today. File saved to Desktop." | Out-File -FilePath "$env:USERPROFILE\Desktop\blotato-check.txt" -Append
} catch {
    "ERROR: $_" | Out-File -FilePath "$env:USERPROFILE\Desktop\blotato-check.txt" -Encoding utf8
}
