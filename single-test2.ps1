# Single post test v2 - captures full error body via Invoke-WebRequest
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"

function TryPost($label, $accountId, $platField, $targetType) {
    $headers = @{ "blotato-api-key" = $apiKey }
    $body = @{
        post = @{
            accountId = $accountId
            content   = @{ text = "Test $label post"; platform = $platField }
            target    = @{ targetType = $targetType }
        }
        scheduledTime = "2026-04-20T09:00:00.000Z"
    } | ConvertTo-Json -Depth 10

    try {
        $resp = Invoke-WebRequest -Uri "$baseUrl/posts" -Method Post -Headers $headers -Body $body -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
        return "OK $($resp.StatusCode): $($resp.Content)"
    } catch {
        $sc = 0
        try { $sc = $_.Exception.Response.StatusCode.value__ } catch {}
        # Try ErrorDetails first (most reliable in PS5)
        $eb = $_.ErrorDetails.Message
        if (-not $eb -or $eb.Length -eq 0) {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $eb = $reader.ReadToEnd()
            } catch { $eb = "(stream read failed)" }
        }
        return "FAIL $sc`: $eb"
    }
}

$results = ""

# Just one test each - get the actual error message
$results += "=== FACEBOOK (acct=25818, platform=facebook, target=facebook) ===`n"
$results += (TryPost "fb" "25818" "facebook" "facebook") + "`n`n"

$results += "=== TWITTER (acct=15712, platform=twitter, target=twitter) ===`n"
$results += (TryPost "tw" "15712" "twitter" "twitter") + "`n`n"

$results += "=== LINKEDIN (acct=17133, platform=linkedin, target=linkedin) ===`n"
$results += (TryPost "li" "17133" "linkedin" "linkedin") + "`n"

[System.Windows.Forms.MessageBox]::Show($results, "Error Detail Test") | Out-Null
