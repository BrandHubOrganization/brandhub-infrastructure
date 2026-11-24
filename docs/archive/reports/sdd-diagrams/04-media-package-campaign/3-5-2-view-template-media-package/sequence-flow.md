# Sequence Flow — View the template Media package

> Supplements `spec.md` (FR 3.5.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **WorkspaceMember** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `WorkspacePackageUI`.
- **System** — `MediaPackageController` / `MediaPackageService`.

---

## Flow A — Luồng thực thi chính: View the template Media package

1. workspacepackageui -> mediapackagecontroll: `GET /api/v1/workspaces/{workspaceId}/media-packages`
2. workspacemember -> workspacepackageui: `navigates to workspace media package tab`
3. mediapackagecontroll -> mediapackageservice: `listAvailablePackages(workspaceId)`
4. mediapackageservice -> mediapackagereposito: `findAllByAgencyIdAndIsTemplateFalseAndAvailableToWorkspacesTrueOrderByCreatedAtDesc(agencyId)`
5. mediapackagereposito --> mediapackageservice: `availablePackages`
6. mediapackageservice --> mediapackagecontroll: `List<MediaPackageResponse>`
7. mediapackagecontroll --> workspacepackageui: `200 OK (availablePackages)`
8. workspacepackageui --> workspacemember: `render available agency packages catalog`
9. workspacepackageui ->> mediapackagecontroll: `GET /api/v1/workspaces/{workspaceId}/media-package`
10. workspacemember ->> workspacepackageui: `views selected package details`
11. mediapackagecontroll ->> mediapackageservice: `getWorkspacePackage(workspaceId)`
12. mediapackageservice ->> workspacemediapackag: `findByWorkspaceId(workspaceId)`
13. workspacemediapackag --> mediapackageservice: `Optional.empty()`
14. mediapackageservice --> mediapackagecontroll: `null`
15. mediapackagecontroll --> workspacepackageui: `200 OK (data: null)`
16. workspacepackageui --> workspacemember: `show informative empty state ('No package selected yet') & prompt Client action`
17. workspacemediapackag --> mediapackageservice: `workspacePackage`
18. mediapackageservice ->> mediapackagereposito: `findById(packageId)`
19. mediapackagereposito --> mediapackageservice: `mediaPackage`
20. mediapackageservice --> mediapackagecontroll: `WorkspaceMediaPackageResponse (status, finalTerms, termsVersion, approvals)`
21. mediapackagecontroll --> workspacepackageui: `200 OK (WorkspaceMediaPackageResponse)`
22. workspacepackageui --> workspacemember: `render package summary (type, budget/duration, terms version, negotiation status)`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
