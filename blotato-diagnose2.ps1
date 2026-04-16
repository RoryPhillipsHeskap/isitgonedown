$ErrorActionPreference = 'Stop'
$outFile = 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-diagnose2-out.txt'
try {
    $headers = @{ 'blotato-api-key' = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU=' }
    $allItems = @()
    $cursor = $null
    do {
        $url = 'https://backend.blotato.com/v2/schedules?limit=100'
        if ($cursor) { $url += "&cursor=$([System.Uri]::EscapeDataString($cursor))" }
        $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        if ($resp.items) { $allItems += $resp.items }
        $cursor = $resp.cursor
    } while ($cursor)

    $today = (Get-Date).ToString('yyyy-MM-dd')
    $yesterday = (Get-Date).AddDays(-1).ToString('yyyy-MM-dd')
    $lines = @()
    $lines += "DATE=$today"
    $lines += "ALL_SCHEDULED=$($allItems.Count)"
    $lines += ""
    $lines += "=== UNIQUE DATES IN SCHEDULE ==="
    $dates = $allItems | Where-Object { $_.scheduledTime } | ForEach-Object { $_.scheduledTime.Substring(0,10) } | Sort-Object -Unique
    foreach ($d in $dates) {
        $count = ($allItems | Where-Object { $_.scheduledTime -like "$d*" }).Count
        $lines += "$d : $count posts"
    }
    $lines += ""
    $lines += "=== STATUS BREAKDOWN ==="
    $statuses = $allItems | Group-Object { $_.status } | Sort-Object Count -Descending
    foreach ($s in $statuses) {
        $lines += "$($s.Name): $($s.Count)"
    }
    $lines += ""
    $lines += "=== SAMPLE ITEMS (first 5) ==="
    $allItems | Select-Object -First 5 | ForEach-Object {
        $lines += "scheduledTime=$($_.scheduledTime) status=$($_.status) platform=$($_.draft.content.platform)"
    }
    $lines | Set-Content -Path $outFile -Encoding utf8
} catch {
    Set-Content -Path $outFile -Value "ERROR: $_" -Encoding utf8
}
