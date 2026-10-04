# Test — 3-10-4-content-moderation-queue

Các kỳ vọng chi tiết: [spec](spec.md), [Report3 spec](report3_spec.md) và mục 3 của [plan kỹ thuật](../plan.md).

- [x] BR-64 phiên bản bất biến: snapshot Mongo `post_versions` khóa theo `postId:version`, PostgreSQL lưu SHA-256 trùng khớp; sửa bài tăng `content_version`.
- [x] FLAGGED gửi duyệt → vào hàng đợi đúng một lần; tác giả ACTIVE không vào.
- [x] Bài đã lên lịch của tác giả bị FLAGGED: `/eligibility` giữ lại (PENDING_REVIEW) và tạo mục chờ.
- [x] APPROVE ghi chú < 10 ký tự → MSG80; APPROVE không tự đăng, chỉ cho phép phiên bản đó.
- [x] BLOCK: ghi đúng 1 thẻ (operationId = id mục), bài về DRAFT, email tác giả, `/eligibility` trả BLOCKED; sửa → phiên bản mới vào hàng đợi riêng.
- [x] Quyết định trên phiên bản đã đổi, mục đã xử lý hoặc rowVersion cũ → 409; cờ nội bộ cho phiên bản cũ → 409.
- [x] DEACTIVATED → AUTHOR_RESTRICTED; sai phiên bản → VERSION_MISMATCH; bài không tồn tại → POST_NOT_FOUND.
- [x] Chưa đăng nhập 401; USER 403; endpoint nội bộ không có/sai khóa → 401.
- [x] VI/EN và light/dark; 390px không tràn ngang.

## Kết quả

- `ContentModerationDatabaseTest` 5/5 (PostgreSQL 17 test DB + Mongo local DB `brandhub_moderation_test`); `AdminSecurityTest` 13/13; `PostServiceImplTest` pass sau khi thêm mock và test phiên bản.
- Full Business suite: 381 test, 0 failure, 11 error baseline (WorkspaceController/WorkspaceTemplate thiếu mock `RequireRoleAspect`, có từ upstream).
- Playwright `tests/e2e/admin/*` 33/33 pass (gồm `moderation.spec.ts` 4/4). 6 test `tests/e2e/auth/{login,register,google-oauth}` lỗi giống hệt trên `develop` gốc (UI đã đổi sau khi viết test), không do thay đổi này.
- Smoke thật: 18 bài demo Mongo local; giả lập publisher gọi `/eligibility` → 12 bài của tác giả FLAGGED bị giữ; giả lập kiểm tra tự động gọi `/flags` → 3 mục; duyệt 1, chặn 1 (thẻ Cam) qua UI; 2 email, audit đủ.

## Hợp đồng tích hợp

```
POST /api/v1/internal/moderation/flags            (Tuấn — FR 3.6.33/3.6.34)
Header X-Internal-Service-Key: ${INTERNAL_SERVICE_KEY}
{ "postId": "...", "contentVersion": 3, "source": "COMPLIANCE|COPYRIGHT", "reason": "..." }
→ 200 { "data": { "moderationId": "..." } }   409 nếu contentVersion không còn là bản hiện tại

POST /api/v1/internal/moderation/eligibility?postId=...&contentVersion=3   (Phước — trước dispatch)
→ 200 { "data": { "allowed": false, "code": "PENDING_REVIEW|BLOCKED|VERSION_MISMATCH|AUTHOR_RESTRICTED|POST_NOT_FOUND|APPROVED|ALLOWED", "reviewId": "..." } }
Chỉ đăng khi allowed=true; lỗi mạng/không xác minh được → không đăng (fail closed).
```

Giới hạn: hàng đợi chỉ có dữ liệu thật khi Tuấn/Phước nối hai endpoint; `PublishJobMessage` hiện chưa mang `contentVersion` nên Phước cần bổ sung.
