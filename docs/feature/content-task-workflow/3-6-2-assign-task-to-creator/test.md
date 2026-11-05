# Test Specification — FR 3.6.2: Assign Task to Creator

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.2` |
| **Function Name** | Assign Task to Creator |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `TaskWorkflowService.assign()` (34 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskWorkflowServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Allow Manager to assign a task to a Creator and optional internal reviewer in the workspace and notify them |
| **Preconditions** | Can connect with server; Caller is Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 5, `Boundary (B)`: 2, `Abnormal (A)`: 11 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED; assignee is MEMBER of workspace | `assigneeId` = `valid creator`, `qcAssigneeId` = `null`, `requiresClientApproval` = `false` | 200 OK - status=ASSIGNED, no QC step | Notification sent to assignee | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED; assignee is MEMBER of workspace | `assigneeId` = `valid creator`, `qcAssigneeId` = `other valid creator`, `requiresClientApproval` = `false` | 200 OK - status=ASSIGNED, QC step enabled | Notification sent to assignee | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED; assignee is MEMBER of workspace | `assigneeId` = `valid creator`, `qcAssigneeId` = `null`, `requiresClientApproval` = `true` | 200 OK - status=ASSIGNED, client approval required | Notification sent to assignee | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED; assignee is MEMBER of workspace | `assigneeId` = `valid creator`, `qcAssigneeId` = `other valid creator`, `requiresClientApproval` = `true` | 200 OK - ASSIGNED, QC + client approval | Notification sent to assignee | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED; assignee is MEMBER of workspace | `assigneeId` = `valid creator`, `requiresClientApproval` = `false` | 200 OK - ASSIGNED, qcAssigneeId omitted treated as null | Notification sent to assignee | **Passed** |
| `UTCID06` | `B` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED; workspace has only 1 creator | `assigneeId` = `the only creator`, `requiresClientApproval` = `false` | 200 OK - status=ASSIGNED | Notification sent to assignee | **Passed** |
| `UTCID07` | `B` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED; workspace has 2 creators | `assigneeId` = `creator A`, `qcAssigneeId` = `creator B`, `requiresClientApproval` = `false` | 200 OK - QC is the last available creator | Notification sent to assignee | **Passed** |
| `UTCID08` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `assigneeId` = `user with role CLIENT`, `requiresClientApproval` = `false` | 400 INVALID_ASSIGNEE | — | **Passed** |
| `UTCID09` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `assigneeId` = `user not in workspace`, `requiresClientApproval` = `false` | 400 INVALID_ASSIGNEE | — | **Passed** |
| `UTCID10` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `assigneeId` = `manager of workspace`, `requiresClientApproval` = `false` | 400 INVALID_ASSIGNEE | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `assigneeId` = `null`, `requiresClientApproval` = `false` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `assigneeId` = `valid creator`, `qcAssigneeId` = `same as assignee`, `requiresClientApproval` = `false` | 400 QC_CANNOT_BE_SAME_AS_ASSIGNEE | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `assigneeId` = `valid creator`, `qcAssigneeId` = `user not in workspace`, `requiresClientApproval` = `false` | 400 INVALID_ASSIGNEE | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG | `assigneeId` = `valid creator`, `requiresClientApproval` = `false` | 409 TASK_DETAIL_NOT_IDENTIFIED | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Task status is DETAIL_IDENTIFIED; User is CREATOR of workspace | `assigneeId` = `valid creator`, `requiresClientApproval` = `false` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Task status is DETAIL_IDENTIFIED; User is CLIENT of workspace | `assigneeId` = `valid creator`, `requiresClientApproval` = `false` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace; Task does not exist | `assigneeId` = `valid creator`, `requiresClientApproval` = `false` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `assigneeId` = `valid creator`, `requiresClientApproval` = `null` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.2`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — FR 3.6.2 / DA-978

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

