# BrandHub Production API Capacity & Load Testing (`prod/loadtest/`)

- Back to [Production Hub](../README.md) · [Infrastructure Hub](../../README.md) · [Operations Runbooks](../../docs/operations/README.md)
- `k6` Test Script: [`brandhub-api.k6.js`](brandhub-api.k6.js)

Authenticated `k6` (`ramping-vus`) workload suite benchmarking BrandHub's read-path capacity through the public HTTPS gateway (`https://api.brandhub.id.vn`) across workspace listing, dashboard aggregation, posts, campaigns, and member directories.

> **Cost & Safety Guardrail**: Generative AI routes (`/api/v1/ai/*`) and external social publishing triggers are intentionally excluded from `brandhub-api.k6.js` so load, stress, and soak runs never consume Groq/Gemini/Claude tokens, Vast.ai GPU hours, or live Facebook/Instagram/TikTok/Threads page quotas.

---

## 1. Prerequisites & Multi-Account Setup

1. Install Grafana `k6` (`winget install GrafanaLabs.k6` on Windows or `brew install k6` on macOS).
2. Provision **20–50 verified test user accounts** (`Owner`, `Manager`, or `Creator` with 2FA disabled, each belonging to at least one seeded workspace).
3. Create `prod/loadtest/users.json` (gitignored by [`../.gitignore`](../.gitignore)):
   ```json
   [
     { "identifier": "loadtest01@demo.brandhub.test", "password": "<test_password>" },
     { "identifier": "loadtest02@demo.brandhub.test", "password": "<test_password>" }
   ]
   ```

> **Why 20+ Accounts Are Required**: `RateLimitGatewayFilterFactory` in `brandhub-api-gateway` enforces a Redis sliding-window rate limit of **`100` requests/minute per authenticated user** (and `20` requests/minute on `/api/v1/auth/**`). Each Virtual User (VU) maps deterministically to `users[(__VU - 1) % users.length]`, logs in once per VU lifecycle, and caches its RS256 `accessToken` + `workspaceId`. Running high VU counts with a single test credential measures `429 Too Many Requests` rejections instead of backend throughput.

---

## 2. Workload Loop & Pass/Fail SLO Thresholds

Each VU simulates realistic interactive workspace browsing with randomized think times (`THINK_MIN=5` to `THINK_MAX=15` seconds, averaging ~1 request every 10 seconds per VU):

1. `GET /api/v1/workspaces`
2. `GET /api/v1/workspaces/:workspaceId/dashboard`
3. `GET /api/v1/workspaces/:workspaceId/posts`
4. `GET /api/v1/workspaces/:workspaceId/campaigns`
5. `GET /api/v1/workspaces/:workspaceId/members`

**Configured `k6` SLO Thresholds**:
- `http_req_failed`: **`rate < 0.01`** (`< 1%` error rate; auto-aborts after `1m` grace period on `smoke`, `load`, and `soak`)
- `http_req_duration`: **`p(95) < 800ms`** and **`p(99) < 2000ms`**
- `rate_limited_429` (custom `Rate` metric): **`rate < 0.01`** (`< 1%` HTTP `429` responses)
- `login_duration` (custom `Trend` metric): tracks RS256 token issuance + BCrypt verification latency on `POST /api/v1/auth/login`

---

## 3. Execution Profiles & CLI Commands

| Profile (`PROFILE=`) | Ramp Schedule (`stages`) | Total Duration | Primary Engineering Goal |
| :--- | :--- | :---: | :--- |
| **`smoke`** *(default)* | `0 → 5 VUs` (`1m`) | `1 min` | Validate TLS, test account pool, JWT extraction, and workspace lookup |
| **`load`** | `0 → 100` (`2m`) → `300` (`5m`) → `600` (`5m`) → `0` (`2m`) | `14 min` | Verify steady-state production capacity (~60 RPS sustained across 600 concurrent users) |
| **`stress`** | `0 → 300` (`2m`) → `800` (`3m`) → `1200` (`3m`) → `1600` (`3m`) → `0` (`2m`) | `13 min` | Locate saturation knee across HikariCP, PostgreSQL (`640m`), MongoDB Atlas, and `business-service` (`1100m`) |
| **`soak`** | `0 → 400` (`5m`) → hold `400` (`50m`) → `0` (`5m`) | `60 min` | Detect memory leaks, connection pool drift, and `t3.small` CPU credit exhaustion on `brandhub-api-gateway` |

```powershell
cd prod/loadtest

# Quick smoke check
k6 run -e BASE_URL=https://api.brandhub.id.vn -e USERS_FILE=users.json -e PROFILE=smoke brandhub-api.k6.js

# Full target load test with JSON summary export
k6 run -e BASE_URL=https://api.brandhub.id.vn -e USERS_FILE=users.json -e PROFILE=load `
  --summary-export=load-summary.json brandhub-api.k6.js
```

---

## 4. Production Telemetry Checklist During Runs

- **On `brandhub-api-gateway` (`t3.small`, `172.31.27.199`)**: Watch CloudWatch `CPUCreditBalance` (burstable `t3.small` baseline is 20% CPU) and `docker stats brandhub-api-gateway nginx`.
- **On `brandhub-core-services` (`m7i-flex.large`, `172.31.24.149`)**: Watch `docker stats` across `brandhub-business-service` (`1100m` cap), `brandhub-postgres` (`640m` cap), and `brandhub-redis` (`384m` cap), plus MongoDB Atlas connection/opcounters.
- **Window Policy**: Execute `load`, `stress`, and `soak` profiles against production only during scheduled off-peak windows.
