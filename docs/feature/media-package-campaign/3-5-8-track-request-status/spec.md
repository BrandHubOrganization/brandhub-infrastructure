# UC — Track Request Status

| | |
|---|---|
| FR Code | 3.5.8 |
| Feature | Track Request Status |
| Domain | Media Package & Contract (FR 3.5) |
| Role | MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Manager điều chỉnh status của Content Request: pending → in progress → accept (sinh Task) hoặc denied. 4 trạng thái do Agency setting, Client không tự set được.

## 2. User Story

Là một Manager,
tôi muốn theo dõi và cập nhật trạng thái Content Request của Client,
để quyết định có triển khai yêu cầu đó hay không.

## 3. Acceptance Criteria

- 4 trạng thái: `pending → in_progress → accepted` (sinh Task mới) hoặc `denied`.
- **Chỉ Manager set trạng thái** — Client hoàn toàn không có quyền tự chuyển trạng thái (chỉ xem).
- Khi set `accepted` → **hệ thống tự động sinh 1 Task mới** trong backlog, gắn `sourceType=content_request`, `sourceRefId` trỏ về Content Request này (xem [12_State_Machines.md](../../../BA/12_State_Machines.md) mục 1).
- Ghi chú bổ sung từ nguồn: luồng thực tế ngoài đời — Template Package (số bài, thời gian, chất lượng) → team thảo luận cụ thể hóa bài viết → ra kế hoạch truyền thông (tiêu đề, nền tảng) → thảo luận với Client → hợp đồng chính thức. Đây là mô tả bối cảnh vận hành, không phải bước riêng trong FR.

## 4. UI / UX

- Trang `/workspaces/:id/content-requests` — Manager thấy dropdown đổi trạng thái, Client chỉ thấy badge trạng thái (view-only).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/content-requests/{requestId}/status
{ "status": "in_progress|accepted|denied" }
→ 200 { "success": true, "data": { "status", "generatedTaskId"? } }
```

## 6. Error Handling

- Client gọi endpoint này → 403 `FORBIDDEN` (chỉ Manager).
- Set status không đúng thứ tự hợp lệ (ví dụ pending → denied trực tiếp có được không? — CHO PHÉP, không bắt buộc phải qua in_progress trước khi denied) → không lỗi, chỉ chặn set lùi trạng thái từ accepted/denied về pending/in_progress.

## 7. Edge Cases

- Set `accepted` 2 lần (double-click) → idempotency, không tạo 2 Task trùng cho cùng 1 Content Request.

## 8. Definition of Done

- Đổi trạng thái đúng luồng, sinh Task tự động khi accepted, Client không set được trạng thái.

## Out of Scope

- Không có.

## Tham chiếu BA

[04_Media_Package_Campaign.md](../../../BA/04_Media_Package_Campaign.md), [12_State_Machines.md](../../../BA/12_State_Machines.md)
