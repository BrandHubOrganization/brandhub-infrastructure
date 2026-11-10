# Sequence Flow — Create Survey

> Supplements `spec.md` (FR 3.6.25). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Manager / Creator** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskDetailPage (UI)`.
- **System** — `LivestreamTaskController` / `LivestreamTaskServiceImpl`.

---

## Flow A — Luồng thực thi chính: Create Survey

1. managercreator -> taskdetailpageui: `Configure questions (type, label, options, timeSlot), title, and click "Create Survey"`
2. taskdetailpageui -> livestreamtaskcontro: `POST /api/v1/workspaces/{wId}/tasks/{taskId}/survey { "title": "...", "questions": [...] }`
3. livestreamtaskcontro -> livestreamtaskservic: `createSurvey(workspaceId, taskId, createSurveyRequest, currentUser)`
4. livestreamtaskservic -> taskrepository: `findByIdAndWorkspaceId(taskId, workspaceId)`
5. taskrepository --> livestreamtaskservic: `return Optional<Task>`
6. livestreamtaskservic --> livestreamtaskcontro: `throw TASK_NOT_FOUND (404 Not Found)`
7. livestreamtaskcontro --> taskdetailpageui: `return 404 Not Found (Task not found in workspace)`
8. taskdetailpageui --> managercreator: `Display error message: "Task not found in workspace"`
9. livestreamtaskservic --> livestreamtaskcontro: `throw INVALID_TASK_TYPE (400 Bad Request)`
10. livestreamtaskcontro --> taskdetailpageui: `return 400 Bad Request (Task must be of type Survey)`
11. taskdetailpageui --> managercreator: `Display error message: "Task must be of type Livestream"`
12. livestreamtaskservic --> livestreamtaskcontro: `throw SURVEY_MUST_HAVE_QUESTIONS`
13. livestreamtaskcontro --> taskdetailpageui: `return 400 Bad Request (Survey must contain at least one question)`
14. taskdetailpageui --> managercreator: `Display error: "Cannot transition from current status to requested status"`
15. livestreamtaskservic -> livestreamtaskservic: `buildSurveyEntity(task, createSurveyRequest)`
16. livestreamtaskservic -> surveyrepository: `save(newSurvey)`
17. surveyrepository --> livestreamtaskservic: `return savedSurvey`
18. livestreamtaskservic -> taskrepository: `linkSurvey(taskId, savedSurvey.getId())`
19. taskrepository --> livestreamtaskservic: `return savedTask`
20. livestreamtaskservic -> livestreamidearespon: `toLivestreamStatusResponse(savedTask)`
21. livestreamidearespon --> livestreamtaskservic: `return statusResponse`
22. livestreamtaskservic --> livestreamtaskcontro: `return statusResponse`
23. livestreamtaskcontro --> taskdetailpageui: `return 200 OK (Updated livestream status)`
24. taskdetailpageui --> managercreator: `Update Stepper badge, refresh active state controls (e.g. enable Submit for Approval if DONE)`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
