const https = require('https');

const BLOTATO_API_KEY = process.env.BLOTATO_API_KEY;

function httpsRequest(hostname, path, headers) {
  return new Promise((resolve, reject) => {
    const options = { hostname, path, method: 'GET', headers };
    const req = https.request(options, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    req.end();
  });
}

function formatDate(iso) {
  if (!iso) return 'N/A';
  const d = new Date(iso);
  return d.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric' }) +
    ' at ' + d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
}

function platformEmoji(platform) {
  const map = {
    twitter: 'X/Twitter',
    instagram: 'Instagram',
    linkedin: 'LinkedIn',
    facebook: 'Facebook',
    tiktok: 'TikTok'
  };
  return map[platform] || platform;
}

function platformColor(platform) {
  const map = {
    twitter: '#1DA1F2',
    instagram: '#E4405F',
    linkedin: '#0A66C2',
    facebook: '#1877F2',
    tiktok: '#000000'
  };
  return map[platform] || '#666666';
}

function buildHtml(items) {
  const now = new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });

  let rows = '';
  if (!items || items.length === 0) {
    rows = '<tr><td colspan="3" style="padding:15px; text-align:center; color:#999;">No scheduled posts found.</td></tr>';
  } else {
    items.forEach((item, i) => {
      const platform = (item.draft && item.draft.target && item.draft.target.targetType) || 'unknown';
      const text = (item.draft && item.draft.content && item.draft.content.text) || 'No content';
      const scheduledAt = item.scheduledAt || '';
      const account = (item.account && (item.account.username || item.account.name)) || '';
      const color = platformColor(platform);
      const bgColor = i % 2 === 0 ? '#ffffff' : '#f9fafb';

      // Truncate text to 200 chars for readability
      const shortText = text.length > 200 ? text.substring(0, 200) + '...' : text;

      rows += `
        <tr style="background:${bgColor};">
          <td style="padding:12px; border-bottom:1px solid #eee; vertical-align:top; white-space:nowrap;">
            <strong style="color:${color};">${platformEmoji(platform)}</strong><br>
            <span style="font-size:11px; color:#888;">@${account}</span>
          </td>
          <td style="padding:12px; border-bottom:1px solid #eee; vertical-align:top; white-space:nowrap; font-size:13px; color:#555;">
            ${formatDate(scheduledAt)}
          </td>
          <td style="padding:12px; border-bottom:1px solid #eee; vertical-align:top; font-size:13px; color:#333; line-height:1.5;">
            ${shortText}
          </td>
        </tr>`;
    });
  }

  return `
<!DOCTYPE html>
<html>
<body style="font-family:Arial,Helvetica,sans-serif; margin:0; padding:20px; background:#f0f2f5;">
  <div style="max-width:800px; margin:0 auto; background:#ffffff; border-radius:12px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,0.1);">
    <div style="background:#2c3e50; padding:25px 30px;">
      <h1 style="margin:0; color:#ffffff; font-size:22px;">IsItGoneDown - Daily Post Report</h1>
      <p style="margin:5px 0 0; color:#95a5a6; font-size:13px;">${now}</p>
    </div>
    <div style="padding:5px 25px 15px;">
      <p style="color:#555; font-size:14px;">Here are your upcoming scheduled Blotato posts (${items ? items.length : 0} total):</p>
      <table style="width:100%; border-collapse:collapse; font-family:Arial,sans-serif;">
        <tr style="background:#f1f3f5;">
          <th style="padding:10px 12px; text-align:left; font-size:12px; color:#666; text-transform:uppercase; border-bottom:2px solid #dee2e6;">Platform</th>
          <th style="padding:10px 12px; text-align:left; font-size:12px; color:#666; text-transform:uppercase; border-bottom:2px solid #dee2e6;">Scheduled</th>
          <th style="padding:10px 12px; text-align:left; font-size:12px; color:#666; text-transform:uppercase; border-bottom:2px solid #dee2e6;">Content</th>
        </tr>
        ${rows}
      </table>
    </div>
    <div style="background:#f8f9fa; padding:15px 25px; border-top:1px solid #eee;">
      <p style="margin:0; color:#aaa; font-size:11px;">Auto-generated daily by Make.com at 10:05 AM | Powered by Blotato API</p>
    </div>
  </div>
</body>
</html>`;
}

exports.handler = async (event) => {
  // Only allow GET
  if (event.httpMethod !== 'GET') {
    return { statusCode: 405, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  const apiKey = BLOTATO_API_KEY || (event.headers && event.headers['blotato-api-key']) || (event.queryStringParameters && event.queryStringParameters.key);
  if (!apiKey) {
    return { statusCode: 400, body: JSON.stringify({ error: 'No API key configured' }) };
  }

  try {
    const result = await httpsRequest(
      'backend.blotato.com',
      '/v2/schedules?limit=20',
      { 'blotato-api-key': apiKey }
    );

    if (result.status !== 200) {
      return {
        statusCode: result.status,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Blotato API error', details: result.body })
      };
    }

    const items = result.body.items || [];
    const html = buildHtml(items);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
      body: html
    };
  } catch (err) {
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: err.message })
    };
  }
};
