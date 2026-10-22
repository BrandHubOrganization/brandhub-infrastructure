# Sequence Flow — Apply Hastag

> Supplements `spec.md` (FR 3.6.17). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Apply Hastag Page`.
- **System** — `HashtagController` / `HashtagService`.

---

## Flow A — Luồng thực thi chính: Apply Hastag

1. hashtagservice -> hashtagservice: `Check active tags, version and required scope`
2. hashtagservice -> hashtagservice: `Check CREATOR and destination rights`
3. hashtagservice -> hashtagservice: `Merge tags; keep snapshots`
4. hashtagservice -> hashtagservice: `Resolve coordinated writeOutcome`
5. creator -> webdashboard: `Select hashtags and Apply to Post`
6. webdashboard -> hashtagcontroller: `PATCH /api/v1/workspaces/{workspaceId}/tasks/{taskId}/hashtags`
7. hashtagcontroller -> hashtagservice: `applyHashtags(user, command)`
8. hashtagservice -> workspacerepository: `Load workspace`
9. workspacerepository --> hashtagservice: `Workspace`
10. hashtagservice -> workspacememberrepos: `Load membership`
11. workspacememberrepos --> hashtagservice: `WorkspaceMember`
12. hashtagservice -> agencyrepository: `Load agency`
13. agencyrepository --> hashtagservice: `Agency`
14. hashtagservice -> hashtagrepository: `Load selected tags and required scope`
15. hashtagrepository --> hashtagservice: `Hashtag`
16. hashtagservice --> hashtagcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
17. hashtagcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
18. webdashboard --> creator: `Display access or resource error`
19. hashtagservice --> hashtagcontroller: `400 Bad Request / 409 Conflict`
20. hashtagcontroller --> webdashboard: `400 Bad Request / 409 Conflict`
21. webdashboard --> creator: `Display apply rejected; no partial save`
22. hashtagservice -> taskhashtagrepositor: `Save usage snapshots (proposed)`
23. taskhashtagrepositor --> hashtagservice: `snapshotOutcome`
24. hashtagservice --> hashtagcontroller: `200 OK`
25. hashtagcontroller --> webdashboard: `200 OK`
26. webdashboard --> creator: `Display updated Post hashtag preview`
27. hashtagservice --> hashtagcontroller: `409 Conflict / 500 Internal Server Error`
28. hashtagcontroller --> webdashboard: `409 Conflict / 500 Internal Server Error`
29. webdashboard --> creator: `Display Apply failure; retain previous selection`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
