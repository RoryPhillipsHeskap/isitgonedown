# PowerShell script to delete existing Instagram scheduled posts from Blotato and recreate them
# Part A: Delete all existing Instagram scheduled posts
# Part B: Re-create 29 Instagram posts with images

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configuration
$apiKey = "blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU="
$logFile = "C:\Users\Rory\Documents\GitHub\isitgonedown\blotato-instagram-reschedule-log.txt"
$baseUrl = "https://backend.blotato.com/v2"
$accountId = "39553"  # Instagram account ID
$platform = "instagram"

# Initialize counters
$deletedCount = 0
$createdCount = 0
$errorCount = 0

# Initialize log file
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"=== Blotato Instagram Reschedule Script ===" | Out-File -FilePath $logFile -Encoding UTF8
"Started: $timestamp" | Out-File -FilePath $logFile -Encoding UTF8 -Append
"" | Out-File -FilePath $logFile -Encoding UTF8 -Append

function Log-Message {
    param([string]$message)
    $msg = "$(Get-Date -Format 'HH:mm:ss'): $message"
    Write-Host $msg
    $msg | Out-File -FilePath $logFile -Encoding UTF8 -Append
}

# ============================================================================
# PART A: DELETE ALL EXISTING INSTAGRAM SCHEDULED POSTS
# ============================================================================

Log-Message "PART A: Deleting existing Instagram scheduled posts..."
Log-Message "Fetching schedules from Blotato API..."

$headers = @{
    "blotato-api-key" = $apiKey
    "Accept" = "*/*"
}

$cursor = $null
$deleteAttempts = 0

do {
    try {
        # Build GET URL with cursor if needed
        $url = "$baseUrl/schedules?limit=100"
        if ($cursor) {
            $url += "&cursor=$cursor"
        }

        Log-Message "Fetching schedules (cursor: $(if ($cursor) { $cursor } else { 'none' }))..."

        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json"

        # Check if response has items
        if ($response.items -and $response.items.Count -gt 0) {
            Log-Message "Found $($response.items.Count) schedule(s) on this page"

            foreach ($item in $response.items) {
                # Check if this is an Instagram post
                if ($item.draft -and $item.draft.content -and $item.draft.content.platform -eq "instagram") {
                    Log-Message "Deleting Instagram scheduled post ID: $($item.id)"

                    try {
                        $deleteUrl = "$baseUrl/schedules/$($item.id)"
                        Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers $headers -ContentType "application/json" | Out-Null
                        Log-Message "  SUCCESS: Deleted ID $($item.id)"
                        $deletedCount++
                        $deleteAttempts++
                    } catch {
                        Log-Message "  ERROR deleting ID $($item.id): $($_.Exception.Message)"
                        $errorCount++
                    }
                }
            }
        } else {
            Log-Message "No more schedules found"
        }

        # Check for next page
        $cursor = $response.cursor
        if ($cursor) {
            Log-Message "More schedules available, cursor: $cursor"
        }
    } catch {
        Log-Message "ERROR fetching schedules: $($_.Exception.Message)"
        $errorCount++
        break
    }
} while ($cursor)

Log-Message "Part A complete. Deleted: $deletedCount posts"
Log-Message ""

# ============================================================================
# PART B: RE-CREATE 29 INSTAGRAM POSTS WITH IMAGES
# ============================================================================

Log-Message "PART B: Creating 29 new Instagram posts..."

