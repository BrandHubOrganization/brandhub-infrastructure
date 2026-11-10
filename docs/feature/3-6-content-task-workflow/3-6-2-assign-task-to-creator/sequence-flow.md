# Sequence Flow — Assign Task To Creator

> Supplements `spec.md` (FR 3.6.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskDetailUI`.
- **System** — `TaskController` / `TaskService`.

---

## Flow A — Luồng thực thi chính: Assign Task To Creator

1. manager -> taskdetailui: `clicks "Assign Task" button on task detail page`
2. taskdetailui -> taskcontroller: `GET /api/v1/workspaces/{workspaceId}/members?role=MEMBER`
3. taskcontroller -> taskservice: `listAssignableMembers(workspaceId)`
4. taskservice -> workspacememberrepos: `findAllByWorkspaceIdAndStatusActive(workspaceId)`
5. workspacememberrepos --> taskservice: `activeMemberList`
6. taskservice --> taskcontroller: `List<WorkspaceMemberResponse>`
7. taskcontroller --> taskdetailui: `200 OK (activeMemberList)`
8. taskdetailui --> manager: `render Assign dialog (assignee dropdown, QC dropdown, requireClientApproval toggle)`
9. manager ->> taskdetailui: `selects assigneeId, optional qcAssigneeId, toggles requiresClientApproval & submits`
10. taskdetailui ->> taskcontroller: `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/assign (AssignTaskRequest)`
11. taskcontroller ->> taskservice: `assignTask(workspaceId, taskId, currentUser, request)`
12. taskservice ->> taskrepository: `findByIdAndWorkspaceId(taskId, workspaceId)`
13. taskrepository --> taskservice: `task`
14. taskservice --> taskcontroller: `throw BusinessException (403 FORBIDDEN)`
15. taskdetailui --> manager: `show access denied error toast`
16. taskcontroller --> taskdetailui: `403 Forbidden`
17. taskservice --> taskcontroller: `throw BusinessException (409 TASK_DETAIL_NOT_IDENTIFIED)`
18. taskdetailui --> manager: `show error alert ("Task must be in DETAIL_IDENTIFIED status before assignment")`
19. taskcontroller --> taskdetailui: `409 Conflict`
20. taskservice --> taskcontroller: `throw BusinessException (400 QC_CANNOT_BE_SAME_AS_ASSIGNEE)`
21. taskdetailui --> manager: `show validation error ("Assignee cannot be assigned to QC their own task")`
22. taskcontroller --> taskdetailui: `400 Bad Request`
23. taskservice ->> workspacememberrepos: `findByWorkspaceIdAndUserId(workspaceId, assigneeId)`
24. workspacememberrepos --> taskservice: `empty`
25. taskservice --> taskcontroller: `throw BusinessException (400 INVALID_ASSIGNEE)`
26. taskcontroller --> taskdetailui: `400 Bad Request`
27. taskdetailui --> manager: `show validation error ("Selected assignee is not an active workspace member")`
28. taskservice ->> workspacememberrepos: `findByWorkspaceIdAndUserId(workspaceId, assigneeId)`
29. workspacememberrepos --> taskservice: `assigneeMember`
30. taskservice ->> workspacememberrepos: `findByWorkspaceIdAndUserId(workspaceId, qcAssigneeId)`
31. workspacememberrepos --> taskservice: `qcMember`
32. taskservice ->> taskrepository: `save(task with assigneeId, qcAssigneeId, requiresClientApproval, status=ASSIGNED)`
33. taskrepository --> taskservice: `savedTask`
34. taskservice --> taskcontroller: `TaskResponse (status=ASSIGNED)`
35. taskcontroller --> taskdetailui: `200 OK (TaskResponse)`
36. taskdetailui --> manager: `show success toast ("Task assigned successfully") & update status badge to ASSIGNED`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
