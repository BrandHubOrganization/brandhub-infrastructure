# Task — RBAC Middleware & Isolation

## DA-176 — Viết RBAC annotation/middleware cho business-service (@RequireRole)
- [ ] Grep xác nhận `UserSystemRoleRepository` tồn tại chưa; tạo nếu thiếu.
- [ ] Thêm `WorkspaceMemberRepository.findByWorkspaceIdAndUserIdAndIsActiveTrue`.
- [ ] Tạo `security/annotation/RequireRole.java`.
- [ ] Tạo `security/aspect/RequireRoleAspect.java` (check SystemRole ADMIN bypass → check MemberRole → check permission override).
- [ ] Xác nhận `spring-boot-starter-aop` có trong build file; thêm nếu thiếu.
- [ ] Tạo/confirm `ForbiddenException` + wire `GlobalExceptionHandler` trả `INSUFFICIENT_ROLE` / `WORKSPACE_ACCESS_DENIED`.
- [ ] Unit test: allow (role đúng), deny (role sai), deny (không phải member), ADMIN bypass, permission override granted=false vẫn deny.

## DA-193 — Implement workspace isolation filter (mọi query phải có workspaceId filter)
- [ ] Viết `WorkspaceIsolationHelper.assertSameWorkspace(resourceWorkspaceId, authUser)`.
- [ ] Audit toàn bộ repository method hiện có chạm bảng workspace-scoped — đảm bảo nhận `workspaceId` làm tham số bắt buộc (không có method "get all" bỏ sót).
- [ ] Áp helper vào service layer cho các entity lookup theo id phụ (vd `memberId`) rồi so `workspaceId`.
- [ ] Integration test: user A gọi API lấy resource của workspace B → 403 `WORKSPACE_ACCESS_DENIED`.

## DA-208 — Implement client isolation cho BRAND_CLIENT (chỉ xem data của clientId mình)
- [ ] Xác nhận entity `Client.java` liên kết `workspaceId` + cách map user BRAND_CLIENT ↔ `clientId` (đọc code trước khi build, chưa rõ trong research ban đầu).
- [ ] Mở rộng `@RequireRole`/`WorkspaceIsolationHelper` (hoặc annotation riêng `@RequireOwnClient`) chặn CLIENT xem data client khác trong cùng workspace.
- [ ] Integration test: CLIENT của client X gọi API data client Y (cùng workspace) → 403.

## Chung
- [ ] Review checklist thủ công: liệt kê toàn bộ controller method nghiệp vụ mới/cũ, xác nhận đã gắn `@RequireRole` phù hợp trước khi merge PR.
- [ ] Cập nhật `test.md` sau khi test thực chạy pass.
