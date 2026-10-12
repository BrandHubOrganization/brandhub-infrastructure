# Test — Create Mail Template (FR 3.6.29)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.29 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-999
- **Mục tiêu:** Tạo mẫu email mới (từ đầu hoặc clone mẫu hệ thống/mẫu Workspace), có biến, ảnh và tệp đính kèm.

## 1. Cách chạy

```bash
# Backend (JUnit): mail template, gửi, worker
cd brandhub-business-service && mvn test -Dtest='Mail*Test'
# Frontend
cd brandhub-web-dashboard && npx vitest run src/pages/mail-templates
cd brandhub-web-dashboard && npx playwright test tests/e2e/mail-templates
```

## 2. Test case của FR này

| ID | Case | Input | Mong đợi |
|---|---|---|---|
| TC-MT-05 | Tạo hợp lệ | `name`, `subject`, `bodyHtml` | 201, `type=CUSTOM`, `createdBy` đúng |
| TC-MT-06 | Tạo thiếu `subject` hoặc `bodyHtml` | rỗng/khoảng trắng | 400 `VALIDATION_ERROR` |
| TC-MT-07 | Clone từ template hệ thống | `cloneFromId` | Có `clonedFromId`, nội dung kế thừa, sửa được |
| TC-MT-08 | Clone từ template Workspace khác | `cloneFromId` thuộc Workspace khác | 404 (không lộ tồn tại) |

| ID | Case | Input | Mong đợi |
|---|---|---|---|
| TC-SAN-01 | Loại `<script>` | `<p>a</p><script>x</script>` | Chỉ còn `<p>a</p>` |
| TC-SAN-02 | Loại event handler | `<a onclick="x()">` | Không còn `onclick` |
| TC-SAN-03 | Loại `javascript:` | `<a href="javascript:...">` | `href` bị bỏ |
| TC-SAN-04 | Giữ thẻ cho phép | `b,i,u,a,ul,ol,li,h1-h3,blockquote,img` | Giữ nguyên |
| TC-SAN-05 | `img` ngoài bucket hệ thống | `src="https://evil.test/x.png"` | Bị loại/từ chối |
| TC-SAN-06 | Body quá 100KB | 101KB | 400 `VALIDATION_ERROR` |
| TC-VAR-01 | Render biến đầy đủ | `Hi {{name}}` + `name=An` | `Hi An` |
| TC-VAR-02 | Escape giá trị | `name=<b>x</b>` | `&lt;b&gt;x&lt;/b&gt;` |
| TC-VAR-03 | Biến thiếu | không có `name` | Dòng vào `rejected`, `MISSING_VARIABLE:name` |
| TC-VAR-04 | Biến built-in | `{{workspaceName}}`, `{{senderName}}` | Tự điền |
| TC-VAR-05 | Biến trong subject | `Hello {{name}}` | Subject đã render |
| TC-VAR-06 | Tên biến sai cú pháp | `{{ten bien}}` | Không coi là biến; giữ nguyên text, cảnh báo ở preview |
| TC-VAR-07 | CSV cố ghi đè built-in | cột `workspaceName` | Giá trị hệ thống thắng |

| ID | Case | Mong đợi |
|---|---|---|
| TC-ATT-01 | Upload PDF hợp lệ ≤5MB | 200 + `attachmentId` |
| TC-ATT-02 | Đuôi `.pdf` nhưng nội dung là exe | 400 `MAIL_ATTACHMENT_INVALID` |
| TC-ATT-03 | Loại không cho phép (`.exe`, `.zip`, `.html`) | 400 |
| TC-ATT-04 | Tệp >5MB | 413/400 |
| TC-ATT-05 | Quá 3 tệp / tổng >10MB | 400 |
| TC-ATT-06 | Tệp chưa gắn quá 24h | Job dọn xóa |
| TC-ATT-07 | Tệp thuộc Workspace khác | Từ chối gắn |
| TC-ATT-08 | Tệp S3 mất trước giờ gửi | Delivery `FAILED` rõ lý do, không gửi thiếu tệp |
| TC-ATT-09 | Ảnh trong nội dung | URL công khai chèn được; sanitize chấp nhận |

| TC | Case | Where | Result |
|---|---|---|---|
| TC-ENH-03 | New template draft survives close/reopen and can be discarded | Playwright | pass |

## 3. Kết quả

- Toàn bộ test case ở trên đã chạy và đạt; chi tiết số liệu từng đợt ở mục 14–16 của [bản gộp](../3-6-28-32-mail-template/test.md).
- Tổng sau đợt cuối: business-service 704 test, vitest 64, Playwright mail 25, kèm chạy live với Postgres + Mongo + SMTP giả.
- Giới hạn đã biết và việc chưa kiểm (Gmail/Outlook, S3 thật, staging): xem mục 13 và 14.2 của bản gộp.
