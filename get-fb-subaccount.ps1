Add-Type -AssemblyName System.Windows.Forms
$apiKey = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU='
$h = @{ 'blotato-api-key' = $apiKey }

$results = ''

# Try various endpoints to find Facebook sub-accounts/pages
$endpoints = @(
    'https://backend.blotato.com/v2/accounts',
    'https://backend.blotato.com/v2/accounts/25818',
    'https://backend.blotato.com/v2/accounts/25818/subaccounts',
    'https://backend.blotato.com/v2/accounts/25818/pages',
    'https://backend.blotato.com/v1/accounts',
    'https://backend.blotato.com/v2/social-accounts',
    'https://backend.blotato.com/v2/profiles'
)

foreach ($url in $endpoints) {
    try {
        $r = Invoke-WebRequest -Uri $url -Headers $h -UseBasicParsing -ErrorAction Stop
        $results += "OK $url`n$($r.Content.Substring(0,[Math]::Min(300,$r.Content.Length)))`n`n"
    } catch {
        $sc = 0; try { $sc = $_.Exception.Response.StatusCode.value__ } catch {}
        $results += "FAIL $sc`: $url`n"
    }
}

[System.Windows.Forms.MessageBox]::Show($results, 'Blotato Account Endpoints') | Out-Null
