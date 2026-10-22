# Sequence Flow — Approval Sequence (Creator -> Manager -> Client)

> Supplements `spec.md` (FR 3.6.9). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator (Author)** — actor tương tác chính trong quy trình.
- **Creator (QC Reviewer)** — actor tương tác chính trong quy trình.
- **Manager (Agency)** — actor tương tác chính trong quy trình.
- **Client (Brand)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TaskDetailPage (UI)`.
- **System** — `TaskApprovalController` / `TaskApprovalServiceImpl`.

---

## Flow A — Luồng thực thi chính: Approval Sequence (Creator -> Manager -> Client)

1. creatorauthor -> taskdetailpageui: `Click "Submit for Review"`
2. taskdetailpageui -> taskapprovalcontroll: `Request submit task for review`
3. taskapprovalcontroll -> taskapprovalservicei: `submitTask(workspaceId, taskId, creatorUser)`
4. taskapprovalservicei -> taskrepository: `findTask(taskId)`
5. taskrepository --> taskapprovalservicei: `return Optional<Task>`
6. taskapprovalservicei --> taskapprovalcontroll: `throw TASK_NOT_FOUND (404 Not Found)`
7. taskapprovalcontroll --> taskdetailpageui: `return 404 Not Found (Task not found in workspace)`
8. taskdetailpageui --> creatorauthor: `Display error: "Task not found"`
9. taskapprovalservicei -> taskapprovalservicei: `determineFirstReviewStep(task)`
10. taskapprovalservicei -> taskrepository: `updateStatus(taskId, nextStatus)`
11. taskrepository --> taskapprovalservicei: `return OK`
12. taskapprovalservicei --> taskapprovalcontroll: `return OK`
13. taskapprovalcontroll --> taskdetailpageui: `200 OK (status=nextStatus)`
14. taskdetailpageui --> creatorauthor: `Update Stepper: Wait to change for accept by QC or Manager`
15. creatorqcreviewer -> taskdetailpageui: `Click "Reject" & enter feedback`
16. taskdetailpageui -> taskapprovalcontroll: `Request reject review (reason)`
17. taskapprovalcontroll -> taskapprovalservicei: `rejectStep(taskId, "QC", reason)`
18. taskapprovalservicei -> taskapprovalreposito: `recordApprovalAction(taskId, "QC", "REJECTED", reason)`
19. taskapprovalreposito --> taskapprovalservicei: `return OK`
20. taskapprovalservicei -> taskrepository: `updateStatus(taskId, 'ASSIGNED')`
21. taskrepository --> taskapprovalservicei: `return 200 OK`
22. taskapprovalservicei --> taskapprovalcontroll: `return taskResponse`
23. taskapprovalcontroll --> taskdetailpageui: `return 200 OK (Task reverted to ASSIGNED for revision)`
24. taskdetailpageui --> creatorauthor: `Notify Creator: QC rejected, revisions required`
25. creatorqcreviewer -> taskdetailpageui: `Click "Approve Quality Check"`
26. taskdetailpageui -> taskapprovalcontroll: `Request approve review ("QC")`
27. taskapprovalcontroll -> taskapprovalservicei: `return taskResponse`
28. taskapprovalservicei -> taskapprovalreposito: `recordApprovalAction(taskId, "QC", "APPROVED")`
29. taskapprovalreposito --> taskapprovalservicei: `return OK`
30. taskapprovalservicei -> taskrepository: `updateStatus(taskId, 'MANAGER_REVIEW')`
31. taskrepository --> taskapprovalservicei: `return 200 OK`
32. taskapprovalservicei --> taskapprovalcontroll: `return taskResponse`
33. taskapprovalcontroll --> taskdetailpageui: `return 200 OK (QC passed, moved to MANAGER_REVIEW)`
34. taskdetailpageui --> manageragency: `Update stepper: Pending Manager review`
35. manageragency -> taskdetailpageui: `Click "Reject" & enter reason ("Brand alignment mismatch")`
36. taskdetailpageui -> taskapprovalcontroll: `Request reject review (reason)`
37. taskapprovalcontroll -> taskapprovalservicei: `rejectStep(taskId, "MANAGER", reason)`
38. taskapprovalservicei -> taskapprovalreposito: `recordApprovalAction(taskId, "MANAGER", "REJECTED", reason)`
39. taskapprovalreposito --> taskapprovalservicei: `return 200 OK`
40. taskapprovalservicei -> taskrepository: `updateStatus(taskId, 'ASSIGNED')`
41. taskrepository --> taskapprovalservicei: `return OK`
42. taskapprovalservicei --> taskapprovalcontroll: `return taskResponse`
43. taskapprovalcontroll --> taskdetailpageui: `return 200 OK (Task reverted to ASSIGNED for revision)`
44. taskdetailpageui --> creatorauthor: `Notify Creator: Manager rejected, reverted to ASSIGNED`
45. manageragency -> taskdetailpageui: `Click "Approve Task"`
46. taskdetailpageui -> taskapprovalcontroll: `Request approve review ("MANAGER")`
47. taskapprovalcontroll -> taskapprovalservicei: `approveStep(taskId, "MANAGER")`
48. taskapprovalservicei -> taskapprovalreposito: `recordApprovalAction(taskId, "MANAGER", "APPROVED")`
49. taskapprovalreposito --> taskapprovalservicei: `return 200 OK`
50. taskapprovalservicei -> taskrepository: `updateStatus(taskId, 'CLIENT_REVIEW')`
51. taskrepository --> taskapprovalservicei: `return OK`
52. taskapprovalservicei --> taskapprovalcontroll: `return taskResponse`
53. taskapprovalcontroll --> taskdetailpageui: `return 200 OK (Manager approved, moved to CLIENT_REVIEW)`
54. taskdetailpageui --> clientbrand: `Notify Client: Pending Client approval`
55. taskapprovalservicei -> taskrepository: `updateStatus(taskId, 'COMPLETED')`
56. taskrepository --> taskapprovalservicei: `return OK`
57. taskapprovalservicei --> taskapprovalcontroll: `return taskResponse`
58. taskapprovalcontroll --> taskdetailpageui: `return 200 OK (Task completed, ready for publishing)`
59. taskdetailpageui --> manageragency: `Stepper displays: "Completed - Ready for Publishing"`
60. clientbrand -> taskdetailpageui: `Click "Reject" & enter client feedback`
61. taskdetailpageui -> taskapprovalcontroll: `Request reject review (reason)`
62. taskapprovalcontroll -> taskapprovalservicei: `rejectStep(taskId, "CLIENT", reason)`
63. taskapprovalservicei -> taskapprovalreposito: `recordApprovalAction(taskId, "CLIENT", "REJECTED", reason)`
64. taskapprovalreposito --> taskapprovalservicei: `return OK`
65. taskapprovalservicei -> taskrepository: `updateStatus(taskId, 'ASSIGNED')`
66. taskrepository --> taskapprovalservicei: `return 200 OK`
67. taskapprovalservicei --> taskapprovalcontroll: `return taskResponse`
68. taskapprovalcontroll --> taskdetailpageui: `return 200 OK (Task reverted to ASSIGNED for revision)`
69. taskdetailpageui --> creatorauthor: `Notify Creator: Client rejected, task reverted to ASSIGNED`
70. clientbrand -> taskdetailpageui: `Click "Final Approve"`
71. taskdetailpageui -> taskapprovalcontroll: `Request approve review ("CLIENT")`
72. taskapprovalcontroll -> taskapprovalservicei: `approveStep(taskId, "CLIENT")`
73. taskapprovalservicei -> taskapprovalreposito: `recordApprovalAction(taskId, "CLIENT", "APPROVED")`
74. taskapprovalreposito --> taskapprovalservicei: `return 200 OK`
75. taskapprovalservicei -> taskrepository: `updateStatus(taskId, 'COMPLETED')`
76. taskrepository --> taskapprovalservicei: `return OK`
77. taskapprovalservicei --> taskapprovalcontroll: `return taskResponse`
78. taskapprovalcontroll --> taskdetailpageui: `return 200 OK (Final approval granted, task COMPLETED)`
79. taskdetailpageui --> clientbrand: `Stepper displays: "Completed - Ready for Publishing"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
