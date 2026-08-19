# Task — Owner/Account Team Analytics Dashboard

## Backend
- [ ] 1. `AuditLogRepository`: thêm `findByWorkspaceIdOrderByCreatedAtDesc`,
      `findByWorkspaceIdInOrderByCreatedAtDesc`.
- [ ] 2. `WorkspaceMemberRepository`: thêm `countByWorkspaceIdAndIsActiveTrue`
      (grep trước xác nhận chưa trùng tên).
- [ ] 3. Tạo `dto/response/AuditLogResponse.java`.
- [ ] 4. Tạo `dto/response/ManagedAuditLogResponse.java`.
- [ ] 5. Tạo `dto/response/ManagedWorkspaceResponse.java`.
- [ ] 6. `WorkspaceService.java`: thêm 3 method signature mới.
- [ ] 7. `WorkspaceServiceImpl.java`: implement `listAuditLogs`,
      `listManagedWorkspaces`, `listManagedAuditLogs` (batch load user/workspace
      tránh N+1, giống pattern `listMembers` có sẵn).
- [ ] 8. `WorkspaceController.java`: thêm `/my-managed`,
      `/my-managed/audit-logs` NGAY SAU `listMyWorkspaces()`, TRƯỚC
      `getWorkspace()` — đúng thứ tự route matching. Thêm
      `/{workspaceId}/audit-logs` sau `/{workspaceId}/members`.
- [ ] 9. Unit test 4 case theo plan.md mục 6.
- [ ] 10. `mvn -o compile` xanh, `mvn -o test` pass toàn bộ (không riêng file
       mới).

## Frontend
- [ ] 11. `types/workspace.ts`: thêm `AuditLogEntry`, `ManagedAuditLogEntry`,
       `ManagedWorkspace`, `PageResponse<T>`.
- [ ] 12. `workspaceService.ts`: thêm `listAuditLogs`, `listManagedWorkspaces`,
       `listManagedAuditLogs`.
- [ ] 13. `Sidebar.tsx`: ẩn section Sáng tạo khi `role === "OWNER"`. Thêm mục
       "Tổng quan" → `/analytics/overview` cho OWNER/ACCOUNT, không phụ thuộc
       `activeWorkspace`.
- [ ] 14. `AnalyticsPage.tsx`: lấy role hiện tại qua `listMembers`, render 4
       khối mới nếu OWNER/ACCOUNT (bảng member, số liệu role — data thật;
       audit log — data thật; cống hiến — mock, comment rõ demo data).
- [ ] 15. Tạo `AnalyticsOverviewPage.tsx`: list workspace + tổng số liệu +
       audit log gộp (data thật) + cống hiến mock mỗi workspace. Xử lý rỗng
       khi user không quản lý workspace nào.
- [ ] 16. `App.tsx`: thêm route `/analytics/overview` (AuthGuard + Layout).
- [ ] 17. i18n: thêm `nav.overview`, `analytics.team.*` (10 key),
       `analytics.overview.*` (7 key) vào `vi.json` + `en.json`, key-parallel.
- [ ] 18. `npx tsc --noEmit` sạch.
- [ ] 19. `npx eslint` trên các file đã sửa sạch.

## Verify
- [ ] 20. Restart business-service load endpoint mới.
- [ ] 21. Test theo `test.md` case 1-9 qua Chrome DevTools.
- [ ] 22. Xác nhận route ordering đúng — gọi `GET /workspaces/my-managed`
       KHÔNG bị lỗi UUID parse (test case dễ bỏ sót nhất).
