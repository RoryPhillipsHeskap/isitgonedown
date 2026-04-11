Add-Type -AssemblyName System.Windows.Forms
$apiKey = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU='
$h = @{ 'blotato-api-key' = $apiKey }
$counts = @{ facebook=0; twitter=0; linkedin=0; instagram=0 }
$page = 1
do {
    $resp = Invoke-RestMethod -Uri "https://backend.blotato.com/v2/schedules?page=$page&limit=50" -Headers $h
    foreach ($s in $resp.schedules) {
        $plat = $s.post.content.platform
        if ($counts.ContainsKey($plat)) { $counts[$plat]++ }
    }
    $page++
} while ($resp.schedules.Count -eq 50)
$msg = "Current scheduled posts:`n"
foreach ($k in @('facebook','twitter','linkedin','instagram')) { $msg += "  $k`: $($counts[$k])`n" }
[System.Windows.Forms.MessageBox]::Show($msg, 'Platform Counts') | Out-Null
