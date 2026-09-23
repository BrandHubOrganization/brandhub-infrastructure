# UC — List Workspace

| | |
|---|---|
| FR Code | 3.4.10 |
| Feature | List Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER/CREATOR/CLIENT |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Hiển thị danh sách Workspace mà current user đang là `WorkspaceMember` (bất kỳ role nào).

## 2. User Story

Là một thành viên Workspace,
tôi muốn xem danh sách Workspace tôi đang tham gia,
để chọn vào 1 Workspace cụ thể để làm việc.

## 3. Acceptance Criteria

- Trả về toàn bộ `Workspace` mà current user có `WorkspaceMember` record (không phân biệt role MANAGER/CREATOR/CLIENT).
- Danh sách KHÔNG nested theo Agency trên route — lấy theo current user (`AuthenticatedUser`) trực tiếp.
- Không có khái niệm "Owner Agency thấy toàn bộ Workspace" ở endpoint này trong code thật — chỉ trả Workspace mà user có membership.

## 4. UI / UX

- Trang danh sách Workspace của user hiện tại (không phải `/agencies/:id/workspaces`).

## 5. API Contract

```
GET /api/v1/workspaces
→ 200 { "success": true, "data": [WorkspaceResponse, ...] }
```

`WorkspaceResponse` gồm: `id`, `name`, `agencyId`, `settings`, `industry`, `companySize`, `website`, `phone`, `location`, `description`, `brandColor`, `logoIcon`, `logoUrl`, `tagline`, `foundedYear`, `facebookUrl`, `linkedinUrl`, `instagramUrl`, `createdAt`.

Ghi chú: có thêm endpoint riêng `GET /api/v1/workspaces/my-managed` trả `List<ManagedWorkspaceResponse>` (`id`, `name`, `role`, `memberCount`) — liệt kê các Workspace mà user là MANAGER, kèm số lượng thành viên.

## 6. Error Handling

- Chưa đăng nhập → 401 (theo cơ chế xác thực chung).

## 7. Edge Cases

- User chưa tham gia Workspace nào → trả mảng rỗng.

## 8. Definition of Done

- `GET /api/v1/workspaces` trả đúng danh sách Workspace mà current user có `WorkspaceMember`.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
