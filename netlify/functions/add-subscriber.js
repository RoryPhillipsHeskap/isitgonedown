const https = require('https');

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS'
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: 'Method not allowed' };

  try {
    const { email, firstName } = JSON.parse(event.body || '{}');
    if (!email) return { statusCode: 400, headers, body: JSON.stringify({ error: 'Email required' }) };

    // Systeme.io API requires fields as an array with slug/value pairs
    const payload = JSON.stringify({
      email,
      fields: firstName ? [{ slug: 'first_name', value: firstName }] : [],
      tags: [{ id: 1943782 }]
    });

    const result = await new Promise((resolve, reject) => {
      const options = {
        hostname: 'api.systeme.io',
        path: '/api/contacts',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': process.env.SYSTEMEIO_API_KEY,
          'Content-Length': Buffer.byteLength(payload)
        }
      };
      const req = https.request(options, (res) => {
        let body = '';
        res.on('data', chunk => body += chunk);
        res.on('end', () => resolve({ status: res.statusCode, body }));
      });
      req.on('error', reject);
      req.write(payload);
      req.end();
    });

    // Log so it's visible in Netlify function logs for debugging
    console.log('Systeme.io response:', result.status, result.body);

    if (result.status >= 200 && result.status < 300) {
      return { statusCode: 200, headers, body: JSON.stringify({ success: true }) };
    } else {
      return { statusCode: result.status, headers, body: JSON.stringify({ error: result.body }) };
    }

  } catch (err) {
    console.error('add-subscriber error:', err.message);
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};
