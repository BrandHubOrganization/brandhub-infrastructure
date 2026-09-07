# Plan — RBAC Middleware & Isolation

## Mục tiêu
Xây `@RequireRole` annotation (method-level RBAC theo `MemberRole` per-workspace) + workspace isolation filter cho toàn bộ query JPA workspace-scoped, thay thế trạng thái hiện tại (chưa có RBAC/isolation nào — `SecurityConfig` chỉ `.authenticated()`, không method security).

## Thành phần liên quan
- `com.brandhub.business.security.AuthenticatedUser` — đã có `getId()`, `getWorkspaceId()`. Cần thêm cách lấy `MemberRole` hiện tại (không có sẵn, hiện chỉ có `role` String claim trong JWT filter — cần xác nhận claim này là gì trước khi build, xem "Rủi ro").
- `com.brandhub.business.model.enums.MemberRole` — đã có (`OWNER, MANAGER, ACCOUNT, CREATOR, CLIENT`).
- `com.brandhub.business.model.enums.SystemRole` — đã có (`ADMIN, USER`), dùng cho bypass check.
- `WorkspaceMemberRepository` — đã có `findFirstByUserIdAndIsActiveTrue`; cần thêm `findByWorkspaceIdAndUserIdAndIsActiveTrue`.
- Mới: `security/annotation/RequireRole.java` (annotation), `security/aspect/RequireRoleAspect.java` (AOP, Spring AOP + `@Aspect`), `exception/ForbiddenException.java` (nếu chưa có exception 403 chuẩn — kiểm tra `exception/` package trước khi tạo mới).
- Mới: `security/WorkspaceIsolationHelper.java` (hoặc JPA `Specification` base) cho isolation filter.
- `config/SecurityConfig.java` — bật `@EnableMethodSecurity` nếu dùng route Spring Security `@PreAuthorize`; **quyết định dùng AOP tự viết thay vì `@PreAuthorize`** vì cần logic custom (re-check DB theo workspaceId, không chỉ role string) — xem quyết định kiến trúc bên dưới.

## Quyết định kiến trúc
- **AOP annotation tự viết (`@RequireRole` + `@Aspect`)** thay vì `@PreAuthorize` SpEL — vì cần trỏ tới DB thay vì tin JWT claim (re-check theo Edge Case đã spec), và cần cả 2 check (role + isolation) trong 1 chỗ.
- Aspect chạy trước method body, đọc `AuthenticatedUser` từ `SecurityContextHolder`, query `WorkspaceMemberRepository.findByWorkspaceIdAndUserIdAndIsActiveTrue(authUser.getWorkspaceId(), authUser.getId())`. Không tìm thấy → 403. Tìm thấy nhưng role không nằm trong `@RequireRole` value → check `WorkspaceMemberPermissionRepository` override → còn không có override → 403.
- SystemRole ADMIN check trước tiên (từ `UserSystemRoleRepository` — cần tạo repo này nếu chưa có, xác nhận trong bước build).

## Thứ tự build
1. Xác nhận `UserSystemRoleRepository` tồn tại chưa (grep) — nếu chưa, tạo repo đơn giản `findByUserId`.
2. Tạo `WorkspaceMemberRepository.findByWorkspaceIdAndUserIdAndIsActiveTrue`.
3. Tạo exception `ForbiddenException` (nếu chưa có pattern tương đương) + wire vào `GlobalExceptionHandler` (tìm handler hiện tại trước, không tạo trùng) trả đúng shape `ApiResponse.error(code, message, requestId)`.
4. Tạo `@RequireRole` annotation (`@Target(METHOD)`, value = `MemberRole[]`).
5. Tạo `RequireRoleAspect` — `@Around` hoặc `@Before` advice, implement logic quyết định kiến trúc ở trên.
6. Đăng ký AOP (`@EnableAspectJAutoProxy` nếu Spring Boot chưa tự bật — thường tự động khi có `spring-boot-starter-aop`; kiểm tra `pom.xml`/`build.gradle` có dependency chưa).
7. Isolation: viết `WorkspaceIsolationHelper.assertSameWorkspace(UUID resourceWorkspaceId, AuthenticatedUser user)` dùng trong service layer cho các entity không đi qua path `workspaceId` sẵn (vd lookup theo `memberId` rồi so `workspaceId` của record đó).
8. Unit test aspect (mock `AuthenticatedUser`, `WorkspaceMemberRepository`) — allow case, deny role case, deny cross-workspace case, ADMIN bypass case.
9. Áp annotation mẫu lên 1-2 endpoint có sẵn (nếu có) để chứng minh hoạt động thật, không chỉ unit test cô lập.

## Rủi ro
- Chưa xác nhận `role` claim trong JWT hiện tại lấy từ đâu (`User.role` String tự do, hay `SystemRole`, hay `MemberRole`) — cần đọc `JwtUtil`/`AuthServiceImpl` trước khi code. Đã chọn hướng "luôn query DB, không tin claim cho authorization" ở Edge Case nên rủi ro này giảm.
- `@EnableAspectJAutoProxy`/AOP dependency có thể chưa có trong `pom.xml` — cần thêm `spring-boot-starter-aop` nếu thiếu.
- Áp `@RequireRole` lên toàn bộ codebase hiện tại là thủ công (chưa có convention enforce tự động) — rủi ro sót endpoint, ghi rõ trong DoD là review checklist thủ công, không tool tự động ở phase này.
