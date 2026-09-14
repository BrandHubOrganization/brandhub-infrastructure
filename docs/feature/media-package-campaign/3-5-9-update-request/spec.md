# UC — Update Request

| | |
|---|---|
| FR Code | 3.5.9 |
| Feature | Update Request |
| Domain | Media Package & Contract (FR 3.5) |
| Role | CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Client điều chỉnh nội dung Content Request, chỉ được làm khi đang ở trạng thái PENDING.

## 2. User Story

Là một Client,
tôi muốn sửa lại nội dung Content Request tôi đã gửi,
khi nó vẫn đang chờ Manager xem xét.

## 3. Acceptance Criteria

- Form sửa `title`, `description`.
- **Chỉ cho sửa khi `status = pending`** — nếu Manager đã chuyển sang `in_progress` hoặc xử lý xong, Client không sửa được nữa.

## 4. UI / UX

- Nút Edit chỉ hiện khi status=pending trong `/workspaces/:id/content-requests`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/content-requests/{requestId}
{ "title"?, "description"? }
→ 200 { "success": true, "data": { ...updated request... } }
```

## 6. Error Handling

- Sửa khi status khác pending → 409 `REQUEST_NOT_EDITABLE`.
- Không phải người tạo request → 403 `FORBIDDEN`.

## 7. Edge Cases

- Manager đổi status sang `in_progress` đúng lúc Client đang gõ sửa → request cuối cùng bị 409 khi submit, FE cần hiển thị rõ lý do (không phải lỗi hệ thống).

## 8. Definition of Done

- Update thành công khi pending, chặn đúng khi không còn pending.

## Out of Scope

- Không có.

## Tham chiếu BA

[04_Media_Package_Campaign.md](../../../BA/04_Media_Package_Campaign.md), [12_State_Machines.md](../../../BA/12_State_Machines.md)
