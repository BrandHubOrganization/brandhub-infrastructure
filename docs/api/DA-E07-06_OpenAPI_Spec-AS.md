# DA-E07-06 — OpenAPI YAML Specification for ai-service

**Status:** Done  
**Priority:** High  
**Blocked by:** DA-E07-02 ✓, DA-E07-04 ✓  
**Blocks:** None

---

## 1. Deliverables

| Artifact | Path | Size |
|---|---|---|
| OpenAPI 3.1 YAML | `brandhub-ai-service/docs/openapi.yaml` | Planned generated artifact from FastAPI |
| OpenAPI reference document | `brandhub-infrastructure/docs/api/DA-E07-06_OpenAPI_Spec.md` | This file |

> The canonical runtime OpenAPI document should be exported from `brandhub-ai-service` after FastAPI routes are implemented. This infrastructure document defines the required coverage, schema structure, security model, and validation checklist for that YAML.

---

## 2. Spec Coverage

**10 operations across 7 tags:**

| Tag | Endpoints | HTTP Methods |
|---|---:|---|
| Health | 1 | GET ×1 |
| AI Content | 2 | POST ×2 |
| AI Image | 1 | POST ×1 |
| AI Video | 2 | POST ×1, GET ×1 |
| AI Ambassador | 1 | POST ×1 |
| AI RAG | 3 | POST ×2, DELETE ×1 |
| AI Trends | 1 | GET ×1 |

### Required Paths

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | `/health` | Public | Service health check |
| POST | `/api/v1/ai/content/generate` | Internal | Generate caption/copy |
| POST | `/api/v1/ai/content/regenerate` | Internal | Regenerate caption/copy with feedback |
| POST | `/api/v1/ai/image/generate` | Internal | Generate image assets |
| POST | `/api/v1/ai/video/generate` | Internal | Start video generation job |
| GET | `/api/v1/ai/video/jobs/{jobId}` | Internal | Poll video job status |
| POST | `/api/v1/ai/ambassador/generate` | Internal | Generate face-consistent ambassador image |
| POST | `/api/v1/ai/rag/upload` | Internal | Upload brand knowledge document |
| POST | `/api/v1/ai/rag/query` | Internal | Query brand knowledge chunks |
| DELETE | `/api/v1/ai/rag/documents/{documentId}` | Internal | Delete indexed knowledge document |
| GET | `/api/v1/ai/trends` | Internal | Fetch trend suggestions |

---

## 3. Schema Components

**Reusable schemas required:**

- Envelope: `ApiResponseSuccess`, `ApiResponseError`, `ErrorBody`, `MetaBody`
- Common: `Platform`, `Language`, `Tone`, `ImageStyle`, `VideoStyle`, `AspectRatio`, `JobStatus`
- Content: `ContentGenerateRequest`, `ContentRegenerateRequest`, `ContentGenerateResponse`, `ContentConstraints`
- Image: `ImageGenerateRequest`, `ImageGenerateResponse`, `Asset`
- Video: `VideoGenerateRequest`, `GenerationJob`, `VideoJobStatus`
- Ambassador: `AmbassadorGenerateRequest`, `AmbassadorGenerateResponse`
- RAG: `RagUploadRequest`, `RagUploadResponse`, `RagQueryRequest`, `RagQueryResponse`, `RagMatch`, `RagDeleteResponse`
- Trends: `TrendQuery`, `Trend`, `TrendsResponse`
- Usage: `AiUsage`, `RagSource`

**Reusable responses:**

- `UnauthorizedInternalKey`
- `ValidationError`
- `AiCreditsExhausted`
- `AiModelUnavailable`
- `AiGenerationFailed`
- `JobNotFound`
- `DocumentNotFound`
- `ServiceUnavailable`

**Reusable parameters:**

- `X-Request-Id` header
- `jobId` path parameter
- `documentId` path parameter
- `workspaceId`, `platform`, `region`, `category`, `limit` query parameters for trends

---

## 4. API Design Decisions

### 4.1 ApiResponse envelope

Every response body wraps in `ApiResponse<T>` per DA-E07-04:

```yaml
success: boolean
data: T | null
error: ErrorBody | null
meta: MetaBody | null
requestId: string (UUID)
version: "v1"
timestamp: ISO8601 UTC
```

### 4.2 Internal service authentication

AI endpoints are internal service-to-service endpoints. They are **not** called directly by web/mobile clients.

All internal endpoints must document:

```yaml
security:
  - InternalApiKey: []
```

Security scheme:

```yaml
InternalApiKey:
  type: apiKey
  in: header
  name: X-Internal-Key
```

### 4.3 Public vs internal endpoints

