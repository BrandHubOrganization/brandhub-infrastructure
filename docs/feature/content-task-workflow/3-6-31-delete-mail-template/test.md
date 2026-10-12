# Test — Delete Mail Template (FR 3.6.31)

- **FR:** 3.6.31 · **Jira:** DA-1001
- **Mục tiêu:** Xóa mềm mẫu email không còn dùng; lô đã gửi trước đó không bị ảnh hưởng.

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
| TC-MT-12 | PATCH/DELETE template không tồn tại | id lạ | 404 `TEMPLATE_NOT_FOUND` |
| TC-MT-13 | Xóa mềm | DELETE | `deletedAt` set; không còn trong list; GET trả 404 |
| TC-MT-14 | Xóa không ảnh hưởng lô cũ | batch đã có | Batch và deliveries nguyên vẹn |
| TC-MT-15 | Truy cập chéo Workspace | token Workspace A, template của B | 404/403, không lộ dữ liệu |

| TC | Case | Where | Result |
|---|---|---|---|
| TC-ENH-10 | Removed attachment is released through the reference check; delete releases all | JUnit | pass |

## 4. Bảo mật

| ID | Case | Mong đợi |
|---|---|---|
| SEC-MT-04 | IDOR template/batch/attachment | 403/404 |

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
