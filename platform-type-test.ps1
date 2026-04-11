# Test different targetType values for each platform
Add-Type -AssemblyName System.Windows.Forms

$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$headers = @{ "blotato-api-key" = $apiKey; "Accept" = "*/*" }

function TryCreate($platform, $accountId, $targetType, $platContent) {
    $body = @{
        post = @{
            accountId = $accountId
            content   = @{ text = "Test post for $platform"; platform = $platContent }
            target    = @{ targetType = $targetType }
        }
        scheduledTime = "2026-04-20T09:00:00.000Z"
    } | ConvertTo-Json -Depth 10

    try {
        $r = Invoke-RestMethod -Uri "$baseUrl/posts" -Method Post -Headers $headers -Body $body -ContentType "application/json"
        return "OK - submissionId=$($r.postSubmissionId)"
    } catch {
        $sc = $_.Exception.Response.StatusCode.value__
        $eb = ""
        try {
            $s = $_.Exception.Response.GetResponseStream()
            $sr = New-Object System.IO.StreamReader($s)
            $eb = $sr.ReadToEnd()
        } catch { $eb = "(no body)" }
        return "FAIL $sc: $eb"
    }
}

$results = ""

# FACEBOOK - try different targetTypes
$results += "=== FACEBOOK (accountId=25818) ===`n"
foreach ($tt in @("facebook","facebookPage","facebook_page","FACEBOOK")) {
    $r = TryCreate "facebook" "25818" $tt "facebook"
    $results += "  targetType='$tt': $r`n"
    Start-Sleep -Milliseconds 500
    if ($r -like "OK*") { break }
}

$results += "`n=== TWITTER (accountId=15712) ===`n"
foreach ($tt in @("twitter","x","X","TWITTER")) {
    $r = TryCreate "twitter" "15712" $tt "twitter"
    $results += "  targetType='$tt': $r`n"
    Start-Sleep -Seconds 2
    if ($r -like "OK*") { break }
}

$results += "`n=== LINKEDIN (accountId=17133) ===`n"
foreach ($tt in @("linkedin","LINKEDIN","linkedIn")) {
    $r = TryCreate "linkedin" "17133" $tt "linkedin"
    $results += "  targetType='$tt': $r`n"
    Start-Sleep -Milliseconds 500
    if ($r -like "OK*") { break }
}

[System.Windows.Forms.MessageBox]::Show($results, "Platform Type Test") | Out-Null
