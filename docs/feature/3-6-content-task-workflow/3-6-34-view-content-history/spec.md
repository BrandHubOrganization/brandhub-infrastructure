# UC — View Content History

| | |
|---|---|
| FR Code | 3.6.35 |
| Feature | View Content History |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xem lịch sử content, không trừ credit AI khi user tái sử dụng tài nguyên đã tạo trước đó.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn xem lịch sử content đã tạo,
và tái sử dụng lại mà không bị trừ credit AI thêm lần nữa.

## 3. Acceptance Criteria

- Hiển thị lịch sử content đã tạo trong Workspace (liên kết Content Version, FR 3.6.10).
- Khi user chọn tái sử dụng 1 content/asset đã tạo trước đó (ví dụ dùng lại ảnh AI đã generate cho bài khác) → **KHÔNG trừ credit AI thêm** (chỉ trừ credit lần generate đầu tiên, xem [08-subscription-billing.md](../../../BA/08-subscription-billing.md)).

## 4. UI / UX

- Trang `/workspaces/:id/content-history`, có filter theo loại content, người tạo.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/content-history
→ 200 { "success": true, "data": [{ "id", "type", "createdBy", "createdAt", "reusedCount" }] }
```

## 6. Error Handling

- Không có quyền truy cập → 403 `FORBIDDEN`.

## 7. Edge Cases

- Content đã bị xóa (soft delete) nhưng từng được reuse → vẫn hiển thị trong lịch sử tái sử dụng (không ẩn khỏi history dù item gốc đã xóa).

## 8. Definition of Done

- Lịch sử hiển thị đúng, tái sử dụng không trừ credit thêm (verify qua AICreditLedger không tăng khi reuse).

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
