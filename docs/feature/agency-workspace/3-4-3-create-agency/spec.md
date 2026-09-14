# UC — Create Agency

| | |
|---|---|
| FR Code | 3.4.3 |
| Feature | Create Agency |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép User tạo mới 1 Agency, tự động trở thành Owner — gắn 1-1 giữa Agency và user tạo ra nó.

## 2. User Story

Là một User,
tôi muốn tạo 1 Agency mới,
để bắt đầu quản lý công ty truyền thông của mình trên BrandHub.

## 3. Acceptance Criteria

- Form nhập `name` (bắt buộc), `description`, `logo` (optional).
- Submit → tạo `Agency` với `ownerId = currentUser.id` — quan hệ 1-1 cố định, không đổi được Owner qua FR khác trong phạm vi CSV hiện tại.
- Redirect vào Agency Dashboard vừa tạo.

## 4. UI / UX

- Trang `/agencies/create`, hoặc modal từ trang List Agency.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/agencies
{ "name": "string", "description"?: "string", "logoUrl"?: "string" }
→ 201 { "success": true, "data": { "id", "name", "ownerId" } }
```

## 6. Error Handling

- `name` trống → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- User đã là Owner của N Agency khác → không giới hạn số lượng Agency tạo mới trong CSV (có thể bị giới hạn theo Subscription Plan — xem FR 3.9, cần xác nhận liên kết khi thiết kế).

## 8. Definition of Done

- Tạo Agency thành công, `ownerId` gắn đúng user hiện tại, không đổi được sau khi tạo.

## Out of Scope

- Chuyển nhượng Owner (transfer ownership) — không có trong CSV hiện tại.

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)
