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
      let lastChecked = null;
      if (f.lastChecked && f.lastChecked.timestampValue) {
        lastChecked = new Date(f.lastChecked.timestampValue);
      }
      let downSince = null;
      if (f.downSince && f.downSince.timestampValue) {
        downSince = new Date(f.downSince.timestampValue);
      }
      // Support comma-separated emails for multiple recipients
      const emailRaw = f.email?.stringValue || '';
      const emails = emailRaw.split(',').map(e => e.trim()).filter(Boolean);
      return {
        docId,
        userId:           f.userId?.stringValue || '',
        emails,
        email:            emailRaw,
        url:              f.url?.stringValue || '',
        displayUrl:       f.displayUrl?.stringValue || '',
        interval:         parseInt(f.interval?.integerValue || f.interval?.doubleValue || 15),
        lastStatus:       f.lastStatus?.stringValue || 'unknown',
        lastChecked,
        downSince,
        lastAlertSent:    f.lastAlertSent?.timestampValue ? new Date(f.lastAlertSent.timestampValue) : null,
        lastResponseTime: f.lastResponseTime ? parseInt(f.lastResponseTime.integerValue || f.lastResponseTime.doubleValue || 0) : null
      };
    })
    .filter(m => m.url && m.emails.length > 0);
}

// ── Firestore REST: update monitor status ────────────────────
async function updateMonitorStatus(docId, lastStatus, lastChecked, lastAlertSent, lastResponseTime, downSince, clearDownSince) {
  const fields = {
    lastStatus:  { stringValue: lastStatus },
    lastChecked: { timestampValue: lastChecked.toISOString() }
  };
  let mask = 'updateMask.fieldPaths=lastStatus&updateMask.fieldPaths=lastChecked';

  if (lastAlertSent) {
    fields.lastAlertSent = { timestampValue: lastAlertSent.toISOString() };
    mask += '&updateMask.fieldPaths=lastAlertSent';
  }
  if (lastResponseTime) {
    fields.lastResponseTime = { integerValue: lastResponseTime };
    mask += '&updateMask.fieldPaths=lastResponseTime';
  }
  if (downSince) {
    fields.downSince = { timestampValue: downSince.toISOString() };
    mask += '&updateMask.fieldPaths=downSince';
  } else if (clearDownSince) {
    fields.downSince = { nullValue: null };
    mask += '&updateMask.fieldPaths=downSince';
  }

  const payload = JSON.stringify({ fields });
  await request({
    hostname: 'firestore.googleapis.com',
    path: `/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/monitors/${docId}?${mask}&key=${FIREBASE_API_KEY}`,
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) }
  }, payload);
}

// ── Firestore REST: write incident record ────────────────────
async function writeIncident(docId, userId, displayUrl, startTime, endTime, durationMins) {
  const fields = {
    monitorId:    { stringValue: docId },
    userId:       { stringValue: userId },
    displayUrl:   { stringValue: displayUrl },
    startTime:    { timestampValue: startTime.toISOString() },
    endTime:      { timestampValue: endTime.toISOString() },
    durationMins: { integerValue: Math.round(durationMins) }
  };
  const payload = JSON.stringify({ fields });
  await request({
    hostname: 'firestore.googleapis.com',
    path: `/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/incidents?key=${FIREBASE_API_KEY}`,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) }
  }, payload);
}

// ── Firestore REST: append response time history ─────────────
async function appendHistory(docId, timestamp, responseTime, status) {
  // Store as a simple sub-collection document
  const fields = {
    t:  { timestampValue: timestamp.toISOString() },
    ms: { integerValue: responseTime || 0 },
    s:  { stringValue: status }
  };
  const payload = JSON.stringify({ fields });
  await request({
    hostname: 'firestore.googleapis.com',
    path: `/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/monitors/${docId}/history?key=${FIREBASE_API_KEY}`,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) }
  }, payload);
}

