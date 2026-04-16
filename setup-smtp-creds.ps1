# One-time: prompts you for the Gmail app password and saves encrypted credentials.
# The resulting XML file can only be decrypted by this Windows user on this machine
# (DPAPI-encrypted via Export-Clixml). Safe to keep on disk.

$credFile = 'C:\Users\Rory\Documents\GitHub\isitgonedown\smtp-creds.xml'

Write-Host ""
Write-Host "Gmail App Password Setup" -ForegroundColor Cyan
Write-Host "========================"
Write-Host ""
Write-Host "This will save encrypted SMTP credentials for admin@isitgonedown.com"
Write-Host "to: $credFile"
Write-Host ""
Write-Host "You'll need:"
Write-Host "  - Username: admin@isitgonedown.com"
Write-Host "  - Password: the 16-character Google App Password (NOT your normal password)"
Write-Host ""
Write-Host "To create an App Password first:"
Write-Host "  1. Sign into admin@isitgonedown.com"
Write-Host "  2. Go to https://myaccount.google.com/apppasswords"
Write-Host "  3. If prompted, enable 2-Step Verification first"
Write-Host "  4. Create a new App Password labelled 'IsItGoneDown Daily Check'"
Write-Host "  5. Copy the 16-char code — you'll paste it when prompted below"
Write-Host ""

$cred = Get-Credential -UserName 'admin@isitgonedown.com' -Message 'Enter the Google App Password (not your normal password)'

if (-not $cred) {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 1
}

$cred | Export-Clixml -Path $credFile
Write-Host ""
Write-Host "✅ Saved encrypted credentials to $credFile" -ForegroundColor Green
Write-Host ""
Write-Host "You can now test by running: blotato-daily-v2.ps1"
Write-Host ""
Read-Host "Press Enter to close"
