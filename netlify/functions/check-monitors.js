const https = require('https');

const FIREBASE_PROJECT = 'isitgonedown';
const FIREBASE_API_KEY = process.env.FIREBASE_API_KEY;
const RESEND_API_KEY   = process.env.RESEND_API_KEY;
const CRON_SECRET      = process.env.CRON_SECRET;
const FROM_EMAIL       = 'alerts@isitgonedown.com';

// ── HTTP helper ──────────────────────────────────────────────
function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(typeof body === 'string' ? body : JSON.stringify(body));
    req.end();
  });
}

// ── Check if a URL is up (returns status + response time ms) ─
function checkUrl(url) {
  return new Promise(resolve => {
    try {
      const u = new URL(url);
      const start = Date.now();
      const options = {
        hostname: u.hostname,
        path: u.pathname || '/',
        method: 'HEAD',
        headers: { 'User-Agent': 'IsItGoneDown-Monitor/1.0' },
        timeout: 10000
      };
      const mod = u.protocol === 'https:' ? https : require('http');
      const req = mod.request(options, res => {
        const elapsed = Date.now() - start;
        resolve({ status: res.statusCode < 500 ? 'up' : 'down', elapsed });
      });
      req.on('error', () => resolve({ status: 'down', elapsed: null }));
      req.on('timeout', () => { req.destroy(); resolve({ status: 'down', elapsed: null }); });
      req.end();
    } catch { resolve({ status: 'down', elapsed: null }); }
  });
}

// ── Firestore REST: read all active monitors ─────────────────
async function getActiveMonitors() {
  const body = {
    structuredQuery: {
      from: [{ collectionId: 'monitors' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'active' },
          op: 'EQUAL',
          value: { booleanValue: true }
        }
      }
    }
  };
  const payload = JSON.stringify(body);
  const res = await request({
    hostname: 'firestore.googleapis.com',
    path: `/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents:runQuery?key=${FIREBASE_API_KEY}`,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) }
  }, payload);

  if (!Array.isArray(res.body)) return [];
  return res.body
    .filter(r => r.document)
    .map(r => {
      const d = r.document;
      const f = d.fields || {};
      const docId = d.name.split('/').pop();
      // Parse lastChecked timestamp
      let lastChecked = null;
      if (f.lastChecked && f.lastChecked.timestampValue) {
        lastChecked = new Date(f.lastChecked.timestampValue);
      }
      return {
        docId,
        userId:      f.userId?.stringValue || '',
        email:       f.email?.stringValue || '',
        url:         f.url?.stringValue || '',
        displayUrl:  f.displayUrl?.stringValue || '',
        interval:    parseInt(f.interval?.integerValue || f.interval?.doubleValue || 15),
        lastStatus:       f.lastStatus?.stringValue || 'unknown',
        lastChecked,
        lastAlertSent:    f.lastAlertSent?.timestampValue ? new Date(f.lastAlertSent.timestampValue) : null,
        lastResponseTime: f.lastResponseTime ? parseInt(f.lastResponseTime.integerValue || f.lastResponseTime.doubleValue || 0) : null
      };
    })
    .filter(m => m.url && m.email);
}

// ── Firestore REST: update monitor status ────────────────────
async function updateMonitorStatus(docId, lastStatus, lastChecked, lastAlertSent, lastResponseTime) {
  const fields = {
    lastStatus:  { stringValue: lastStatus },
    lastChecked: { timestampValue: lastChecked.toISOString() }
  };
  if (lastAlertSent) fields.lastAlertSent = { timestampValue: lastAlertSent.toISOString() };
  if (lastResponseTime) fields.lastResponseTime = { integerValue: lastResponseTime };

  const payload = JSON.stringify({ fields });
  let mask = 'updateMask.fieldPaths=lastStatus&updateMask.fieldPaths=lastChecked';
  if (lastAlertSent) mask += '&updateMask.fieldPaths=lastAlertSent';
  if (lastResponseTime) mask += '&updateMask.fieldPaths=lastResponseTime';

  await request({
    hostname: 'firestore.googleapis.com',
    path: `/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/monitors/${docId}?${mask}&key=${FIREBASE_API_KEY}`,
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) }
  }, payload);
}