# Post data array (day, scheduledAt, text, imageUrl)
$posts = @(
    @{
        day = 2
        scheduledAt = "2026-04-08T09:00:00.000Z"
        text = "Our community voting feature lets real users confirm outages in real time. No more 'is it just me?' moments. Try it → isitgonedown.com"
        imageUrl = "https://export-download.canva.com/yF17A/DAHGKyyF17A/-1/0/0001-8772385574556158572.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T184311Z&X-Amz-Expires=6255&X-Amz-Signature=677af3a91f6bad2e49d54046cb978a0bf3c5fe6289f95eb5490a121265fac82b&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A27%3A26%20GMT"
    },
    @{
        day = 3
        scheduledAt = "2026-04-09T09:00:00.000Z"
        text = "We've all been there. The site's down and you're sitting there hitting F5 like it owes you money. Skip the chaos → isitgonedown.com 😂"
        imageUrl = "https://export-download.canva.com/sXvYY/DAHGK8sXvYY/-1/0/0001-3249846530441805463.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T021158Z&X-Amz-Expires=66724&X-Amz-Signature=516e530ed390b1884fe31c8e93bdaa40459da59ea1676da88d77bad30a381c02&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A44%3A02%20GMT"
    },
    @{
        day = 4
        scheduledAt = "2026-04-10T09:00:00.000Z"
        text = "Did you know? Most major websites go down at least a few times a year. IsItGone tracks it — and so does our community. Check any site for free → isitgonedown.com"
        imageUrl = "https://export-download.canva.com/4UaT8/DAHGKy4UaT8/-1/0/0001-3885979978731609482.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T111021Z&X-Amz-Expires=35738&X-Amz-Signature=747921ec7cfefb6d37cff67ac8dcacb6d0f08e6d5d0829e8e9772075733f3137&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A05%3A59%20GMT"
    },
    @{
        day = 5
        scheduledAt = "2026-04-11T09:00:00.000Z"
        text = "How it works: just type in any website URL and IsItGone checks it live — plus you can see if other users are reporting the same thing. Simple, fast, free 👉 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/IGYXc/DAHGK4IGYXc/-1/0/0001-102956290965416705.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T181359Z&X-Amz-Expires=9217&X-Amz-Signature=8abf7e862e94b65e1a617aca09788cd6a972c5e14468a28e79b5278649d7295e&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A47%3A36%20GMT"
    },
    @{
        day = 6
        scheduledAt = "2026-04-12T09:00:00.000Z"
        text = "💡 Bookmark of the week: isitgonedown.com — so next time your favourite site goes dark, you're not sitting there wondering if it's just you."
        imageUrl = "https://export-download.canva.com/4lWs4/DAHGK94lWs4/-1/0/0001-7629597168662021546.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260406%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260406T235344Z&X-Amz-Expires=77163&X-Amz-Signature=f282720e6b26b602742c51cdaf036d91de868ed51792bd88fcf5b95e45b53e86&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A19%3A47%20GMT"
    },
    @{
        day = 7
        scheduledAt = "2026-04-13T09:00:00.000Z"
        text = "It's been a great first week! Hundreds of site checks, community votes coming in. If you haven't tried it yet → isitgonedown.com 🚀"
        imageUrl = "https://export-download.canva.com/JAoTA/DAHGK7JAoTA/-1/0/0001-3003274449443268102.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T004746Z&X-Amz-Expires=72462&X-Amz-Signature=7dba3cd21ed8453561ca6dd97588b869da1b57b1586929a510c187ea16f30f52&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A55%3A28%20GMT"
    },
    @{
        day = 8
        scheduledAt = "2026-04-14T09:00:00.000Z"
        text = "What do people check most on IsItGone? Streaming sites, social media, and banks. Because those are the three things we truly can't live without 😂"
        imageUrl = "https://export-download.canva.com/2vdjY/DAHGK52vdjY/-1/0/0001-5134602973110289246.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T181737Z&X-Amz-Expires=7633&X-Amz-Signature=837c5b3fb1c5d6764cc0a8e9485aa3e91668080b59366d898ae19269885f9ecf&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A24%3A50%20GMT"
    },
    @{
        day = 9
        scheduledAt = "2026-04-15T09:00:00.000Z"
        text = "No sign-up. No email. No fuss. Just go to isitgonedown.com, type a URL, and get your answer. Done. ✅"
        imageUrl = "https://export-download.canva.com/9YDXY/DAHGK89YDXY/-1/0/0001-2568677086311087540.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T053715Z&X-Amz-Expires=56546&X-Amz-Signature=4ea232481b4ac6a372a527df73d59fa2c9da4fde402c2d6f85a566d6ddd9cc16&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A19%3A41%20GMT"
    },
    @{
        day = 10
        scheduledAt = "2026-04-16T09:00:00.000Z"
        text = "There's something quietly satisfying about seeing 40 people all vote 'down' on a site at the same time. Misery loves company 😂 → isitgonedown.com"
        imageUrl = "https://export-download.canva.com/biBnU/DAHGK4biBnU/-1/0/0001-5707686026695766742.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T002417Z&X-Amz-Expires=73685&X-Amz-Signature=d05f4c8315783a88f68bcc4bdbb172423462c638d098213dc59429b8f3874b32&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A52%3A22%20GMT"
    },
    @{
        day = 11
        scheduledAt = "2026-04-17T09:00:00.000Z"
        text = "😂 Relatable? The moment a website doesn't load, you're suddenly convinced your entire internet is broken. Check isitgonedown.com first — it's probably them, not you."
        imageUrl = "https://export-download.canva.com/KvVQA/DAHGKzKvVQA/-1/0/0001-3768886386058444252.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T161616Z&X-Amz-Expires=18229&X-Amz-Signature=f4d302c5417b5ca96f7ecb71d92eaf96072742d56e79029241b3fa671f05d5d3&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A20%3A05%20GMT"
    },
    @{
        day = 12
        scheduledAt = "2026-04-18T09:00:00.000Z"
        text = "Fast. Free. No drama. IsItGone checks any website in seconds so you're not left wondering. → isitgonedown.com ⚡"
        imageUrl = "https://export-download.canva.com/j4VUE/DAHGK9j4VUE/-1/0/0001-911352423638130299.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T154502Z&X-Amz-Expires=18856&X-Amz-Signature=5b49c933997b8377f5f995640a662b9871389cf600fffd9148822346ba7d02c9&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A59%3A18%20GMT"
    },
    @{
        day = 13
        scheduledAt = "2026-04-19T09:00:00.000Z"
        text = "Sometimes the answer is 'yep, it's just you.' IsItGone will tell you that too — with zero judgment. 😂 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/aVcZ0/DAHGKwaVcZ0/-1/0/0001-7944849141125585716.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T133641Z&X-Amz-Expires=25310&X-Amz-Signature=bb3dc14ed15a953f1c792b95caccbd7877df3203388cab58ee3e57d5f1a2cab1&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A38%3A31%20GMT"
    },
    @{
        day = 14
        scheduledAt = "2026-04-20T09:00:00.000Z"
        text = "Two weeks live! Thanks to everyone who's checked a site, voted in the community, or shared IsItGone. You're the best 🙏 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/Ka9Hk/DAHGK7Ka9Hk/-1/0/0001-6102876896311527787.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T190258Z&X-Amz-Expires=7553&X-Amz-Signature=18113f4a9f2a003509a71613c13aa6d7b375c2dcc181bdc98ee2b31bf5ae9e9a&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A08%3A51%20GMT"
    },
    @{
        day = 15
        scheduledAt = "2026-04-21T09:00:00.000Z"
        text = "Question of the day: which website would cause you the most chaos if it went down right now? Let us know in the comments 😂 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/5fszs/DAHGK_5fszs/-1/0/0001-6344945374999970597.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T092319Z&X-Amz-Expires=42672&X-Amz-Signature=76053110788d758212e4d3ef2f2507c6cc89c68a520f7f422a75c2cee01d4b2f&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A14%3A31%20GMT"
    },
    @{
        day = 16
        scheduledAt = "2026-04-22T09:00:00.000Z"
        text = "🔧 Behind the scenes at IsItGone: fixing a tricky Firestore bug that made votes silently disappear. The internet is complicated, folks. isitgonedown.com"
        imageUrl = "https://export-download.canva.com/fE8zA/DAHGK_fE8zA/-1/0/0001-8045054233933473398.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T101152Z&X-Amz-Expires=38893&X-Amz-Signature=5d2fc5e09228576bcfa78155a895e9a8b08e73785e68de02531d15e36630ea80&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A00%3A05%20GMT"
    },
    @{
        day = 17
        scheduledAt = "2026-04-23T09:00:00.000Z"
        text = "Tag a friend who always thinks their internet is broken when it's actually the website 😂👇 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/1_P8s/DAHGK-1_P8s/-1/0/0001-6150164690615282475.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T123915Z&X-Amz-Expires=29834&X-Amz-Signature=2a90db4252a10d2f76c149d249cf59429254e6948d7e11eafdaa9106beb262cc&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A56%3A29%20GMT"
    },
    @{
        day = 18
        scheduledAt = "2026-04-24T09:00:00.000Z"
        text = "Day 18 of sharing IsItGone and we're still at it! If you haven't checked it out yet, now's the time 👉 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/G81nE/DAHGK8G81nE/-1/0/0001-8045054235506180800.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T131818Z&X-Amz-Expires=28124&X-Amz-Signature=4b3ad6696301be773a8f7d1097322f00ecbd0fbf338a75812c7d81744382b59a&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A07%3A02%20GMT"
    },
    @{
        day = 19
        scheduledAt = "2026-04-25T09:00:00.000Z"
        text = "💡 Life tip: always check if a website is down before assuming it's your internet. Saves you a router reboot and a lot of unnecessary stress. → isitgonedown.com"
        imageUrl = "https://export-download.canva.com/OfkY4/DAHGKxOfkY4/-1/0/0001-3173285336953479382.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T145924Z&X-Amz-Expires=21936&X-Amz-Signature=a9e22a79ffa82bcb086919b0b2b5cae5a59d876a8b35116498809864fee5f63c&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A05%3A00%20GMT"
    },
    @{
        day = 20
        scheduledAt = "2026-04-26T09:00:00.000Z"
        text = "Sneak peek: IsItGone is getting some upgrades soon 🔮 Shareable status pages are on the way. Watch this space! isitgonedown.com"
        imageUrl = "https://export-download.canva.com/vB1HQ/DAHGKxvB1HQ/-1/0/0001-4721397710770222961.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T075049Z&X-Amz-Expires=48758&X-Amz-Signature=533d74565dccba0440d32de8b7251729bdfee3d6475d492097b98bf6cc143e0e&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A23%3A27%20GMT"
    },
    @{
        day = 21
        scheduledAt = "2026-04-27T09:00:00.000Z"
        text = "Three weeks of IsItGone! 🎉 If you've been following along, thank you. If you're new here — welcome! Go check a website 👉 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/etvUQ/DAHGK9etvUQ/-1/0/0001-5002872686950029888.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T023414Z&X-Amz-Expires=64577&X-Amz-Signature=6669443ec1968616a7b21255195eba89d6e9add1108747f4070290763c7d498a&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A30%3A31%20GMT"
    },
    @{
        day = 22
        scheduledAt = "2026-04-28T09:00:00.000Z"
        text = "Monday tip: check that your key work sites are up before your first meeting of the week. IsItGone — your Monday morning assistant. 😄 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/DbUFM/DAHGK0DbUFM/-1/0/0001-414830563609125921.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260406%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260406T193751Z&X-Amz-Expires=91550&X-Amz-Signature=254bcb3f98f08c670b5ee4f5f008605f152afe28f99d23cecddc2e7aada1eeb8&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A03%3A41%20GMT"
    },
    @{
        day = 23
        scheduledAt = "2026-04-29T09:00:00.000Z"
        text = "That moment when you check IsItGone and realise you're not alone — 60 people already voted 'it's down.' Pure vindication 🙌 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/Glqvo/DAHGK8Glqvo/-1/0/0001-328136272500157520.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260406%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260406T201950Z&X-Amz-Expires=87771&X-Amz-Signature=04babdb13ddf3eaa574398bcdf30ff0a755cf9ef2b53c01807742c34a6efdbcc&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A42%3A41%20GMT"
    },
    @{
        day = 24
        scheduledAt = "2026-04-30T09:00:00.000Z"
        text = "Fun fact: Google has gone down. AWS has gone down. Even Facebook went dark for hours in 2021. No site is too big to fall. → isitgonedown.com"
        imageUrl = "https://export-download.canva.com/jGsFs/DAHGK9jGsFs/-1/0/0001-4823854601849676294.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T100033Z&X-Amz-Expires=39322&X-Amz-Signature=9dcc800fb77c695c0751e5802bed9ca1c3935ea8f7908ad158254b222c7dee1c&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A55%3A55%20GMT"
    },
    @{
        day = 25
        scheduledAt = "2026-05-01T09:00:00.000Z"
        text = "😂 The classic move: spend 20 minutes troubleshooting your own connection, then realise the site has been down for everyone. Start at isitgonedown.com and save yourself the grief."
        imageUrl = "https://export-download.canva.com/moMks/DAHGK_moMks/-1/0/0001-8772385572638483242.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T144153Z&X-Amz-Expires=21521&X-Amz-Signature=a0868b53e057c004d00cf3a155c0226f407b2f60d967cd8cfbdfec4e75ef6197&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A40%3A34%20GMT"
    },
    @{
        day = 26
        scheduledAt = "2026-05-02T09:00:00.000Z"
        text = "Built IsItGone because I once spent 45 minutes troubleshooting my internet before realising it was the website. Never again. 😂 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/oXRIM/DAHGK2oXRIM/-1/0/0001-6344945374063900893.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T111506Z&X-Amz-Expires=33878&X-Amz-Signature=88a20eb723c93163b3187dee41ab4c7c52804cd9a7df28d1bf8f797bcae1f957&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2020%3A39%3A44%20GMT"
    },
    @{
        day = 27
        scheduledAt = "2026-05-03T09:00:00.000Z"
        text = "Streaming site down on a Saturday night again? Classic. Check isitgonedown.com to confirm it's not just you, then grab a snack while you wait 😂"
        imageUrl = "https://export-download.canva.com/4m_C0/DAHGK74m_C0/-1/0/0001-7944849144257959095.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T131739Z&X-Amz-Expires=29297&X-Amz-Signature=961b57693f99afbb75f97689691749ef6707b89f9d7380af3d7a08b306c6faab&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A25%3A56%20GMT"
    },
    @{
        day = 28
        scheduledAt = "2026-05-04T09:00:00.000Z"
        text = "Four weeks in! Thank you to every single person who's used IsItGone, shared it, or voted in the community. You make it what it is 🙏 isitgonedown.com"
        imageUrl = "https://export-download.canva.com/ra-bM/DAHGKyra-bM/-1/0/0001-3770012289677527006.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T011201Z&X-Amz-Expires=71512&X-Amz-Signature=9eabf5efdb2c242b18b4785a5b5d041c64056a48a9c62927e8e7890044b298d9&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A03%3A53%20GMT"
    },
    @{
        day = 29
        scheduledAt = "2026-05-05T09:00:00.000Z"
        text = "🔮 What's coming to IsItGone: shareable status pages, keyword alerts, and more community tools. Exciting times ahead! isitgonedown.com"
        imageUrl = "https://export-download.canva.com/27PjA/DAHGKx27PjA/-1/0/0001-8772385571995775549.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T100851Z&X-Amz-Expires=40330&X-Amz-Signature=ac830fb29ef0d80d1279246fb281adb07464443adab8696f2b560ba692266cf6&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A21%3A01%20GMT"
    },
    @{
        day = 30
        scheduledAt = "2026-05-06T09:00:00.000Z"
        text = "30 days of IsItGone! 🎉 We're just getting started. If you've found it useful — please share it. If you're new — welcome! Check any site now → isitgonedown.com"
        imageUrl = "https://export-download.canva.com/Uv_tE/DAHGK3Uv_tE/-1/0/0001-6616287251498715836.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQYCGKMUH5AO7UJ26%2F20260407%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260407T132222Z&X-Amz-Expires=28599&X-Amz-Signature=087241b1e572fcb24df9b86ee69c974de76db2af03ccc0c2399760ba92740d04&X-Amz-SignedHeaders=host%3Bx-amz-expected-bucket-owner&response-expires=Tue%2C%2007%20Apr%202026%2021%3A19%3A01%20GMT"
    }
)

