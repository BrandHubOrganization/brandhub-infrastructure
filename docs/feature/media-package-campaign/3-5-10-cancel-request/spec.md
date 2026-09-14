# UC — Cancel Request

| | |
|---|---|
| FR Code | 3.5.10 |
| Feature | Cancel Request |
| Domain | Media Package & Contract (FR 3.5) |
| Role | CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Client hủy Content Request, chỉ hợp lệ khi status đang PENDING — sau khi đổi trạng thái khác, Client hết quyền hủy.

## 2. User Story

Là một Client,
tôi muốn hủy Content Request tôi đã gửi,
khi nó vẫn đang chờ xử lý và tôi không còn cần nữa.

## 3. Acceptance Criteria

- Bấm Cancel (confirm dialog).
- **Chỉ hợp lệ khi `status = pending`** — giống điều kiện Update Request (FR 3.5.9).
- Sau khi Manager đổi status (in_progress/accepted/denied), Client không hủy được nữa.

## 4. UI / UX

- Nút Cancel cạnh nút Edit, chỉ hiện khi status=pending.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/workspaces/{id}/content-requests/{requestId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Hủy khi status khác pending → 409 `REQUEST_NOT_CANCELLABLE`.
- Không phải người tạo request → 403 `FORBIDDEN`.

## 7. Edge Cases

- Cancel là xóa cứng hay soft delete? Theo tinh thần nhất quán với các FR khác trong CSV (đa số soft delete) — đề xuất soft delete (`status=cancelled`) để giữ lịch sử, cần xác nhận khi thiết kế kỹ thuật.

## 8. Definition of Done

- Cancel thành công khi pending, chặn đúng khi không còn pending.

## Out of Scope

- Không có.

## Tham chiếu BA

[04_Media_Package_Campaign.md](../../../BA/04_Media_Package_Campaign.md), [12_State_Machines.md](../../../BA/12_State_Machines.md)
