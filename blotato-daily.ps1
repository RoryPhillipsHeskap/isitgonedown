$ErrorActionPreference = 'Stop'
try {
    $headers = @{ 'api-key' = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU=' }
    $allItems = @()
    $cursor = $null
    do {
        $url = 'https://backend.blotato.com/v2/schedules?limit=100'
        if ($cursor) { $url += "&cursor=$cursor" }
        $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        $allItems += $resp.items
        $cursor = $resp.nextCursor
    } while ($cursor)
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $todayPosts = $allItems | Where-Object { $_.scheduledTime -like "$today*" }
    $out = "DATE=$today`r`nTOTAL=$($todayPosts.Count)`r`n"
    foreach ($p in $todayPosts) {
        $out += "$($p.draft.content.platform)|$($p.status)|$($p.scheduledTime)`r`n"
    }
    $out | Out-File -FilePath 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-daily-result.txt' -Encoding utf8
} catch {
    "ERROR: $_" | Out-File -FilePath 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-daily-result.txt' -Encoding utf8
}
