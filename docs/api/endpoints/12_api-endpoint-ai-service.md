# DA-E07-02 — AI Service Endpoints

**Sprint:** 4  
**Owner:** Tuan (AI)  
**Priority:** Critical  
**Blocks:** DA-E07-06, DA-E05-08  
**Service:** `brandhub-ai-service`

---

## 1. Conventions

**Internal base URL:** `http://ai-service:8082`  
**API prefix:** `/api/v1`  
**Caller:** `business-service` only. Client apps must not call `ai-service` directly.  
**Authentication:** all endpoints require internal service authentication.

| Header | Required | Description |
|---|---:|---|
| `X-Internal-Key` | Yes | Shared internal API key configured by environment variable. |
| `X-Request-Id` | Recommended | UUID propagated from `api-gateway` for log correlation. Generate one if absent. |

All responses must use the `ApiResponse<T>` envelope defined in `docs/api/DA-E07-04_API_Response_Format.md`.

### Standard Success Shape

```json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": null,
  "requestId": "9c7e79a7-d684-4d3a-9651-bcb6682e56a4",
  "version": "v1",
  "timestamp": "2026-07-03T09:30:00Z"
}
```

### Standard Error Shape

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "fields": {
        "prompt": "must not be blank"
      }
    }
  },
  "meta": null,
  "requestId": "9c7e79a7-d684-4d3a-9651-bcb6682e56a4",
  "version": "v1",
  "timestamp": "2026-07-03T09:30:00Z"
}
```

### Common HTTP Status Codes

| Status | Meaning |
|---:|---|
| `200 OK` | Request completed successfully. |
| `202 Accepted` | Async generation job accepted; poll status endpoint. |
| `400 Bad Request` | Invalid request body, unsupported platform/style/tone, missing required field. |
| `401 Unauthorized` | Missing or invalid `X-Internal-Key`. |
| `404 Not Found` | Requested job, document, or ambassador profile not found. |
| `409 Conflict` | Duplicate document or incompatible generation state. |
| `429 Too Many Requests` | AI credits/quota exhausted or upstream provider rate limited. |
| `500 Internal Server Error` | Unhandled service error. |
| `502 Bad Gateway` | Upstream AI provider failed or is unreachable. |
| `503 Service Unavailable` | AI service, vector DB, storage, or provider temporarily unavailable. |

### Supported Enums

| Field | Allowed Values |
|---|---|
| `platform` | `facebook`, `instagram`, `tiktok`, `zalo`, `linkedin` |
| `tone` | `professional`, `friendly`, `playful`, `luxury`, `bold`, `informative` |
| `language` | `vi`, `en` |
| `imageStyle` | `product`, `lifestyle`, `fashion`, `minimal`, `studio`, `ugc` |
| `videoStyle` | `short_ad`, `product_showcase`, `tutorial`, `storytelling` |

---

## 2. Endpoint Summary

| # | Method | Path | Purpose | Sync |
|---:|---|---|---|---|
| 1 | `POST` | `/api/v1/ai/content/generate` | Generate new caption/copy. | Sync |
| 2 | `POST` | `/api/v1/ai/content/regenerate` | Regenerate copy using reviewer feedback. | Sync |
| 3 | `POST` | `/api/v1/ai/image/generate` | Generate image and return S3 asset URLs. | Async |
| 4 | `POST` | `/api/v1/ai/video/generate` | Generate video job and return polling info. | Async |
| 5 | `GET` | `/api/v1/ai/video/jobs/{jobId}` | Read video generation job status. | Sync |
| 6 | `POST` | `/api/v1/ai/ambassador/generate` | Generate face-consistent brand ambassador image. | Async |
| 7 | `POST` | `/api/v1/ai/rag/upload` | Ingest brand knowledge into vector store. | Async |
| 8 | `POST` | `/api/v1/ai/rag/query` | Query brand knowledge for RAG context. | Sync |
| 9 | `DELETE` | `/api/v1/ai/rag/documents/{documentId}` | Delete one knowledge document. | Sync |
| 10 | `GET` | `/api/v1/ai/trends` | Return trend suggestions by platform/region/category. | Sync |

---

## 3. `/ai/content`

### 3.1 Generate Content

**Endpoint:** Generate content  
**Purpose:** Generate caption/copy and hashtags using campaign context and optional RAG context.  
**Method:** `POST`  
**Path:** `/api/v1/ai/content/generate`

#### Request Body

```json
{
  "workspaceId": "0a7dd0f8-16df-4a6d-8e59-036b9e0a3c35",
  "clientId": "f5f7a78b-7c3d-4b68-a8d1-b02b5177cb11",
  "contentRequestId": "64b8e8f0d9f2c834b39a9001",
  "platform": "instagram",
  "language": "vi",
  "tone": "friendly",
  "topic": "Ra mắt bộ sưu tập thời trang hè",
  "objective": "increase_engagement",
  "targetAudience": "women 18-30 interested in fashion",
  "brandVoice": "modern, confident, premium",
  "keywords": ["summer", "fashion", "new collection"],
  "constraints": {
    "maxCaptionLength": 2200,
    "hashtagCount": 8,
    "includeEmoji": true,
    "avoidWords": ["sale off quá đà"]
  },
  "useRag": true
}
```

#### Response Body

```json
{
  "success": true,
  "data": {
    "caption": "Mùa hè này, hãy để phong cách của bạn lên tiếng...",
    "hashtags": ["#BrandHub", "#SummerFashion", "#OOTD"],
    "callToAction": "Khám phá bộ sưu tập ngay hôm nay.",
    "ragSources": [
      {
        "documentId": "doc_01J1R8R6X4ZK6C",
        "title": "Brand Voice Guideline",
        "score": 0.87
      }
    ],
    "usage": {
      "provider": "groq",
      "model": "llama-3.1-70b-versatile",
      "inputTokens": 892,
      "outputTokens": 214,
      "creditsUsed": 3
    }
  },
  "error": null,
  "meta": null,
  "requestId": "d9a705e0-9331-4b48-af3d-35fe3ca70a50",
  "version": "v1",
  "timestamp": "2026-07-03T09:30:00Z"
}
```

#### Validation / Input Constraints

- `workspaceId`, `clientId`, `platform`, `language`, `tone`, and `topic` are required.
- `topic`: 5-500 characters.
- `keywords`: max 20 items; each item max 50 characters.
- `constraints.maxCaptionLength`: 50-5000.
- `constraints.hashtagCount`: 0-30.
- If `useRag=true`, at least one knowledge document should exist for the client.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `VALIDATION_ERROR` | Missing required field or invalid enum. |
| `400` | `AI_INVALID_TONE` | Unsupported tone. |
| `400` | `AI_INVALID_PLATFORM` | Unsupported platform. |
| `400` | `AI_RAG_NO_DOCUMENTS` | `useRag=true` but no indexed documents exist. |
| `429` | `AI_CREDITS_EXHAUSTED` | Workspace has no remaining AI credits. |
| `502` | `AI_MODEL_UNAVAILABLE` | LLM provider unavailable. |

### 3.2 Regenerate Content

**Endpoint:** Regenerate content  
**Purpose:** Regenerate an existing AI output using human feedback or changed constraints.  
**Method:** `POST`  
**Path:** `/api/v1/ai/content/regenerate`

#### Request Body

```json
{
  "workspaceId": "0a7dd0f8-16df-4a6d-8e59-036b9e0a3c35",
  "clientId": "f5f7a78b-7c3d-4b68-a8d1-b02b5177cb11",
  "previousCaption": "Mùa hè này, hãy để phong cách của bạn lên tiếng...",
  "feedback": "Ngắn hơn, cao cấp hơn, ít emoji hơn",
  "platform": "instagram",
  "language": "vi",
  "tone": "luxury",
  "constraints": {
    "maxCaptionLength": 1000,
    "hashtagCount": 5,
    "includeEmoji": false
  }
}
```

#### Response Body

```json
{
  "success": true,
  "data": {
    "caption": "Tinh giản hơn, nổi bật hơn. Bộ sưu tập hè mới dành cho những ngày bạn muốn khác biệt.",
    "hashtags": ["#SummerEdit", "#LuxuryFashion", "#BrandHub"],
    "callToAction": "Xem ngay bộ sưu tập mới.",
    "usage": {
      "provider": "groq",
      "model": "llama-3.1-70b-versatile",
      "inputTokens": 604,
      "outputTokens": 126,
      "creditsUsed": 2
    }
  },
  "error": null,
  "meta": null,
  "requestId": "e9387fb8-330d-4e69-9983-7e5be043b168",
  "version": "v1",
  "timestamp": "2026-07-03T09:32:00Z"
}
```

#### Validation / Input Constraints

- `previousCaption` and `feedback` are required.
- `previousCaption`: max 5000 characters.
- `feedback`: 5-1000 characters.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `VALIDATION_ERROR` | Feedback is blank or too long. |
| `400` | `AI_CONTENT_TOO_LONG` | Previous caption + feedback exceeds model context limit. |
| `429` | `AI_CREDITS_EXHAUSTED` | Workspace has no remaining AI credits. |
| `500` | `AI_GENERATION_FAILED` | Provider returned empty or unusable content. |

---

## 4. `/ai/image`

### 4.1 Generate Image

**Endpoint:** Generate image  
**Purpose:** Generate one or more campaign images and return stored asset URLs.  
**Method:** `POST`  
**Path:** `/api/v1/ai/image/generate`

#### Request Body

```json
{
  "workspaceId": "0a7dd0f8-16df-4a6d-8e59-036b9e0a3c35",
  "clientId": "f5f7a78b-7c3d-4b68-a8d1-b02b5177cb11",
  "prompt": "A premium summer fashion campaign photo with linen dresses, warm daylight, clean background",
  "negativePrompt": "low quality, distorted hands, blurry, watermark",
  "imageStyle": "fashion",
  "aspectRatio": "4:5",
  "count": 3,
  "outputFormat": "png",
  "seed": 123456,
  "referenceAssetUrl": "s3://brandhub-dev/assets/ref-product.png"
}
```

#### Response Body

```json
{
  "success": true,
  "data": {
    "jobId": "img_01J1R9HT7N1Q8Q4Q8T73M2N7DQ",
    "status": "COMPLETED",
    "assets": [
      {
        "assetId": "asset_01J1R9J7PJ6ADZBBK7MXQY3M9A",
        "url": "https://cdn.brandhub.dev/ai/images/asset_01J1R9J7PJ6ADZBBK7MXQY3M9A.png",
        "width": 1024,
        "height": 1280,
        "format": "png"
      }
    ],
    "usage": {
      "provider": "stability",
      "model": "stable-image-core",
      "creditsUsed": 8
    }
  },
  "error": null,
  "meta": null,
  "requestId": "bd431f88-e6e7-4a35-ae93-35b081442ebc",
  "version": "v1",
  "timestamp": "2026-07-03T09:35:00Z"
}
```

#### Validation / Input Constraints

- `prompt`: required, 10-2000 characters.
- `count`: 1-4 in MVP.
- `aspectRatio`: one of `1:1`, `4:5`, `9:16`, `16:9`.
- `outputFormat`: `png`, `jpg`, or `webp`.
- `referenceAssetUrl` must point to an approved internal S3 object if provided.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `VALIDATION_ERROR` | Invalid aspect ratio, count, or format. |
| `400` | `FILE_TOO_LARGE` | Reference asset exceeds configured size limit. |
| `400` | `INVALID_FILE_TYPE` | Reference asset MIME type is not allowed. |
| `429` | `AI_CREDITS_EXHAUSTED` | Workspace has no remaining AI credits. |
| `502` | `AI_MODEL_UNAVAILABLE` | Image provider unavailable. |

---

## 5. `/ai/video`

### 5.1 Generate Video

**Endpoint:** Generate video  
**Purpose:** Submit an async video generation job and return a job id for polling.  
**Method:** `POST`  
**Path:** `/api/v1/ai/video/generate`

#### Request Body

```json
{
  "workspaceId": "0a7dd0f8-16df-4a6d-8e59-036b9e0a3c35",
  "clientId": "f5f7a78b-7c3d-4b68-a8d1-b02b5177cb11",
  "script": "Introduce the summer collection in a 10-second vertical ad.",
  "videoStyle": "short_ad",
  "platform": "tiktok",
  "durationSeconds": 10,
  "aspectRatio": "9:16",
  "referenceImageUrls": [
    "https://cdn.brandhub.dev/assets/product-01.png"
  ],
  "musicMood": "upbeat"
}
```

#### Response Body

```json
{
  "success": true,
  "data": {
    "jobId": "vid_01J1RA42E49B4P9BVHF1XYT3QZ",
    "status": "PENDING",
    "estimatedSeconds": 180,
    "pollUrl": "/api/v1/ai/video/jobs/vid_01J1RA42E49B4P9BVHF1XYT3QZ"
  },
  "error": null,
  "meta": null,
  "requestId": "52bb47d3-452d-4671-bb18-b630dccad560",
  "version": "v1",
  "timestamp": "2026-07-03T09:40:00Z"
}
```

#### Validation / Input Constraints

- `script`: required, 10-3000 characters.
- `durationSeconds`: 5-30 in MVP.
- `aspectRatio`: `9:16` or `16:9`.
- Max 5 reference images.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `VALIDATION_ERROR` | Invalid duration, platform, or aspect ratio. |
| `400` | `AI_INVALID_PLATFORM` | Platform not supported for video generation. |
| `429` | `AI_CREDITS_EXHAUSTED` | Workspace has no remaining AI credits. |
| `502` | `AI_MODEL_UNAVAILABLE` | Video provider unavailable. |

### 5.2 Get Video Job Status

**Endpoint:** Get video job status  
**Purpose:** Poll async video generation status.  
**Method:** `GET`  
**Path:** `/api/v1/ai/video/jobs/{jobId}`

#### Response Body

```json
{
  "success": true,
  "data": {
    "jobId": "vid_01J1RA42E49B4P9BVHF1XYT3QZ",
    "status": "COMPLETED",
    "progress": 100,
    "asset": {
      "assetId": "asset_01J1RAK3Y72Y6H57EF2NQAXZJ7",
      "url": "https://cdn.brandhub.dev/ai/videos/asset_01J1RAK3Y72Y6H57EF2NQAXZJ7.mp4",
      "durationSeconds": 10,
      "format": "mp4"
    },
    "errorMessage": null
  },
  "error": null,
  "meta": null,
  "requestId": "f588d519-cf93-4c2f-8a2a-3a33ddb05a38",
  "version": "v1",
  "timestamp": "2026-07-03T09:44:00Z"
}
```

#### Validation / Input Constraints

- `jobId` must start with `vid_`.
- Valid statuses: `PENDING`, `PROCESSING`, `COMPLETED`, `FAILED`, `CANCELLED`.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `404` | `JOB_NOT_FOUND` | Job id does not exist or belongs to another workspace. |
| `500` | `AI_GENERATION_FAILED` | Job failed without provider-specific details. |

---

## 6. `/ai/ambassador`

### 6.1 Generate Brand Ambassador Image

**Endpoint:** Generate ambassador image  
**Purpose:** Generate a face-consistent brand ambassador image using reference face/product assets.  
**Method:** `POST`  
**Path:** `/api/v1/ai/ambassador/generate`

#### Request Body

```json
{
  "workspaceId": "0a7dd0f8-16df-4a6d-8e59-036b9e0a3c35",
  "clientId": "f5f7a78b-7c3d-4b68-a8d1-b02b5177cb11",
  "ambassadorId": "amb_01J1RBF59F3PZ6HW12DDXH3CYA",
  "faceImageUrl": "https://cdn.brandhub.dev/ambassadors/face-01.png",
  "productImageUrl": "https://cdn.brandhub.dev/products/dress-01.png",
  "prompt": "Fashion model wearing the product in a clean studio campaign photo",
  "imageStyle": "studio",
  "aspectRatio": "4:5",
  "count": 2
}
```

#### Response Body

```json
{
  "success": true,
  "data": {
    "jobId": "amb_01J1RBQHYN8SJSVQ1YTBVM0XCK",
    "status": "COMPLETED",
    "assets": [
      {
        "assetId": "asset_01J1RBQY4BHRGDNQPNSDN3RCBV",
        "url": "https://cdn.brandhub.dev/ai/ambassador/asset_01J1RBQY4BHRGDNQPNSDN3RCBV.png",
        "width": 1024,
        "height": 1280
      }
    ],
    "identityConsistencyScore": 0.91,
    "usage": {
      "provider": "instantid",
      "model": "instantid-sdxl",
      "creditsUsed": 12
    }
  },
  "error": null,
  "meta": null,
  "requestId": "48fb22b9-62d2-410e-ad9e-0f6d61e98968",
  "version": "v1",
  "timestamp": "2026-07-03T09:50:00Z"
}
```

#### Validation / Input Constraints

- Either `ambassadorId` or `faceImageUrl` is required.
- `faceImageUrl` must reference one clear human face.
- `productImageUrl` is optional but must be an approved internal asset if provided.
- `count`: 1-4 in MVP.
- Reject images with unsupported MIME type or unsafe content.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `VALIDATION_ERROR` | Missing face reference or invalid prompt. |
| `400` | `INVALID_FILE_TYPE` | Face/product image type not supported. |
| `404` | `AI_AMBASSADOR_NOT_FOUND` | `ambassadorId` not found. |
| `500` | `AI_GENERATION_FAILED` | Face-consistent generation failed. |
| `502` | `AI_MODEL_UNAVAILABLE` | InstantID/provider unavailable. |

---

## 7. `/ai/rag`

### 7.1 Upload Knowledge Document

**Endpoint:** Upload RAG document  
**Purpose:** Ingest client brand knowledge into vector store for future generation.  
**Method:** `POST`  
**Path:** `/api/v1/ai/rag/upload`

#### Request Body

Use `multipart/form-data`.

| Field | Type | Required | Description |
|---|---|---:|---|
| `workspaceId` | string UUID | Yes | Workspace scope. |
| `clientId` | string UUID | Yes | Client scope. |
| `title` | string | Yes | Document title. |
| `sourceType` | string | Yes | `pdf`, `docx`, `txt`, `url`. |
| `file` | binary | Conditional | Required for file sources. |
| `sourceUrl` | string URL | Conditional | Required when `sourceType=url`. |
| `tags` | string[] | No | Search/filter tags. |

#### Response Body

```json
{
  "success": true,
  "data": {
    "documentId": "doc_01J1RC7FE1GG8J6RJDFF1CPWW4",
    "status": "INDEXED",
    "chunksIndexed": 42,
    "collectionName": "brand_0a7dd0f8_f5f7a78b",
    "title": "Brand Voice Guideline"
  },
  "error": null,
  "meta": null,
  "requestId": "161e82d2-c974-493a-81c9-c7254bdd1136",
  "version": "v1",
  "timestamp": "2026-07-03T10:00:00Z"
}
```

#### Validation / Input Constraints

- Accepted file types: PDF, DOCX, TXT.
- Max file size: 20 MB in MVP.
- `sourceUrl` must use `https://`.
- Extracted text must contain at least 100 characters after cleanup.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `NO_FILE_PROVIDED` | File source selected but no file uploaded. |
| `400` | `INVALID_FILE_TYPE` | Unsupported MIME type. |
| `400` | `FILE_TOO_LARGE` | File exceeds max size. |
| `409` | `DOCUMENT_ALREADY_EXISTS` | Same checksum already indexed for the client. |
| `503` | `SERVICE_UNAVAILABLE` | ChromaDB or embedding model unavailable. |

