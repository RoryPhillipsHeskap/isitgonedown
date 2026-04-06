// Netlify Scheduled Function — runs daily at 9 AM UTC
// Posts today's IsItGoneDown content to Twitter, LinkedIn, Facebook, Instagram via Blotato

const https = require('https');

const BLOTATO_API_KEY = 'blt_GV1PlBxKT6OSshia7334Tm4yen/n0q3hcQzJF/6obfU=';
const CAMPAIGN_START = new Date('2026-04-07T00:00:00Z');

// 30-day content plan (Day 1 = 2026-04-07, Day 30 = 2026-05-06)
const CONTENT = [
  { // Day 1
    twitter: "Is your favourite site actually down, or is it just you? Find out in 2 seconds → isitgonedown.com #WebDev #SideProject",
    linkedin: "I built a tool that answers the question we all ask ourselves at 2am: is this website actually down, or have I broken the internet again? Check it out: isitgonedown.com",
    facebook: "Tired of wondering if a website is down just for you? IsItGone tells you in seconds — and the community can vote too. Free, fast, no sign-up. 👉 isitgonedown.com",
  },
  { // Day 2
    twitter: "Not only do we check if a site's down — real users vote on it too. Democracy, but for the internet 🗳️ isitgonedown.com #WebTools",
    linkedin: "What makes IsItGone different? Community voting. If a site's down, chances are hundreds of people are already there confirming it. Crowd-sourced reliability checks.",
    facebook: "Our community voting feature lets real users confirm outages in real time. No more 'is it just me?' moments. Try it → isitgonedown.com",
  },
  { // Day 3
    twitter: "Stages of a website being down: 1) It's probably me 2) Refresh 47 times 3) Check isitgonedown.com 4) Relief/rage 😂 #Relatable",
    linkedin: "The five stages of a website outage: Denial → Refresh → Refresh again → Google it → Check isitgonedown.com. Skip to step 5 next time.",
    facebook: "We've all been there. The site's down and you're sitting there hitting F5 like it owes you money. Skip the chaos → isitgonedown.com 😂",
  },
  { // Day 4
    twitter: "Did you know the average website experiences ~14.4 hours of downtime per year? That's a lot of F5 keys. isitgonedown.com 🔍 #WebStats",
    linkedin: "Fun fact: the average website experiences roughly 14 hours of downtime annually. For high-traffic sites, that's millions in lost revenue. IsItGone helps you know the moment it happens.",
    facebook: "Did you know? Most major websites go down at least a few times a year. IsItGone tracks it — and so does our community. Check any site for free → isitgonedown.com",
  },
  { // Day 5
    twitter: "How IsItGone works: 1️⃣ Paste a URL 2️⃣ We ping it 3️⃣ Community confirms 4️⃣ You know in seconds. isitgonedown.com",
    linkedin: "IsItGone in 3 steps: Enter any URL → Get an instant status check → See what the community says. No account needed. No fluff. Just answers.",
    facebook: "How it works: just type in any website URL and IsItGone checks it live — plus you can see if other users are reporting the same thing. Simple, fast, free 👉 isitgonedown.com",
  },
  { // Day 6
    twitter: "Weekend tip: bookmark isitgonedown.com. You'll thank yourself next time Netflix, Spotify, or your bank goes down 🤷 #LifeHack",
    linkedin: "Quick tip for the weekend: add isitgonedown.com to your bookmarks. You'll need it more than you think — outages don't take days off.",
    facebook: "💡 Bookmark of the week: isitgonedown.com — so next time your favourite site goes dark, you're not sitting there wondering if it's just you.",
  },
  { // Day 7
    twitter: "One week in and IsItGone is already helping people stop blaming their WiFi for things that aren't their fault 😂 isitgonedown.com",
    linkedin: "A week of helping people answer the age-old question: is it me, or is the internet broken? Turns out — it's rarely just you. isitgonedown.com",
    facebook: "It's been a great first week! Hundreds of site checks, community votes coming in. If you haven't tried it yet → isitgonedown.com 🚀",
  },
  { // Day 8
    twitter: "Top sites people check on IsItGone: Netflix, Instagram, Roblox, banking apps. In other words — the important stuff 😂 #WebTools",
    linkedin: "Interesting trend: the most-checked sites on IsItGone tend to be streaming services and banks. Which makes total sense — those are the ones that really hurt when they're down.",
    facebook: "What do people check most on IsItGone? Streaming sites, social media, and banks. Because those are the three things we truly can't live without 😂",
  },
  { // Day 9
    twitter: "IsItGone: no account, no email, no faff. Just check if a site is down and get on with your day. isitgonedown.com ⚡",
    linkedin: "We made IsItGone with zero sign-up required. Because if your website is already down, the last thing you need is to create another account to check it.",
    facebook: "No sign-up. No email. No fuss. Just go to isitgonedown.com, type a URL, and get your answer. Done. ✅",
  },
  { // Day 10
    twitter: "When 50 users all vote 'down' at the same time — that's not a bug, that's a chorus. 🎶 isitgonedown.com #CommunityPowered",
    linkedin: "The best part of IsItGone? The community. When a site goes down, users flood in to vote and confirm. It's crowd-sourced reliability in real time.",
    facebook: "There's something quietly satisfying about seeing 40 people all vote 'down' on a site at the same time. Misery loves company 😂 → isitgonedown.com",
  },
  { // Day 11
    twitter: "Me: *loses internet for 0.3 seconds* Also me: *immediately checks isitgonedown.com* 😂 #TooRelatable",
    linkedin: "We've all had that moment of panic when a page doesn't load. Before you restart the router, unplug the TV, and blame the cat — just check isitgonedown.com.",
    facebook: "😂 Relatable? The moment a website doesn't load, you're suddenly convinced your entire internet is broken. Check isitgonedown.com first — it's probably them, not you.",
  },
  { // Day 12
    twitter: "Results in under 2 seconds. Because when a site's down, every second of uncertainty is painful. ⚡ isitgonedown.com",
    linkedin: "Speed matters when a site's down. IsItGone returns results in seconds — no waiting, no loading spinners that somehow make the anxiety worse.",
    facebook: "Fast. Free. No drama. IsItGone checks any website in seconds so you're not left wondering. → isitgonedown.com ⚡",
  },
  { // Day 13
    twitter: "Plot twist: the website wasn't down. It was just you. (We've all been there.) isitgonedown.com 😂",
    linkedin: "Fun Saturday thought: IsItGone is equally good at telling you the site is fine and it IS actually just your internet. Humbling, but useful.",
    facebook: "Sometimes the answer is 'yep, it's just you.' IsItGone will tell you that too — with zero judgment. 😂 isitgonedown.com",
  },
  { // Day 14
    twitter: "Two weeks of IsItGone. Turns out a LOT of websites go down. Who knew? (Everyone. Everyone knew.) isitgonedown.com",
    linkedin: "Two weeks in, one thing is clear: websites go down far more often than most people realise. IsItGone is here every time it happens.",
    facebook: "Two weeks live! Thanks to everyone who's checked a site, voted in the community, or shared IsItGone. You're the best 🙏 isitgonedown.com",
  },
  { // Day 15
    twitter: "What's the site you always check first when you think the internet's broken? Drop it below 👇 😂 isitgonedown.com",
    linkedin: "Genuine question for the community: which website going down causes you the most pain? For me it's always the payment processor at the worst possible moment.",
    facebook: "Question of the day: which website would cause you the most chaos if it went down right now? Let us know in the comments 😂 isitgonedown.com",
  },
  { // Day 16
    twitter: "Building IsItGone taught me that Firestore security rules are not optional. Lesson learned the hard way 😂 #buildinpublic #webdev",
    linkedin: "Building in public moment: IsItGone's community voting broke for a while because of a Firestore permissions issue. Fixed now — and I documented every step so it doesn't happen again.",
    facebook: "🔧 Behind the scenes at IsItGone: fixing a tricky Firestore bug that made votes silently disappear. The internet is complicated, folks. isitgonedown.com",
  },
  { // Day 17
    twitter: "Know someone who always blames their WiFi for everything? Send them isitgonedown.com. It might change their life. 😂",
    linkedin: "If you know someone who spends 20 minutes troubleshooting their connection before realising it's not them — share IsItGone with them. You'd be doing them a favour.",
    facebook: "Tag a friend who always thinks their internet is broken when it's actually the website 😂👇 isitgonedown.com",
  },
  { // Day 18
    twitter: "18 days of posting. 18 days of websites going down. The internet really is fragile. 😂 isitgonedown.com",
    linkedin: "Consistency update: 18 days of sharing IsItGone, and every single day someone finds a new way to appreciate 'oh, so it IS down for everyone.'",
    facebook: "Day 18 of sharing IsItGone and we're still at it! If you haven't checked it out yet, now's the time 👉 isitgonedown.com",
  },
  { // Day 19
    twitter: "Pro tip: when a site's down, check isitgonedown.com BEFORE you unplug your router. Save yourself the grief. 😂 #LifeHack",
    linkedin: "Quick productivity tip: before you spend 10 minutes troubleshooting your own connection, spend 5 seconds on isitgonedown.com. It'll tell you if the problem is actually upstream.",
    facebook: "💡 Life tip: always check if a website is down before assuming it's your internet. Saves you a router reboot and a lot of unnecessary stress. → isitgonedown.com",
  },
  { // Day 20
    twitter: "We're working on some new features for IsItGone. Community-powered status pages, anyone? 👀 Stay tuned. isitgonedown.com",
    linkedin: "Exciting things in the pipeline for IsItGone — including shareable per-monitor status pages. More details soon. isitgonedown.com",
    facebook: "Sneak peek: IsItGone is getting some upgrades soon 🔮 Shareable status pages are on the way. Watch this space! isitgonedown.com",
  },
  { // Day 21
    twitter: "Three weeks of IsItGone. Feeling good. The internet is still fragile. We're still here. 🚀 isitgonedown.com",
    linkedin: "Three weeks live. What started as a side project to scratch my own itch has turned into something real. Thank you to everyone who's used it, shared it, or voted on it.",
    facebook: "Three weeks of IsItGone! 🎉 If you've been following along, thank you. If you're new here — welcome! Go check a website 👉 isitgonedown.com",
  },
  { // Day 22
    twitter: "Monday energy: checking if the websites you need for work are actually up before your 9am call. isitgonedown.com ☕",
    linkedin: "Start the week right: make sure the tools you rely on are actually online. isitgonedown.com has your back every morning.",
    facebook: "Monday tip: check that your key work sites are up before your first meeting of the week. IsItGone — your Monday morning assistant. 😄 isitgonedown.com",
  },
  { // Day 23
    twitter: "Nothing better than checking IsItGone and seeing the whole community already voted 'down'. Vindication. 🙌 isitgonedown.com",
    linkedin: "The best feeling: you check IsItGone, and 60 other people have already voted that the site is down. You're not imagining it. It really is broken. Vindicated.",
    facebook: "That moment when you check IsItGone and realise you're not alone — 60 people already voted 'it's down.' Pure vindication 🙌 isitgonedown.com",
  },
  { // Day 24
    twitter: "Reminder: even Google has gone down. No site is immune. That's why isitgonedown.com exists. 😄",
    linkedin: "A reminder that even the biggest platforms in the world experience outages. Google, AWS, Cloudflare, Facebook — all have had major incidents. IsItGone tracks them all.",
    facebook: "Fun fact: Google has gone down. AWS has gone down. Even Facebook went dark for hours in 2021. No site is too big to fall. → isitgonedown.com",
  },
  { // Day 25
    twitter: "The most unhinged troubleshooting journey: clear cache → try incognito → switch browsers → restart router → check isitgonedown.com → oh it's them 😂",
    linkedin: "We've all done the full troubleshooting loop before checking if the site itself is just down. IsItGone is the step you should always do first.",
    facebook: "😂 The classic move: spend 20 minutes troubleshooting your own connection, then realise the site has been down for everyone. Start at isitgonedown.com and save yourself the grief.",
  },
  { // Day 26
    twitter: "If checking isitgonedown.com has ever saved you from restarting your router unnecessarily, you are the reason we built this. 🙏",
    linkedin: "IsItGone exists for one reason: to save you from unnecessary router reboots, modem checks, and calls to your ISP. If it's helped you, share it.",
    facebook: "Built IsItGone because I once spent 45 minutes troubleshooting my internet before realising it was the website. Never again. 😂 isitgonedown.com",
  },
  { // Day 27
    twitter: "Saturday night sites most likely to go down: streaming services. Coincidence? Probably not. 😂 isitgonedown.com",
    linkedin: "Fun observation: Saturday evenings see a spike in streaming outages. Peak demand, peak frustration, peak IsItGone usage. Enjoy your weekend — we're watching the uptime.",
    facebook: "Streaming site down on a Saturday night again? Classic. Check isitgonedown.com to confirm it's not just you, then grab a snack while you wait 😂",
  },
  { // Day 28
    twitter: "28 days of posting about IsItGone. Internet still fragile. Community still growing. We're not stopping. 🚀 isitgonedown.com",
    linkedin: "Four weeks of IsItGone. The question 'is it down or just me?' never goes away — and neither do we. Thank you to everyone who's been part of this.",
    facebook: "Four weeks in! Thank you to every single person who's used IsItGone, shared it, or voted in the community. You make it what it is 🙏 isitgonedown.com",
  },
  { // Day 29
    twitter: "Coming soon to IsItGone: shareable status pages, keyword monitoring, and more. Watch this space. 👀 isitgonedown.com",
    linkedin: "Exciting roadmap ahead for IsItGone: public status pages you can share, keyword monitoring, and smarter community insights. More to come — stay tuned.",
    facebook: "🔮 What's coming to IsItGone: shareable status pages, keyword alerts, and more community tools. Exciting times ahead! isitgonedown.com",
  },
  { // Day 30
    twitter: "30 days. Countless sites checked. One simple mission: helping people figure out if it's them or the internet. isitgonedown.com 🚀",
    linkedin: "30 days of IsItGone. One mission, one tool, one community. Thank you for being part of this journey. Here's to the next 30. isitgonedown.com",
    facebook: "30 days of IsItGone! 🎉 We're just getting started. If you've found it useful — please share it. If you're new — welcome! Check any site now → isitgonedown.com",
  },
];

