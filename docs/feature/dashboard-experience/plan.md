# Plan
1. Query cache theo user/Agency, load nguồn độc lập, billing/members chỉ Owner, lọc đúng Agency.
2. Shared Workspace list + Task phân trang 20; không tải tất cả Workspace/Task để tính KPI.
3. Tab cá nhân có dữ liệu, fallback logo, compact invitations/profile, bỏ nhật ký giả.
4. Cập nhật vi/dashboard.json + en/dashboard.json; Skeleton/Select/Button và theme token.
5. CI Web; QA read-only local nếu môi trường sẵn sàng; ghi rõ hạn chế, không commit local-only.

## Workspace overview extension
Use RoleWorkspaceOverview with TanStack Query and existing task/campaign services. Retain the publishing screen/header via a compact footer action; suppress redundant legacy overview requests. Order task rows by overdue/review/active/closed. Reuse task deep links and approval routes. Add parallel vi/workspace.json and en/workspace.json keys. No migration or new dependencies.