### 7.2 Query RAG Knowledge

**Endpoint:** Query RAG knowledge  
**Purpose:** Retrieve top matching brand knowledge chunks for content generation.  
**Method:** `POST`  
**Path:** `/api/v1/ai/rag/query`

#### Request Body

```json
{
  "workspaceId": "0a7dd0f8-16df-4a6d-8e59-036b9e0a3c35",
  "clientId": "f5f7a78b-7c3d-4b68-a8d1-b02b5177cb11",
  "query": "brand tone for summer collection",
  "topK": 5,
  "minScore": 0.7,
  "tags": ["brand-voice", "campaign"]
}
```

#### Response Body

```json
{
  "success": true,
  "data": {
    "matches": [
      {
        "documentId": "doc_01J1RC7FE1GG8J6RJDFF1CPWW4",
        "chunkId": "chunk_0007",
        "title": "Brand Voice Guideline",
        "content": "The brand voice is modern, confident, premium, and concise.",
        "score": 0.89,
        "metadata": {
          "page": 2,
          "tags": ["brand-voice"]
        }
      }
    ]
  },
  "error": null,
  "meta": null,
  "requestId": "4468dbd1-e637-469c-9633-2d01d18cc6d6",
  "version": "v1",
  "timestamp": "2026-07-03T10:05:00Z"
}
```

