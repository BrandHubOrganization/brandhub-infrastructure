# UC — Content Moderation Queue

| | |
|---|---|
| FR Code | 3.10.4 |
| Feature | Content Moderation Queue |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị content của Creator bị dính chính sách kiểm duyệt hệ thống — Admin check lại xem quyết định hệ thống đúng hay không.

## 2. User Story

Là một Admin,
tôi muốn review các content bị hệ thống tự động đánh dấu vi phạm,
để xác nhận quyết định đó có đúng hay cần override.

## 3. Acceptance Criteria

- List content bị flag từ Check Compliance Content (FR 3.6.33) hoặc Check Copyright Infringement (FR 3.6.34).
- Admin xem chi tiết vi phạm được hệ thống phát hiện, quyết định: giữ nguyên quyết định hệ thống (chặn) hoặc override (cho phép tiếp tục).

## 4. UI / UX

- Trang Admin `/admin/content-moderation`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/admin/content-moderation-queue
→ 200 { "success": true, "data": [{ "taskId", "violationSummary", "flaggedAt" }] }

POST /api/v1/admin/content-moderation-queue/{taskId}/override
{ "decision": "approve|block", "note"? }
→ 200 { "success": true, "data": { ...updated decision... } }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Queue hiển thị đúng, override hoạt động.

## Out of Scope

- Không có.

## Tham chiếu BA

[09-admin-management.md](../../../BA/09-admin-management.md)
