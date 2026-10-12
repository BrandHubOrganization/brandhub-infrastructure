# Test — Update Mail Template (FR 3.6.30)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.30 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-1000
- **Mục tiêu:** Sửa một phần mẫu email của mình (hoặc của Workspace nếu là OWNER/MANAGER); mẫu hệ thống chỉ Admin sửa.

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
| TC-MT-09 | PATCH một phần | chỉ `name` | Chỉ `name` đổi, `updatedAt` mới |
| TC-MT-10 | PATCH template hệ thống từ Workspace | — | 403 `SYSTEM_TEMPLATE_READ_ONLY` |
| TC-MT-11 | CREATOR sửa template của người khác | — | 403; OWNER/MANAGER thì 200 |
| TC-MT-12 | PATCH/DELETE template không tồn tại | id lạ | 404 `TEMPLATE_NOT_FOUND` |
| TC-MT-15 | Truy cập chéo Workspace | token Workspace A, template của B | 404/403, không lộ dữ liệu |

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
| TC-ENH-10 | Removed attachment is released through the reference check; delete releases all | JUnit | pass |

## 3. Kết quả

- Toàn bộ test case ở trên đã chạy và đạt; chi tiết số liệu từng đợt ở mục 14–16 của [bản gộp](../3-6-28-32-mail-template/test.md).
- Tổng sau đợt cuối: business-service 704 test, vitest 64, Playwright mail 25, kèm chạy live với Postgres + Mongo + SMTP giả.
- Giới hạn đã biết và việc chưa kiểm (Gmail/Outlook, S3 thật, staging): xem mục 13 và 14.2 của bản gộp.
