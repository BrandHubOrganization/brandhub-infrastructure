# UC — Remove Member

| | |
|---|---|
| FR Code | 3.4.9 |
| Feature | Remove Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xóa Member khỏi Agency — mất quyền truy cập nhưng tài nguyên họ tạo ra vẫn giữ nguyên (tài sản chung của Agency).

## 2. User Story

Là một Owner,
tôi muốn xóa 1 Member khỏi Agency,
nhưng không muốn mất các tài nguyên họ đã tạo ra khi còn làm việc.

## 3. Acceptance Criteria

- Bấm Remove Member (có confirm).
- Xóa `AgencyMember` record — Member mất quyền truy cập MỌI Workspace của Agency đó ngay lập tức (kể cả Workspace họ đang có role Manager/Member).
- **Tài nguyên họ tạo ra (Task, Material, Content...) KHÔNG bị xóa** — vẫn thuộc Workspace/Agency như tài sản chung.
- Nếu được thêm lại vào Agency sau đó (Invite lại), họ **được chỉnh sửa/sử dụng tiếp** các tài nguyên cũ đó (không mất quyền truy cập vĩnh viễn với dữ liệu họ từng tạo).

## 4. UI / UX

- Nút Remove trong danh sách Member ở `/agencies/:id/members`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/agencies/{id}/members/{memberId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không phải Owner → 403 `FORBIDDEN`.
- Xóa chính Owner (không hợp lệ, Owner không thể tự remove mình qua FR này) → 409 `CANNOT_REMOVE_OWNER`.

## 7. Edge Cases

- Member bị xóa đang có Task đang `IN_PROGRESS` được assign cho họ ở 1 Workspace → Task đó KHÔNG tự động unassign, Manager cần xử lý thủ công (reassign) — vì tài nguyên/công việc vẫn thuộc Workspace.

## 8. Definition of Done

- Remove thành công, mất quyền truy cập ngay, tài nguyên cũ vẫn còn, thêm lại vẫn dùng tiếp được (test case rõ ràng).

## Out of Scope

- Tự động reassign Task khi Member bị xóa (cần xử lý thủ công theo AC).

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)
