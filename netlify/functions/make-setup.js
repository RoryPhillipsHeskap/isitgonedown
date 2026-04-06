const https = require('https');

function makeRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch(e) { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

exports.handler = async (event) => {
  const token = event.queryStringParameters && event.queryStringParameters.token;
  const action = event.queryStringParameters && event.queryStringParameters.action;
  const scenarioId = '5159819';

  if (!token) {
    return { statusCode: 400, body: JSON.stringify({ error: 'Missing token' }) };
  }

  // GET scenario blueprint
  if (!action || action === 'get') {
    const result = await makeRequest({
      hostname: 'eu1.make.com',
      path: `/api/v2/scenarios/${scenarioId}?cols[]=blueprint`,
      method: 'GET',
      headers: {
        'Authorization': `Token ${token}`,
        'Content-Type': 'application/json'
      }
    });
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result)
    };
  }

  // PATCH scenario blueprint to add Google Sheets module
  if (action === 'patch') {
    const blueprintStr = event.queryStringParameters.blueprint;
    if (!blueprintStr) {
      return { statusCode: 400, body: JSON.stringify({ error: 'Missing blueprint' }) };
    }
    const bodyStr = JSON.stringify({ blueprint: JSON.parse(decodeURIComponent(blueprintStr)) });
    const result = await makeRequest({
      hostname: 'eu1.make.com',
      path: `/api/v2/scenarios/${scenarioId}`,
      method: 'PATCH',
      headers: {
        'Authorization': `Token ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(bodyStr)
      }
    }, bodyStr);
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result)
    };
  }

  return { statusCode: 400, body: JSON.stringify({ error: 'Unknown action' }) };
};
