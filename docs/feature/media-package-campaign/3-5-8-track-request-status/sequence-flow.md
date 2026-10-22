# Sequence Flow — Track Request Status

> Supplements `spec.md` (FR 3.5.8). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Mânger** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `ContentRequestPage (UI)`.
- **System** — `ContentRequestController` / `ContentRequestService`.

---

## Flow A — Luồng thực thi chính: Track Request Status

1. mnger -> contentrequestpageui: `navigates to Content Requests board / list`
2. contentrequestcontro -> contentrequestservic: `getContentRequests(workspaceId, userId, queryParams)`
3. contentrequestservic -> contentrequestservic: `claimAcceptanceAtomic(workspaceId, requestId)`
4. contentrequestpageui -> contentrequestcontro: `GET /api/v1/workspaces/{workspaceId}/content-requests (queryParams: page, limit, status, headers: Bearer accessToken)`
5. contentrequestservic -> contentrequestreposi: `findByWorkspaceId(workspaceId, queryParams)`
6. contentrequestreposi --> contentrequestservic: `requestPage`
7. contentrequestservic --> contentrequestcontro: `ContentRequestPageResponse`
8. contentrequestpageui --> mnger: `render requests list with status badges (PENDING, IN_PROGRESS, ACCEPTED, DENIED)`
9. contentrequestcontro --> contentrequestpageui: `200 OK (ContentRequestPageResponse)`
10. mnger ->> contentrequestpageui: `selects request & clicks "Update Status" (e.g. IN_PROGRESS or ACCEPTED)`
11. contentrequestcontro ->> contentrequestservic: `updateContentRequestStatus(workspaceId, requestId, userId, payload)`
12. contentrequestpageui ->> contentrequestcontro: `PATCH /api/v1/workspaces/{workspaceId}/content-requests/{requestId}/status (UpdateStatusPayload(targetStatus, note), headers: Bearer accessToken)`
13. contentrequestservic -> contentrequestservic: `validateManagerRole(workspaceId, userId)`
14. contentrequestservic --> contentrequestcontro: `throw AccessDeniedException (403 Forbidden)`
15. contentrequestcontro --> contentrequestpageui: `403 Forbidden (MANAGER_ROLE_REQUIRED)`
16. contentrequestpageui --> mnger: `show error toast ('Only agency managers can update request status')`
17. contentrequestservic ->> contentrequestreposi: `findByWorkspaceIdAndId(workspaceId, requestId)`
18. contentrequestreposi --> contentrequestservic: `request`
19. contentrequestservic --> contentrequestcontro: `throw ResourceNotFoundException (404 Not Found)`
20. contentrequestcontro --> contentrequestpageui: `404 Not Found (REQUEST_NOT_FOUND)`
21. contentrequestpageui --> mnger: `show error toast ('Content request not found')`
22. contentrequestservic --> contentrequestcontro: `throw IllegalStateException (409 Conflict)`
23. contentrequestcontro --> contentrequestpageui: `409 Conflict (TERMINAL_STATE_CANNOT_BE_REOPENED)`
24. contentrequestpageui --> mnger: `show error modal ('Terminal state cannot be reopened')`
25. contentrequestservic ->> contentrequestreposi: `updateStatus(workspaceId, requestId, IN_PROGRESS, note)`
26. contentrequestreposi --> contentrequestservic: `updatedRequest`
27. contentrequestservic --> contentrequestcontro: `ContentRequestResponse (status=IN_PROGRESS)`
28. contentrequestcontro --> contentrequestpageui: `200 OK (ContentRequestResponse)`
29. contentrequestpageui --> mnger: `update badge to IN_PROGRESS & show success toast`
30. contentrequestservic ->> contentrequestreposi: `updateStatus(workspaceId, requestId, ACCEPTED)`
31. contentrequestreposi --> contentrequestservic: `acceptedRequest`
32. contentrequestservic ->> taskrepository: `createBacklogTask(workspaceId, campaignId=null, title, description, type, dueDate, sourceType=CONTENT_REQUEST, sourceRefId=requestId)`
33. taskrepository --> contentrequestservic: `createdTask`
34. contentrequestservic ->> contentrequestreposi: `setGeneratedTaskId(requestId, createdTask.id)`
35. contentrequestreposi --> contentrequestservic: `finalizedRequest`
36. contentrequestservic --> contentrequestcontro: `ContentRequestResponse (status=ACCEPTED, generatedTaskId=createdTask.id)`
37. contentrequestcontro --> contentrequestpageui: `200 OK (ContentRequestResponse)`
38. contentrequestpageui --> mnger: `update badge to ACCEPTED, display linked task link & show success toast`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
