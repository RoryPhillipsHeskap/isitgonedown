Add-Type -AssemblyName System.Windows.Forms
$apiKey = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU='
$h = @{ 'blotato-api-key' = $apiKey }
$counts = @{ facebook=0; twitter=0; linkedin=0; instagram=0 }
$page = 1
do {
    $resp = Invoke-RestMethod -Uri "https://backend.blotato.com/v2/schedules?page=$page&limit=50" -Headers $h
    foreach ($s in $resp.items) {
        $plat = $s.draft.content.platform
        if ($counts.ContainsKey($plat)) { $counts[$plat]++ }
    }
    $page++
} while ($resp.items.Count -eq 50)
$msg = "Scheduled posts per platform:`n`n"
foreach ($k in @('facebook','twitter','linkedin','instagram')) {
    $icon = if ($counts[$k] -eq 25) { 'OK' } else { 'WARN' }
    $msg += "  [$icon] $k`: $($counts[$k]) / 25`n"
}
[System.Windows.Forms.MessageBox]::Show($msg, 'Final Platform Check') | Out-Null
