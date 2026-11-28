# Sequence Flow — Cancel Request

> Supplements `spec.md` (FR 3.5.10). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Client** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `CancelRequestModal (UI)`.
- **System** — `ContentRequestController` / `ContentRequestService`.

---

## Flow A — Luồng thực thi chính: Cancel Request

1. client -> cancelrequestmodalui: `clicks "Cancel Request" & confirms modal dialog`
2. cancelrequestmodalui -> contentrequestcontro: `DELETE /api/v1/workspaces/{workspaceId}/content-requests/{requestId} (headers: Bearer accessToken)`
3. contentrequestcontro -> contentrequestservic: `cancelContentRequest(workspaceId, requestId, userId)`
4. contentrequestservic -> contentrequestreposi: `findByWorkspaceIdAndId(workspaceId, requestId)`
5. contentrequestreposi --> contentrequestservic: `request`
6. contentrequestservic --> contentrequestcontro: `throw ResourceNotFoundException (404 Not Found)`
7. contentrequestcontro --> cancelrequestmodalui: `404 Not Found (REQUEST_NOT_FOUND)`
8. cancelrequestmodalui --> client: `show error toast ('Content request not found')`
9. contentrequestservic --> contentrequestcontro: `throw AccessDeniedException (403 Forbidden)`
10. contentrequestcontro --> cancelrequestmodalui: `403 Forbidden (FORBIDDEN_REQUEST_OWNERSHIP)`
11. cancelrequestmodalui --> client: `show error toast ('Forbidden: Only the requesting client can cancel this request')`
12. contentrequestservic --> contentrequestcontro: `throw BusinessConflictException (409 REQUEST_NOT_CANCELLABLE)`
13. contentrequestcontro --> cancelrequestmodalui: `409 Conflict (REQUEST_NOT_CANCELLABLE)`
14. cancelrequestmodalui --> client: `show error modal ('Cannot cancel: request is already processed or completed')`
15. contentrequestservic ->> contentrequestreposi: `findAndModifyCancel(workspaceId, requestId)`
16. contentrequestreposi --> contentrequestservic: `null (0 modified)`
17. contentrequestservic --> contentrequestcontro: `throw BusinessConflictException (409 REQUEST_NOT_CANCELLABLE)`
18. contentrequestcontro --> cancelrequestmodalui: `409 Conflict (REQUEST_NOT_CANCELLABLE)`
19. cancelrequestmodalui --> client: `show error toast ('Cancellation failed: request status was modified concurrently')`
20. contentrequestreposi --> contentrequestservic: `cancelledRequest`
21. contentrequestservic --> contentrequestcontro: `ContentRequestResponse (status=CANCELLED)`
22. contentrequestcontro --> cancelrequestmodalui: `200 OK (ContentRequestResponse)`
23. cancelrequestmodalui --> client: `show success toast ('Content request cancelled successfully') & disable actions`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
