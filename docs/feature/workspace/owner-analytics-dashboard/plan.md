# Plan — Owner/Account Team Analytics Dashboard

## Backend (brandhub-business-service)

### 1. AuditLogRepository — query method mới
```java
Page<AuditLog> findByWorkspaceIdOrderByCreatedAtDesc(UUID workspaceId, Pageable pageable);
Page<AuditLog> findByWorkspaceIdInOrderByCreatedAtDesc(List<UUID> workspaceIds, Pageable pageable);
```
Spring Data tự sinh cả 2 — không cần `@Query`.

### 2. DTO mới
`dto/response/AuditLogResponse.java`:
```java
public record AuditLogResponse(
        Long id, UUID userId, String userFullName, AuditAction action,
        String resourceType, String resourceId, OffsetDateTime createdAt
) {}
```
`dto/response/ManagedAuditLogResponse.java` — thêm 2 field so với trên:
```java
public record ManagedAuditLogResponse(
        Long id, UUID workspaceId, String workspaceName, UUID userId,
        String userFullName, AuditAction action, String resourceType,
        String resourceId, OffsetDateTime createdAt
) {}
```
`dto/response/ManagedWorkspaceResponse.java`:
```java
public record ManagedWorkspaceResponse(
        UUID id, String name, String slug, String logoUrl,
        MemberRole role, long memberCount
) {}
```

### 3. WorkspaceService (interface) + Impl — method mới
```java
Page<AuditLogResponse> listAuditLogs(UUID workspaceId, Pageable pageable);
List<ManagedWorkspaceResponse> listManagedWorkspaces(AuthenticatedUser currentUser);
Page<ManagedAuditLogResponse> listManagedAuditLogs(AuthenticatedUser currentUser, Pageable pageable);
```

`listAuditLogs`: gọi `auditLogRepository.findByWorkspaceIdOrderByCreatedAtDesc`,
map sang `AuditLogResponse` — cần join tên user (`userRepository.findAllById`
theo batch giống pattern `listMembers` hiện có, tránh N+1).

`listManagedWorkspaces`: `workspaceMemberRepository.findByUserIdAndIsActiveTrue(currentUser.getId())`
→ filter `role == OWNER || role == ACCOUNT` → với mỗi membership, lấy
`Workspace` (`workspaceRepository.findAllById` batch) + đếm member qua
`countByWorkspaceIdAndIsActiveTrue` mới (mục 4) → map `ManagedWorkspaceResponse`.

`listManagedAuditLogs`: gọi `listManagedWorkspaces` trước lấy list
`workspaceId`, nếu rỗng trả `Page.empty()` ngay (tránh query IN rỗng), không
thì `findByWorkspaceIdInOrderByCreatedAtDesc`, map kèm `workspaceName` (từ
map đã build ở bước trước).

### 4. WorkspaceMemberRepository — thêm count method
```java
long countByWorkspaceIdAndIsActiveTrue(UUID workspaceId);
```

### 5. WorkspaceController — 3 endpoint mới
**Thứ tự khai báo quan trọng**: `/my-managed` và `/my-managed/audit-logs`
PHẢI đặt trước `@GetMapping("/{workspaceId}")` trong file, nếu không Spring
sẽ match nhầm `"my-managed"` thành giá trị `workspaceId` (path variable
String → UUID parse fail → 400 sai lỗi). Đặt 2 route mới ngay sau
`listMyWorkspaces()`, trước `getWorkspace()`.
```java
@GetMapping("/my-managed")
public ApiResponse<List<ManagedWorkspaceResponse>> listManagedWorkspaces(
        @AuthenticationPrincipal AuthenticatedUser currentUser, WebRequest webRequest) { ... }

@GetMapping("/my-managed/audit-logs")
public ApiResponse<Page<ManagedAuditLogResponse>> listManagedAuditLogs(
        @AuthenticationPrincipal AuthenticatedUser currentUser,
        @PageableDefault(size = 20) Pageable pageable, WebRequest webRequest) { ... }

@GetMapping("/{workspaceId}/audit-logs")
@RequireRole({MemberRole.OWNER, MemberRole.ACCOUNT})
public ApiResponse<Page<AuditLogResponse>> listAuditLogs(
        @PathVariable UUID workspaceId,
        @PageableDefault(size = 20) Pageable pageable, WebRequest webRequest) { ... }
```
Đặt `/{workspaceId}/audit-logs` sau `/{workspaceId}/members` như các route
con khác — không xung đột vì đã có prefix `/{workspaceId}/`.

### 6. Test
`WorkspaceServiceTest` bổ sung:
- `listAuditLogs_returnsWorkspaceScopedLogs`
- `listManagedWorkspaces_filtersOwnerAndAccountOnly`
- `listManagedWorkspaces_userWithNoManagedWorkspace_returnsEmpty`
- `listManagedAuditLogs_userWithNoManagedWorkspace_returnsEmptyPageWithoutQuery`
  (verify không gọi `findByWorkspaceIdInOrderByCreatedAtDesc` khi list rỗng)

## Frontend (brandhub-web-dashboard)

### 7. Sidebar.tsx
- Ẩn section `nav.sections.create` hoàn toàn khi `role === "OWNER"` — thêm
  filter mới trong `filteredSections` map, tương tự cách filter CLIENT hiện
  có.
- Thêm mục "Tổng quan" (`nav.overview` → `/analytics/overview`) vào section
  `nav.sections.overview`, chỉ hiện khi `role === "OWNER" || role === "ACCOUNT"`.
  Lưu ý: đây không cần `activeWorkspace` — hiện luôn nếu role phù hợp, kể cả
  khi không có workspace active (khác logic "cần workspace context" của các
  mục khác) vì trang overview độc lập với workspace đang chọn.

