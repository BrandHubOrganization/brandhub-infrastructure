# UC — Remove Agency

| | |
|---|---|
| FR Code | 3.4.6 |
| Feature | Remove Agency |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Confirmed — đã code phần soft-delete (xác nhận 2026-09-21); **restore + cascade Workspace CHƯA code**, đúng như TODO đã ghi ở task.md (chờ DA-E16-10) |

## 1. Objective

Cho phép Owner xóa (mềm) Agency, có confirm, khôi phục được trong 30 ngày.

## 2. User Story

Là một Owner,
tôi muốn xóa Agency không còn dùng nữa,
nhưng vẫn có thể khôi phục nếu tôi đổi ý trong 30 ngày.

## 3. Acceptance Criteria

- Bấm Remove → dialog confirm rõ ràng (liệt kê hệ quả: toàn bộ Workspace con cũng bị ảnh hưởng).
- Set `Agency.status = SOFT_DELETED`, `deletedAt = now()`.
- Sau 30 ngày không khôi phục → có thể bị xóa cứng bởi job dọn dẹp định kỳ (thiết kế kỹ thuật riêng, không thuộc phạm vi FR này).
- Toàn bộ Workspace con của Agency cũng chuyển `inactive` theo (tương tự Delete Workspace FR 3.4.15).

## 4. UI / UX

- Nút Remove ở Agency Settings, confirm dialog 2 lớp (nhập tên Agency để xác nhận, giống pattern xóa nguy hiểm).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/agencies/{id}
→ 200 { "success": true, "data": null }

POST /api/v1/agencies/{id}/restore
→ 200 { "success": true, "data": { ...restored agency... } }
```

## 6. Error Handling

- Không phải Owner → 403 `FORBIDDEN`.
- Đã bị soft-delete quá 30 ngày → 410 `RESTORE_WINDOW_EXPIRED`.

## 7. Edge Cases

- Owner xóa nhầm rồi khôi phục ngay trong 30 ngày → toàn bộ Workspace con cũng phải được khôi phục lại trạng thái trước đó (không chỉ Agency).

## 8. Definition of Done

- Soft delete + restore hoạt động đúng, Workspace con bị ảnh hưởng đúng theo logic.

## Out of Scope

- Xóa cứng ngay lập tức (không có trong CSV — chỉ soft delete).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
