# UC — View Workspace Members

| | |
|---|---|
| FR Code | 3.4.18 |
| Feature | View Workspace Members |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị danh sách thành viên của 1 Workspace.

## 2. User Story

Là một Member của Workspace,
tôi muốn xem danh sách thành viên,
để biết ai đang tham gia và vai trò của họ.

## 3. Acceptance Criteria

- List toàn bộ `WorkspaceMember` của Workspace: tên, email, role (OWNER/MANAGER/MEMBER), ngày tham gia.
- Mọi Member trong Workspace xem được (không giới hạn chỉ Owner/Manager).

## 4. UI / UX

- Trang `/workspaces/:id/members`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/members
→ 200 { "success": true, "data": [{ "id", "userId", "fullName", "role", "joinedAt" }] }
```

## 6. Error Handling

- Không phải member của Workspace này → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- List hiển thị đúng, mọi Member xem được.

## Out of Scope

- Không có.

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)