#### Validation / Input Constraints

- `query`: required, 3-1000 characters.
- `topK`: 1-20; default 5.
- `minScore`: 0.0-1.0; default 0.65.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `AI_RAG_NO_DOCUMENTS` | No indexed knowledge documents for client. |
| `400` | `VALIDATION_ERROR` | Invalid `topK`, `minScore`, or query. |
| `503` | `SERVICE_UNAVAILABLE` | ChromaDB unavailable. |

### 7.3 Delete Knowledge Document

**Endpoint:** Delete RAG document  
**Purpose:** Remove one knowledge document and all indexed chunks.  
**Method:** `DELETE`  
**Path:** `/api/v1/ai/rag/documents/{documentId}`

#### Response Body

```json
{
  "success": true,
  "data": {
    "documentId": "doc_01J1RC7FE1GG8J6RJDFF1CPWW4",
    "deleted": true,
    "chunksDeleted": 42
  },
  "error": null,
  "meta": null,
  "requestId": "566cf9c2-d5f0-427b-884a-278a7af948c2",
  "version": "v1",
  "timestamp": "2026-07-03T10:08:00Z"
}
```

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `404` | `DOCUMENT_NOT_FOUND` | Document id does not exist for the client/workspace. |
| `503` | `SERVICE_UNAVAILABLE` | Vector store unavailable. |

