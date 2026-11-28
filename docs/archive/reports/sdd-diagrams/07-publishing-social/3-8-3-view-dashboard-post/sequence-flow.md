# Sequence Flow — View Dashboard Post

> Supplements `spec.md` (FR 3.8.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **«Actor»
Member / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `PostDashboardResponse`.
- **System** — `PostController` / `PostServiceImpl`.

---

## Flow A — Luồng thực thi chính: View Dashboard Post

1. actormembermanager -> postdashboardpageui: `Navigate to "Post Dashboard" menu`
2. postdashboardpageui -> postcontroller: `GET /api/v1/workspaces/{workspaceId}/posts/dashboard`
3. postcontroller -> postserviceimpl: `3: getDashboardMetrics(workspaceId)`
4. postserviceimpl -> postmongorepository: `countByWorkspaceIdAndStatus(workspaceId, 'PUBLISHED')`
5. postmongorepository --> postserviceimpl: `return totalPublishedCount`
6. postserviceimpl -> postmongorepository: `aggregateByPlatform(workspaceId)`
7. postmongorepository --> postserviceimpl: `return platformBreakdownMap`
8. postserviceimpl -> postmongorepository: `calculatePublishSuccessRate(workspaceId)`
9. postmongorepository --> postserviceimpl: `return successRatePercentage`
10. postserviceimpl -> postdashboardrespons: `new PostDashboardResponse(totalPublishedCount, platformBreakdownMap, successRatePercentage)`
11. postdashboardrespons --> postserviceimpl: `return dashboardData`
12. postserviceimpl --> postcontroller: `return dashboardData`
13. postcontroller --> postdashboardpageui: `return 200 OK (ApiResponse { data: dashboardData })`
14. postdashboardpageui --> actormembermanager: `Render overview KPI cards, charts, and platform breakdown`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
