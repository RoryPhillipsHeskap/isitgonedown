# Fix all platforms - ASCII-safe captions
Add-Type -AssemblyName System.Windows.Forms

$apiKey    = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU='
$baseUrl   = 'https://backend.blotato.com/v2'
$fbPageId  = '61574740391585'
$imgBase   = 'https://isitgonedown.com/social-images/instagram'

$posts = @(
    @{ day=6; date='2026-04-12T09:00:00.000Z'; tw='Weekend tip: bookmark isitgonedown.com. You''ll thank yourself next time Netflix, Spotify, or your bank goes down  #LifeHack'; li='Quick tip for the weekend: add isitgonedown.com to your bookmarks. You''ll need it more than you think - outages don''t take days off.'; fb=' Bookmark of the week: isitgonedown.com - so next time your favourite site goes dark, you''re not sitting there wondering if it''s just you.' },
    @{ day=7; date='2026-04-13T09:00:00.000Z'; tw='One week in and IsItGone is already helping people stop blaming their WiFi for things that aren''t their fault  isitgonedown.com'; li='A week of helping people answer the age-old question: is it me, or is the internet broken? Turns out - it''s rarely just you. isitgonedown.com'; fb='It''s been a great first week! Hundreds of site checks, community votes coming in. If you haven''t tried it yet  isitgonedown.com ' },
    @{ day=8; date='2026-04-14T09:00:00.000Z'; tw='Top sites people check on IsItGone: Netflix, Instagram, Roblox, banking apps. In other words - the important stuff  #WebTools'; li='Interesting trend: the most-checked sites on IsItGone tend to be streaming services and banks. Which makes total sense - those are the ones that really hurt when they''re down.'; fb='What do people check most on IsItGone? Streaming sites, social media, and banks. Because those are the three things we truly can''t live without ' },
    @{ day=9; date='2026-04-15T09:00:00.000Z'; tw='IsItGone: no account, no email, no faff. Just check if a site is down and get on with your day. isitgonedown.com '; li='We made IsItGone with zero sign-up required. Because if your website is already down, the last thing you need is to create another account to check it.'; fb='No sign-up. No email. No fuss. Just go to isitgonedown.com, type a URL, and get your answer. Done. ' },
    @{ day=10; date='2026-04-16T09:00:00.000Z'; tw='When 50 users all vote ''down'' at the same time - that''s not a bug, that''s a chorus.  isitgonedown.com #CommunityPowered'; li='The best part of IsItGone? The community. When a site goes down, users flood in to vote and confirm. It''s crowd-sourced reliability in real time.'; fb='There''s something quietly satisfying about seeing 40 people all vote ''down'' on a site at the same time. Misery loves company   isitgonedown.com' },
    @{ day=11; date='2026-04-17T09:00:00.000Z'; tw='Me: *loses internet for 0.3 seconds* Also me: *immediately checks isitgonedown.com*  #TooRelatable'; li='We''ve all had that moment of panic when a page doesn''t load. Before you restart the router, unplug the TV, and blame the cat - just check isitgonedown.com.'; fb=' Relatable? The moment a website doesn''t load, you''re suddenly convinced your entire internet is broken. Check isitgonedown.com first - it''s probably them, not you.' },
    @{ day=12; date='2026-04-18T09:00:00.000Z'; tw='Results in under 2 seconds. Because when a site''s down, every second of uncertainty is painful.  isitgonedown.com'; li='Speed matters when a site''s down. IsItGone returns results in seconds - no waiting, no loading spinners that somehow make the anxiety worse.'; fb='Fast. Free. No drama. IsItGone checks any website in seconds so you''re not left wondering.  isitgonedown.com ' },
    @{ day=13; date='2026-04-19T09:00:00.000Z'; tw='Plot twist: the website wasn''t down. It was just you. (We''ve all been there.) isitgonedown.com '; li='Fun Saturday thought: IsItGone is equally good at telling you the site is fine and it IS actually just your internet. Humbling, but useful.'; fb='Sometimes the answer is ''yep, it''s just you.'' IsItGone will tell you that too - with zero judgment.  isitgonedown.com' },
    @{ day=14; date='2026-04-20T09:00:00.000Z'; tw='Two weeks of IsItGone. Turns out a LOT of websites go down. Who knew? (Everyone. Everyone knew.) isitgonedown.com'; li='Two weeks in, one thing is clear: websites go down far more often than most people realise. IsItGone is here every time it happens.'; fb='Two weeks live! Thanks to everyone who''s checked a site, voted in the community, or shared IsItGone. You''re the best  isitgonedown.com' },
    @{ day=15; date='2026-04-21T09:00:00.000Z'; tw='What''s the site you always check first when you think the internet''s broken? Drop it below   isitgonedown.com'; li='Genuine question for the community: which website going down causes you the most pain? For me it''s always the payment processor at the worst possible moment.'; fb='Question of the day: which website would cause you the most chaos if it went down right now? Let us know in the comments  isitgonedown.com' },
    @{ day=16; date='2026-04-22T09:00:00.000Z'; tw='Building IsItGone taught me that Firestore security rules are not optional. Lesson learned the hard way  #buildinpublic #webdev'; li='Building in public moment: IsItGone''s community voting broke for a while because of a Firestore permissions issue. Fixed now - and I documented every step so it doesn''t happen again.'; fb=' Behind the scenes at IsItGone: fixing a tricky Firestore bug that made votes silently disappear. The internet is complicated, folks. isitgonedown.com' },
    @{ day=17; date='2026-04-23T09:00:00.000Z'; tw='Know someone who always blames their WiFi for everything? Send them isitgonedown.com. It might change their life. '; li='If you know someone who spends 20 minutes troubleshooting their connection before realising it''s not them - share IsItGone with them. You''d be doing them a favour.'; fb='Tag a friend who always thinks their internet is broken when it''s actually the website  isitgonedown.com' },
    @{ day=18; date='2026-04-24T09:00:00.000Z'; tw='18 days of posting. 18 days of websites going down. The internet really is fragile.  isitgonedown.com'; li='Consistency update: 18 days of sharing IsItGone, and every single day someone finds a new way to appreciate ''oh, so it IS down for everyone.'''; fb='Day 18 of sharing IsItGone and we''re still at it! If you haven''t checked it out yet, now''s the time  isitgonedown.com' },
    @{ day=19; date='2026-04-25T09:00:00.000Z'; tw='Pro tip: when a site''s down, check isitgonedown.com BEFORE you unplug your router. Save yourself the grief.  #LifeHack'; li='Quick productivity tip: before you spend 10 minutes troubleshooting your own connection, spend 5 seconds on isitgonedown.com. It''ll tell you if the problem is actually upstream.'; fb=' Life tip: always check if a website is down before assuming it''s your internet. Saves you a router reboot and a lot of unnecessary stress.  isitgonedown.com' },
    @{ day=20; date='2026-04-26T09:00:00.000Z'; tw='We''re working on some new features for IsItGone. Community-powered status pages, anyone?  Stay tuned. isitgonedown.com'; li='Exciting things in the pipeline for IsItGone - including shareable per-monitor status pages. More details soon. isitgonedown.com'; fb='Sneak peek: IsItGone is getting some upgrades soon  Shareable status pages are on the way. Watch this space! isitgonedown.com' },
    @{ day=21; date='2026-04-27T09:00:00.000Z'; tw='Three weeks of IsItGone. Feeling good. The internet is still fragile. We''re still here.  isitgonedown.com'; li='Three weeks live. What started as a side project to scratch my own itch has turned into something real. Thank you to everyone who''s used it, shared it, or voted on it.'; fb='Three weeks of IsItGone!  If you''ve been following along, thank you. If you''re new here - welcome! Go check a website  isitgonedown.com' },
    @{ day=22; date='2026-04-28T09:00:00.000Z'; tw='Monday energy: checking if the websites you need for work are actually up before your 9am call. isitgonedown.com '; li='Start the week right: make sure the tools you rely on are actually online. isitgonedown.com has your back every morning.'; fb='Monday tip: check that your key work sites are up before your first meeting of the week. IsItGone - your Monday morning assistant.  isitgonedown.com' },
    @{ day=23; date='2026-04-29T09:00:00.000Z'; tw='Nothing better than checking IsItGone and seeing the whole community already voted ''down''. Vindication.  isitgonedown.com'; li='The best feeling: you check IsItGone, and 60 other people have already voted that the site is down. You''re not imagining it. It really is broken. Vindicated.'; fb='That moment when you check IsItGone and realise you''re not alone - 60 people already voted ''it''s down.'' Pure vindication  isitgonedown.com' },
    @{ day=24; date='2026-04-30T09:00:00.000Z'; tw='Reminder: even Google has gone down. No site is immune. That''s why isitgonedown.com exists. '; li='A reminder that even the biggest platforms in the world experience outages. Google, AWS, Cloudflare, Facebook - all have had major incidents. IsItGone tracks them all.'; fb='Fun fact: Google has gone down. AWS has gone down. Even Facebook went dark for hours in 2021. No site is too big to fall.  isitgonedown.com' },
    @{ day=25; date='2026-05-01T09:00:00.000Z'; tw='The most unhinged troubleshooting journey: clear cache  try incognito  switch browsers  restart router  check isitgonedown.com  oh it''s them '; li='We''ve all done the full troubleshooting loop before checking if the site itself is just down. IsItGone is the step you should always do first.'; fb=' The classic move: spend 20 minutes troubleshooting your own connection, then realise the site has been down for everyone. Start at isitgonedown.com and save yourself the grief.' },
    @{ day=26; date='2026-05-02T09:00:00.000Z'; tw='If checking isitgonedown.com has ever saved you from restarting your router unnecessarily, you are the reason we built this. '; li='IsItGone exists for one reason: to save you from unnecessary router reboots, modem checks, and calls to your ISP. If it''s helped you, share it.'; fb='Built IsItGone because I once spent 45 minutes troubleshooting my internet before realising it was the website. Never again.  isitgonedown.com' },
    @{ day=27; date='2026-05-03T09:00:00.000Z'; tw='Saturday night sites most likely to go down: streaming services. Coincidence? Probably not.  isitgonedown.com'; li='Fun observation: Saturday evenings see a spike in streaming outages. Peak demand, peak frustration, peak IsItGone usage. Enjoy your weekend - we''re watching the uptime.'; fb='Streaming site down on a Saturday night again? Classic. Check isitgonedown.com to confirm it''s not just you, then grab a snack while you wait ' },
    @{ day=28; date='2026-05-04T09:00:00.000Z'; tw='28 days of posting about IsItGone. Internet still fragile. Community still growing. We''re not stopping.  isitgonedown.com'; li='Four weeks of IsItGone. The question ''is it down or just me?'' never goes away - and neither do we. Thank you to everyone who''s been part of this.'; fb='Four weeks in! Thank you to every single person who''s used IsItGone, shared it, or voted in the community. You make it what it is  isitgonedown.com' },
    @{ day=29; date='2026-05-05T09:00:00.000Z'; tw='Coming soon to IsItGone: shareable status pages, keyword monitoring, and more. Watch this space.  isitgonedown.com'; li='Exciting roadmap ahead for IsItGone: public status pages you can share, keyword monitoring, and smarter community insights. More to come - stay tuned.'; fb=' What''s coming to IsItGone: shareable status pages, keyword alerts, and more community tools. Exciting times ahead! isitgonedown.com' },
    @{ day=30; date='2026-05-06T09:00:00.000Z'; tw='30 days. Countless sites checked. One simple mission: helping people figure out if it''s them or the internet. isitgonedown.com '; li='30 days of IsItGone. One mission, one tool, one community. Thank you for being part of this journey. Here''s to the next 30. isitgonedown.com'; fb='30 days of IsItGone!  We''re just getting started. If you''ve found it useful - please share it. If you''re new - welcome! Check any site now  isitgonedown.com' }
)

