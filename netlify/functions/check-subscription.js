const https = require('https');

function stripeRequest(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.stripe.com',
      path,
      method: 'GET',
      headers: { 'Authorization': 'Bearer ' + process.env.STRIPE_SECRET_KEY }
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch(e) { reject(e); } });
    });
    req.on('error', reject);
    req.end();
  });
}

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, OPTIONS'
  };
  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  try {
    const { email } = event.queryStringParameters || {};
    if (!email) return { statusCode: 400, headers, body: JSON.stringify({ isPro: false }) };
    const customers = await stripeRequest('/v1/customers?email=' + encodeURIComponent(email.toLowerCase()) + '&limit=1');
    if (!customers.data || customers.data.length === 0) return { statusCode: 200, headers, body: JSON.stringify({ isPro: false }) };
    const subs = await stripeRequest('/v1/subscriptions?customer=' + customers.data[0].id + '&status=active&limit=1');
    return { statusCode: 200, headers, body: JSON.stringify({ isPro: !!(subs.data && subs.data.length > 0) }) };
  } catch(err) {
    return { statusCode: 500, headers, body: JSON.stringify({ isPro: false }) };
  }
};
