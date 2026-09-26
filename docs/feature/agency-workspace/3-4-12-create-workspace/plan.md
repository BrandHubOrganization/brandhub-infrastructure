# Plan — Create Workspace (FR 3.4.12)

> Liên kết: [spec.md](spec.md) — cho Agency member tạo Workspace mới, người tạo mặc định là MANAGER, có thể gán thêm thành viên (kể cả chuyển giao MANAGER) ngay lúc tạo.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.createWorkspace()`, `assignMembersInternal()` |
| File đã có | `WorkspaceController` (`POST /api/v1/workspaces`), `WorkspaceRequest`, `WorkspaceResponse`, `AgencyMemberRepository`, `WorkspaceMemberRepository` |

## 2. API Contract (final)

```
POST /api/v1/workspaces
Authorization: Bearer <access-token>
Body: {
  name, agencyId,
  industry?, companySize?, website?, phone?, location?, description?,
  brandColor?, logoIcon?, tagline?, foundedYear?,
  facebookUrl?, linkedinUrl?, instagramUrl?,
  assignMembers?: [{ userId, role }]
}
→ 200 ApiResponse<WorkspaceResponse>
```

Không lệch spec.md — đã khớp code thật, kể cả `agencyId` nằm trong body (không phải path param).

## 3. Data Model

- `INSERT workspaces` (`settings` mặc định `{}`, `createdBy = currentUser.id`).
- `INSERT workspace_members` cho người tạo (role MANAGER, hoặc CREATOR nếu có chuyển giao), trong cùng transaction.
- Với `assignMembers`: mỗi entry `INSERT workspace_members` riêng (qua `assignMembersInternal`, tái dùng logic chung với FR 3.4.19 Add Workspace Member).
- Không migration.

## 4. Luồng xử lý

1. Check `currentUser` là `AgencyMember` của `agencyId` → không phải → 403 `NOT_AGENCY_OWNER`.
2. Xác định `anotherManagerChosen` = có entry `assignMembers` với `role=MANAGER` và `userId != currentUser.id` hay không.
3. `INSERT workspaces`.
4. `INSERT workspace_members` cho người tạo — role MANAGER (mặc định) hoặc CREATOR (nếu `anotherManagerChosen`).
5. Nếu có `assignMembers`: gọi `assignMembersInternal` xử lý từng entry (check AgencyMember, check trùng MANAGER, insert).
6. Trả `WorkspaceResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `AgencyMember` (đã có), `Workspace`/`WorkspaceMember` entity |
| Bị chặn | `Add Workspace Member` (3.4.19) — dùng chung `assignMembersInternal` |

## 6. Rủi ro kỹ thuật

- **`assignMembersInternal` dùng chung giữa Create và Add Member (3.4.19)** — thay đổi logic 1 chỗ ảnh hưởng cả 2 FR, cần test cả 2 khi sửa.
- **2 nhánh lỗi chưa được spec.md mục 6 liệt kê đầy đủ** (theo sequence-flow.md): `403 NOT_AGENCY_MEMBER` (entry trong `assignMembers` không thuộc agency) và `USER_NOT_FOUND` (userId không tồn tại) — đã bổ sung ở test.md, cần đồng bộ spec.md nếu BA yêu cầu.
- **Transaction boundary:** bước tạo Workspace + WorkspaceMember người tạo nằm cùng transaction; các entry `assignMembers` xử lý ngay sau — nếu 1 entry lỗi giữa chừng (ví dụ `USER_NOT_FOUND`), cần xác nhận toàn bộ transaction rollback hay chỉ entry đó fail (rủi ro dữ liệu inconsistent nếu partial-commit).
