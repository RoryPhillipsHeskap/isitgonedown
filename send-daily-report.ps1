$ErrorActionPreference = 'Stop'
try {
    $outlook = New-Object -ComObject Outlook.Application
    $mail = $outlook.CreateItem(0)
    $mail.To = "roryphillips@heskap.com"
    $mail.Subject = "✅ IsItGoneDown Posts 2026-04-12 — 4/4 published"
    $mail.Body = "Today's IsItGoneDown social posts (9 AM):

✅ Twitter/X — published
✅ LinkedIn — published
✅ Facebook — published
✅ Instagram — published

All 4 posts sent successfully.

---
Twitter: https://x.com/isitgonedown/status/2043252793239105738
LinkedIn: https://linkedin.com/feed/update/urn:li:share:7449018483759226880
Facebook: https://facebook.com/1081129795079160_122104222724824679
Instagram: https://www.instagram.com/p/DXBpqNmFFQq/
"
    $mail.Send()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($mail) | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook) | Out-Null
    "SUCCESS" | Out-File "C:\Users\Rory\Documents\GitHub\isitgonedown\send-report-result.txt" -Encoding utf8
} catch {
    "ERROR: $_" | Out-File "C:\Users\Rory\Documents\GitHub\isitgonedown\send-report-result.txt" -Encoding utf8
}
