# Test — Update Mail Template (FR 3.6.30)

- **FR:** 3.6.30 · **Jira:** DA-1000
- **Mục tiêu:** Sửa một phần mẫu email của mình (hoặc của Workspace nếu là OWNER/MANAGER); mẫu hệ thống chỉ Admin sửa.

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

## 4. Bảo mật

| ID | Case | Mong đợi |
|---|---|---|
| SEC-MT-04 | IDOR template/batch/attachment | 403/404 |
| SEC-MT-06 | Mass assignment (`type`, `workspaceId`, `createdBy` trong body) | Bị bỏ qua |

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
