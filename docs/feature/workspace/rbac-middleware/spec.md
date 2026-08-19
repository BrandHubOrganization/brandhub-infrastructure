# UC — RBAC Middleware & Isolation

| | |
|---|---|
| Feature | RBAC middleware + workspace isolation |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | C. Hạ tầng bảo mật |

## 1. Objective

Chặn truy cập trái phép giữa các workspace và giữa các role trong cùng workspace. Mọi endpoint nghiệp vụ (trừ auth công khai) phải:
1. Xác định `MemberRole` của user hiện tại trong `workspaceId` đang thao tác.
2. Từ chối nếu role không đủ quyền cho hành động đó (`@RequireRole`).
3. Tự động lọc mọi truy vấn dữ liệu workspace-scoped theo đúng `workspaceId` của user — không cho user A đọc/ghi data workspace B dù có quyền role tương đương.

## 2. User Story

Là hệ thống,
tôi muốn tự động kiểm tra role + phạm vi workspace trên mọi request,
để một user không thể thao tác ngoài workspace của họ hoặc vượt quyền role được gán.

## 3. Acceptance Criteria

- Annotation `@RequireRole({MemberRole...})` gắn trên method controller → chặn 403 nếu role hiện tại của user trong workspace đang active không nằm trong danh sách cho phép.
- `AuthenticatedUser.getWorkspaceId()` (lấy từ JWT claim) được dùng làm nguồn workspace hiện tại — không tin `workspaceId` do client gửi trong body/param cho mục đích authorization (chỉ dùng để chọn resource, không override quyền).
- Nếu user gọi API JOIN/access resource thuộc `workspaceId` khác với `AuthenticatedUser.getWorkspaceId()` → 403 `WORKSPACE_ACCESS_DENIED`, bất kể role.
- SystemRole `ADMIN` (platform-level, bảng `user_system_roles`) bypass toàn bộ `@RequireRole` check (admin toàn quyền) — không bypass isolation nếu chưa implement admin cross-workspace view (out of scope).
- Mọi JPA repository method động chạm bảng workspace-scoped (`workspaces`, `workspace_members`, `workspace_invitations`, `workspace_member_permissions`, và các bảng nghiệp vụ tương lai có cột `workspaceId`) phải nhận `workspaceId` làm điều kiện WHERE bắt buộc — không có method "get all" bỏ qua workspaceId.
- Role không có trong `workspace_members` (chưa từng là member workspace đó) → 403, không 404 (tránh lộ thông tin tồn tại của resource).

## 4. Role Matrix (MemberRole)

| Role | Ý nghĩa | Quyền mặc định |
|---|---|---|
| `OWNER` | Chủ workspace | Full quyền: quản lý workspace, member, billing, nội dung |
| `ACCOUNT` | Quản lý tài khoản/khách hàng | Quản lý member + client, không xoá workspace |
| `CREATOR` | Tạo nội dung | Tạo/sửa nội dung, không quản lý member |
| `CLIENT` | Khách hàng duyệt nội dung | Xem + duyệt/từ chối nội dung, không sửa |
| `VIEWER` | Xem nội bộ | Chỉ đọc |

Fine-grained override: bảng `workspace_member_permissions` (permission string + granted boolean) cho phép cấp/thu quyền lẻ ngoài role mặc định — middleware ưu tiên override nếu có bản ghi cho `(workspaceMemberId, permission)`, fallback về role matrix nếu không có override.

**Ghi chú:** đây là note ban đầu (Jira DA-193 ghi "MongoDB") thực tế là mô tả cũ/sai — toàn bộ dữ liệu Workspace/Member đã ở PostgreSQL qua JPA. Isolation filter implement bằng JPA (Specification hoặc base repository pattern tự thêm `workspaceId = :currentWorkspaceId`), không phải Mongo query filter.

## 5. API Contract

Không có endpoint riêng — đây là cross-cutting middleware áp dụng lên toàn bộ controller nghiệp vụ. Ví dụ áp dụng:

```java
@RequireRole({MemberRole.OWNER, MemberRole.ACCOUNT})
@DeleteMapping("/workspaces/{workspaceId}/members/{memberId}")
public ApiResponse<Void> removeMember(...)
```

Response 403 khi vi phạm role:
```json
{ "success": false, "error": { "code": "INSUFFICIENT_ROLE", "message": "Không đủ quyền thực hiện thao tác này" } }
```

Response 403 khi vi phạm workspace isolation:
```json
{ "success": false, "error": { "code": "WORKSPACE_ACCESS_DENIED", "message": "Không có quyền truy cập workspace này" } }
```

## 6. Error Handling

- Chưa đăng nhập / JWT thiếu `workspaceId` claim → 401 (đã xử lý ở `JwtAuthenticationFilter`, ngoài scope feature này).
- Role không đủ quyền → 403 `INSUFFICIENT_ROLE`.
- Truy cập workspace khác → 403 `WORKSPACE_ACCESS_DENIED`.
- User không còn là member active (`workspace_members.isActive = false`) → 403 `WORKSPACE_ACCESS_DENIED`.

## 7. Edge Cases

- User bị remove khỏi workspace nhưng JWT cũ chưa hết hạn (`workspaceId` claim đã stale) → mỗi request phải re-check `WorkspaceMemberRepository.findFirstByUserIdAndIsActiveTrue` thay vì tin tuyệt đối claim (quyết định: **re-check DB mỗi request**, ưu tiên đúng đắn hơn hiệu năng ở giai đoạn này).
- User là member của nhiều workspace (multi-tenant) — JWT chỉ mang 1 `workspaceId` tại một thời điểm; chuyển workspace yêu cầu re-login/refresh token (out of scope đổi mới ở đây, theo thiết kế JWT hiện tại).
- SystemRole ADMIN nhưng không phải member workspace nào — vẫn bypass `@RequireRole`, nhưng nếu chưa có route "admin xem mọi workspace" thì thực tế không gọi được các endpoint cần `workspaceId` hợp lệ trong JWT (giới hạn hiện tại, ghi nhận không giải quyết trong phase này).
- Permission override tồn tại nhưng `granted = false` — override tường minh từ chối dù role mặc định cho phép.

## 8. Definition of Done

- `@RequireRole` annotation + AOP aspect (hoặc Spring Security custom bean) hoạt động, có unit test cho case allow/deny.
- Isolation filter/helper áp dụng được cho `WorkspaceMemberRepository`, `WorkspaceRepository` — có ít nhất 1 integration test chứng minh user A không đọc được data workspace B.
- Toàn bộ test case mục 9 (test.md) pass.
- Không có endpoint nghiệp vụ mới nào thiếu `@RequireRole` (checklist review thủ công khi PR).

## Out of Scope

- Cross-workspace switch không cần re-login (giữ nguyên hành vi JWT hiện tại).
- Admin cross-workspace dashboard/view.
- UI hiển thị permission matrix cho end-user (chỉ backend enforcement).
