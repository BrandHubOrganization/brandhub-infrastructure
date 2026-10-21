# Sequence Flow — Update Request

> Supplements `spec.md` (FR 3.5.9). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Client** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `EditContentRequestModal (UI)`.
- **System** — `ContentRequestController` / `ContentRequestService`.

---

## Flow A — Luồng thực thi chính: Update Request

1. client -> editcontentrequestmo: `edits title and/or description & clicks "Save Changes"`
2. contentrequestcontro -> contentrequestservic: `updateContentRequest(workspaceId, requestId, userId, payload)`
3. editcontentrequestmo -> contentrequestcontro: `PATCH /api/v1/workspaces/{workspaceId}/content-requests/{requestId} (UpdateContentRequestPayload(title, description), headers: Bearer accessToken)`
4. contentrequestservic -> contentrequestreposi: `findByWorkspaceIdAndId(workspaceId, requestId)`
5. contentrequestreposi --> contentrequestservic: `request`
6. contentrequestservic --> contentrequestcontro: `throw ResourceNotFoundException (404 Not Found)`
7. contentrequestcontro --> editcontentrequestmo: `404 Not Found (REQUEST_NOT_FOUND)`
8. editcontentrequestmo --> client: `show error toast ('Content request not found')`
9. contentrequestservic --> contentrequestcontro: `throw AccessDeniedException (403 Forbidden)`
10. contentrequestcontro --> editcontentrequestmo: `403 Forbidden (FORBIDDEN_REQUEST_OWNERSHIP)`
11. editcontentrequestmo --> client: `show error toast ('Forbidden: Only the requesting client can edit this request')`
12. contentrequestservic --> contentrequestcontro: `throw BusinessConflictException (409 REQUEST_NOT_EDITABLE)`
13. contentrequestcontro --> editcontentrequestmo: `409 Conflict (REQUEST_NOT_EDITABLE)`
14. editcontentrequestmo --> client: `show error modal ('Request is no longer pending and cannot be modified')`
15. contentrequestservic ->> contentrequestreposi: `findAndModifyPending(workspaceId, requestId, payload.title, payload.description)`
16. contentrequestreposi --> contentrequestservic: `null (0 modified)`
17. contentrequestservic --> contentrequestcontro: `throw BusinessConflictException (409 REQUEST_NOT_EDITABLE)`
18. contentrequestcontro --> editcontentrequestmo: `409 Conflict (REQUEST_NOT_EDITABLE)`
19. editcontentrequestmo --> client: `show error toast ('Conflict: Manager changed request status concurrently')`
20. contentrequestreposi --> contentrequestservic: `updatedRequest`
21. contentrequestservic --> contentrequestcontro: `ContentRequestResponse (updatedRequest)`
22. contentrequestcontro --> editcontentrequestmo: `200 OK (ContentRequestResponse)`
23. editcontentrequestmo --> client: `show success toast ('Request updated successfully') & refresh details`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
