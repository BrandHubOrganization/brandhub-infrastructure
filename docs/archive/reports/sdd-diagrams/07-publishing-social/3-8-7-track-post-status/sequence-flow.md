# Sequence Flow — Track Post Status

> Supplements `spec.md` (FR 3.8.7). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `PostStatusBadge / TrackingModal (UI)`.
- **System** — `PostController` / `PostServiceImpl`.

---

## Flow A — Luồng thực thi chính: Track Post Status

1. creatormanager -> poststatusbadgetrack: `Click "View Publishing Status" on Post card`
2. poststatusbadgetrack -> postcontroller: `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/status`
3. postcontroller -> postserviceimpl: `getPostPublishStatus(workspaceId, postId)`
4. postserviceimpl -> postmongorepository: `findByIdAndWorkspaceId(postId, workspaceId)`
5. postmongorepository --> postserviceimpl: `return PostDocument (status, failReason, updatedAt, targetPlatforms)`
6. postserviceimpl -> postserviceimpl: `mapToStepperProgress(postDoc.getStatus())`
7. postserviceimpl -> poststatustrackingre: `new PostStatusTrackingResponse(status, currentStep, failReason, targetPlatforms, updatedAt)`
8. poststatustrackingre --> postserviceimpl: `return trackingData`
9. postserviceimpl --> postcontroller: `return trackingData`
10. postcontroller --> poststatusbadgetrack: `return 200 OK (ApiResponse { data: trackingData })`
11. poststatusbadgetrack --> creatormanager: `Render status stepper badge (Pending → In Progress → Done / Fail)`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
