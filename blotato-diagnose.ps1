# Diagnostic: dump first few schedule items to see structure
$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$baseUrl = "https://backend.blotato.com/v2"
$outFile = "C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-diagnose-out.txt"

$headers = @{
    "blotato-api-key" = $apiKey
    "Accept" = "*/*"
}

# Get first page of schedules
$response = Invoke-RestMethod -Uri "$baseUrl/schedules?limit=5" -Method Get -Headers $headers -ContentType "application/json"

# Dump full structure
$response | ConvertTo-Json -Depth 10 | Out-File -FilePath $outFile -Encoding UTF8

# Also try getting posts directly
try {
    $postsResp = Invoke-RestMethod -Uri "$baseUrl/posts?limit=5" -Method Get -Headers $headers -ContentType "application/json"
    "`n`n=== POSTS endpoint ===" | Out-File -FilePath $outFile -Encoding UTF8 -Append
    $postsResp | ConvertTo-Json -Depth 10 | Out-File -FilePath $outFile -Encoding UTF8 -Append
} catch {
    "`n`nPosts endpoint failed: $_" | Out-File -FilePath $outFile -Encoding UTF8 -Append
}

Write-Host "Done. Check blotato-diagnose-out.txt"
