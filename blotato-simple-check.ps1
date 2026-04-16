$outFile = 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-simple-out.txt'
try {
    $headers = @{ 'blotato-api-key' = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU=' }
    $resp = Invoke-RestMethod -Uri 'https://backend.blotato.com/v2/schedules?limit=100' -Headers $headers -Method GET
    $items = $resp.items
    $out = "COUNT=$($items.Count)`n"
    $out += "CURSOR=$($resp.cursor)`n`n"
    # Show first 10 items
    for ($i = 0; $i -lt [Math]::Min(10, $items.Count); $i++) {
        $p = $items[$i]
        $out += "[$i] time=$($p.scheduledTime) status=$($p.status) platform=$($p.draft.content.platform)`n"
    }
    # Count by date
    $out += "`nDATE COUNTS:`n"
    $dateCounts = @{}
    foreach ($p in $items) {
        if ($p.scheduledTime -and $p.scheduledTime.Length -ge 10) {
            $d = $p.scheduledTime.Substring(0,10)
            if ($dateCounts.ContainsKey($d)) { $dateCounts[$d]++ } else { $dateCounts[$d] = 1 }
        }
    }
    foreach ($d in ($dateCounts.Keys | Sort-Object)) {
        $out += "$d : $($dateCounts[$d])`n"
    }
    [System.IO.File]::WriteAllText($outFile, $out, [System.Text.Encoding]::UTF8)
} catch {
    [System.IO.File]::WriteAllText($outFile, "ERROR: $_", [System.Text.Encoding]::UTF8)
}
