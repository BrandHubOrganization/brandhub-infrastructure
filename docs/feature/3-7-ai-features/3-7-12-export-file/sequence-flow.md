# Sequence Flow — Export File

> Supplements `spec.md` (FR 3.7.8). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Export File Page`.
- **System** — `AiAssetController` / `AiAssetService`.

---

## Flow A — Luồng thực thi chính: Export File

1. aiassetservice -> aiassetservice: `Validate access, permissions and format compatibility`
2. creator -> webdashboard: `Choose asset and export format`
3. webdashboard -> aiassetcontroller: `GET /api/v1/ai/assets/{assetId}/export?format={format}`
4. aiassetcontroller -> aiassetservice: `exportAsset(user, command)`
5. aiassetservice -> workspacerepository: `Load workspace access`
6. workspacerepository --> aiassetservice: `Workspace`
7. aiassetservice -> generatedassetreposi: `Load asset metadata`
8. generatedassetreposi --> aiassetservice: `GeneratedAsset`
9. aiassetservice --> aiassetcontroller: `400 Bad Request / 403 Forbidden / 404 Not Found`
10. aiassetcontroller --> webdashboard: `400 Bad Request / 403 Forbidden / 404 Not Found`
11. webdashboard --> creator: `Display access or format error`
12. aiassetservice -> s3storageconverter: `Read source bytes and convert format`
13. s3storageconverter --> aiassetservice: `exportOutcome`
14. aiassetservice --> aiassetcontroller: `503 Service Unavailable`
15. aiassetcontroller --> webdashboard: `503 Service Unavailable`
16. webdashboard --> creator: `Display export error`
17. aiassetservice --> aiassetcontroller: `200 OK`
18. aiassetcontroller --> webdashboard: `200 OK`
19. webdashboard --> creator: `Display export download started`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