// ── Format duration for email ────────────────────────────────
function formatDuration(minutes) {
  if (minutes < 1)  return 'less than a minute';
  if (minutes < 60) return `${Math.round(minutes)} minute${Math.round(minutes) === 1 ? '' : 's'}`;
  const h = Math.floor(minutes / 60);
  const m = Math.round(minutes % 60);
  return m > 0 ? `${h}h ${m}m` : `${h} hour${h === 1 ? '' : 's'}`;
}

// ── Send email via Resend ────────────────────────────────────
async function sendAlert(emails, displayUrl, newStatus, url, downSince) {
  const isDown = newStatus === 'down';
  const subject = isDown
    ? `🔴 ${displayUrl} is DOWN`
    : `✅ ${displayUrl} is back UP`;

  let durationLine = '';
  if (!isDown && downSince) {
    const mins = (Date.now() - downSince.getTime()) / 60000;
    durationLine = `<p style="margin:0 0 16px;font-size:0.88rem;color:#f59e0b;font-weight:600;">⏱ Was down for ${formatDuration(mins)}</p>`;
  }

  const html = `
    <div style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:480px;margin:0 auto;background:#0a0a0f;color:#e4e4f0;border-radius:12px;overflow:hidden;">
      <div style="background:${isDown ? '#ef4444' : '#22c55e'};padding:24px 28px;">
        <h1 style="margin:0;font-size:1.3rem;color:#fff;">${isDown ? '🔴 Site is DOWN' : '✅ Site is back UP'}</h1>
      </div>
      <div style="padding:24px 28px;">
        <p style="font-size:1.1rem;font-weight:700;margin:0 0 8px;color:#fff;">${displayUrl}</p>
        <p style="margin:0 0 20px;color:#9ca3af;font-size:0.9rem;">${url}</p>
        ${durationLine}
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

  // Send to all email addresses
  const toList = Array.isArray(emails) ? emails : [emails];
  for (const to of toList) {
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
    console.log(`Resend → ${to}:`, res.status, JSON.stringify(res.body));
  }
}

// ── Main handler ─────────────────────────────────────────────
exports.handler = async (event) => {
  const headers = { 'Access-Control-Allow-Origin': '*' };

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
    // Check if due
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

    const wasDown = monitor.lastStatus === 'down';
    const isDown  = newStatus === 'down';
    const shouldAlert = (isDown && !wasDown) || (!isDown && wasDown);

    // Track downSince
    let newDownSince = monitor.downSince;
    let clearDownSince = false;

    if (isDown && !wasDown) {
      // Just went down — record when
      newDownSince = now;
    } else if (!isDown && wasDown) {
      // Just came back up — clear downSince after using it
      clearDownSince = true;
    }

    // Send alert
    let alertSent = monitor.lastAlertSent;
    if (shouldAlert) {
      try {
        await sendAlert(monitor.emails, monitor.displayUrl, newStatus, monitor.url, monitor.downSince);
        alertSent = now;
        console.log(`Alert sent to ${monitor.emails.join(', ')} for ${monitor.displayUrl}`);
      } catch(e) {
        console.error('Failed to send alert:', e.message);
      }
    }

    // Write incident record when site recovers
    if (!isDown && wasDown && monitor.downSince) {
      try {
        const durationMins = (now - monitor.downSince) / 60000;
        await writeIncident(monitor.docId, monitor.userId, monitor.displayUrl, monitor.downSince, now, durationMins);
        console.log(`Incident logged: ${monitor.displayUrl} down for ${Math.round(durationMins)} mins`);
      } catch(e) {
        console.error('Failed to write incident:', e.message);
      }
    }

    // Append response time history
    try {
      await appendHistory(monitor.docId, now, elapsed, newStatus);
    } catch(e) {
      console.error('Failed to append history:', e.message);
    }

    // Update monitor document
    try {
      await updateMonitorStatus(
        monitor.docId,
        newStatus,
        now,
        alertSent !== monitor.lastAlertSent ? alertSent : null,
        elapsed,
        isDown && !wasDown ? newDownSince : null,
        clearDownSince
      );
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
