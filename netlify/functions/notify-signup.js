const https = require('https');

function resendRequest(payload) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify(payload);
    const req = https.request({
      hostname: 'api.resend.com',
      path: '/emails',
      method: 'POST',
      headers: {
        'Authorization': 'Bearer ' + process.env.RESEND_API_KEY,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body)
      }
    }, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'Method Not Allowed' };

  try {
    const { email, name } = JSON.parse(event.body || '{}');
    if (!email) return { statusCode: 400, body: 'Missing email' };

    const now = new Date().toLocaleString('en-IE', {
      timeZone: 'Europe/Dublin',
      dateStyle: 'full',
      timeStyle: 'short'
    });

    await resendRequest({
      from: 'IsItGoneDown <alerts@isitgonedown.com>',
      to: ['roryphillips@heskap.com'],
      subject: '🎉 New Pro signup on IsItGoneDown!',
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:0 auto;padding:24px;">
          <h2 style="color:#f59e0b;margin-bottom:4px;">New Pro Signup! 🎉</h2>
          <p style="color:#666;margin-top:0;">Someone just joined IsItGoneDown Pro.</p>
          <table style="width:100%;border-collapse:collapse;margin-top:16px;">
            <tr>
              <td style="padding:10px 12px;background:#f9f9f9;font-weight:600;width:80px;">Email</td>
              <td style="padding:10px 12px;background:#f9f9f9;">${email}</td>
            </tr>
            <tr>
              <td style="padding:10px 12px;font-weight:600;">Name</td>
              <td style="padding:10px 12px;">${name || '(not provided)'}</td>
            </tr>
            <tr>
              <td style="padding:10px 12px;background:#f9f9f9;font-weight:600;">Time</td>
              <td style="padding:10px 12px;background:#f9f9f9;">${now}</td>
            </tr>
          </table>
          <p style="margin-top:20px;font-size:0.85rem;color:#999;">
            View in <a href="https://dashboard.stripe.com/customers" style="color:#f59e0b;">Stripe</a> ·
            <a href="https://console.firebase.google.com" style="color:#f59e0b;">Firebase</a>
          </p>
        </div>
      `
    });

    return { statusCode: 200, body: JSON.stringify({ ok: true }) };
  } catch(e) {
    console.error('notify-signup error:', e);
    return { statusCode: 500, body: 'Error' };
  }
};