---

## 8. `/ai/trends`

### 8.1 Get Trend Suggestions

**Endpoint:** Get trend suggestions  
**Purpose:** Return normalized trend topics for a platform, region, and category.  
**Method:** `GET`  
**Path:** `/api/v1/ai/trends`

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---:|---|---|
| `workspaceId` | UUID string | Yes | — | Workspace scope for usage tracking. |
| `platform` | string | Yes | — | Social platform. |
| `region` | string | No | `VN` | ISO country/region code. |
| `category` | string | No | `general` | Trend category, e.g. `fashion`, `beauty`, `food`. |
| `limit` | integer | No | `20` | Number of trends to return. |

#### Example Request

```http
GET /api/v1/ai/trends?workspaceId=0a7dd0f8-16df-4a6d-8e59-036b9e0a3c35&platform=tiktok&region=VN&category=fashion&limit=10
```

#### Response Body

```json
{
  "success": true,
  "data": {
    "platform": "tiktok",
    "region": "VN",
    "category": "fashion",
    "trends": [
      {
        "keyword": "summer outfit",
        "score": 91,
        "growth": 0.34,
        "hashtags": ["#summeroutfit", "#thoitranghe"],
        "suggestedAngles": [
          "Mix linen items for hot weather",
          "Before/after styling transition"
        ]
      }
    ],
    "source": "provider_cache",
    "cachedUntil": "2026-07-03T11:00:00Z"
  },
  "error": null,
  "meta": null,
  "requestId": "e2346607-d25e-475f-89c4-c3bb6629e37c",
  "version": "v1",
  "timestamp": "2026-07-03T10:10:00Z"
}
```

