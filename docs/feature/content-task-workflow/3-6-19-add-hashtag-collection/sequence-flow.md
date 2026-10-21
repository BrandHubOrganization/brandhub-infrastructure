# Sequence Flow — Add Hastag Collection

> Supplements `spec.md` (FR 3.6.19). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Add Hastag Collection Page`.
- **System** — `HashtagController` / `HashtagService`.

---

## Flow A — Luồng thực thi chính: Add Hastag Collection

1. hashtagservice -> hashtagservice: `Validate purpose and Client-owned required scope`
2. hashtagservice -> hashtagservice: `Normalize submitted tag`
3. hashtagservice -> hashtagservice: `Check session, scope and add permission`
4. hashtagservice -> hashtagservice: `Commit / rollback`
5. creatorclientmanager -> webdashboard: `Submit tag, purpose and optional required scope`
6. webdashboard -> hashtagcontroller: `POST /api/v1/workspaces/{workspaceId}/hashtags`
7. hashtagcontroller -> hashtagservice: `createHashtag(user, command)`
8. hashtagservice -> workspacerepository: `Load workspace`
9. workspacerepository --> hashtagservice: `Workspace`
10. hashtagservice -> workspacememberrepos: `Load membership`
11. workspacememberrepos --> hashtagservice: `WorkspaceMember`
12. hashtagservice -> agencyrepository: `Load agency`
13. agencyrepository --> hashtagservice: `Agency`
14. hashtagservice -> hashtagrepository: `Find normalized-tag match`
15. hashtagrepository --> hashtagservice: `Hashtag`
16. hashtagservice --> hashtagcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
17. hashtagcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
18. webdashboard --> creatorclientmanager: `Display access or resource error`
19. hashtagservice --> hashtagcontroller: `400 Bad Request / 409 Conflict`
20. hashtagcontroller --> webdashboard: `400 Bad Request / 409 Conflict`
21. webdashboard --> creatorclientmanager: `Display validation error / HASHTAG_ALREADY_EXISTS`
22. hashtagservice -> hashtagrepository: `Insert unique tag and creator/time`
23. hashtagrepository --> hashtagservice: `writeOutcome`
24. hashtagservice --> hashtagcontroller: `201 Created`
25. hashtagcontroller --> webdashboard: `201 Created`
26. webdashboard --> creatorclientmanager: `Display new collection entry`
27. webdashboard --> creatorclientmanager: `Display duplicate conflict or save error`
28. hashtagservice --> hashtagcontroller: `409 Conflict / 500 Internal Server Error`
29. hashtagcontroller --> webdashboard: `409 Conflict / 500 Internal Server Error`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
