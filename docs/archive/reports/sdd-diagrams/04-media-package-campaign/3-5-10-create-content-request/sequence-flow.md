# Sequence Flow — Create Content Request

> Supplements `spec.md` (FR 3.5.7). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Client** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `CreateContentRequestModal (UI)`.
- **System** — `ContentRequestController` / `ContentRequestService`.

---

## Flow A — Luồng thực thi chính: Create Content Request

1. client -> createcontentrequest: `enters title, description, type (POST|LIVESTREAM|SURVEY), dueDate & clicks "Submit Request"`
2. createcontentrequest -> contentrequestcontro: `POST /api/v1/workspaces/{workspaceId}/content-requests (CreateContentRequestPayload, headers: Bearer accessToken)`
3. contentrequestservic -> contentrequestservic: `validateWorkspaceClient(workspaceId, userId)`
4. contentrequestservic -> contentrequestservic: `buildContentRequest(workspaceId, userId, payload)`
5. contentrequestcontro -> contentrequestservic: `createContentRequest(workspaceId, userId, payload)`
6. contentrequestservic --> contentrequestcontro: `throw AccessDeniedException (403 Forbidden)`
7. contentrequestcontro --> createcontentrequest: `403 Forbidden (WORKSPACE_ACCESS_DENIED)`
8. createcontentrequest --> client: `show error toast ('Access denied: Only workspace clients can create content requests')`
9. contentrequestservic --> contentrequestcontro: `throw ValidationException (400 Bad Request)`
10. contentrequestcontro --> createcontentrequest: `400 Bad Request (INVALID_CONTENT_REQUEST_PAYLOAD)`
11. createcontentrequest --> client: `display field error messages ('Invalid payload: check required fields and due date')`
12. contentrequestservic ->> contentrequestreposi: `save(contentRequest)`
13. contentrequestreposi --> contentrequestservic: `savedRequest`
14. contentrequestservic --> contentrequestcontro: `ContentRequestResponse (id, workspaceId, title, type, dueDate, status=PENDING, createdAt)`
15. contentrequestcontro --> createcontentrequest: `201 Created (ContentRequestResponse)`
16. createcontentrequest --> client: `show success toast ('Content request submitted as PENDING') & refresh request list`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