Log-Message "Creating $($posts.Count) Instagram posts..."

foreach ($postData in $posts) {
    try {
        Log-Message "Creating Day $($postData.day) post (scheduled for $($postData.scheduledAt))..."

        # Build request body
        $body = @{
            post = @{
                accountId = $accountId
                content = @{
                    text = $postData.text
                    mediaUrls = @($postData.imageUrl)
                    platform = $platform
                }
                target = @{
                    targetType = $platform
                }
            }
            scheduledTime = $postData.scheduledAt
        } | ConvertTo-Json -Depth 10

        # POST to create the scheduled post
        $createUrl = "$baseUrl/posts"
        $response = Invoke-RestMethod -Uri $createUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"

        Log-Message "  SUCCESS: Created Day $($postData.day) (ID: $($response.id))"
        $createdCount++

        # Add 2-second delay between posts
        Start-Sleep -Seconds 2
    } catch {
        Log-Message "  ERROR creating Day $($postData.day): $($_.Exception.Message)"
        $errorCount++
    }
}

Log-Message ""
Log-Message "=== SUMMARY ==="
Log-Message "Deleted: $deletedCount"
Log-Message "Created: $createdCount"
Log-Message "Errors: $errorCount"
Log-Message ""

$endTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"Completed: $endTime" | Out-File -FilePath $logFile -Encoding UTF8 -Append
"DONE: Deleted=$deletedCount Created=$createdCount Errors=$errorCount" | Out-File -FilePath $logFile -Encoding UTF8 -Append

Write-Host "Script complete. Log saved to: $logFile"
