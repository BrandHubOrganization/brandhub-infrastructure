# Test — View Mail Template (FR 3.6.28)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.28 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-998
- **Mục tiêu:** Xem danh sách, chi tiết, preview mẫu email của Workspace (kèm mẫu hệ thống) và lịch sử các lần gửi.

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

## 3. Kết quả

- Toàn bộ test case ở trên đã chạy và đạt; chi tiết số liệu từng đợt ở mục 14–16 của [bản gộp](../3-6-28-32-mail-template/test.md).
- Tổng sau đợt cuối: business-service 704 test, vitest 64, Playwright mail 25, kèm chạy live với Postgres + Mongo + SMTP giả.
- Giới hạn đã biết và việc chưa kiểm (Gmail/Outlook, S3 thật, staging): xem mục 13 và 14.2 của bản gộp.
