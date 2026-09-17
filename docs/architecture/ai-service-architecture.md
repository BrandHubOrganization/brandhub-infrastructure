# AI Architecture — ai-service Internal Design

> DA-1158 (DA-E05-07). Nguồn: `docs/ba/06-ai-features.md`, `docs/ba/use-cases/05-ai-features.md`, `docs/database/schema-v2/brandhub-dbml.dbml`.

## 1. Internal Architecture (FastAPI)

```
ai-service/
├── routers/          # FastAPI route handlers, 1 file per feature group
│   ├── caption.py         (UC-75)
│   ├── ambassador.py      (UC-76)
│   ├── image.py           (UC-77)
│   ├── video.py           (UC-78, async job pattern)
│   ├── trending.py        (UC-74, UC-80 crawl config)
│   ├── livestream.py      (UC-81)
│   └── collaborator.py    (UC-82)
├── services/          # business logic, tách khỏi router
│   ├── llm_router.py       # chọn model theo task type
│   ├── prompt_builder.py   # ghép form + ambassador + materials → prompt
│   ├── credit_reporter.py  # ghi ai_usage_logs sau mỗi lần generate
│   └── rag_service.py      # ChromaDB retrieval cho brand voice
├── clients/            # external API clients
│   ├── groq_client.py
│   ├── stability_client.py
│   └── veo_client.py
└── tasks/              # async job handling (video-gen)
    └── video_job_worker.py    # background task, poll-based status
```

- **Async task handling:** video-gen job chạy nền qua FastAPI `BackgroundTasks` (hoặc Celery nếu volume tăng — chưa cần ở giai đoạn hiện tại), trạng thái lưu tạm trong `ai_usage_logs`/in-memory job store, client poll `GET /internal/ai/video/{jobId}/status`.
- **Service layer tách khỏi router:** router chỉ parse request/validate input, gọi `services/*` — giữ router mỏng, dễ test logic độc lập.

## 2. ChromaDB Schema

| Field | Type | Mô tả |
|---|---|---|
| `id` | string | UUID của document/chunk |
| `embedding` | vector | Sinh từ sentence-transformers (model cấu hình qua env, không hardcode) |
| `metadata.agencyId` | string | **Cấp cô lập chính (V2)** — không phải `workspaceId` |
| `metadata.workspaceId` | string \| null | Optional — brand voice có thể áp dụng riêng theo Workspace nếu Agency cấu hình khác nhau giữa các Workspace |
| `metadata.sourceType` | string | `brand_document` \| `material_description` \| `hashtag_history` |
| `metadata.createdAt` | ISO 8601 | Thời điểm index |

### Collection naming convention (SỬA so với bản V1 cũ)

```
agency_{agencyId}_brand_voice
```

**Lý do đổi từ `workspace_{workspaceId}_brand_voice` (V1) sang cấp Agency:** AI credit và brand voice knowledge trong V2 gắn với **Agency** (1 Owner quản lý credit chung cho toàn Agency, có thể set hạn mức riêng từng Creator — xem `docs/ba/08-subscription-billing.md`), không phải từng Workspace lẻ. Một Agency có nhiều Workspace (nhiều Client) nhưng brand voice tổng quát của Agency (giọng văn, phong cách) có thể dùng chung — Workspace cụ thể chỉ cần lọc thêm qua `metadata.workspaceId` khi Client đó có brand riêng biệt cần tách.

- **top-K retrieval:** 5 (mặc định cho RAG context injection vào prompt).

## 3. LLM Routing Strategy

| Task type | Model/Endpoint | UC |
|---|---|---|
| Caption/Text generation | Groq LLaMA (model ID qua config, không hardcode — vd `llama3-8b-8192`) | UC-75 |
| RAG (brand voice retrieval + generation) | Groq + ChromaDB retrieval trước khi gửi prompt | UC-74 (trending), context injection cho UC-75/77/78 |
| Image generation | Stability AI, LoRA fine-tune tùy chỉnh theo brand | UC-77 |
| Video generation | Google Veo hoặc third-party API tương đương | UC-78 |
| Livestream script | Groq LLaMA, cùng pipeline với Caption | UC-81 |
| Recommend Collaborator | Groq LLaMA, không cần RAG (không phụ thuộc brand voice riêng) | UC-82 |

- **Config, không hardcode:** model ID/endpoint đọc từ biến môi trường (`GROQ_MODEL_ID`, `STABILITY_API_KEY`, `VEO_API_ENDPOINT`) — cho phép swap model không cần sửa code, chỉ đổi config khi cần nâng cấp/hạ cấp chất lượng vs chi phí.

## 4. Credit Accounting (liên kết business-service)

- ai-service tự ghi `ai_usage_logs` (MongoDB, ai-service sở hữu) sau MỖI lần generate thành công — dùng cho audit/debug, không phải nguồn số dư chính.
- Số dư credit thật (`ai_credit_ledgers`) và hạn mức từng Creator (`ai_credit_creator_limits`) nằm ở PostgreSQL, business-service sở hữu — business-service kiểm tra TRƯỚC khi gọi ai-service, trừ credit SAU khi ai-service trả kết quả (xem `docs/architecture/business-ai-rest-contract.md` §6).
- Tái sử dụng asset đã generate trước đó (UC-79 Export) **không** trừ credit lần 2 — FR 3.6.35.
