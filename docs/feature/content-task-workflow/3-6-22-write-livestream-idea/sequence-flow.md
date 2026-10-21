# Sequence Flow — Write Livestream Idea

> Supplements `spec.md` (FR 3.6.22). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Manager / Creator** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskDetailPage (UI)`.
- **System** — `LivestreamTaskController` / `LivestreamTaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: Write Livestream Idea

1. managercreator -> taskdetailpageui: `Fill in Livestream Idea & Target Goal, click "Save Idea"`
2. taskdetailpageui -> livestreamtaskcontro: `PATCH /api/v1/workspaces/{wId}/tasks/{taskId}/livestream/idea { "idea": "...", "goal": "..." }`
3. livestreamtaskcontro -> livestreamtaskservic: `saveLivestreamIdea(workspaceId, taskId, ideaRequest, currentUser)`
4. livestreamtaskservic -> taskrepository: `findByIdAndWorkspaceId(taskId, workspaceId)`
5. taskrepository --> livestreamtaskservic: `return Optional<Task>`
6. livestreamtaskservic --> livestreamtaskcontro: `throw TASK_NOT_FOUND (404 Not Found)`
7. livestreamtaskcontro --> taskdetailpageui: `return 404 Not Found (Task not found in workspace)`
8. taskdetailpageui --> managercreator: `Display error: "Task not found in workspace"`
9. livestreamtaskservic --> livestreamtaskcontro: `throw INVALID_TASK_TYPE (400 Bad Request)`
10. livestreamtaskcontro --> taskdetailpageui: `return 400 Bad Request (Task must be of type Livestream)`
11. taskdetailpageui --> managercreator: `Display error message: "Task must be of type Livestream"`
12. livestreamtaskservic --> livestreamtaskcontro: `throw INVALID_PAYLOAD (400 Bad Request)`
13. livestreamtaskcontro --> taskdetailpageui: `return 400 Bad Request (Idea description or goal cannot be blank)`
14. taskdetailpageui --> managercreator: `Display validation message: "Idea description or goal cannot be blank"`
15. livestreamtaskservic -> livestreamtaskservic: `updateLivestreamIdea(task, ideaRequest.getIdea(), ideaRequest.getGoal())`
16. livestreamtaskservic -> taskrepository: `save(task)`
17. taskrepository --> livestreamtaskservic: `return savedTask`
18. livestreamtaskservic -> livestreamidearespon: `toLivestreamIdeaResponse(savedTask)`
19. livestreamidearespon --> livestreamtaskservic: `return ideaResponse`
20. livestreamtaskservic --> livestreamtaskcontro: `return ideaResponse`
21. livestreamtaskcontro --> taskdetailpageui: `return 200 OK (Updated idea, goal, and task status)`
22. taskdetailpageui --> managercreator: `Display notification: "Livestream idea saved successfully" & enable Script tab`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
