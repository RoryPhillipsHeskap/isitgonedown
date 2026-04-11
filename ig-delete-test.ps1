# Test DELETE on one schedule ID to see the exact error
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

$testId = "701369"
$msg = "Testing DELETE on ID $testId`n`n"

# Try /v2/schedules/{id}
try {
    $r = Invoke-WebRequest -Uri "$baseUrl/schedules/$testId" -Method Delete -Headers $headers -UseBasicParsing
    $msg += "DELETE /schedules/$testId => $($r.StatusCode) $($r.StatusDescription)`nBody: $($r.Content)"
} catch {
    $sc = $_.Exception.Response.StatusCode.value__
    $body = ""
    try {
        $s = $_.Exception.Response.GetResponseStream()
        $sr = New-Object System.IO.StreamReader($s)
        $body = $sr.ReadToEnd()
    } catch { $body = "(could not read body)" }
    $msg += "DELETE /schedules/$testId => ERROR $sc`nBody: $body`n`n"
}

# Try /v2/posts/{id}
try {
    $r2 = Invoke-WebRequest -Uri "$baseUrl/posts/$testId" -Method Delete -Headers $headers -UseBasicParsing
    $msg += "DELETE /posts/$testId => $($r2.StatusCode) $($r2.StatusDescription)`nBody: $($r2.Content)"
} catch {
    $sc2 = $_.Exception.Response.StatusCode.value__
    $body2 = ""
    try {
        $s2 = $_.Exception.Response.GetResponseStream()
        $sr2 = New-Object System.IO.StreamReader($s2)
        $body2 = $sr2.ReadToEnd()
    } catch { $body2 = "(could not read body)" }
    $msg += "DELETE /posts/$testId => ERROR $sc2`nBody: $body2"
}

[System.Windows.Forms.MessageBox]::Show($msg, "DELETE Test") | Out-Null
