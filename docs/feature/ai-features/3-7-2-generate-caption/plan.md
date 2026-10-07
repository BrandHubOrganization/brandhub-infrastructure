# Plan — 3.7.2 Generate Caption (luồng 4 bước, chốt 2026-10-08)

## Luồng

```
1. Bối cảnh   Creator: chủ đề, mục tiêu, giọng điệu, nền tảng, độ dài, (tuỳ chọn) trend từ 3.7.1
              Hệ thống tự thêm: thông tin thương hiệu (workspace + client profile), 3 bài đã đăng gần nhất,
              tiêu đề task, tài liệu Knowledge Base (RAG, AI service tự tra theo client_id = workspaceId)
2. Sinh       1 lần gọi LLM → 3 phương án HOOK_DRIVEN / STORYTELLING / DIRECT_CTA (Gemini; Groq nếu có key)
3. Kiểm tra   mỗi phương án: con số không có nguồn (giá, %, ngày), có dùng trend, cảm xúc PhoBERT v12,
              tuân thủ (hook FR 3.6.33 — hiện NOT_CHECKED)
4. Tinh chỉnh  Ngắn lại / Dài hơn / Thêm CTA / Bớt emoji / Trang trọng / Thân mật / góp ý tự do;
              phiên bản cho nền tảng khác; Chèn / Thay toàn bộ → ghi lại lựa chọn (ai_caption_generations)
```

## Thành phần

| Lớp | File |
|---|---|
| DB | `2026-10-08-ai-credit-usages.sql`, `2026-10-08-ai-caption-generations.sql` |
| AI service | `models/content_models.py` (goal, examples, trend_keywords, client_id, signals, refine/adapt), `services/caption_service.py`, `endpoints/content.py` (`/captions/refine`, `/captions/adapt`), `utils/prompt_builder.py` (tone FRIENDLY/PLAYFUL của panel cũ) |
| Business | `AiCreditService`, `AiCaptionService`, `CaptionContextService`, `CaptionComplianceCheck`, `AiCaptionController` |
| Web | `components/ai/AiCaptionDialog.tsx` (dùng chung), `services/aiCaptionService.ts`, nút trong `content-writing/index.tsx` và `editor/components/AIGeneratePanel.tsx` |

API: `POST /workspaces/{id}/ai/captions`, `/captions/refine`, `/captions/adapt`, `/captions/{generationId}/choice`, `GET /workspaces/{id}/ai/credits`.
Giá: `ai.credits.caption.base` (1), `.per-1000-chars` (0), `.refine` (1), `.adapt` (1) — chưa chốt, 0 = miễn phí.

## Ghi chú tích hợp (để người phụ trách hoặc AI code biết cách nối)

| Phụ thuộc | Chủ | Đã dựng sẵn | Việc cần làm khi FR xong |
|---|---|---|---|
| **FR 3.6.33 Check Compliance** | Tuấn | `CaptionComplianceCheck.check(workspaceId, caption)` trả `NOT_CHECKED`; UI đã hiện trạng thái, `BLOCKED` khoá nút Chèn/Thay | Thay thân hàm bằng engine 3.6.33, giữ chữ ký `Result(status, issues[code,message,excerpt])`; phải nhanh. Khi bài được lưu, moderation dùng contract riêng `{postId,contentVersion,source:COMPLIANCE,reason}`, không gửi Result caption trực tiếp |
| **FR 3.9.5 AI Credit Tracking** | Tuấn | Bảng `ai_credit_usages` (agency, user, workspace, feature, credits, month, refunded_at) | Đọc bảng này cho màn theo dõi; feature: `CAPTION`, `CAPTION_REFINE`, `CAPTION_ADAPT`, (3.7.7) `VIDEO` |
| **FR 3.9.6 Buy Credit** | Tuấn | `AiCreditService.balance` chỉ cộng credit gói (`ponytail` comment) | Cộng credit đã mua vào `allowance` trong `AiCreditService.balance` |
| **FR 3.9.7 Set Credit** | Tuấn | Hạn mức Creator (`ai_credit_creator_limits`) đã được áp **cứng** | Chỉ cần ghi bảng; không đổi code caption |
| **FR 3.6.1/3.6.2 Task detail/assign, 3.5.7 Content Request** | Lộc | Dialog gửi `taskId`; `CaptionContextService.task()` lấy tiêu đề task | Khi Task có brief/nền tảng/Content Request: mở rộng `CaptionContextService.task()` trả thêm các trường đó |
| **Knowledge Base (RAG)** | (chưa có FR riêng) | AI request dùng `client_id = workspaceId`; ChromaDB `brandhub_rag` lưu metadata `clientId` | Upload tài liệu với `client_id = workspaceId`; truy vấn lọc `clientId`; trang Knowledge Base hiện còn mock, cần cấu hình ChromaDB |
| **FR 3.6.10 Content Writing View — version history** | Trung | `ai_caption_generations.task_id` + `chosen_at` + `final_text` | Muốn gắn nhãn "AI tạo" cho phiên bản: join theo `task_id` và thời điểm |
| **Panel AI cũ trong Trình soạn** | Lộc | Đã thêm nút mở dialog dùng chung; sửa tone FRIENDLY/PLAYFUL bị rơi về PROFESSIONAL | Cân nhắc bỏ `generatePost` (không trừ credit) và chỉ dùng dialog chung |
| **Hashtag từ dữ liệu trend** | Lộc | API `/api/v1/ai/content/hashtags` dùng `HashtagExtractor`, dữ liệu Redis và chế độ Zero-LLM | Nối gợi ý hashtag thật vào dialog; hashtag của ba phương án hiện vẫn do LLM đề xuất |

## Hoàn tất phần còn dang dở

- Đồng bộ spec với luồng đã được người dùng chốt.
- Kiểm chứng RAG bằng metadata `clientId` đúng với `VectorStoreService.upsert_chunks`.
- Ghi credit và generation trong `TransactionTemplate` sau khi LLM trả kết quả; kiểm tra rollback bằng PostgreSQL test.
- Chặn chèn bản adapt `BLOCKED`; reset các bản adapt/công cụ khi tạo generation mới, giữ nền tảng của kết quả cho refine.
- Chạy lại test caption AI, test credit/history, build/lint web và E2E dialog. Ghi riêng lỗi baseline của bộ test toàn hệ thống.