#### Validation / Input Constraints

- `workspaceId` and `platform` are required.
- `limit`: 1-50.
- `region`: 2 uppercase letters where possible.
- Cache trends per `(platform, region, category)` to avoid upstream quota pressure.

#### Common Errors

| Status | Code | Trigger |
|---:|---|---|
| `400` | `AI_INVALID_PLATFORM` | Unsupported platform. |
| `400` | `VALIDATION_ERROR` | Invalid `limit`, `region`, or missing workspace. |
| `502` | `AI_MODEL_UNAVAILABLE` | Trend provider unavailable. |
| `503` | `SERVICE_UNAVAILABLE` | Cache/vector support service unavailable. |

---

## 9. Implementation Notes

- All handlers should be `async def` and use async clients for external providers.
- Never call external AI providers from unit tests; mock Groq, Stability AI, Google Veo, InstantID, S3, and ChromaDB.
- `business-service` should check workspace subscription and AI credit availability before calling expensive generation endpoints when possible; `ai-service` should still enforce usage logging defensively.
- Store generated images/videos in S3-compatible storage and return CDN or signed URLs, not raw binary in JSON.
- Do not expose provider prompts, stack traces, API keys, or raw provider errors in response bodies.
- Prefer `202 Accepted` for long-running video/image jobs when provider latency exceeds normal HTTP timeout budgets.

---

## 10. Acceptance Checklist

- [x] `/ai/content` endpoint group defined.
- [x] `/ai/image` endpoint group defined.
- [x] `/ai/video` endpoint group defined.
- [x] `/ai/ambassador` endpoint group defined.
- [x] `/ai/rag` endpoint group defined.
- [x] `/ai/trends` endpoint group defined.
- [x] Each endpoint includes method, path, request/response examples, status codes, validation, and common errors.
- [x] Response format aligned with DA-E07-04 `ApiResponse<T>`.
