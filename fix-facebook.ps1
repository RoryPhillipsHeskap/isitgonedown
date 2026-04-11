# Fix Facebook posts - correct pageId
Add-Type -AssemblyName System.Windows.Forms

$apiKey   = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU='
$baseUrl  = 'https://backend.blotato.com/v2'
$acctId   = '25818'
$pageId   = '1081129795079160'
$imgBase  = 'https://isitgonedown.com/social-images/instagram'

$posts = @(
    @{ day=6; date='2026-04-12T09:00:00.000Z'; fb=' Bookmark of the week: isitgonedown.com - so next time your favourite site goes dark, you''re not sitting there wondering if it''s just you.' },
    @{ day=7; date='2026-04-13T09:00:00.000Z'; fb='It''s been a great first week! Hundreds of site checks, community votes coming in. If you haven''t tried it yet  isitgonedown.com ' },
    @{ day=8; date='2026-04-14T09:00:00.000Z'; fb='What do people check most on IsItGone? Streaming sites, social media, and banks. Because those are the three things we truly can''t live without ' },
    @{ day=9; date='2026-04-15T09:00:00.000Z'; fb='No sign-up. No email. No fuss. Just go to isitgonedown.com, type a URL, and get your answer. Done. ' },
    @{ day=10; date='2026-04-16T09:00:00.000Z'; fb='There''s something quietly satisfying about seeing 40 people all vote ''down'' on a site at the same time. Misery loves company   isitgonedown.com' },
    @{ day=11; date='2026-04-17T09:00:00.000Z'; fb=' Relatable? The moment a website doesn''t load, you''re suddenly convinced your entire internet is broken. Check isitgonedown.com first - it''s probably them, not you.' },
    @{ day=12; date='2026-04-18T09:00:00.000Z'; fb='Fast. Free. No drama. IsItGone checks any website in seconds so you''re not left wondering.  isitgonedown.com ' },
    @{ day=13; date='2026-04-19T09:00:00.000Z'; fb='Sometimes the answer is ''yep, it''s just you.'' IsItGone will tell you that too - with zero judgment.  isitgonedown.com' },
    @{ day=14; date='2026-04-20T09:00:00.000Z'; fb='Two weeks live! Thanks to everyone who''s checked a site, voted in the community, or shared IsItGone. You''re the best  isitgonedown.com' },
    @{ day=15; date='2026-04-21T09:00:00.000Z'; fb='Question of the day: which website would cause you the most chaos if it went down right now? Let us know in the comments  isitgonedown.com' },
    @{ day=16; date='2026-04-22T09:00:00.000Z'; fb=' Behind the scenes at IsItGone: fixing a tricky Firestore bug that made votes silently disappear. The internet is complicated, folks. isitgonedown.com' },
    @{ day=17; date='2026-04-23T09:00:00.000Z'; fb='Tag a friend who always thinks their internet is broken when it''s actually the website  isitgonedown.com' },
    @{ day=18; date='2026-04-24T09:00:00.000Z'; fb='Day 18 of sharing IsItGone and we''re still at it! If you haven''t checked it out yet, now''s the time  isitgonedown.com' },
    @{ day=19; date='2026-04-25T09:00:00.000Z'; fb=' Life tip: always check if a website is down before assuming it''s your internet. Saves you a router reboot and a lot of unnecessary stress.  isitgonedown.com' },
    @{ day=20; date='2026-04-26T09:00:00.000Z'; fb='Sneak peek: IsItGone is getting some upgrades soon  Shareable status pages are on the way. Watch this space! isitgonedown.com' },
    @{ day=21; date='2026-04-27T09:00:00.000Z'; fb='Three weeks of IsItGone!  If you''ve been following along, thank you. If you''re new here - welcome! Go check a website  isitgonedown.com' },
    @{ day=22; date='2026-04-28T09:00:00.000Z'; fb='Monday tip: check that your key work sites are up before your first meeting of the week. IsItGone - your Monday morning assistant.  isitgonedown.com' },
    @{ day=23; date='2026-04-29T09:00:00.000Z'; fb='That moment when you check IsItGone and realise you''re not alone - 60 people already voted ''it''s down.'' Pure vindication  isitgonedown.com' },
    @{ day=24; date='2026-04-30T09:00:00.000Z'; fb='Fun fact: Google has gone down. AWS has gone down. Even Facebook went dark for hours in 2021. No site is too big to fall.  isitgonedown.com' },
    @{ day=25; date='2026-05-01T09:00:00.000Z'; fb=' The classic move: spend 20 minutes troubleshooting your own connection, then realise the site has been down for everyone. Start at isitgonedown.com and save yourself the grief.' },
    @{ day=26; date='2026-05-02T09:00:00.000Z'; fb='Built IsItGone because I once spent 45 minutes troubleshooting my internet before realising it was the website. Never again.  isitgonedown.com' },
    @{ day=27; date='2026-05-03T09:00:00.000Z'; fb='Streaming site down on a Saturday night again? Classic. Check isitgonedown.com to confirm it''s not just you, then grab a snack while you wait ' },
    @{ day=28; date='2026-05-04T09:00:00.000Z'; fb='Four weeks in! Thank you to every single person who''s used IsItGone, shared it, or voted in the community. You make it what it is  isitgonedown.com' },
    @{ day=29; date='2026-05-05T09:00:00.000Z'; fb=' What''s coming to IsItGone: shareable status pages, keyword alerts, and more community tools. Exciting times ahead! isitgonedown.com' },
    @{ day=30; date='2026-05-06T09:00:00.000Z'; fb='30 days of IsItGone!  We''re just getting started. If you''ve found it useful - please share it. If you''re new - welcome! Check any site now  isitgonedown.com' }
)

$hPost = @{ 'blotato-api-key' = $apiKey; 'Content-Type' = 'application/json' }
$ok = 0; $fail = 0; $firstErr = ''

foreach ($p in $posts) {
    $body = @{
        post = @{
            accountId = $acctId
            content   = @{ text = $p.fb; mediaUrls = @("$imgBase/day-$($p.day).jpg"); platform = 'facebook' }
            target    = @{ targetType = 'facebook'; pageId = $pageId }
        }
        scheduledTime = $p.date
    } | ConvertTo-Json -Depth 10
    Start-Sleep -Seconds 1
    try {
        $r = Invoke-RestMethod -Uri "$baseUrl/posts" -Method Post -Headers $hPost -Body $body -ErrorAction Stop
        $ok++
    } catch {
        $fail++
        if ($firstErr -eq '') {
            $sc = 0; try { $sc = $_.Exception.Response.StatusCode.value__ } catch {}
            $eb = $_.ErrorDetails.Message
            if (-not $eb) { try { $stream=$_.Exception.Response.GetResponseStream(); $eb=(New-Object System.IO.StreamReader($stream)).ReadToEnd() } catch {} }
            $firstErr = "Day $($p.day) HTTP$sc`: $eb"
        }
    }
}

$msg = "FACEBOOK: $ok OK, $fail FAIL"
if ($firstErr) { $msg += "`nFirst error: $firstErr" }
[System.Windows.Forms.MessageBox]::Show($msg, 'Facebook Fix Results') | Out-Null
