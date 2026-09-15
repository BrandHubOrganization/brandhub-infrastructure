# UC — Leave Workspace

| | |
|---|---|
| FR Code | 3.4.16 |
| Feature | Leave Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Member tự rời khỏi 1 Workspace, nhưng vẫn còn trong Agency (rời Workspace ≠ rời Agency).

## 2. User Story

Là một Member,
tôi muốn rời khỏi 1 Workspace tôi không còn tham gia,
nhưng vẫn giữ tư cách thành viên Agency để tham gia Workspace khác.

## 3. Acceptance Criteria

- Bấm Leave Workspace (confirm dialog).
- Xóa `WorkspaceMember` record của user đó khỏi Workspace này.
- **`AgencyMember` record KHÔNG bị ảnh hưởng** — user vẫn còn trong Agency, chỉ mất quyền ở Workspace cụ thể này.

## 4. UI / UX

- Nút 'Rời Workspace' trong Workspace Settings/Members (chỉ hiện với chính user đó, không phải Owner tự leave workspace của mình dễ dàng nếu là Manager duy nhất — xem Edge Cases).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/leave
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- User là Manager DUY NHẤT của Workspace → 409 `CANNOT_LEAVE_AS_ONLY_MANAGER` (Workspace luôn cần ít nhất 1 Manager, theo yêu cầu FR 3.4.12 bắt buộc có Manager khi tạo).

## 7. Edge Cases

- Manager duy nhất muốn leave → phải gán Manager khác trước (qua Update Workspace Member Role, FR 3.4.20) rồi mới leave được.

## 8. Definition of Done

- Leave thành công, vẫn còn trong Agency; chặn đúng trường hợp Manager duy nhất.

## Out of Scope

- Tự động chọn Manager thay thế khi Manager duy nhất leave (phải làm thủ công trước).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
