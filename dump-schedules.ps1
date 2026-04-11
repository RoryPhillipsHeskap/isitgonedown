Add-Type -AssemblyName System.Windows.Forms
$apiKey = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU='
$h = @{ 'blotato-api-key' = $apiKey }
$resp = Invoke-RestMethod -Uri "https://backend.blotato.com/v2/schedules?page=1&limit=5" -Headers $h
$raw = $resp | ConvertTo-Json -Depth 10
# Show top-level keys and first item
$keys = ($resp | Get-Member -MemberType NoteProperty).Name -join ', '
$msg = "Top-level keys: $keys`n`nTotal/Count field: $($resp.total) / $($resp.count)`n`nFirst 2000 chars of raw:`n" + $raw.Substring(0, [Math]::Min(2000, $raw.Length))
[System.Windows.Forms.MessageBox]::Show($msg, 'Raw Schedule Dump') | Out-Null
