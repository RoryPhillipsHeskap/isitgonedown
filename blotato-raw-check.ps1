$outFile = 'C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-raw-out.txt'
try {
    $headers = @{ 'blotato-api-key' = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU=' }
    $resp = Invoke-RestMethod -Uri 'https://backend.blotato.com/v2/schedules?limit=5' -Headers $headers -Method GET
    # Dump raw JSON of entire response
    $json = $resp | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($outFile, $json, [System.Text.Encoding]::UTF8)
} catch {
    [System.IO.File]::WriteAllText($outFile, "ERROR: $_", [System.Text.Encoding]::UTF8)
}
