const https = require('https');

const FIREBASE_PROJECT = 'isitgonedown';
const FIREBASE_API_KEY = process.env.FIREBASE_API_KEY;
const BASE = `firestore.googleapis.com`;
const DOC_PATH = `/v1/projects/${FIREBASE_PROJECT}/databases/(default)/documents/communityVotes`;

function httpsRequest(path, method, body) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const options = {
      hostname: BASE,
      path,
      method,
      headers: { 'Content-Type': 'application/json' }
    };
    if (payload) options.headers['Content-Length'] = Buffer.byteLength(payload);
    const req = https.request(options, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

function urlToDocId(url) {
  return url.replace(/[^a-zA-Z0-9]/g, '_').substring(0, 100);
}

async function getVotes(docId) {
  const res = await httpsRequest(`${DOC_PATH}/${docId}?key=${FIREBASE_API_KEY}`, 'GET', null);
  if (res.status === 404 || !res.body.fields) return { downCount: 0, upCount: 0 };
  const f = res.body.fields;
  return {
    downCount: parseInt(f.downCount?.integerValue || 0),
    upCount:   parseInt(f.upCount?.integerValue   || 0)
  };
}

async function setVotes(docId, downCount, upCount) {
  const fields = {
    downCount: { integerValue: String(downCount) },
    upCount:   { integerValue: String(upCount) }
  };
  // No updateMask — this creates the document if it doesn't exist, or replaces it if it does
  const res = await httpsRequest(`${DOC_PATH}/${docId}?key=${FIREBASE_API_KEY}`, 'PATCH', { fields });
  if (res.status < 200 || res.status >= 300) {
    throw new Error(`Firestore PATCH failed: ${res.status} ${JSON.stringify(res.body)}`);
  }
  return res;
}

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Content-Type': 'application/json'
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };

  const params = event.queryStringParameters || {};

  // GET — return current vote counts for a URL
  if (event.httpMethod === 'GET') {
    const url = params.url;
    if (!url) return { statusCode: 400, headers, body: JSON.stringify({ error: 'url required' }) };

const votes = await getVotes(urlToDocId(url));
    return { statusCode: 200, headers, body: JSON.stringify(votes) };
  }

  // POST — cast or remove a vote
  if (event.httpMethod === 'POST') {
    try {
      const { url, vote, action } = JSON.parse(event.body || '{}');
      if (!url) return { statusCode: 400, headers, body: JSON.stringify({ error: 'url required' }) };
      if (!vote || !['up', 'down'].includes(vote)) {
        return { statusCode: 400, headers, body: JSON.stringify({ error: 'vote must be up or down' }) };
      }

      const docId = urlToDocId(url);
      const current = await getVotes(docId);
      const delta = action === 'remove' ? -1 : 1;

      const newDown = Math.max(0, current.downCount + (vote === 'down' ? delta : 0));
      const newUp   = Math.max(0, current.upCount   + (vote === 'up'   ? delta : 0));

      await setVotes(docId, newDown, newUp);

      return { statusCode: 200, headers, body: JSON.stringify({ downCount: newDown, upCount: newUp }) };
    } catch(e) {
      console.error('community-vote error:', e.message);
      return { statusCode: 500, headers, body: JSON.stringify({ error: e.message }) };
    }
  }

  return { statusCode: 405, headers, body: 'Method not allowed' };
};