Baseline giai đoạn 1 chưa test ứng dụng; các dòng dưới giữ checklist nghiệm thu đầy đủ. Đợt 2026-10-15 đã chạy unit/MockMvc, Mongo cô lập và browser mock; không tuyên bố đã test Atlas/PostgreSQL inbox/Approval integration. Evidence/giới hạn: [bàn giao đợt 2/3](../task-workflow-phase-2-3.md). AC theo [spec](spec.md) §3/6/7.

| ID | Input/điều kiện | AC | Mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| A01 | Manager, DETAIL_IDENTIFIED, Creator active | Giao lần đầu | ASSIGNED + assignment audit + notification | Happy | Chưa test |
| A02 | Creator khác làm QC hoặc null, Client approval true/false | QC/Client tùy chọn | Lưu đúng cấu hình duyệt, Client vẫn đọc/bình luận ở cả hai giá trị | Happy | Chưa test |
| A03 | QC=assignee; wrong WS/role/inactive; dùng membership ID | Ràng buộc identity | 400 theo field, không ghi/outbox | Error | Chưa test |
| A04 | BACKLOG chưa xác định chi tiết | Error §6 | 409 TASK_DETAIL_NOT_IDENTIFIED | Error | Chưa test |
| A05 | ASSIGNED chưa start đổi Creator/QC | Giao lại | Giữ ASSIGNED, revision tăng | Edge | Chưa test |
| A06 | IN_PROGRESS/review/terminal/reject ASSIGNED có marker | Khóa sau start | 409, không đổi người/lịch sử approval | Error | Chưa test |
| A07 | Assignee bấm Start lần đầu | Q8 | IN_PROGRESS, firstStartedAt/By server, revision tăng | Happy | Chưa test |
| A08 | Không phải assignee bấm Start hoặc chỉ mở trang/editor | Q8/quyền | Không start; 403 nếu mutation trái quyền | Error | Chưa test |
| A09 | Retry/concurrent assign/start/cancel/complete | Audit/state | Chỉ một mutation, không phục hồi CANCELLED | Edge | Chưa test |
| A10 | Membership bị gỡ giữa options và submit | Active same WS | API từ chối, không dùng options cached làm quyền | Error | Chưa test |
| A11 | Legacy thiếu first-start evidence | Không mở khóa reject | Yêu cầu review, không gán null tự động | Edge | Chưa test |
| A12 | Outbox retry hoặc SQL insert thành công rồi worker crash | Notification | Một inbox delivery, có retry không mất | Edge | Chưa test |
| A13 | Owner Agency không là Manager WS | Quyền Manager | 403; Owner là Manager WS thì hợp lệ | Error | Chưa test |
| A14 | vi/en, light/dark, mobile/keyboard, empty Creator list | i18n/theme | Nhãn/quyền đúng, không submit selection giả | Happy | Chưa test |
| A15 | Resubmit sau reject với QC có/không | Giữ history/Q7 | Phối hợp E51-03 duyệt lại QC/Manager, marker không reset | Edge | Chưa test |
| A16 | Assign/reassign Task thủ công với requiresClientApproval=true | Q13 | Hợp lệ khi đủ guard, không có lỗi Q12; Client xem/bình luận được | Happy | Chưa test |
| A17 | Task manual/Campaign/Request với requiresClientApproval=false | Q13 | Vẫn giao được và Client xem/bình luận được, không thêm bước Client duyệt | Happy | Chưa test |
| A18 | Form Assign cho cả ba nguồn Task | Q13/UI | Không có bộ chọn nội bộ/thường, checkbox Client duyệt không khóa theo nguồn | Edge | Chưa test |

Slice bổ sung: duplicate/outdated worker lease không đổi event mới; SQL delivery retry cùng UUID không nhân đôi inbox; schema chưa migration không tạo collection; notification chỉ giao việc, không gửi mail; form lưu thất bại giữ Creator/QC và cờ duyệt.
