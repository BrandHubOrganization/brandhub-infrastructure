# UC — Add Workspace Member

| | |
|---|---|
| FR Code | 3.4.19 |
| Feature | Add Workspace Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner/Manager thêm 1 Member (đã có trong Agency) vào Workspace với role cụ thể.

## 2. User Story

Là một Owner hoặc Manager,
tôi muốn thêm 1 thành viên Agency vào Workspace,
để họ tham gia làm việc với role phù hợp.

## 3. Acceptance Criteria

- Chọn 1 `AgencyMember` (điều kiện bắt buộc: người này phải đã là Member của Agency chứa Workspace này — xem [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md) mục 'Quan hệ Agency Member ↔ Workspace Member').
- Chọn role: `OWNER` | `MANAGER` | `MEMBER` (bao gồm Creator).
- Tạo `WorkspaceMember` mới — **role này CHỈ áp dụng cho Workspace đang thêm vào**, không ảnh hưởng role của người đó ở Workspace khác trong cùng Agency.

## 4. UI / UX

- Nút 'Thêm thành viên' trong `/workspaces/:id/members`, dropdown chọn từ AgencyMember chưa có trong Workspace này.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/members
{ "userId": "string", "role": "OWNER|MANAGER|MEMBER" }
→ 201 { "success": true, "data": { "id", "userId", "role", "joinedAt" } }
```

## 6. Error Handling

- `userId` không phải Member của Agency chứa Workspace này → 400 `USER_NOT_AGENCY_MEMBER`.
- User đã có trong Workspace này rồi → 409 `ALREADY_WORKSPACE_MEMBER`.

## 7. Edge Cases

- Thêm 1 người đã là MANAGER ở Workspace khác (cùng Agency) vào Workspace này với role MEMBER → hoàn toàn hợp lệ, role độc lập theo từng Workspace.

## 8. Definition of Done

- Add thành công, role chỉ áp dụng đúng Workspace này (verify bằng test 2 Workspace khác nhau).

## Out of Scope

- Không có.

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)
