# Single post test - shows full error for each platform
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"

function TryPost($label, $accountId, $platform, $targetType) {
    $headers = @{ "blotato-api-key" = $apiKey }
    $body = @{
        post = @{
            accountId = $accountId
            content   = @{ text = "Test $label post"; platform = $platform }
            target    = @{ targetType = $targetType }
        }
        scheduledTime = "2026-04-20T09:00:00.000Z"
    } | ConvertTo-Json -Depth 10

    try {
        $r = Invoke-RestMethod -Uri "$baseUrl/posts" -Method Post -Headers $headers -Body $body -ContentType "application/json"
        return "OK - id=$($r.postSubmissionId)"
    } catch {
        $sc = 0
        $eb = "(no body)"
        try { $sc = $_.Exception.Response.StatusCode.value__ } catch {}
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $eb = $reader.ReadToEnd()
        } catch {}
        return "FAIL $sc`: $eb"
    }
}

$results = ""

# Facebook - try a few targetType values
$results += "=== FACEBOOK (id=25818) ===`n"
foreach ($tt in @("facebook", "facebookPage", "page", "FACEBOOK_PAGE")) {
    $r = TryPost "facebook" "25818" "facebook" $tt
    $results += "  targetType=$tt`: $r`n"
    if ($r -like "OK*") { break }
    Start-Sleep -Milliseconds 300
}

$results += "`n=== TWITTER (id=15712) ===`n"
foreach ($tt in @("twitter", "x", "X", "tweet")) {
    $r = TryPost "twitter" "15712" "twitter" $tt
    $results += "  targetType=$tt`: $r`n"
    if ($r -like "OK*") { break }
    Start-Sleep -Seconds 3
}

$results += "`n=== LINKEDIN (id=17133) ===`n"
foreach ($tt in @("linkedin", "LINKEDIN", "linkedIn", "linkedinProfile")) {
    $r = TryPost "linkedin" "17133" "linkedin" $tt
    $results += "  targetType=$tt`: $r`n"
    if ($r -like "OK*") { break }
    Start-Sleep -Milliseconds 300
}

[System.Windows.Forms.MessageBox]::Show($results, "Single Post Test") | Out-Null
