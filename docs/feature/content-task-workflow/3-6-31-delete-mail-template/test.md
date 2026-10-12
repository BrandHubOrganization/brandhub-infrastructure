# Test — Delete Mail Template (FR 3.6.31)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.31 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-1001
- **Mục tiêu:** Xóa mềm mẫu email không còn dùng; lô đã gửi trước đó không bị ảnh hưởng.

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
| TC-MT-12 | PATCH/DELETE template không tồn tại | id lạ | 404 `TEMPLATE_NOT_FOUND` |
| TC-MT-13 | Xóa mềm | DELETE | `deletedAt` set; không còn trong list; GET trả 404 |
| TC-MT-14 | Xóa không ảnh hưởng lô cũ | batch đã có | Batch và deliveries nguyên vẹn |
| TC-MT-15 | Truy cập chéo Workspace | token Workspace A, template của B | 404/403, không lộ dữ liệu |

| TC | Case | Where | Result |
|---|---|---|---|
| TC-ENH-10 | Removed attachment is released through the reference check; delete releases all | JUnit | pass |

## 3. Kết quả

- Toàn bộ test case ở trên đã chạy và đạt; chi tiết số liệu từng đợt ở mục 14–16 của [bản gộp](../3-6-28-32-mail-template/test.md).
- Tổng sau đợt cuối: business-service 704 test, vitest 64, Playwright mail 25, kèm chạy live với Postgres + Mongo + SMTP giả.
- Giới hạn đã biết và việc chưa kiểm (Gmail/Outlook, S3 thật, staging): xem mục 13 và 14.2 của bản gộp.
