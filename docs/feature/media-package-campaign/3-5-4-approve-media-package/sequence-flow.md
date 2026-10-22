# Sequence Flow — Approve Media  package

> Supplements `spec.md` (FR 3.5.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **nUser (Client / Agency)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `WorkspacePackageUI`.
- **System** — `MediaPackageController` / `MediaPackageService`.

---

## Flow A — Luồng thực thi chính: Approve Media  package

1. nuserclientagency -> workspacepackageui: `reviews negotiated terms and clicks "Approve Package"`
2. workspacepackageui -> mediapackagecontroll: `POST /api/v1/workspaces/{workspaceId}/media-package/approve`
3. mediapackageservice -> mediapackageservice: `set negotiationStatus = APPROVED`
4. mediapackageservice -> mediapackageservice: `set approvedByAgencyAt = now`
5. mediapackageservice -> mediapackageservice: `set approvedByClientAt = now`
6. mediapackagecontroll -> mediapackageservice: `approvePackage(workspaceId, currentUser)`
7. mediapackageservice -> workspacemediapackag: `findByWorkspaceIdForUpdate(workspaceId)`
8. workspacemediapackag --> mediapackageservice: `workspacePackage`
9. workspacemediapackag -> mediapackagereposito: `findById(packageId)`
10. mediapackagereposito --> workspacemediapackag: `mediaPackage`
11. workspacemediapackag --> mediapackageservice: `WorkspaceMediaPackageResponse (status: APPROVED)`
12. mediapackageservice --> mediapackagecontroll: `200 OK (already approved)`
13. mediapackagecontroll --> workspacepackageui: `show notice ('Package is already fully approved')`
14. mediapackageservice --> mediapackagecontroll: `throw BusinessException (403 WORKSPACE_ACCESS_DENIED)`
15. mediapackagecontroll --> workspacepackageui: `403 Forbidden (WORKSPACE_ACCESS_DENIED)`
16. workspacepackageui --> nuserclientagency: `show error toast ('Access denied')`
17. mediapackageservice ->> workspacemediapackag: `save(workspacePackage)`
18. workspacemediapackag --> mediapackageservice: `savedPackage`
19. mediapackageservice ->> mediapackagereposito: `findById(packageId)`
20. mediapackagereposito --> mediapackageservice: `mediaPackage`
21. mediapackageservice --> mediapackagecontroll: `WorkspaceMediaPackageResponse (one approval timestamp set)`
22. mediapackagecontroll --> workspacepackageui: `200 OK (one approval timestamp recorded)`
23. workspacepackageui --> nuserclientagency: `show toast ('Approved terms version. Awaiting second party confirmation')`
24. mediapackageservice ->> workspacemediapackag: `save(workspacePackage)`
25. workspacemediapackag --> mediapackageservice: `savedPackage`
26. mediapackageservice ->> mediapackagereposito: `findById(packageId)`
27. mediapackagereposito --> mediapackageservice: `mediaPackage`
28. mediapackageservice --> mediapackagecontroll: `WorkspaceMediaPackageResponse (status: APPROVED)`
29. mediapackagecontroll --> workspacepackageui: `200 OK (status: APPROVED)`
30. workspacepackageui --> nuserclientagency: `show success modal ('Media Package fully approved! Ready to create Campaign')`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
