// BrandHub API load test (k6).
// Run:  k6 run -e BASE_URL=https://api.brandhub.id.vn -e USERS_FILE=users.json -e PROFILE=smoke brandhub-api.k6.js
// users.json: [{"identifier":"loadtest1@...","password":"..."}, ...]  (test accounts only, git-ignored)
// Gateway limits 100 req/min per user -> use several accounts so the test does not just measure 429s.
import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { SharedArray } from 'k6/data';
import { Rate, Trend } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'https://api.brandhub.id.vn';
const PROFILE = __ENV.PROFILE || 'smoke';
const THINK_MIN = Number(__ENV.THINK_MIN || 5);
const THINK_MAX = Number(__ENV.THINK_MAX || 15);

const users = new SharedArray('users', () => JSON.parse(open(__ENV.USERS_FILE || './users.json')));

const rateLimited = new Rate('rate_limited_429');
const loginTime = new Trend('login_duration', true);

// Ramp profiles: target = concurrent virtual users (each ~1 req / 10s like a real user).
const PROFILES = {
  smoke: [{ duration: '1m', target: 5 }],
  load: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 300 },
    { duration: '5m', target: 600 },
    { duration: '2m', target: 0 },
  ],
  stress: [
    { duration: '2m', target: 300 },
    { duration: '3m', target: 800 },
    { duration: '3m', target: 1200 },
    { duration: '3m', target: 1600 },
    { duration: '2m', target: 0 },
  ],
  soak: [
    { duration: '5m', target: 400 },
    { duration: '50m', target: 400 }, // drains t3.small CPU credits -> shows sustained capacity
    { duration: '5m', target: 0 },
  ],
};

export const options = {
  scenarios: {
    browse: { executor: 'ramping-vus', startVUs: 0, stages: PROFILES[PROFILE], gracefulRampDown: '30s' },
  },
  thresholds: {
    http_req_failed: [{ threshold: 'rate<0.01', abortOnFail: PROFILE !== 'stress', delayAbortEval: '1m' }],
    http_req_duration: ['p(95)<800', 'p(99)<2000'],
    rate_limited_429: ['rate<0.01'],
  },
};

function authHeaders(token) {
  return { headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } };
}

function login() {
  const u = users[(__VU - 1) % users.length];
  const res = http.post(`${BASE_URL}/api/v1/auth/login`, JSON.stringify(u), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'POST /auth/login' },
  });
  loginTime.add(res.timings.duration);
  check(res, { 'login 200': (r) => r.status === 200 });
  const token = res.json('data.accessToken');
  if (!token) {
    console.error(`login failed for ${u.identifier}: ${res.status} ${res.json('error.code')}`);
    sleep(30); // back off instead of hammering /auth/login
  }
  return token;
}

function get(path, token, name) {
  const res = http.get(`${BASE_URL}${path}`, { ...authHeaders(token), tags: { name } });
  rateLimited.add(res.status === 429);
  check(res, { [`${name} 2xx`]: (r) => r.status >= 200 && r.status < 300 });
  return res;
}

const think = () => sleep(THINK_MIN + Math.random() * (THINK_MAX - THINK_MIN));

// Per-VU state: log in once, reuse token like a real session.
let token = null;
let workspaceId = null;

export default function () {
  if (!token) {
    token = login();
    if (!token) return;
    const ws = get('/api/v1/workspaces', token, 'GET /workspaces');
    const list = ws.json('data');
    const items = Array.isArray(list) ? list : (list && (list.content || list.items)) || [];
    workspaceId = items.length ? items[0].id : null;
    think();
  }

  group('workspace browse', () => {
    get('/api/v1/workspaces', token, 'GET /workspaces');
    think();
    if (!workspaceId) return;
    get(`/api/v1/workspaces/${workspaceId}/dashboard`, token, 'GET /workspaces/:id/dashboard');
    think();
    get(`/api/v1/workspaces/${workspaceId}/posts`, token, 'GET /workspaces/:id/posts');
    think();
    get(`/api/v1/workspaces/${workspaceId}/campaigns`, token, 'GET /workspaces/:id/campaigns');
    think();
    get(`/api/v1/workspaces/${workspaceId}/members`, token, 'GET /workspaces/:id/members');
    think();
  });
}
