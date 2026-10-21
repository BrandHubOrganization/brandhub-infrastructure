# Sequence Flow — Write Livestream Script

> Supplements `spec.md` (FR 3.6.23). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskDetailPage (UI)`.
- **System** — `LivestreamTaskController` / `LivestreamTaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: Write Livestream Script

1. creator -> taskdetailpageui: `Enter timeline segments (timeMark, content, speaker, shotList) & click "Save Script"`
2. taskdetailpageui -> livestreamtaskcontro: `PATCH /api/v1/workspaces/{wId}/tasks/{taskId}/livestream/script { "segments": [...] }`
3. livestreamtaskcontro -> livestreamtaskservic: `saveLivestreamScript(workspaceId, taskId, scriptRequest, creatorUser)`
4. livestreamtaskservic -> taskrepository: `findByIdAndWorkspaceId(taskId, workspaceId)`
5. taskrepository --> livestreamtaskservic: `return Optional<Task>`
6. livestreamtaskservic --> livestreamtaskcontro: `throw TASK_NOT_FOUND (404 Not Found)`
7. livestreamtaskcontro --> taskdetailpageui: `return 404 Not Found (Task not found in workspace)`
8. taskdetailpageui --> creator: `Display error: "Task not found in workspace"`
9. livestreamtaskservic --> livestreamtaskcontro: `throw INVALID_TASK_TYPE (400 Bad Request)`
10. livestreamtaskcontro --> taskdetailpageui: `return 400 Bad Request (Task must be of type Livestream)`
11. taskdetailpageui --> creator: `Display error message: "Task must be of type Livestream"`
12. livestreamtaskservic --> livestreamtaskcontro: `throw LIVESTREAM_IDEA_REQUIRED (400 Bad Request)`
13. livestreamtaskcontro --> taskdetailpageui: `return 400 Bad Request (Please complete Livestream Idea first)`
14. taskdetailpageui --> creator: `Display validation warning: "Please complete Livestream Idea before drafting script"`
15. livestreamtaskservic --> livestreamtaskcontro: `throw SCRIPT_CANNOT_BE_EMPTY (400 Bad Request)`
16. livestreamtaskcontro --> taskdetailpageui: `return 400 Bad Request (Livestream script must contain at least one segment)`
17. taskdetailpageui --> creator: `Display validation error: "Livestream script must contain at least one timeline segment"`
18. livestreamtaskservic -> livestreamtaskservic: `updateLivestreamScript(task, scriptRequest.getSegments())`
19. livestreamtaskservic -> taskrepository: `save(task)`
20. taskrepository --> livestreamtaskservic: `return savedTask`
21. livestreamtaskservic -> livestreamidearespon: `toLivestreamScriptResponse(savedTask)`
22. livestreamidearespon --> livestreamtaskservic: `return scriptResponse`
23. livestreamtaskservic --> livestreamtaskcontro: `return scriptResponse`
24. livestreamtaskcontro --> taskdetailpageui: `return 200 OK (Saved timeline segments & cues)`
25. taskdetailpageui --> creator: `Display notification: "Livestream script saved successfully" & update timeline preview`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