// Blotato account IDs
const ACCOUNTS = [
  { id: 15712, platform: 'Twitter',   contentKey: 'twitter'  },
  { id: 17133, platform: 'LinkedIn',  contentKey: 'linkedin' },
  { id: 25818, platform: 'Facebook',  contentKey: 'facebook' },
  { id: 39553, platform: 'Instagram', contentKey: 'facebook' }, // Instagram uses Facebook content
];

function postToBlotato(accountId, text) {
  return new Promise((resolve, reject) => {
    const bodyStr = JSON.stringify({ accountId, text, postingType: 'automatic' });
    const req = https.request({
      hostname: 'backend.blotato.com',
      path: '/v2/posts',
      method: 'POST',
      headers: {
        'blotato-api-key': BLOTATO_API_KEY,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(bodyStr),
      },
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch (e) { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    req.write(bodyStr);
    req.end();
  });
}

exports.handler = async (event) => {
  const todayUTC = new Date();
  todayUTC.setHours(0, 0, 0, 0);
  const dayIndex = Math.round((todayUTC - CAMPAIGN_START) / (1000 * 60 * 60 * 24));

  if (dayIndex < 0 || dayIndex >= CONTENT.length) {
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Outside 30-day campaign window', dayIndex }),
    };
  }

  const dayContent = CONTENT[dayIndex];
  const dayNumber = dayIndex + 1;
  const results = [];

  for (const account of ACCOUNTS) {
    const text = dayContent[account.contentKey];
    try {
      const result = await postToBlotato(account.id, text);
      results.push({ platform: account.platform, accountId: account.id, status: result.status, body: result.body });
      console.log(`Posted to ${account.platform}: ${result.status}`);
    } catch (err) {
      results.push({ platform: account.platform, accountId: account.id, error: err.message });
      console.error(`Error posting to ${account.platform}:`, err.message);
    }
  }

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ dayNumber, results }),
  };
};
