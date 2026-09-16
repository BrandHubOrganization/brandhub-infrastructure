# UC — Update Workspace Member Role

| | |
|---|---|
| FR Code | 3.4.20 |
| Feature | Update Workspace Member Role |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner/Manager đổi role của 1 Member trong chính Workspace đó.

## 2. User Story

Là một Owner hoặc Manager,
tôi muốn đổi role của 1 thành viên trong Workspace,
để điều chỉnh quyền hạn phù hợp với công việc thực tế.

## 3. Acceptance Criteria

- Chọn Member trong danh sách → đổi role sang `OWNER`/`MANAGER`/`MEMBER`.
- Đổi role **chỉ ảnh hưởng Workspace hiện tại** — không lan sang Workspace khác của cùng Member trong cùng Agency.

## 4. UI / UX

- Dropdown đổi role ngay trong bảng Members ở `/workspaces/:id/members`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/members/{memberId}
{ "role": "OWNER|MANAGER|MEMBER" }
→ 200 { "success": true, "data": { ...updated member... } }
```

## 6. Error Handling

- Đổi role của MANAGER duy nhất xuống MEMBER mà không có Manager khác thay thế → 409 `CANNOT_REMOVE_LAST_MANAGER` (tương tự ràng buộc ở FR 3.4.16).

## 7. Edge Cases

- Owner đổi role của chính mình xuống MEMBER → cho phép nếu còn ít nhất 1 Manager khác trong Workspace này.

## 8. Definition of Done

- Đổi role thành công, chặn đúng trường hợp mất Manager cuối cùng.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
