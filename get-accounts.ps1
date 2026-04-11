# Get Blotato accounts to see platform types
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/accounts" -Method Get -Headers $headers
    $msg = ($r | ConvertTo-Json -Depth 5)
    if ($msg.Length -gt 3000) { $msg = $msg.Substring(0, 3000) + "..." }
} catch {
    $sc = $_.Exception.Response.StatusCode.value__
    $eb = ""
    try { $s=$_.Exception.Response.GetResponseStream(); $sr=New-Object System.IO.StreamReader($s); $eb=$sr.ReadToEnd() } catch {}
    $msg = "ERROR $sc`: $eb"
}

[System.Windows.Forms.MessageBox]::Show($msg, "Blotato Accounts") | Out-Null
