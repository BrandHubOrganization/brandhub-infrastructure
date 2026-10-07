# UC — Generate Caption

| | |
|---|---|
| FR Code | 3.7.2 |
| Feature | Generate Caption |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.1 — luồng 4 bước được xác nhận 2026-10-08 |
| Trạng thái tài liệu | Đã triển khai; đang kiểm chứng và nối các FR phụ thuộc |

## 1. Objective

Dùng LLM + prompt tạo caption cho bài post.

## 2. User Story

Là một Creator,
tôi muốn AI tạo caption cho bài đăng,
để tiết kiệm thời gian viết nội dung.

## 3. Acceptance Criteria

- Input: topic, tone, platform đích, độ dài mong muốn.
- AI trả về 1 hoặc nhiều phương án caption để Creator chọn/chỉnh sửa.
- Trừ credit AI theo lượt generate (xem [08-subscription-billing.md](../../../BA/08-subscription-billing.md)).

## 4. UI / UX

- Nút 'AI Generate Caption' trong Content Writing View (Task Detail, loại Post).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/generate-caption
{ "topic", "tone", "platform", "length" }
→ 200 { "success": true, "data": { "captions": ["string"], "creditsUsed": number } }
```

## 6. Error Handling

- Hết credit AI → 402 `INSUFFICIENT_AI_CREDIT`.
- LLM service lỗi → 502 `AI_SERVICE_UNAVAILABLE`.

## 7. Edge Cases

- Generate nhiều lần liên tiếp cho cùng Task → mỗi lần trừ credit riêng (không cache/miễn phí lần sau, trừ trường hợp reuse content cũ theo FR 3.6.35).

## 8. Definition of Done

- Generate thành công, trừ credit đúng.

## Out of Scope

- Không có.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)

## Bổ sung khi thiết kế kỹ thuật (2026-10-08)

- API thực tế: `POST /api/v1/workspaces/{workspaceId}/ai/captions` (MANAGER/CREATOR, `@RequireRole` cần workspaceId trên path)
  `{ topic (10–1000), tone, platform, length, language }` → `{ captions: [{ type, title, caption, hashtags, characterCount, recommendedMaxChars }], creditsUsed, creditsRemaining }`.
  `GET /api/v1/workspaces/{workspaceId}/ai/credits` → số credit còn dùng được.
- 3 phương án cố định từ AI service: HOOK_DRIVEN, STORYTELLING, DIRECT_CTA; bối cảnh thương hiệu lấy từ tên/ngành/mô tả workspace.
- **Giá credit chưa chốt** (người dùng xác nhận 2026-10-08) → cấu hình: `ai.credits.caption.base` (mặc định 1) + `ai.credits.caption.per-1000-chars` (mặc định 0, tính trên prompt + output). Cả hai = 0 → miễn phí.
- Credit theo BR 3.9.x: credit tháng của agency = gói của Owner (không có gói → Basic); hạn mức Creator do Owner đặt là **cứng**. Chỉ trừ khi AI trả kết quả; AI lỗi → 502 `AI_SERVICE_UNAVAILABLE`, không trừ. Hết credit → 402 `INSUFFICIENT_AI_CREDIT` trước khi gọi AI.
- UI: nút "AI tạo caption" trong Content Writing View; mỗi phương án có "Chèn" (tại con trỏ) và "Thay toàn bộ" (qua Yjs để người cùng soạn thấy một thay đổi).
- **i18n:** `editor.aiCaption.*` song song vi/en. **Light/Dark:** token theme sẵn có.

## Luồng mở rộng đã xác nhận (2026-10-08)

Người dùng đã xác nhận trong cuộc trò chuyện **Vite dist.js module not found (fork) (fork)**: làm luồng bốn bước và dựng điểm nối, ghi chú rõ cho Tuấn/Lộc/Trung.

1. **Bối cảnh:** chủ đề, mục tiêu (`engagement/sales/announcement/storytelling`), tone, nền tảng, độ dài, ngôn ngữ và trend tuỳ chọn. Hệ thống bổ sung thông tin workspace/client profile, tối đa ba bài đã đăng và tiêu đề task trong cùng workspace. AI tra tài liệu RAG theo tenant; thiếu RAG/bài cũ/cảm xúc thì bỏ qua nguồn đó.
2. **Sinh:** một lần gọi LLM trả ba phương án. Kết quả cho biết những nguồn bối cảnh đã được đưa vào prompt; đây không phải bằng chứng AI đã sử dụng từng nguồn trong câu chữ.
3. **Kiểm tra:** hiển thị cảm xúc PhoBERT, dấu hiệu dùng từ khoá trend, con số cần xác nhận và trạng thái tuân thủ. Kiểm tra con số chỉ là gợi ý, không chứng nhận nội dung đúng. `NOT_CHECKED` cho đến khi nối FR 3.6.33; `BLOCKED` không được chèn/thay, kể cả bản chuyển nền tảng.
4. **Tinh chỉnh:** ngắn/dài hơn, thêm CTA, bớt emoji, trang trọng/thân mật hoặc góp ý tự do; chuyển một caption sang các nền tảng được chọn; lưu phương án và nội dung tại thời điểm chèn/thay. Ghi lựa chọn một lần, chỉ cho đúng người tạo trong đúng workspace. Không coi đây là theo dõi toàn bộ chỉnh sửa sau đó trong editor.

### API bổ sung

- `POST /api/v1/workspaces/{workspaceId}/ai/captions/refine`: `{ caption, instruction, feedback?, platform?, language?, topic? }` → `{ drafts, creditsUsed, creditsRemaining }`. `custom` bắt buộc có feedback.
- `POST /api/v1/workspaces/{workspaceId}/ai/captions/adapt`: `{ caption, platforms, language?, topic? }` → `{ drafts, creditsUsed, creditsRemaining }`, một bản cho mỗi nền tảng riêng biệt.
- `POST /api/v1/workspaces/{workspaceId}/ai/captions/{generationId}/choice`: `{ type, action: INSERT|REPLACE, finalText? }` → thành công không có dữ liệu. Lựa chọn lặp/khác người/khác workspace trả `400 INVALID_REQUEST`.
- Kết quả generate bổ sung `generationId`, `context` và `signals/compliance` trên mỗi phương án. Kết quả refine/adapt cũng có `signals/compliance`.
- Giá refine/adapt cấu hình riêng qua `ai.credits.caption.refine` và `ai.credits.caption.adapt` (mặc định 1, 0 = miễn phí); giá cuối cùng chưa chốt.
- Credit và lịch sử generation phải được ghi trong cùng giao dịch: lưu thất bại không được giữ khoản credit đã trừ. Không giữ giao dịch ghi dữ liệu trong lúc chờ LLM.

### UI States và phần phụ thuộc

- Dùng chung dialog tại Content Writing View và Trình soạn Nội dung. Bản generate mới xoá trạng thái tinh chỉnh/bản chuyển nền tảng của lần trước; tinh chỉnh luôn dùng nền tảng của kết quả đã tạo.
- Dùng `editor.aiCaption.*` trong cả `vi/editor.json` và `en/editor.json`, token theme và các lớp `dark:` cho cảnh báo.
- RAG dùng trường metadata thực tế `clientId` (giá trị `workspaceId`); upload tài liệu phải dùng cùng tenant đó.
- Chưa nối: engine tuân thủ của Tuấn, credit mua thêm/credit tracking, task brief và content request của Lộc, nhãn phiên bản AI của Trung. Điểm nối được liệt kê trong `plan.md`.
- Hashtag trong phương án hiện do LLM đề xuất. Hashtag từ dữ liệu trend thật đã có API `/api/v1/ai/content/hashtags`; phần nối vào dialog được ghi riêng, không coi là đã hoàn tất.
- Panel tạo nhanh cũ của Lộc vẫn tồn tại và chưa đi qua credit service. Nút dialog mới sử dụng API có credit; cần Lộc hợp nhất panel để loại bỏ luồng miễn phí cũ.