### 8. types/workspace.ts — type mới
```ts
export interface AuditLogEntry {
  id: number;
  userId: string;
  userFullName: string | null;
  action: string;
  resourceType: string;
  resourceId: string | null;
  createdAt: string;
}
export interface ManagedAuditLogEntry extends AuditLogEntry {
  workspaceId: string;
  workspaceName: string;
}
export interface ManagedWorkspace {
  id: string; name: string; slug: string; logoUrl: string | null;
  role: MemberRole; memberCount: number;
}
export interface PageResponse<T> {
  content: T[]; totalElements: number; totalPages: number; number: number; size: number;
}
```

### 9. workspaceService.ts — method mới
```ts
listAuditLogs: (workspaceId: string, page = 0, size = 20) =>
  api.get<ApiResponse<PageResponse<AuditLogEntry>>>(
    `/api/v1/workspaces/${workspaceId}/audit-logs`, { params: { page, size } }),
listManagedWorkspaces: () =>
  api.get<ApiResponse<ManagedWorkspace[]>>("/api/v1/workspaces/my-managed"),
listManagedAuditLogs: (page = 0, size = 20) =>
  api.get<ApiResponse<PageResponse<ManagedAuditLogEntry>>>(
    "/api/v1/workspaces/my-managed/audit-logs", { params: { page, size } }),
```

### 10. AnalyticsPage.tsx — mở rộng
- Đọc `role` hiện tại — không có sẵn nguồn gọn ở trang này. Cách lấy: gọi
  `workspaceService.listMembers(activeWorkspaceId)` tìm `userId` hiện tại
  giống pattern `WorkspaceSettingsPage.tsx` đã dùng. `activeWorkspaceId` lấy
  từ `useAuthStore`.
- Nếu role OWNER/ACCOUNT: render thêm 4 khối mới (bảng member, số liệu role,
  audit log — data thật; card cống hiến — mock) dưới phần hiện có.
- Card cống hiến mock: dùng data cứng trong component, comment rõ
  `// demo data — chưa có module Post/Content thật`.

### 11. AnalyticsOverviewPage.tsx (mới)
- Route mới `/analytics/overview` trong `App.tsx`, bọc `AuthGuard` + `Layout`
  như các trang khác.
- Gọi `listManagedWorkspaces()` — nếu rỗng, hiện empty state, không tự động
  redirect (role check đã làm ở Sidebar visibility, nhưng URL vẫn truy cập
  trực tiếp được — trang tự xử lý rỗng thay vì crash, đúng Acceptance
  Criteria).
- Danh sách workspace + tổng số liệu tính từ response.
- Gọi `listManagedAuditLogs()` hiển thị bảng gộp.
- Card cống hiến mock lặp lại theo từng workspace trong danh sách.

### 12. i18n
Thêm `nav.overview`, `nav.sections.overview` (đã có, tái dùng), namespace
`analytics.team.*` (10 key: title, memberTableTitle, roleLabel, statusLabel,
totalMembersLabel, byRoleLabel, activityTitle, activityEmpty,
contributionTitle, contributionSubtitle) và `analytics.overview.*` (title,
description, workspaceListTitle, totalWorkspacesLabel, totalMembersLabel,
activityTitle, empty) — thêm đồng thời `vi.json` + `en.json`.

## File Touch List
- `brandhub-business-service/.../repository/AuditLogRepository.java`
- `brandhub-business-service/.../repository/WorkspaceMemberRepository.java`
- `brandhub-business-service/.../dto/response/AuditLogResponse.java` (mới)
- `brandhub-business-service/.../dto/response/ManagedAuditLogResponse.java` (mới)
- `brandhub-business-service/.../dto/response/ManagedWorkspaceResponse.java` (mới)
- `brandhub-business-service/.../service/WorkspaceService.java`
- `brandhub-business-service/.../service/impl/WorkspaceServiceImpl.java`
- `brandhub-business-service/.../controller/WorkspaceController.java`
- `brandhub-business-service/src/test/.../WorkspaceServiceTest.java`
- `brandhub-web-dashboard/src/components/layout/Sidebar.tsx`
- `brandhub-web-dashboard/src/types/workspace.ts`
- `brandhub-web-dashboard/src/services/workspaceService.ts`
- `brandhub-web-dashboard/src/pages/AnalyticsPage.tsx`
- `brandhub-web-dashboard/src/pages/AnalyticsOverviewPage.tsx` (mới)
- `brandhub-web-dashboard/src/App.tsx`
- `brandhub-web-dashboard/src/i18n/locales/vi.json`, `en.json`

## Rủi ro
- Route ordering Spring MVC (`/my-managed` trước `/{workspaceId}`) — nếu
  quên, lỗi sẽ khó debug (UUID parse exception mơ hồ) — task.md phải nhắc
  lại rõ.
- `AnalyticsPage.tsx` cần biết role hiện tại nhưng không có sẵn nguồn gọn —
  chấp nhận thêm 1 lần gọi `listMembers` nữa (page-local state), không tối
  ưu nhưng đúng pattern đã lặp lại nhiều lần trong codebase này, không phá
  vỡ convention.
- `countByWorkspaceIdAndIsActiveTrue` mới thêm vào `WorkspaceMemberRepository`
  — kiểm tra chưa trùng tên method có sẵn trước khi thêm.
