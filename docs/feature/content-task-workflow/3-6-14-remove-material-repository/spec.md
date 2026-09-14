# UC — Remove Material Repository

| | |
|---|---|
| FR Code | 3.6.14 |
| Feature | Remove Material Repository |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xóa Material khỏi Repository.

## 2. User Story

Là một Creator,
tôi muốn xóa 1 Material không còn cần dùng,
để giữ kho tài liệu gọn gàng.

## 3. Acceptance Criteria

- Xóa Material (đề xuất soft delete để nhất quán với các FR xóa khác trong CSV, giữ lịch sử tham chiếu nếu đã dùng trong Task).

## 4. UI / UX

- Nút Delete trong list Material, có confirm.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/workspaces/{id}/materials/{materialId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Material đã được dùng trong 1 Task đã COMPLETED → vẫn cho xóa khỏi Repository nhưng giữ nguyên tham chiếu ở Task cũ (không phá vỡ lịch sử).

## 8. Definition of Done

- Xóa thành công, không phá vỡ dữ liệu Task đã dùng Material đó trước đây.

## Out of Scope

- Không có.

## Tham chiếu BA

[05_Content_Task_Workflow.md](../../../BA/05_Content_Task_Workflow.md)
