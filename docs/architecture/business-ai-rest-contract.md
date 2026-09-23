# business-service ↔ ai-service — REST Communication Contract

> DA-1155 (DA-E05-04, phần REST). Bổ sung nội dung còn thiếu — RabbitMQ contract (business↔publisher) đã có ở [rabbitmq-publisher-contract.html](rabbitmq-publisher-contract.html); doc này chỉ phủ phần REST business→ai.

## 1. Kết nối

- **Giao thức:** REST/HTTP, đồng bộ (business-service gọi, chờ response trực tiếp — không qua RabbitMQ).
- **Base URL:** `http://ai-service:8082` (internal Docker network, không qua api-gateway — ai-service không public).
- **Xác thực:** shared internal API key, header `X-Internal-Api-Key` (không dùng JWT — ai-service không tự verify JWT user).
- **Timeout:** 30s cho text-gen (caption, script), 120s cho image-gen, 300s cho video-gen (video-gen có thể async — xem §3).
- **Retry policy:** business-service retry 1 lần với backoff 2s nếu timeout/5xx; không retry nếu 4xx (lỗi input, retry vô ích).

## 2. Endpoint chính (theo UC-74 → UC-82, `docs/ba/use-cases/05-ai-features.md`)

| Endpoint | UC | Mô tả |
|---|---|---|
| `POST /internal/ai/caption` | UC-75 | Generate caption từ prompt |
| `POST /internal/ai/ambassador` | UC-76 | Generate virtual brand ambassador |
| `POST /internal/ai/image` | UC-77 | Generate image (form + model + materials → prompt) |
| `POST /internal/ai/video` | UC-78 | Generate video (async, xem §3) |
| `POST /internal/ai/livestream-script` | UC-81 | Generate mẫu kịch bản livestream |
| `GET /internal/ai/trending` | UC-74 | Trending topics + hashtag suggestions |
| `POST /internal/ai/collaborator-recommend` | UC-82 | Recommend Third-party Collaborator |

## 3. Async pattern cho Video Generation (UC-78)

Video-gen có thể mất >30s (gọi API bên thứ 3) — dùng poll thay vì giữ connection mở:

```
1. business-service: POST /internal/ai/video { workspaceId, prompt, styleTemplate }
   → ai-service trả 202 Accepted + { jobId }
2. business-service poll: GET /internal/ai/video/{jobId}/status
   → { status: "PROCESSING" | "DONE" | "FAILED", resultUrl? }
```

## 4. Request/Response mẫu — Generate Image (UC-77)

```json
// Request
POST /internal/ai/image
{
  "workspaceId": "uuid",
  "agencyId": "uuid",
  "styleTemplate": "anime",
  "formInput": { "prompt": "...", "aspectRatio": "1:1" },
  "ambassadorId": "uuid | null",
  "materialRefs": ["material_repository_id_1", "brand_collection_id_2"]
}

// Response 200
{
  "generatedUrl": "https://s3.../generated/xxx.png",
  "creditCost": 1,
  "generatedAt": "ISO 8601"
}
```

## 5. Business context lookup (ai-service → business-service, hướng ngược lại)

Khi ai-service cần dữ liệu nghiệp vụ (Workspace name, Agency brand voice config) mà không có sẵn trong request payload, nó gọi ngược lại business-service qua REST — cùng cơ chế `X-Internal-Api-Key`, **không** query trực tiếp PostgreSQL/MongoDB của business-service (xem [service-boundaries.md](../service-boundaries.md) §4 rule 1).

```
GET http://business-service:8081/internal/workspaces/{workspaceId}/brand-context
→ { agencyId, workspaceName, brandVoiceSummary }
```

## 6. AI Credit — nguồn sự thật

- ai-service **không** trừ credit trực tiếp — chỉ ghi `ai_usage_logs` (MongoDB, ai-service sở hữu) sau mỗi lần generate thành công.
- business-service là nguồn sự thật cho số dư credit (`ai_credit_ledgers`, `ai_credit_creator_limits` — PostgreSQL). business-service kiểm tra hạn mức TRƯỚC khi gọi ai-service (chặn sớm nếu Creator đã vượt `ai_credit_creator_limits`), rồi trừ credit sau khi ai-service trả kết quả thành công.
