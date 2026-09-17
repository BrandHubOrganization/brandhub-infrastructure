# UC — Create Content Request

| | |
|---|---|
| FR Code | 3.5.7 |
| Feature | Create Content Request |
| Domain | Media Package & Contract (FR 3.5) |
| Role | CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Client tạo bài content mới đề xuất ngoài Campaign, chờ Manager duyệt trước khi phân task cho role khác.

## 2. User Story

Là một Client,
tôi muốn đề xuất thêm 1 bài content mới,
để yêu cầu Agency thực hiện ngoài kế hoạch Campaign đã duyệt.

## 3. Acceptance Criteria

- Client tạo Content Request: `title`, `description`.
- Trạng thái ban đầu `pending` — chờ Manager coi và quyết định.
- **[CONFIRMED 2026-09-14]** Role list CSV ghi cả OWNER/MANAGER/CLIENT nhưng hành động Create chỉ do CLIENT — Owner/Manager chỉ có quyền TRUY CẬP xem (để duyệt sau ở FR 3.5.8), không tự tạo request cho mình.
- Cần note lại để sau này tính vào công việc bổ sung (liên quan billing/KPI ngoài phạm vi Package gốc).

## 4. UI / UX

- Trang `/workspaces/:id/content-requests/create` — chỉ hiện nút này cho user có vai trò Client.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/content-requests
{ "title": "string", "description": "string" }
→ 201 { "success": true, "data": { "id", "status": "pending" } }
```

## 6. Error Handling

- User không phải Client của Workspace này → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt ở bước tạo.

## 8. Definition of Done

- Tạo Content Request thành công, chỉ Client thao tác được.

## Out of Scope

- Không có.

## Tham chiếu BA

[04-media-package-campaign.md](../../../BA/04-media-package-campaign.md), [12-state-machines.md](../../../BA/12-state-machines.md)
