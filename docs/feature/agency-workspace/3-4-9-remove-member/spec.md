# UC — Remove Member

| | |
|---|---|
| FR Code | 3.4.9 |
| Feature | Remove Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.2 — Cập nhật 2026-09-23 — ErrorCode riêng `CANNOT_REMOVE_OWNER` (409) |
| Trạng thái tài liệu | Confirmed — đã code, đã thêm mã lỗi riêng `CANNOT_REMOVE_OWNER` (409) thay cho `FORBIDDEN` (403) |

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

- Nút Remove trong danh sách Member ở `/agencies/:agencyId/members`.

## 5. API Contract (khớp code thật)

```
DELETE /api/v1/agencies/{agencyId}/members/{memberId}
→ 200 { "success": true, "data": null }
```

Route path khớp đúng. `memberId` là `AgencyMember.id` (không phải `userId`).

## 6. Error Handling

- Không phải Owner của Agency → 403 `NOT_AGENCY_OWNER`.
- `memberId` không tồn tại hoặc không thuộc agency này → 404 `NOT_FOUND`.
- Cố xóa member có role OWNER → **409 `CANNOT_REMOVE_OWNER`** ("Cannot remove the owner of the agency"). Mã lỗi riêng đã được thêm vào `ErrorCode` (`HttpStatus.CONFLICT`) — **trước đây dùng chung `FORBIDDEN` (403), nay đã thay**.

## 7. Edge Cases

- Member bị xóa đang có Task đang `IN_PROGRESS` được assign cho họ ở 1 Workspace → Task đó KHÔNG tự động unassign, Manager cần xử lý thủ công (reassign) — vì tài nguyên/công việc vẫn thuộc Workspace.

## 8. Definition of Done

- Remove thành công, mất quyền truy cập ngay, tài nguyên cũ vẫn còn, thêm lại vẫn dùng tiếp được (test case rõ ràng). Chặn xóa Owner đã hoạt động đúng (trả 409 `CANNOT_REMOVE_OWNER`).

## Out of Scope

- Tự động reassign Task khi Member bị xóa (cần xử lý thủ công theo AC).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
