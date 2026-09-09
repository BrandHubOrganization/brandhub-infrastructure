# DA-E07-01 — Report Endpoints

**Group:** Report | **Base path:** `/api/v1/reports`  
**Auth policy:** All endpoints `[JWT]`

**Index:** [00_conventions.md](00_conventions.md) | [← Back to main](../DA-E07-01_Business_Service_Endpoints.md)

---

## Endpoints in this group

| # | Method | Path | Roles |
|---|--------|------|-------|
| 56 | POST | `/api/v1/reports` | OWNER, MANAGER, ACCOUNT |
| 57 | GET | `/api/v1/reports/{jobId}` | OWNER, MANAGER, ACCOUNT, CLIENT |
| 58 | GET | `/api/v1/reports` | OWNER, MANAGER, ACCOUNT |

> **Generation model:** Reports are generated asynchronously. POST creates a job (status: PENDING), a background worker processes it and uploads the result to S3. Client polls GET /{jobId} until status = DONE.

---

## POST /api/v1/reports

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`, `ACCOUNT`  
**Goal:** Trigger asynchronous report generation.

**Request body:**
```json
{
  "clientId": "uuid (optional — omit for workspace-wide report; provide for client-specific report)",
  "dateFrom": "ISO8601 date (required — e.g. 2025-01-01)",
  "dateTo": "ISO8601 date (required — e.g. 2025-01-31)",
  "format": "PDF | CSV (optional, default PDF)"
}
```

**Response 202:**
```json
{
  "success": true,
  "data": {
    "jobId": "string (MongoDB ObjectId)",
    "status": "PENDING",
    "estimatedSeconds": 30
  }
}
```

**Errors:**
- `400 INVALID_DATE_RANGE` — `dateFrom` after `dateTo`, or range exceeds 365 days
- `400 DATE_REQUIRED` — missing required date fields
- `403 CLIENT_ACCESS_DENIED` — ACCOUNT requesting report for unassigned client

**Implementation notes:**
- Insert `report_jobs` document in MongoDB: `{ workspaceId, clientId?, dateFrom, dateTo, format, status: PENDING, requestedBy: X-User-Id, createdAt: now() }`
- Publish message to RabbitMQ `report.generate` queue for background processing
- Worker generates report → uploads to S3 key: `reports/{workspaceId}/{jobId}.{format.toLowerCase()}`
- Worker updates `report_jobs` doc: `status = DONE`, `fileUrl = S3 presigned URL`, `completedAt = now()`
- Rate limit: max 5 concurrent PENDING jobs per workspace

---

## GET /api/v1/reports/{jobId}

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`, `ACCOUNT`, `CLIENT`  
**Goal:** Poll report job status. When DONE, returns download URL.

**Path param:** `jobId` (MongoDB ObjectId)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "jobId": "string",
    "status": "PENDING | RUNNING | DONE | FAILED",
    "format": "PDF | CSV",
    "clientId": "uuid | null",
    "dateFrom": "ISO8601",
    "dateTo": "ISO8601",
    "fileUrl": "string (S3 presigned URL, 1h TTL — only populated when status = DONE)",
    "errorMessage": "string | null (populated when status = FAILED)",
    "createdAt": "ISO8601",
    "completedAt": "ISO8601 | null"
  }
}
```

**Errors:**
- `403 FORBIDDEN` — CLIENT accessing a report not for their client; ACCOUNT accessing report for unassigned client
- `404 JOB_NOT_FOUND`

**Implementation notes:**
- `CLIENT` access: `report_jobs.clientId = their linked clientId` AND `report_jobs.workspaceId = X-Workspace-Id`
- S3 presigned URL generated fresh on each poll request (URL may expire between polls — regenerate each time)
- Poll interval recommendation: 3–5 seconds; max 60 attempts before treating as failed

---

## GET /api/v1/reports

**Auth:** `[JWT]` | **Roles:** `OWNER`, `MANAGER`, `ACCOUNT`  
**Goal:** List past report jobs for the workspace.

**Query params:**
- `clientId` (uuid, optional — filter by client)
- `status` (optional — `PENDING | RUNNING | DONE | FAILED`)
- `page` (default 1)
- `size` (default 20, max 50)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "jobId": "string",
        "status": "string",
        "format": "PDF | CSV",
        "clientId": "uuid | null",
        "clientName": "string | null",
        "dateFrom": "ISO8601",
        "dateTo": "ISO8601",
        "requestedBy": "uuid",
        "requestedByName": "string",
        "createdAt": "ISO8601",
        "completedAt": "ISO8601 | null"
      }
    ],
    "total": "number",
    "page": "number",
    "size": "number"
  }
}
```

**Implementation notes:**
- Scoped to `workspaceId = X-Workspace-Id`
- ACCOUNT filter: only jobs for their assigned clients + workspace-level jobs they created
- `fileUrl` NOT included in list — fetch via GET /{jobId} to get download link
- Ordered by `createdAt DESC`
