const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, OPTIONS'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    const { email } = event.queryStringParameters || {};
    if (!email) return { statusCode: 400, headers, body: JSON.stringify({ isPro: false }) };

    const customers = await stripe.customers.list({ email: email.toLowerCase(), limit: 1 });
    if (customers.data.length === 0) return { statusCode: 200, headers, body: JSON.stringify({ isPro: false }) };

    const subscriptions = await stripe.subscriptions.list({
      customer: customers.data[0].id,
      status: 'active',
      limit: 1
    });

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ isPro: subscriptions.data.length > 0 })
    };
  } catch (err) {
    return { statusCode: 500, headers, body: JSON.stringify({ isPro: false, error: err.message }) };
  }
};
