# Test Specification — FR 3.6.3: Add Comments on Task

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.3` |
| **Function Name** | Add Comments on Task |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskCommentService.create()` (30 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskCommentServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Add threaded comments with optional attachments and @mentions on a workspace task and broadcast real-time notifications |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `valid text` | 201 Created - CommentResponse(id, content, authorId, createdAt) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Task exists in workspace; User is CREATOR of workspace | `content` = `valid text` | 201 Created - CommentResponse | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Task exists in workspace; User is CLIENT of workspace | `content` = `valid text` | 201 Created - CommentResponse | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Task exists in workspace; User is CLIENT of workspace; Task requiresClientApproval=false | `content` = `valid text` | 201 Created - comment allowed regardless of approval flag | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `text with @mention of member` | 201 Created - CommentResponse | Mentioned user notified | **Passed** |
| `UTCID06` | `N` | Can connect with server; Task exists in workspace; User is CREATOR of workspace | `content` = `valid text`, `attachments` = `1 image URL` | 201 Created - CommentResponse with attachment | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Task exists in workspace; User is CREATOR of workspace | `content` = `valid text`, `attachments` = `2 reference links` | 201 Created - CommentResponse with 2 attachments | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MANAGER of workspace; Task exists in workspace; Task has 3 comments | `taskId` = `valid task` | 200 OK - list of 3 comments ordered by createdAt asc | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User is MANAGER of workspace; Task exists in workspace; Task has no comments | `taskId` = `valid task` | 200 OK - empty list | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `1 char` | 201 Created - CommentResponse | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `max length text` | 201 Created - CommentResponse | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `max length + 1 chars` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `valid text`, `attachments` = `empty list` | 201 Created - CommentResponse without attachments | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `null` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `empty` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Task exists in workspace | `content` = `blank spaces only` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Task exists in workspace; User is not a member of workspace | `content` = `valid text` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Task does not exist | `content` = `valid text` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is MANAGER of workspace; Task belongs to another workspace | `content` = `valid text` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — FR 3.6.3 / DA-1236

AC theo [spec](spec.md) §3/6/7. Kết quả cập nhật 2026-10-17 bên dưới; kiểm thử cô lập không thay thế kiểm thử S3/inbox/Gateway thật.

2026-10-17: C06 no longer includes QC. Verify actual Manager membership, Creator, Client including ClientProfile-resolved User IDs; terminal comments and arbitrary Workspace isolation. Build/compile and isolated browser/manual checks only; no test files under src or commits. Private bucket policy must cover task-comment-images/; never store these under public image/ prefix. Idempotent replay returns the original successful result even after upload expiry/attachment binding, but a changed payload conflicts. Same-key concurrent writes retry as duplicate lookup after transaction abort. Empty content stays invalid even with images, per minLength contract.

| ID | Input/điều kiện | AC | Mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| C01 | Manager/Creator/Client có quyền Task gửi text/link | Bình luận/timeline | Author snapshot server, thứ tự/cursor đúng | Happy | Chưa test |
| C02 | COMPLETED/CANCELLED hoặc Campaign completed | Terminal comment | Gửi mới được, không đổi state/round/Campaign | Edge | Chưa test |
| C03 | Client xem/bình luận Task thủ công requiresClientApproval=false hoặc true | Q13/Edge §7 | Cả hai đều được, nếu còn active cùng WS | Happy | Chưa test |
| C04 | Client đọc/gửi comment và xem ảnh ATTACHED trên Task cũ thiếu revision/start | Q13/legacy | Được theo membership; không tự sửa state/marker; DRAFT người khác vẫn bị chặn | Edge | Chưa test |
| C05 | Gỡ membership sau từng tham gia | Edge §7 | Chặn đọc/gửi/ảnh và delivery mới | Error | Chưa test |
| C06 | Mention assignee/Managers/tác giả/Client, không QC | Recipients | Dedup, bỏ tác giả, Client chỉ mentioned | Happy | Pass Mongo/outbox; chờ inbox thật |
| C07 | Mention wrong WS/inactive/no Task access | Mention ACL | Từ chối, không lộ tên/no delivery | Error | Chưa test |
| C08 | 5 JPEG/PNG/WebP mỗi ảnh đúng 5MB | Ảnh BA | Nhận, private, bind đúng một comment | Happy | Chưa test |
| C09 | 6 ảnh, >5MB, MIME giả, corrupt, arbitrary URL | Ảnh thực/ownership | Field errors, không lưu comment nửa chừng | Error | Chưa test |
| C10 | Upload người khác/Task khác/ATTACHED hoặc bind đồng thời | Ownership | 409/400, không gắn lại | Error | Chưa test |
| C11 | DRAFT cleanup đua bind; S3 delete lỗi | Ảnh không mất | Không xóa ATTACHED, retry giữ metadata tới khi xóa xong | Edge | Chưa test |
| C12 | Cùng clientRequestId cùng/khác payload | Retry | Một comment; khác payload conflict | Edge | Chưa test |
| C13 | Comment cùng timestamp và phân trang trong lúc có comment mới | Timeline | Không mất/trùng item qua cursor | Edge | Chưa test |
| C14 | HTML/script/javascript URL trong text | Text/link an toàn | Escape/plain text, không XSS | Error | Chưa test |
| C15 | Worker crash sau SQL commit; người nhận mất quyền | Notification | Một delivery hoặc SUPPRESSED, không lộ nội dung | Edge | Chưa test |
| C16 | vi/en/light/dark/mobile/keyboard mention; upload lỗi | i18n/theme | Giữ draft/focus, không mất text/ảnh hợp lệ | Happy | Chưa test |
| C17 | Mongo transaction abort giữa comment/bind/outbox | Tạo bình luận | Không comment/notification/binding nửa chừng | Error | Chưa test |
| C18 | Client truy cập comment/ảnh/mention-options của Task WS khác | Workspace isolation | Từ chối, không lộ dữ liệu WS khác | Error | Chưa test |
| C19 | Gõ @/@tên đầu dòng/sau khoảng trắng, chọn chuột/↑↓ Enter, nhiều lần cùng User | Nhập trực tiếp | Thay đúng token, giữ text phía sau/caret, dedup User IDs; không gửi khi chọn tên | UX | Chưa test |
| C20 | Email, selection khác rỗng, Escape, IME tiếng Việt, tên dài sát 10.000 ký tự | Không chọn nhầm | Không popup email, không gửi/chọn trong composition, không cắt mất text khi quá giới hạn, Escape không đóng Task | Edge | Chưa test |
| C21 | Tìm thành viên chậm/lỗi/không kết quả/phân trang; vi/en/light/dark/375/768/1440 | Feedback/a11y | Không hiện kết quả cũ để chọn nhầm; retry/load-more; focus giữ ở textarea, danh sách không tràn | UX | Chưa test |
| C22 | Gõ @ giữa câu/dòng wrap, scroll popup gần mép | Popup theo caret | Dropdown nổi tại @, không đẩy layout, flip/clamp trong viewport, không đóng Task khi chọn | UX | Chưa test |
| C23 | Chọn/xóa/cắt/Undo mention, trùng User, toolbar | Nhãn inline | Highlight ngay trong text; User IDs dedup từ nhãn còn lại, xóa nhãn cuối bỏ người nhận; undo khôi phục | Happy | Chưa test |
| C24 | Paste HTML giả mention/script, >10.000 ký tự, emoji/IME, lỗi gửi rồi retry | An toàn/giữ draft | Chỉ plain text; không nhận ID giả, không vượt giới hạn; retry giữ nhãn và request key, gửi xong reset | Edge | Chưa test |

## Bằng chứng kiểm tra ngày 2026-10-17

Không tạo/commit file test trong src. Helper tạm và ảnh kiểm tra chỉ ở target/ hoặc output/playwright/ đã ignore.

- Backend: 46 test hiện có của TaskWorkflowService/TaskWorkflowMembers/TaskWorkflowController/TaskNotificationWorker pass sau clean build.
- Mongo 7 replica set **container riêng, không gắn volume dữ liệu dự án, localhost:27031**, init từ file hiện tại; 38 assertions pass. Container và dữ liệu kiểm thử tạm đã được dọn sau test. PostgreSQL repositories, inbox và object storage được mock, không dùng Atlas/demo.
- C01/02/04: pass scoped service, author snapshot, ClientProfile → User ID, đọc/gửi trên FINISHED/CANCELLED thiếu workflow markers; không thay Task status/approvalRound/markers.
- C03: xác minh Client được xem terminal Task requiresClientApproval=false; cần test bổ sung manual Task/cờ true qua UI thật.
- C05/07/18: pass ngoại Workspace, mention lạ, Client bị gỡ membership không được đọc/xem ảnh; worker SUPPRESSED với Client đã mất quyền. Chưa stress-test race removal đồng thời xuyên PostgreSQL/Mongo.
- C08/09: PNG/JPEG/WebP thật decode thành công; PNG đúng 5 MiB được nhận; MIME giả bị từ chối. Browser chặn ảnh 5 MiB + 1. Chưa chạy toàn bộ tổ hợp 5/6 ảnh và malformed image qua multipart thật.
- C10/11: chủ upload preview được DRAFT, người khác bị chặn; ATTACHED có quyền Task đọc được; không bind ảnh người khác; cleanup xóa DRAFT hết hạn và giữ ATTACHED. Chưa fault-injection lỗi S3 delete/race cleanup với bind thật.
- C12/13/17: hai luồng cùng clientRequestId chỉ một comment; replay sau gắn ảnh trả comment cũ, đổi payload conflict; cursor cùng timestamp không mất/trùng; lỗi bind thứ hai rollback cả binding thứ nhất, không comment/outbox nửa chừng.
- C14/16: browser thật với API mock: script hiển thị plain text; mention, lỗi mất response giữ draft, retry cùng requestId không tạo trùng, ảnh/upload/preview hoạt động. Đã xem screenshot light tại 375/768/1440 và dark tại 1440; không tràn vùng comment. Chưa test locale en và mọi phím trên mọi browser.
- C15: worker comment gửi tới mock inbox trên terminal Task và suppress Client bị gỡ. SQL ON CONFLICT reuse adapter hiện có; chưa giả lập crash sau SQL commit trên PostgreSQL thật.
- ESLint phần Web mới pass. TypeScript toàn repo chưa pass do lỗi sẵn ở Content Writing/editor/Workspace dashboard/AppRoutes; không sửa phần thành viên khác. Không có lỗi TypeScript trỏ tới file comment mới tại lần kiểm tra này.

Các dòng “Chưa test” trong bảng là case đầy đủ chưa được xác minh end-to-end; các kiểm tra con đã qua được ghi rõ ở trên, không tự đánh pass toàn bộ từ mock.

### Bổ sung @ trực tiếp trong ô nhập

- Parser/replacement: 17 assertions pass bằng helper local ngoài src: đầu dòng/whitespace, Unicode dấu tổ hợp, email/URL, selection không rỗng, caret giữa token, giữ suffix/dấu câu, không cắt text vượt 10.000 ký tự.
- Browser API-mock: C19 pass keyboard ↑↓ Enter, click chọn, giữ focus/caret và văn bản phía sau, dedup User IDs trong payload; chọn tên không POST, Ctrl+Enter khi đã chọn mới gửi.
- C20: pass email không mở danh sách, Escape chỉ đóng gợi ý (chặn trước handler capture của Task dialog), composition Enter/Ctrl+Enter không gửi nhầm; giới hạn độ dài kiểm helper, chưa thử mọi bộ gõ thực tế.
- C21: pass empty/error/retry, layout light tại 375/768/1440, dark 1440 và đổi vi/en. Đã xem ảnh chụp; test dùng API mock, chưa stress-test phân trang/chậm mạng và screen reader thực tế. Không có lỗi lint phần mới; typecheck vẫn chỉ báo các lỗi ngoài scope đã liệt kê.

### Dropdown tại caret và mention inline (UX thay cho textarea)

- C22 browser API-mock pass: đo popup.x so với Range của ký tự @ trên desktop (sai số ≤3 px), ô nhập không đổi chiều cao khi mở popup; popup không vượt viewport 375/768/1440. Đã xem screenshot desktop/mobile và nhãn dark/en. Radix Popover virtual anchor theo vị trí @, không sửa primitive chung.
- C23 pass: chọn chuột/↑↓ Enter chèn node có nền nổi bật; xóa nguyên node bằng Backspace và Undo khôi phục; Ctrl+X cắt nhãn và Ctrl+Z khôi phục; nhắc cùng User nhiều lần chỉ gửi một ID; xóa nhãn cuối không còn ID trong payload gửi tiếp. Toolbar Nhắc tên vẫn chèn node và giữ được khi upload ảnh. Chưa kiểm mọi tổ hợp trên các browser.
- C24 pass: retry sau mất response giữ node và cùng clientRequestId; gửi xong editor rỗng; paste HTML/script/mention giả chỉ thành plain text và không có User ID; không vượt 10.000 ký tự; composition Enter không chọn/gửi. Header/lịch sử comment vẫn dùng dữ liệu plain text, không suy đoán highlight từ tên người trong dữ liệu cũ.
- ESLint các file mới pass; typecheck toàn repo vẫn bị chặn bởi các lỗi Content Writing/editor/dashboard/AppRoutes ngoài scope đã ghi. Không sửa package.json/lockfile hoặc thêm test trong src. Không có thay đổi Backend/API/DB cho phần UX này.
