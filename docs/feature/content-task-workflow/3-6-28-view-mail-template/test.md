# Test Specification — FR 3.6.28: View Mail Template

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.28` |
| **Function Name** | View Mail Template |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MailTemplateServiceImpl.list()` (22 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MailTemplateServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | List and view system default and custom workspace email templates along with supported placeholder variables |
| **Preconditions** | Can connect with server; Caller is Owner, Manager, or Creator in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `workspaceId` = `valid workspace` | 200 OK - list of templates | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `templates` = `3 templates` | 200 OK - 3 items with id, name, subject | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace exists; Mail template exists in workspace; User is CREATOR of workspace | `workspaceId` = `valid workspace` | 200 OK - list of templates | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `order` = `default` | 200 OK - sorted by createdAt desc | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `templates` = `template with long subject` | 200 OK - subject preview returned | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `templates` = `1 template` | 200 OK - 1 item | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists | `templates` = `none` | 200 OK - empty list | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `templates` = `one soft-deleted, 2 active` | 200 OK - only 2 active templates | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists | `templates` = `0 templates` | 200 OK - data [] | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `templates` = `exactly 1 template` | 200 OK - single item | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `templates` = `1000 templates` | 200 OK - all or paged list | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `subject` = `255 chars` | 200 OK - subject not truncated in data | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Workspace exists; User is not a member of workspace | `workspaceId` = `valid workspace` | FORBIDDEN (403) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace exists; User is CLIENT of workspace | `workspaceId` = `valid workspace` | FORBIDDEN (403) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace | `workspaceId` = `non-existent workspace` | WORKSPACE_NOT_FOUND (404) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Workspace exists; Mail template exists in workspace | `workspaceId` = `other workspace` | FORBIDDEN (403) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace | `workspaceId` = `null` | VALIDATION_ERROR (400) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.28`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — View Mail Template (FR 3.6.28)

- **FR:** 3.6.28 · **Jira:** DA-998
- **Mục tiêu:** Xem danh sách, chi tiết, preview mẫu email của Workspace (kèm mẫu hệ thống) và lịch sử các lần gửi.

## 1. Cách chạy 

```bash
# Backend (cần Postgres + Mongo thật cho phần worker/quota)
cd brandhub-business-service && mvn clean test -Dtest='MailTemplate*Test,MailSend*Test,MailDelivery*Test,Quota*Test,Unsubscribe*Test'

# Frontend
cd brandhub-web-dashboard && npm test                     # Vitest
npx playwright test tests/e2e/mail-templates              # E2E (mock REST)

# Live integration (backend thật + SMTP giả)
# Chạy backend thật (profile dev) + SMTP giả cổng 2525, rồi gọi API bằng curl; các bước và kết quả
# ở mục 7 (không có script commit sẵn).
```
Ghi chú môi trường: nếu Maven báo `source level 25`, chạy `mvn clean` (class của IDE trong `target/`). Playwright cần `npx playwright install chromium`.

## 2. Ma trận kiểm thử

| Tầng | Công cụ | Phạm vi |
|---|---|---|
| Đơn vị service | JUnit 5 + Mockito | CRUD, quyền, sanitize, render biến, phân loại người nhận, hẹn giờ |
| Tích hợp DB | JUnit + Postgres/Mongo thật | `SKIP LOCKED`, quota đồng thời, idempotent, retention |
| Frontend logic | Vitest | Parse biến, parse CSV, validate form |
| UI | Playwright (mock REST) | Luồng người dùng, trạng thái UI, i18n, light/dark |
| Live | Node script + SMTP giả | Header, tệp đính kèm, unsubscribe thật, quota, hẹn giờ |

## 3. Test case của FR này

| ID | Case | Input | Mong đợi |
|---|---|---|---|
| TC-MT-01 | List chỉ lấy template của Workspace và hệ thống khi `includeSystem=true` | 2 template Workspace + 1 hệ thống | 3 mục; khi `false` còn 2 |
| TC-MT-02 | List bỏ template đã xóa mềm | 1 template `deletedAt != null` | Không xuất hiện |
| TC-MT-03 | List có tìm kiếm và phân trang | `q=sale`, `size=1` | Chỉ mục khớp; `page` đúng |
| TC-MT-04 | CLIENT/không thành viên gọi list | role CLIENT | 403 `FORBIDDEN` |
| TC-MT-15 | Truy cập chéo Workspace | token Workspace A, template của B | 404/403, không lộ dữ liệu |

| ID | Case | Input | Mong đợi |
|---|---|---|---|
| TC-PRE-01 | Preview trả biến còn thiếu | thiếu `x` | `missingVariables=["x"]` |

| ID | Case | Mong đợi |
|---|---|---|
| TC-HIS-01 | Danh sách lô | Đúng Workspace, mới nhất trước |
| TC-HIS-02 | Chi tiết lô | Phân trang + lọc trạng thái |
| TC-HIS-03 | Quyền xem | OWNER/MANAGER/CREATOR xem; CLIENT 403 |
| TC-HIS-04 | Quota | `GET mail-quota` khớp số đã dùng |
| TC-HIS-05 | Notification | Lô xong/lỗi → người tạo nhận 1 thông báo |
| TC-HIS-06 | Retention | Lô >12 tháng: deliveries và `body_html` xóa, counters còn |

| TC | Case | Where | Result |
|---|---|---|---|
| TC-ENH-01 | Preview renders the typed body; mobile toggle limits width to 375px | Playwright | pass |
| TC-ENH-02 | `{{nmae}}` shows a "Did you mean {{name}}" hint, saving is not blocked | Playwright + vitest | pass |

## 4. Bảo mật

| ID | Case | Mong đợi |
|---|---|---|
| SEC-MT-04 | IDOR template/batch/attachment | 403/404 |
| SEC-MT-07 | Rò rỉ email trên trang unsubscribe | Chỉ hiển thị email đã che |

## 5. Tiêu chí đạt

- 100% case mục 3–11 đạt hoặc có ghi chú giới hạn rõ ràng.
- Không còn lỗi lint/type-check mới; vi/en song song; light/dark kiểm tra.
- Mọi AC trong spec §4 có ít nhất một case tương ứng đạt.

## 6. Giới hạn đã biết (dự kiến)

- Không quét virus (chỉ allow-list + magic bytes).
- Giao hàng at-least-once: crash đúng khoảnh khắc giữa gửi và commit có thể gửi trùng một mail.
- Worker đơn instance được kiểm cho `SKIP LOCKED`; scale đa instance chưa được xác nhận ở môi trường thật.
- Hiển thị email phụ thuộc client thư (Gmail/Outlook/Apple Mail) — kiểm tra bằng mắt.
- Gmail có thể vẫn đánh dấu spam dù đã cap; cần theo dõi thực tế.

## 7. Kết quả thực thi

### 14.1 Bước 1–2 (CRUD, sanitize, render, preview) — 2026-10-12
Nhánh `feat/DA-998-mail-template-crud` (business-service), commit `23503e3`.

| Nhóm | Cách chạy | Kết quả |
|---|---|---|
| JUnit: `HtmlSanitizerTest` | `mvn test` | 11/11 (TC-SAN-01..05 và biến thể) |
| JUnit: `TemplateRendererTest` | `mvn test` | 8/8 (TC-VAR-01..07) |
| JUnit: `MailTemplateServiceImplTest` | `mvn test` | 28/28 (TC-MT-01..15 mức service, TC-PRE-01) |
| Toàn bộ business-service | `mvn clean test` | 587/587, không hồi quy |
| Live (backend thật + Postgres + Mongo local) | curl, DB scratch | pass: tạo (script bị loại), 401/403/404, PATCH khác người tạo 403, PATCH subject trống 400, preview escape, tìm kiếm, soft delete (`deletedAt` set, GET 404, list loại) |
| Migration Mongo `2026-10-12-create-mail-templates-collection.js` | mongosh trên DB tạm | validator nhận bản ghi hợp lệ, từ chối `subject` rỗng và `type` sai; chạy lại idempotent; 3 index |

Chưa chạy: gửi (DA-1002), tệp đính kèm (DA-1256), hẹn giờ/unsubscribe (DA-1257), lịch sử (DA-1258), Admin (DA-1259), toàn bộ frontend và E2E.

Ghi chú triển khai: ảnh trong nội dung bị loại hết cho đến khi cấu hình `mail.allowed-image-hosts` (bước tệp đính kèm); subject không HTML-escape (là header văn bản thuần), chỉ bỏ xuống dòng.

### 16. Enhancements (Addendum A)

| TC | Case | Where | Result |
|---|---|---|---|
| TC-ENH-01 | Preview renders the typed body; mobile toggle limits width to 375px | Playwright | pass |
| TC-ENH-02 | `{{nmae}}` shows a "Did you mean {{name}}" hint, saving is not blocked | Playwright + vitest | pass |
| TC-ENH-03 | New template draft survives close/reopen and can be discarded | Playwright | pass |
| TC-ENH-04 | Members/Clients picked and a saved group are merged without duplicates | Playwright + vitest | pass |
| TC-ENH-05 | Finished batch with failures: Resend queues only failed rows, Export CSV downloads | Playwright + JUnit | pass |
| TC-ENH-06 | Resend refused while sending / when nothing failed / by a non-owner creator | JUnit | pass |
| TC-ENH-07 | CSV cells starting with `= + - @` are prefixed with `'` | JUnit | pass |
| TC-ENH-08 | Unsubscribed list pages, re-subscribe needs OWNER/MANAGER | Playwright + JUnit | pass |
| TC-ENH-09 | Group create keeps only valid distinct emails, capped per Workspace, owner-only delete | JUnit | pass |
| TC-ENH-10 | Removed attachment is released through the reference check; delete releases all | JUnit | pass |

Totals after this pass: business-service 704, vitest 64, Playwright mail 25.
Known limit: the first Playwright run after a cold dev server start can time out once (re-run passes).