$platforms = @(
    @{ name='facebook'; acct='25818'; plat='facebook'; tt='facebook'; pageId=$fbPageId; delay=1 }
    @{ name='twitter';  acct='15712'; plat='twitter';  tt='twitter';  pageId=$null;    delay=5 }
    @{ name='linkedin'; acct='17133'; plat='linkedin'; tt='linkedin'; pageId=$null;    delay=1 }
)

$hPost = @{ 'blotato-api-key' = $apiKey; 'Content-Type' = 'application/json' }

$results = ''
foreach ($cfg in $platforms) {
    $ok = 0; $fail = 0; $firstErr = ''
    foreach ($p in $posts) {
        $cap = switch ($cfg.name) {
            'facebook' { $p.fb }
            'twitter'  { $p.tw }
            'linkedin' { $p.li }
        }
        $tgt = @{ targetType = $cfg.tt }
        if ($cfg.pageId) { $tgt['pageId'] = $cfg.pageId }
        $body = @{
            post = @{
                accountId = $cfg.acct
                content   = @{ text = $cap; mediaUrls = @("$imgBase/day-$($p.day).jpg"); platform = $cfg.plat }
                target    = $tgt
            }
            scheduledTime = $p.date
        } | ConvertTo-Json -Depth 10
        Start-Sleep -Seconds $cfg.delay
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
    $line = "$($cfg.name.ToUpper()): $ok OK, $fail FAIL"
    if ($firstErr) { $line += "`n  First error: $firstErr" }
    $results += $line + "`n"
}

[System.Windows.Forms.MessageBox]::Show($results, 'Fix Results') | Out-Null
