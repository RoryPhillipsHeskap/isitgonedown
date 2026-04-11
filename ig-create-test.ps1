# Test creating one Instagram post with CORRECT body structure
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$headers = @{
    "blotato-api-key" = $apiKey
    "Accept"          = "*/*"
}

$bodyObj = @{
    post = @{
        accountId = "39553"
        content   = @{
            text      = "Down for everyone, or just you? Find out in seconds at isitgonedown.com - the fastest way to check if any site is really down or if it's just on your end."
            mediaUrls = @("https://isitgonedown.com/social-images/instagram/day-6.jpg")
            platform  = "instagram"
        }
        target    = @{
            targetType = "instagram"
        }
    }
    scheduledTime = "2026-04-12T09:00:00.000Z"
}
$bodyJson = $bodyObj | ConvertTo-Json -Depth 10

$msg = "POST body:`n$bodyJson`n`n"

try {
    $r = Invoke-RestMethod -Uri "$baseUrl/posts" -Method Post -Headers $headers -Body $bodyJson -ContentType "application/json"
    $msg += "SUCCESS! Response:`n$($r | ConvertTo-Json -Depth 5)"
} catch {
    $sc = $_.Exception.Response.StatusCode.value__
    $body = ""
    try {
        $s = $_.Exception.Response.GetResponseStream()
        $sr = New-Object System.IO.StreamReader($s)
        $body = $sr.ReadToEnd()
    } catch { $body = "(could not read)" }
    $msg += "ERROR: $sc`nBody: $body"
}

[System.Windows.Forms.MessageBox]::Show($msg, "Create Test v2") | Out-Null
