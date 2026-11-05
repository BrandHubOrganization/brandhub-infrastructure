# Test Specification — FR 3.6.1: Identify Task Detail

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.1` |
| **Function Name** | Identify Task Detail |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskWorkflowService.detail()` (45 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskWorkflowServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Specify and view full task details (taskType POST/SURVEY, platform, dueDate, scheduledAt, priority, brief, references) |
| **Preconditions** | Can connect with server; Task exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is POST | `description` = `valid text`, `dueDate` = `future date`, `typeSpecificFields` = `valid post fields` | 200 OK - task status=DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is SURVEY | `description` = `valid text`, `dueDate` = `future date`, `typeSpecificFields` = `valid survey fields` | 200 OK - task status=DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is SURVEY | `description` = `valid text`, `dueDate` = `future date`, `typeSpecificFields` = `valid survey fields` | 200 OK - task status=DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task from Content Request with client description | `description` = `null (keep original)`, `dueDate` = `future date` | 200 OK - original description kept, DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task from Content Request with client description | `description` = `original + extra notes`, `dueDate` = `future date` | 200 OK - description updated, DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is POST | `description` = `valid text`, `dueDate` = `future date`, `typeSpecificFields` = `empty object` | 200 OK - DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is POST | `description` = `valid text`, `dueDate` = `today` | 200 OK - DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is POST | `description` = `1 char`, `dueDate` = `future date` | 200 OK - DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is POST | `description` = `max length text`, `dueDate` = `future date` | 200 OK - DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is POST | `description` = `valid text`, `dueDate` = `tomorrow (min future)` | 200 OK - DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG; Task type is POST | `description` = `valid text`, `dueDate` = `far future (1 year)` | 200 OK - DETAIL_IDENTIFIED | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is MANAGER of workspace; Task status is ASSIGNED | `description` = `valid text`, `dueDate` = `future date` | 409 TASK_NOT_IN_BACKLOG | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MANAGER of workspace; Task status is DETAIL_IDENTIFIED | `description` = `valid text`, `dueDate` = `future date` | 409 TASK_NOT_IN_BACKLOG | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Task status is BACKLOG; User is CREATOR of workspace | `description` = `valid text`, `dueDate` = `future date` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Task status is BACKLOG; User is CLIENT of workspace | `description` = `valid text`, `dueDate` = `future date` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Task status is BACKLOG; User is not a member of workspace | `description` = `valid text`, `dueDate` = `future date` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace; Task does not exist | `description` = `valid text`, `dueDate` = `future date` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Task status is BACKLOG | `description` = `null`, `dueDate` = `null` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — FR 3.6.1 / DA-978

> **Ưu tiên BA mới 2026-10-15:** xem [Task năm trạng thái + inline autosave](../task-five-state-inline-edit/spec.md). TODO thay BACKLOG/DETAIL_IDENTIFIED/ASSIGNED; giao việc cần mô tả + deadline hợp lệ, không chuyển trạng thái. IN_REVIEW lưu bước QC/Manager/Client riêng, reject về IN_PROGRESS, bước cuối thành công mới FINISHED. Manager khóa sửa/giao lại sau lần bắt đầu đầu tiên. Phần vòng đời/form cũ bên dưới được giữ làm lịch sử, không phải contract mới. Đợt này chỉ code FR 3.6.1/2; Approval và Comments không được coi là đã hoàn thành.

## Bảng chi tiết bên phải — kịch bản trước code 2026-10-15

- P01: click/Enter Task mở đúng workflow ở bên phải, list vẫn tương tác trên desktop, không dialog tóm tắt hoặc chuyển trang; URL có task.
- P02: đóng bằng nút/Escape, trả focus về nút Task; Back/Forward mở/đóng/chọn đúng Task, giữ query khác/filter/view/page.
- P03: mở Task A rồi B hoặc đổi Workspace: không rò dữ liệu/bản nháp; provider không thiếu, không tạo client mỗi rerender.
- P04: direct link task và route detail cũ mở cùng bảng; không phụ thuộc Task có trên trang list hiện tại.
- P05: lưu brief/giao việc/bắt đầu thành công cập nhật status/assignee/deadline trong list; không tự start khi mở; 409 giữ draft.
- P06: loading/error/retry, schema/legacy locked, Client chỉ xem; không mock fallback hoặc mở quyền mới.
- P07: 375/768/1440, light/dark/vi/en, không tràn viewport; mobile Sheet có focus trap và Escape/close; desktop không trap focus danh sách.

Kết quả 2026-10-15: 132 Vitest tests/14 files pass (4 regression provider/desktop aside/legacy route dùng workflow hook thật), TypeScript và production build pass. Scoped lint không lỗi; useTasks vẫn có 2 cảnh báo hook từ trước. Browser CLI dùng TaskList thật + workflow thật + MemoryRouter, không bọc QueryClientProvider từ harness, mock API không ghi DB: desktop không modal, giữ query/search/view, chuyển Task không lẫn draft, Back/Forward, detail/assign/start cập nhật list, Creator mở bảng không tự start, 409 giữ draft, Escape/focus/Enter, Client readonly, direct/legacy links, error/retry; light/dark, vi/en, 375/768/1440. Không có pageerror; Vite HMR bị local-network policy chặn và HTTP 409/503 chủ ý từ fixture không phải lỗi ứng dụng. Browser không chứng minh live Atlas/auth/ACL; page/filter/pagination chưa test với dataset nhiều trang. Ảnh và harness ở `.local-backups/task-panel-20261015` ngoài repo Web; không thêm Playwright test spec.

Baseline giai đoạn 1 chưa test ứng dụng; các dòng bên dưới giữ checklist nghiệm thu đầy đủ. Đợt 2026-10-15 đã có unit/MockMvc, Mongo cô lập và browser mock cho phần workflow; evidence/giới hạn ở [bàn giao đợt 2/3](../task-workflow-phase-2-3.md). Không coi tất cả dòng đã pass trên Atlas.

| ID | Input/điều kiện | AC | Mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| D01 | Manager, BACKLOG, brief + deadline hợp lệ | Xác định lần đầu | DETAIL_IDENTIFIED, giữ Task ID/nguồn | Happy | Chưa test |
| D02 | POST có dueDate và plannedPublishAt ≥ dueDate | Hai thời điểm | Lưu riêng, không tạo lịch publish | Happy | Chưa test |
| D03 | LIVESTREAM/SURVEY/EVENT_PLAN/PRESS_RECOMMENDATION | Khung 5 loại | Lưu common brief, không đổi specialist content | Happy | Chưa test |
| D04 | DETAIL_IDENTIFIED/ASSIGNED chưa bắt đầu, revision đúng | Sửa trước start | Giữ status và người phụ trách | Edge | Chưa test |
| D05 | IN_PROGRESS/review/terminal hoặc reject → ASSIGNED có marker | Khóa sau start | 409, không sửa/hồi sinh Task | Error | Chưa test |
| D06 | Creator/Client/Owner không là Manager WS | Quyền Manager | 403, không ghi | Error | Chưa test |
| D07 | Task thuộc WS khác; người dùng không còn active cùng WS | Workspace scope | Không lộ dữ liệu, 404/403 theo auth scope | Error | Chưa test |
| D08 | DueDate trước max(today,start), sau end; timezone sát nửa đêm | Giới hạn ngày | UI min/max và API cùng từ chối | Error | Chưa test |
| D09 | POST publish trước due hoặc ngoài Campaign; non-POST gửi publish | Hai thời điểm/ngày | Field errors, không tự clamp | Error | Chưa test |
| D10 | Manual không Campaign; hạn hôm nay | Hạn manual | Hợp lệ theo ngày Workspace | Edge | Chưa test |
| D11 | Campaign hết ngày hoặc completed | Edge case spec §7 | Không có hạn mới hợp lệ/409 completed | Edge | Chưa test |
| D12 | Content Request đã có description | Edge case spec §7 | Có thể giữ/bổ sung, không mất sourceRefId | Edge | Chưa test |
| D13 | Revision stale/detail đua cancel hoặc completion | Giữ audit/state | Conflict, CANCELLED không bị phục hồi | Error | Chưa test |
| D14 | Legacy thiếu first-start/revision | Q13/legacy | Client vẫn đọc/bình luận; Manager cần review trước mutation | Edge | Chưa test |
| D15 | Client xem Task Manager tạo thủ công và Task Campaign/Request | Q13 | Đọc workflow cùng WS, không có bộ chọn nội bộ/thường | Happy | Chưa test |
| D16 | Mở editor/trang mà không bấm start | Trigger start | Không có firstStartedAt/status mới | Edge | Chưa test |
| D17 | Đổi vi/en; light/dark; 375/768/1440; chỉ bàn phím | i18n/theme § cuối | Không hardcode, không mất contrast; focus lỗi và giữ input | Happy | Chưa test |
| D18 | DB chưa có foundation | Error/readiness | 503 rõ, không mutation nửa chừng | Error | Chưa test |
| D19 | Client đọc được Task rồi gọi PATCH detail/assign | Q13/quyền | 403, quyền đọc/bình luận không cấp quyền quản lý | Error | Chưa test |
| D20 | Detail đua assign cùng expectedRevision | CAS | Mutation stale trả 409, không ghi đè cấu hình giao việc | Edge | Chưa test |

Schema tests/evidence tập trung tại [setup giai đoạn 1](../task-workflow-phase-1.md), không thay test API này.

Slice bổ sung: mọi nguồn vào đúng Task Detail; read workflow không cấp quyền editor; min/max ngày và timezone khác browser; giờ DST thiếu/không rõ; legacy raw marker missing khác explicit null; không tạo/sửa DB khi chỉ mở trang.
