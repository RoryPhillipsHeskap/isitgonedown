const https = require('https');

// Nodes to check from — label, check-host.net node name
const NODES = [
  { id: 'de1.node.check-host.net',  label: '🇩🇪 Germany'       },
  { id: 'uk1.node.check-host.net',  label: '🇬🇧 UK'            },
  { id: 'us1.node.check-host.net',  label: '🇺🇸 USA East'      },
  { id: 'us2.node.check-host.net',  label: '🇺🇸 USA West'      },
  { id: 'jp1.node.check-host.net',  label: '🇯🇵 Japan'         },
  { id: 'sg1.node.check-host.net',  label: '🇸🇬 Singapore'     }
];

function request(options) {
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

  const params = event.queryStringParameters || {};

  // ── Poll for results ──────────────────────────────────────────
  if (params.result) {
    const requestId = params.result;
    let res;
    try {
      res = await request({
        hostname: 'check-host.net',
        path: `/check-result/${requestId}`,
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'IsItGoneDown/1.0'
        },
        timeout: 10000
      });
    } catch (e) {
      return { statusCode: 502, headers, body: JSON.stringify({ error: 'Failed to poll results' }) };
    }

    if (res.status !== 200 || typeof res.body !== 'object') {
      return { statusCode: 502, headers, body: JSON.stringify({ error: 'Bad response from check-host.net' }) };
    }

    // Parse each node result
    const results = {};
    for (const node of NODES) {
      const nodeData = res.body[node.id];
      if (!nodeData || nodeData === null) {
        results[node.id] = { label: node.label, status: 'pending' };
        continue;
      }
      // nodeData is an array; first element is the result
      const r = Array.isArray(nodeData) ? nodeData[0] : nodeData;
      if (!r || r === null) {
        results[node.id] = { label: node.label, status: 'pending' };
        continue;
      }
      // r[0] is status string: "1" = ok, "0" = fail, or error object
      if (Array.isArray(r)) {
        const code = r[0]; // 1 = ok, 0 = fail
        const time = r[1]; // response time in seconds
        if (code === 1) {
          results[node.id] = {
            label: node.label,
            status: 'up',
            elapsed: time ? Math.round(time * 1000) : null
          };
        } else {
          results[node.id] = { label: node.label, status: 'down' };
        }
      } else {
        // Error object like { error: "..." }
        results[node.id] = { label: node.label, status: 'down', error: r.error || 'Error' };
      }
    }

    const allDone = Object.values(results).every(r => r.status !== 'pending');
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ requestId, results, done: allDone })
    };
  }

  // ── Initiate a new check ──────────────────────────────────────
  if (!params.host) {
    return { statusCode: 400, headers, body: JSON.stringify({ error: 'Missing host parameter' }) };
  }

  // Sanitise — strip protocol and path, keep hostname only
  let host = params.host.trim();
  try {
    if (!host.startsWith('http')) host = 'https://' + host;
    host = new URL(host).hostname;
  } catch {
    return { statusCode: 400, headers, body: JSON.stringify({ error: 'Invalid host' }) };
  }

  const nodeParam = NODES.map(n => `node=${encodeURIComponent(n.id)}`).join('&');
  const path = `/check-http?host=${encodeURIComponent(host)}&${nodeParam}`;

  let res;
  try {
    res = await request({
      hostname: 'check-host.net',
      path,
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'IsItGoneDown/1.0'
      },
      timeout: 10000
    });
  } catch (e) {
    return { statusCode: 502, headers, body: JSON.stringify({ error: 'Failed to initiate check' }) };
  }

  if (res.status !== 200 || !res.body || !res.body.request_id) {
    return {
      statusCode: 502,
      headers,
      body: JSON.stringify({ error: 'Unexpected response from check-host.net', detail: res.body })
    };
  }

  return {
    statusCode: 200,
    headers,
    body: JSON.stringify({
      requestId: res.body.request_id,
      nodes: NODES.map(n => n.id),
      labels: Object.fromEntries(NODES.map(n => [n.id, n.label]))
    })
  };
};
