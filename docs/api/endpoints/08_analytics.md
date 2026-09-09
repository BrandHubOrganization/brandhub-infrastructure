# DA-E07-01 — Analytics Endpoints

**Group:** Analytics | **Base path:** `/api/v1/analytics`  
**Auth policy:** All endpoints `[JWT]`

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Roles |
|---|--------|------|-------|
| 53 | GET | `/api/v1/analytics/workspace` | OWNER, MANAGER, ACCOUNT |
| 54 | GET | `/api/v1/analytics/clients/{clientId}` | OWNER, MANAGER, ACCOUNT, CLIENT |
| 55 | GET | `/api/v1/analytics/ai-usage` | OWNER |

> **Data source:** All analytics computed via MongoDB aggregation on `posts` and `ai_usage_logs` collections. No separate analytics store — queries run at request time. Cache with Redis (TTL 5 min) for high-traffic endpoints.
>
> **Note:** These endpoints measure BrandHub platform usage data (posts created, AI credits consumed). They do NOT return social platform engagement metrics (likes, reach, impressions) — those require separate social API integration, tracked via future `platform_metrics` collection.

---

## GET /api/v1/analytics/workspace

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`, `ACCOUNT`  
**Goal:** Aggregate post stats across all clients in the workspace for a date range.

**Query params:**
- `from` (ISO date string, required — e.g. `2025-01-01`)
- `to` (ISO date string, required — e.g. `2025-01-31`)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "period": {
      "from": "ISO8601",
      "to": "ISO8601"
    },
    "totalPosts": "number",
    "publishedPosts": "number",
    "failedPosts": "number",
    "cancelledPosts": "number",
    "pendingPosts": "number (DRAFT + PENDING_APPROVAL + APPROVED + SCHEDULED)",
    "postsByStatus": {
      "DRAFT": "number",
      "PENDING_APPROVAL": "number",
      "APPROVED": "number",
      "SCHEDULED": "number",
      "PUBLISHED": "number",
      "FAILED": "number",
      "CANCELLED": "number"
    },
    "postsByPlatform": {
      "FACEBOOK": "number",
      "INSTAGRAM": "number",
      "TIKTOK": "number",
      "THREADS": "number",
      "ZALO_OA": "number"
    },
    "aiGeneratedCount": "number",
    "topClients": [
      {
        "clientId": "uuid",
        "clientName": "string",
        "postCount": "number"
      }
    ]
  }
}
```

**Errors:**
- `400 INVALID_DATE_RANGE` — `from` after `to`, or range exceeds 365 days
- `400 DATE_REQUIRED` — `from` or `to` missing

**Implementation notes:**
- MongoDB aggregation on `posts` collection: `{ workspaceId: X-Workspace-Id, createdAt: { $gte: from, $lte: to } }`
- `topClients`: top 5 by post count, `$group` by `clientId` then `$sort` by count desc, join client names from PG (or cache)
- Redis cache key: `analytics:workspace:{workspaceId}:{from}:{to}` TTL 5 min

---

## GET /api/v1/analytics/clients/{clientId}

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`, `ACCOUNT`, `CLIENT`  
**Goal:** Per-client post stats and service package usage for the period.

**Path param:** `clientId` (UUID)

**Query params:**
- `from` (ISO date string, required)
- `to` (ISO date string, required)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "clientId": "uuid",
    "clientName": "string",
    "period": {
      "from": "ISO8601",
      "to": "ISO8601"
    },
    "totalPosts": "number",
    "publishedPosts": "number",
    "failedPosts": "number",
    "postsByPlatform": {
      "FACEBOOK": "number",
      "INSTAGRAM": "number",
      "TIKTOK": "number",
      "THREADS": "number",
      "ZALO_OA": "number"
    },
    "aiGeneratedCount": "number",
    "servicePackageUsage": {
      "postsUsed": "number (published this calendar month)",
      "postsLimit": "number (-1 = unlimited)",
      "aiCreditsUsed": "number (used this calendar month)",
      "aiCreditsLimit": "number"
    }
  }
}
```

**Errors:**
- `403 FORBIDDEN` — ACCOUNT accessing unassigned client; CLIENT accessing non-own client
- `404 CLIENT_NOT_FOUND`
- `400 INVALID_DATE_RANGE`

**Implementation notes:**
- `servicePackageUsage`: counts for current calendar month (not the query `from/to` range), since quotas reset monthly
- `CLIENT` access check: `clients.portal_user_id = X-User-Id`

---

## GET /api/v1/analytics/ai-usage

**Auth:** `[JWT]` | **Roles:** `OWNER`  
**Goal:** AI credit consumption breakdown by feature for the workspace.

**Query params:**
- `from` (ISO date string, required)
- `to` (ISO date string, required)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "period": {
      "from": "ISO8601",
      "to": "ISO8601"
    },
    "totalCreditsUsed": "number",
    "byFeature": {
      "content_gen": "number",
      "image_gen": "number",
      "video_gen": "number",
      "rag": "number",
      "ambassador": "number",
      "trends": "number"
    },
    "byClient": [
      {
        "clientId": "uuid",
        "clientName": "string",
        "creditsUsed": "number"
      }
    ],
    "dailyUsage": [
      {
        "date": "YYYY-MM-DD",
        "creditsUsed": "number"
      }
    ]
  }
}
```

**Errors:**
- `400 INVALID_DATE_RANGE` — range exceeds 90 days (daily breakdown too granular beyond that)
- `400 DATE_REQUIRED`

**Implementation notes:**
- MongoDB aggregation on `ai_usage_logs`: `{ workspaceId: X-Workspace-Id, createdAt: { $gte: from, $lte: to } }`
- `byFeature`: `$group` by `feature` field
- `byClient`: `$group` by `clientId`, top 10
- `dailyUsage`: `$group` by `{ $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }`
- Only OWNER can see AI cost — MANAGER/ACCOUNT do not have billing visibility