// ── Send email via Resend ────────────────────────────────────
async function sendAlert(to, displayUrl, newStatus, url) {
  const isDown = newStatus === 'down';
  const subject = isDown
    ? `🔴 ${displayUrl} is DOWN`
    : `✅ ${displayUrl} is back UP`;

  const html = `
    <div style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:480px;margin:0 auto;background:#0a0a0f;color:#e4e4f0;border-radius:12px;overflow:hidden;">
      <div style="background:${isDown ? '#ef4444' : '#22c55e'};padding:24px 28px;">
        <h1 style="margin:0;font-size:1.3rem;color:#fff;">${isDown ? '🔴 Site is DOWN' : '✅ Site is back UP'}</h1>
      </div>
      <div style="padding:24px 28px;">
        <p style="font-size:1.1rem;font-weight:700;margin:0 0 8px;color:#fff;">${displayUrl}</p>
        <p style="margin:0 0 20px;color:#9ca3af;font-size:0.9rem;">${url}</p>
        <p style="margin:0 0 24px;font-size:0.9rem;color:#d1d5db;">
          ${isDown
            ? 'Our monitor detected that this site is currently unreachable. We\'ll notify you as soon as it comes back online.'
            : 'Great news — this site is back online and responding normally.'}
        </p>
        <a href="https://isitgonedown.com/?url=${encodeURIComponent(displayUrl)}"
           style="display:inline-block;background:#7c6ff7;color:#fff;text-decoration:none;padding:10px 20px;border-radius:8px;font-weight:600;font-size:0.88rem;">
          Check it now →
        </a>
        <p style="margin:24px 0 0;font-size:0.75rem;color:#6b6b80;">
          You're receiving this because you set up monitoring on IsItGoneDown.com.<br>
          <a href="https://isitgonedown.com" style="color:#7c6ff7;">Manage your monitors</a>
        </p>
      </div>
    </div>`;

  const payload = JSON.stringify({ from: FROM_EMAIL, to, subject, html });
  const res = await request({
    hostname: 'api.resend.com',
    path: '/emails',
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload)
    }
  }, payload);
  console.log('Resend response:', res.status, JSON.stringify(res.body));
  return res;
}

// ── Main handler ─────────────────────────────────────────────
exports.handler = async (event) => {
  const headers = { 'Access-Control-Allow-Origin': '*' };

  // Validate cron secret
  const secret = event.headers['x-cron-secret'] || event.queryStringParameters?.secret;
  if (secret !== CRON_SECRET) {
    return { statusCode: 401, headers, body: 'Unauthorised' };
  }

  const now = new Date();
  console.log('check-monitors running at', now.toISOString());

  let monitors;
  try {
    monitors = await getActiveMonitors();
    console.log(`Found ${monitors.length} active monitors`);
  } catch(e) {
    console.error('Failed to read monitors:', e.message);
    return { statusCode: 500, headers, body: 'Failed to read monitors' };
  }

  const results = [];

  for (const monitor of monitors) {
    // Check if this monitor is due (based on interval)
    if (monitor.lastChecked) {
      const minutesSinceCheck = (now - monitor.lastChecked) / 60000;
      if (minutesSinceCheck < monitor.interval) {
        results.push({ url: monitor.displayUrl, skipped: true });
        continue;
      }
    }

    // Check the URL
    let newStatus, elapsed;
    try {
      const result = await checkUrl(monitor.url);
      newStatus = result.status;
      elapsed   = result.elapsed;
    } catch(e) {
      newStatus = 'down';
      elapsed   = null;
    }

    console.log(`${monitor.displayUrl}: ${monitor.lastStatus} → ${newStatus} (${elapsed}ms)`);

    // Send alert if:
    // - site just went DOWN (from up or unknown)
    // - site came back UP (from down)
    const wasDown = monitor.lastStatus === 'down';
    const isDown  = newStatus === 'down';
    const shouldAlert = (isDown && !wasDown) || (!isDown && wasDown);

    let alertSent = monitor.lastAlertSent;
    if (shouldAlert) {
      try {
        await sendAlert(monitor.email, monitor.displayUrl, newStatus, monitor.url);
        alertSent = now;
        console.log(`Alert sent to ${monitor.email} for ${monitor.displayUrl}`);
      } catch(e) {
        console.error('Failed to send alert:', e.message);
      }
    }

    // Update Firestore
    try {
      await updateMonitorStatus(monitor.docId, newStatus, now, alertSent !== monitor.lastAlertSent ? alertSent : null, elapsed);
    } catch(e) {
      console.error('Failed to update monitor:', e.message);
    }

    results.push({ url: monitor.displayUrl, was: monitor.lastStatus, now: newStatus, elapsed });
  }

  return {
    statusCode: 200,
    headers,
    body: JSON.stringify({ checked: results.length, results })
  };
};