- Public endpoint: `GET /health`
- Internal endpoints: all `/api/v1/ai/**`

`/api/v1/ai/**` should not be routed publicly through `api-gateway`. `business-service` calls `ai-service` through Docker/internal network hostname `ai-service:8082`.

### 4.4 Async job responses

Long-running AI operations should support `202 Accepted`:

- `/api/v1/ai/image/generate`
- `/api/v1/ai/video/generate`
- `/api/v1/ai/ambassador/generate`
- `/api/v1/ai/rag/upload`

Response shape:

```yaml
jobId: string
status: PENDING | PROCESSING | COMPLETED | FAILED | CANCELLED
estimatedSeconds: integer
pollUrl: string
```

### 4.5 204 Never Used

Do not use `204 No Content`. Empty success responses return `200` with:

```yaml
success: true
data: null
error: null
```

### 4.6 File upload

RAG document upload uses `multipart/form-data`.

Required fields:

- `workspaceId`
- `clientId`
- `title`
- `sourceType`
- `file` when `sourceType` is `pdf`, `docx`, or `txt`
- `sourceUrl` when `sourceType` is `url`

---

## 5. FastAPI Integration

### 5.1 Swagger UI auto-served at

FastAPI should expose:

```text
http://localhost:8082/docs
http://localhost:8082/redoc
http://localhost:8082/openapi.json
```

### 5.2 Export expected YAML/JSON artifact

After `brandhub-ai-service` runs locally:

```bash
curl http://localhost:8082/openapi.json > docs/openapi.json
```

If a YAML artifact is required:

```bash
python -c "import json, yaml; print(yaml.safe_dump(json.load(open('docs/openapi.json')), sort_keys=False))" > docs/openapi.yaml
```

### 5.3 Recommended FastAPI metadata

```python
app = FastAPI(
    title="BrandHub AI Service API",
    version="1.0.0",
    description="Internal OpenAPI contract for BrandHub ai-service",
    openapi_url="/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
)
```

### 5.4 Security dependency

All `/api/v1/ai/**` routers should use an internal key dependency:

```python
async def require_internal_key(x_internal_key: str = Header(..., alias="X-Internal-Key")):
    if x_internal_key != settings.INTERNAL_API_KEY:
        raise HTTPException(status_code=401, detail="Missing or invalid internal API key")
```

---

## 6. Key Error Codes per Endpoint Group

| Domain | Sample Codes |
|---|---|
| Content | `AI_CONTENT_TOO_LONG`, `AI_INVALID_TONE`, `AI_INVALID_PLATFORM`, `AI_RAG_NO_DOCUMENTS` |
| Image | `VALIDATION_ERROR`, `FILE_TOO_LARGE`, `INVALID_FILE_TYPE`, `AI_MODEL_UNAVAILABLE` |
| Video | `VALIDATION_ERROR`, `AI_INVALID_PLATFORM`, `JOB_NOT_FOUND`, `AI_GENERATION_FAILED` |
| Ambassador | `AI_AMBASSADOR_NOT_FOUND`, `INVALID_FILE_TYPE`, `AI_GENERATION_FAILED` |
| RAG | `AI_RAG_NO_DOCUMENTS`, `NO_FILE_PROVIDED`, `INVALID_FILE_TYPE`, `FILE_TOO_LARGE`, `DOCUMENT_NOT_FOUND` |
| Trends | `AI_INVALID_PLATFORM`, `VALIDATION_ERROR`, `SERVICE_UNAVAILABLE` |
| Security | `INTERNAL_KEY_INVALID` |
| Quota | `AI_CREDITS_EXHAUSTED` |

---

## 7. Validation Checklist

- [x] All 6 required endpoint groups are covered: content, image, video, ambassador, RAG, trends
- [x] Public health endpoint is separated from internal AI endpoints
- [x] `X-Internal-Key` security scheme is documented
- [x] `X-Request-Id` header is documented for tracing
- [x] Every response uses `ApiResponse<T>` structure from DA-E07-04
- [x] Async endpoints document `202 Accepted`
- [x] No `204 No Content` response is used
- [x] Multipart upload contract for RAG documents is documented
- [x] Error responses use codes from the shared catalogue where available
- [ ] After implementation, export `/openapi.json` from FastAPI and validate it in Swagger Editor

---

## 8. File Reference

```text
brandhub-ai-service/
└── docs/
    ├── openapi.json      ← exported from FastAPI /openapi.json after implementation
    └── openapi.yaml      ← optional YAML export from the JSON spec

brandhub-infrastructure/
└── docs/api/
    └── DA-E07-06_OpenAPI_Spec.md   ← this reference document
```
