# Plan — Send Email via Template (FR 3.6.32)

- **FR:** 3.6.32 · **Jira:** DA-1002
- **Mục tiêu:** Gửi email theo mẫu tới danh sách người nhận: hàng đợi, hạn mức, hẹn giờ/hủy, hủy đăng ký, lịch sử, Admin.
- **Spec:** [spec.md](spec.md) · **Sequence:** [report4_sequence.puml](report4_sequence.puml)

## 1. Mục tiêu và phạm vi

Cho phép thành viên Workspace soạn **mẫu email** có biến, đính kèm tệp/ảnh, rồi **gửi** (ngay hoặc hẹn giờ) cho Client hoặc danh sách người nhận (target customer), có giới hạn tốc độ theo chuẩn Gmail, có link hủy đăng ký, có lịch sử gửi. Admin quản trị thư viện mẫu hệ thống để Workspace clone và để soạn Broadcast (FR 3.10.1).

| Trong phạm vi | Ngoài phạm vi (lần này) |
|---|---|
| CRUD template theo Workspace; clone từ template hệ thống | Contact List lưu sẵn (người nhận dán/CSV lúc gửi) |
| Biến `{{x}}`, preview, gửi thử cho chính mình | Cá nhân hóa `{{fullName}}` trong Broadcast 3.10.1 |
| Gửi ngay + **hẹn giờ** (snapshot nội dung), hủy lịch | Sửa lịch đã hẹn (muốn đổi thì hủy và hẹn lại) |
| Tệp đính kèm + ảnh trong nội dung | Quét virus (chỉ allow-list + magic bytes) |
| Quota theo ngày, throttle, suppression + unsubscribe | Giới hạn theo gói Subscription |
| Lịch sử gửi, thông báo trong app, retention 12 tháng | Thống kê mở mail/click |
| Admin: CRUD template hệ thống + chọn mẫu cho Broadcast | Hàng đợi tách service riêng / đa instance |

## 2. Quyết định đã chốt

| # | Chủ đề | Quyết định |
|---|---|---|
| D1 | Phạm vi | **Theo Workspace** (`/workspaces/{id}/mail-templates`); BA §9 cập nhật |
| D2 | Quyền | OWNER + MANAGER + CREATOR dùng cả 5 chức năng; CLIENT không. Sửa/xóa template: người tạo hoặc OWNER/MANAGER |
| D3 | Người nhận | Dán/upload CSV lúc gửi; tối đa **200 người/lần**; nhiều người; ngoài hệ thống được phép |
| D4 | Kiến trúc gửi | **Async qua outbox**; trả `202 + batchId`; worker gửi nền |
| D5 | Giới hạn | **450/ngày toàn hệ thống**, **100/ngày/Workspace**, 200/lần; cấu hình bằng env |
| D6 | Chống spam | Footer unsubscribe + `suppression list` **theo Workspace gửi**; chỉ áp cho người **ngoài** Workspace |
| D7 | Biến thiếu | Loại dòng đó, gửi phần còn lại, trả `rejected[]` kèm lý do |
| D8 | Tệp | **Cả hai**: tệp đính kèm + ảnh trong nội dung; 5MB/tệp, tối đa 3 tệp, tổng 10MB; allow-list loại + magic bytes |
| D9 | Gắn tệp | **Cả hai**: tệp mặc định gắn vào template; lúc gửi thêm/bớt được |
| D10 | Hẹn giờ | Sau tối thiểu 5 phút, tối đa 30 ngày; **snapshot** nội dung lúc hẹn; hủy được trước giờ gửi; không sửa lịch; múi giờ Workspace |
| D11 | Quota & lịch | Trừ quota theo **ngày gửi thực tế**; hết quota lúc đến giờ thì **dời sang ngày sau** (PENDING) |
| D12 | Lịch sử | OWNER/MANAGER/CREATOR xem toàn bộ; giữ **12 tháng** (xóa nội dung + địa chỉ, giữ số liệu tổng) |
| D13 | Thông báo | Notification trong app cho người tạo khi lô hoàn tất/lỗi (dùng hệ thống notification có sẵn) |
| D14 | Trình soạn | **TipTap** rich-text có chèn biến và ảnh; backend sanitize |
| D15 | Template hệ thống | Seed 4 mẫu; Workspace chỉ **clone**; Admin sửa/xóa; Admin có UI + API quản trị |
| D16 | Broadcast 3.10.1 | Nút "Chọn mẫu" **chỉ sao chép** subject/body vào form; không đổi worker 3.10.1 |
| D17 | Kỹ thuật | Xóa mềm `deletedAt`; sửa bằng `PATCH`; trường `bodyHtml`; From = `MAIL_FROM` hệ thống, **Reply-To = email người gửi** |
| D18 | Điểm vào gửi | Trang template **và** nút trên trang Client (tự điền người nhận và `{{clientName}}`) |

### 2.1 Chỗ khác với spec/Jira gốc (đã chấp thuận)
| Spec/Jira gốc | Thực tế triển khai | Lý do |
|---|---|---|
| `200 { messageId }` đồng bộ | `202 { batchId, ... }` | Gửi hàng loạt qua hàng đợi (D4) |
| `recipientEmail` (một) / `recipients: []` | `recipients: [{email, name?, variables?}]` | Nhiều người nhận (D3) |
| 502 khi SMTP lỗi | 502 chỉ cho **gửi thử** (đồng bộ). Lỗi từng người trong lô → trạng thái `FAILED` + retry | Async |
| Hard delete (sequence) | Soft delete | Spec FR 3.6.31 |
| `body` | `bodyHtml` | Khớp ERD |
| 429 khi vượt quota (Q3b) và "dời ngày sau" (D11) | Gửi ngay: nếu số người hợp lệ vượt quota **còn lại hôm nay** của Workspace → **429**. Hẹn giờ: luôn nhận, dời ngày khi thi hành | Gửi ngay cần phản hồi tức thì; lịch thì không chặn |

## 3. Vai trò và quyền

| Hành động | OWNER | MANAGER | CREATOR | CLIENT | ADMIN hệ thống |
|---|---|---|---|---|---|
| Xem danh sách / chi tiết template | ✔ | ✔ | ✔ | ✘ | ✔ (mẫu hệ thống) |
| Tạo / clone | ✔ | ✔ | ✔ | ✘ | ✔ (mẫu hệ thống) |
| Sửa / xóa template của Workspace | ✔ | ✔ | chỉ của mình | ✘ | — |
| Sửa / xóa template hệ thống | ✘ | ✘ | ✘ | ✘ | ✔ |
| Gửi, gửi thử, preview, hẹn giờ | ✔ | ✔ | ✔ | ✘ | — |
| Xem lịch sử lô / người nhận | ✔ | ✔ | ✔ | ✘ | — |
| Hủy lô đã hẹn | ✔ | ✔ | chỉ lô của mình | ✘ | — |

Backend: `@RequireRole({OWNER, MANAGER, CREATOR})` + kiểm tra sở hữu cho sửa/xóa/hủy. Admin API dùng quyền hệ thống `ADMIN` như các `Admin*Controller` hiện có.

### 4.2 PostgreSQL (cùng DB với `admin_email_outbox`, để enqueue transactional và `FOR UPDATE SKIP LOCKED`)

**`mail_batches`** — một lần bấm gửi
`id uuid pk`, `workspace_id`, `template_id`, `template_name`, `sent_by uuid`, `kind` (`SEND`/`TEST`), `status` (`SCHEDULED`/`QUEUED`/`SENDING`/`COMPLETED`/`CANCELLED`/`FAILED`), `subject`, `body_html` (snapshot chưa gắn biến), `attachments jsonb` (snapshot), `scheduled_at`, `timezone`, `total`, `accepted`, `rejected_count`, `sent_count`, `failed_count`, `suppressed_count`, `created_at`, `completed_at`.

**`mail_deliveries`** — một người nhận
`id uuid pk`, `batch_id fk`, `recipient`, `recipient_name`, `variables jsonb`, `rendered_subject`, `rendered_body_html`, `external_audience boolean` (có chèn footer unsubscribe hay không), `status` (`PENDING`/`SENT`/`FAILED`/`SUPPRESSED`), `attempts int`, `last_error`, `next_attempt_at`, `sent_at`, `event_key unique` (`MAIL:{batchId}:{lower(email)}`, idempotent).

**`mail_send_quota`** — `day date`, `scope` (`SYSTEM`/`WORKSPACE`), `scope_id`, `sent_count int`, PK `(day, scope, scope_id)`. "Ngày" tính theo `Asia/Ho_Chi_Minh`.

**`mail_suppressions`** — `id`, `workspace_id`, `email_lower`, `reason` (`UNSUBSCRIBED`), `created_at`, unique `(workspace_id, email_lower)`.

**`mail_attachments`** (tệp tạm trước khi gắn) — `id`, `workspace_id`, `uploaded_by`, `name`, `content_type`, `size`, `s3_key`, `kind` (`FILE`/`IMAGE`), `created_at`, `bound boolean`; job dọn tệp chưa gắn quá 24h.

Migration đặt ở `docs/database/migrations/` (SQL cho Postgres, JS cho Mongo, kèm cập nhật `init-postgres-v2.sql`, `init-mongo.js`, ERD, DBML — cùng pattern các migration 2026-10-xx).

### 5.2 Gửi
```
POST /workspaces/{id}/mail-templates/{tid}/send
{
  "recipients": [{ "email": "a@x.com", "name": "An", "variables": { "company": "ACME" } }],
  "variables": { "campaign": "Sale 11.11" },     // dùng chung mọi dòng; biến dòng ghi đè
  "attachmentIds": ["..."],                      // bỏ trống = dùng đính kèm mặc định của template; [] = không đính kèm
  "scheduledAt": "2026-11-01T09:00:00+07:00"     // bỏ trống = gửi ngay
}
→ 202 { "batchId", "status": "QUEUED"|"SCHEDULED", "total", "accepted", "rejected": [{ "email", "reason" }], "scheduledAt" }
```
Quy tắc: `recipients` rỗng → 400 `VALIDATION_ERROR`; >200 → 400; email sai/trùng (so sánh không phân biệt hoa thường) → vào `rejected`; thiếu biến → `rejected: MISSING_VARIABLE:x`; tất cả bị loại → 400; gửi ngay vượt quota còn lại → 429 `MAIL_QUOTA_EXCEEDED` (kèm `remainingToday`); `scheduledAt` ngoài [now+5 phút, now+30 ngày] → 400 `MAIL_SCHEDULE_OUT_OF_RANGE`.

### 5.3 Lô và lịch sử
| Method | Path | Mô tả |
|---|---|---|
| GET | `/workspaces/{id}/mail-batches?status=&templateId=&page=&size=` | Danh sách lô |
| GET | `/workspaces/{id}/mail-batches/{bid}?page=&size=&status=` | Chi tiết lô + người nhận phân trang |
| POST | `/workspaces/{id}/mail-batches/{bid}/cancel` | Chỉ lô `SCHEDULED` (409 `MAIL_BATCH_NOT_CANCELLABLE` nếu khác) |
| GET | `/workspaces/{id}/mail-quota` | `{ day, workspaceUsed, workspaceLimit, systemRemaining }` để UI hiển thị |

### 5.5 Công khai
| Method | Path | Mô tả |
|---|---|---|
| GET | `/public/mail/unsubscribe?token=` | Trang xác nhận (HTML, vi/en) |
| POST | `/public/mail/unsubscribe?token=` | Thực hiện hủy (hỗ trợ one-click RFC 8058); idempotent; token ký HMAC, không hết hạn, không tiết lộ thông tin khác |

### 5.6 Admin
| Method | Path | Mô tả |
|---|---|---|
| GET/POST | `/admin/mail-templates` | List / tạo template hệ thống (`SYSTEM_DEFAULT`, `workspaceId=null`) |
| GET/PATCH/DELETE | `/admin/mail-templates/{tid}` | Xem / sửa / xóa mềm |

Mã lỗi mới: `TEMPLATE_NOT_FOUND` 404, `SYSTEM_TEMPLATE_READ_ONLY` 403, `MAIL_QUOTA_EXCEEDED` 429, `MAIL_SCHEDULE_OUT_OF_RANGE` 400, `MAIL_ATTACHMENT_INVALID` 400, `MAIL_BATCH_NOT_CANCELLABLE` 409, `EMAIL_SERVICE_UNAVAILABLE` 502.

### 6.2 Gửi ngay (3.6.32)
1. Người dùng chọn template, dán/upload CSV (FE parse thành `recipients`), điền biến, xem **preview**, có thể **gửi thử**.
2. Backend: kiểm quyền → render từng dòng → loại dòng lỗi → kiểm quota còn lại hôm nay → ghi `mail_batches` + `mail_deliveries(PENDING)` trong một transaction → `202`.
3. Worker (xem 7) gửi nền; mỗi người `SENT`/`FAILED`/`SUPPRESSED`.
4. Hết lô: cập nhật batch `COMPLETED` (hoặc `FAILED` nếu toàn bộ lỗi), gửi notification trong app cho người tạo.

### 6.3 Hẹn giờ
1. Giống 6.2 nhưng có `scheduledAt`; batch `SCHEDULED`; **snapshot** subject/body/đính kèm; không trừ quota.
2. Đến giờ: một job chuyển batch `SCHEDULED → QUEUED`, đặt `next_attempt_at` các delivery.
3. Hủy: `POST .../cancel` → `CANCELLED`, delivery `PENDING` bị bỏ. Không sửa lịch.

### 6.4 Người nhận trong Workspace so với ngoài
- "Trong Workspace" = email trùng `contact_email` của Client profile liên kết Workspace, hoặc email của thành viên active.
- Trong Workspace: là thông báo giao dịch → **không** chèn footer, **không** kiểm suppression.
- Ngoài Workspace: chèn footer + `List-Unsubscribe`/`List-Unsubscribe-Post`; bỏ qua nếu nằm trong `mail_suppressions` của Workspace (`SUPPRESSED`).

### 6.5 Hủy đăng ký
Người nhận bấm link → trang công khai → xác nhận → `mail_suppressions(workspace_id, email)`. Các lần gửi sau của **Workspace đó** bỏ qua email này; Workspace khác và Broadcast Admin không bị ảnh hưởng.

### 6.6 Admin
1. Admin console có trang quản lý mẫu hệ thống (CRUD) — cùng form TipTap.
2. Form soạn Broadcast 3.10.1 có nút "Chọn mẫu": mở danh sách mẫu hệ thống, chọn → **sao chép** subject/body vào form (không biến). Worker 3.10.1 giữ nguyên.
3. Seed 4 mẫu: *Chào mừng Client mới*, *Yêu cầu duyệt nội dung*, *Thông báo chiến dịch / khuyến mãi*, *Báo cáo hiệu quả định kỳ*.

### 6.7 Điểm vào từ trang Client
Nút "Gửi email" ở trang Client mở modal gửi với `recipients = [contact_email]`, `variables.clientName = displayName`/`contactName`; client chọn template rồi gửi như 6.2.

## 7. Worker và giới hạn tốc độ

- **Deliver loop** (mỗi ~5 giây): chọn delivery `PENDING` và `next_attempt_at <= now` bằng `FOR UPDATE SKIP LOCKED`, theo thứ tự `next_attempt_at`.
- **Quota**: trước khi gửi, tăng nguyên tử `mail_send_quota` SYSTEM và WORKSPACE nếu còn dưới cap; hết cap thì `next_attempt_at = 00:00 ngày kế (Asia/Ho_Chi_Minh)`, giữ PENDING.
- **Throttle**: tối đa 20 mail/phút toàn hệ thống (cấu hình) để tránh burst bị Gmail đánh dấu.
- **Retry**: tối đa 5 lần, backoff 1 → 5 → 15 → 60 phút; sau đó `FAILED` kèm `last_error`.
- **Idempotent**: `event_key` unique; xử lý crash giữa lúc gửi và commit là at-least-once (giống `AdminEmailOutbox`), ghi nhận trong tài liệu.
- **Guard dev**: dùng lại `admin.mail.allowed-recipients` và `suppressed-domain` của outbox hiện có để dev không gửi mail thật.
- **Job lịch**: mỗi phút chuyển batch `SCHEDULED` đến hạn. **Job retention**: hằng ngày xóa `mail_deliveries` quá 12 tháng, xóa `body_html` của batch tương ứng. **Job dọn tệp** chưa gắn quá 24h.
- `MailService` thêm hàm gửi có tệp đính kèm, có Reply-To và header List-Unsubscribe, **ném** `EmailDeliveryException` khi lỗi; 4 hàm cũ giữ nguyên hành vi.

## 10. Cấu hình

| Property / env | Mặc định | Ý nghĩa |
|---|---|---|
| `MAIL_QUOTA_SYSTEM_PER_DAY` | 450 | cap toàn hệ thống |
| `MAIL_QUOTA_WORKSPACE_PER_DAY` | 100 | cap mỗi Workspace |
| `MAIL_MAX_RECIPIENTS_PER_SEND` | 200 | tối đa mỗi lần gửi |
| `MAIL_THROTTLE_PER_MINUTE` | 20 | tốc độ gửi |
| `MAIL_MAX_ATTEMPTS` | 5 | số lần thử |
| `MAIL_UNSUBSCRIBE_SECRET` | (bắt buộc) | ký token hủy |
| `MAIL_ATTACHMENT_MAX_BYTES` | 5MB | mỗi tệp |
| `MAIL_RETENTION_MONTHS` | 12 | giữ lịch sử |
| `MAIL_PUBLIC_BASE_URL` | URL backend công khai | dựng link unsubscribe |

## 11. Kế hoạch kiểm thử

| Tầng | Nội dung chính |
|---|---|
| JUnit (service) | CRUD + quyền (tạo/sửa/xóa của người khác), clone, template hệ thống read-only, soft delete, sanitize (XSS payload), render biến (thiếu biến, escape), recipients (rỗng/trùng/sai/quá 200), phân loại trong/ngoài Workspace, suppression, quota (còn/hết, dời ngày), hẹn giờ (biên 5 phút/30 ngày, hủy, snapshot), retry/backoff, `EmailDeliveryException` → 502 cho gửi thử, attachment (loại, magic bytes giả đuôi, kích thước) |
| JUnit (worker) | `SKIP LOCKED`, idempotent `event_key`, throttle, crash giữa chừng |
| Vitest | Parse biến, parse CSV (dấu phẩy/ngoặc kép/BOM/dòng trống), validate form |
| Playwright E2E | List/tạo/sửa/xóa, gửi ngay (mock), hẹn giờ + hủy, upload CSV có dòng lỗi, quota hiển thị, gửi từ trang Client |
| Integration live | Backend thật + Postgres + Mongo + SMTP giả (GreenMail/MailHog): gửi 1 và nhiều người, hết quota → dời ngày (chỉnh đồng hồ/cap nhỏ), unsubscribe thật, header `List-Unsubscribe`, tệp đính kèm tới hộp thư |
| Bảo mật | Truy cập chéo Workspace, token unsubscribe giả mạo, SSRF/URL ảnh ngoài bucket, upload file giả mạo |

## 12. Thứ tự triển khai và đề xuất tách Jira

| Bước | Nội dung | Gợi ý Jira |
|---|---|---|
| 1 | Migration Postgres + Mongo, entity/repository, cấu hình | DA-998 (nền) |
| 2 | Template CRUD + RBAC + sanitize + clone + preview | DA-998, DA-999, DA-1000, DA-1001 |
| 3 | Tệp đính kèm + ảnh (S3, magic bytes) | DA-1256 |
| 4 | Engine gửi: batch, deliveries, worker, quota, throttle, retry, gửi thử | DA-1002 |
| 5 | Hẹn giờ + hủy + snapshot; quota; suppression + unsubscribe công khai | DA-1257 |
| 6 | Lịch sử, notification, retention | DA-1258 |
| 7 | FE Workspace: list/form/modal gửi/lô | DA-998..DA-1002 |
| 8 | FE trang Client + Admin console + Broadcast picker + seed 4 mẫu | DA-1259 |
| 9 | Docs: cập nhật spec/ERD/DBML/BA, test report | — |

Ghi chú: Jira gốc chỉ có 5 task; 4 task mở rộng DA-1256..DA-1259 đã được tạo dưới DA-939 (2026-10-12) và gán cho chủ task.

## 13. Giả định (đã được chủ task đồng ý 2026-10-12)

1. Múi giờ "ngày" của quota là `Asia/Ho_Chi_Minh`; múi giờ hẹn giờ lấy từ `settings.timezone` của Workspace, mặc định như trên.
2. Throttle 20 mail/phút và backoff 1/5/15/60 phút là giá trị đề xuất, cấu hình được.
3. Token unsubscribe không hết hạn; hủy là idempotent.
4. Trang unsubscribe công khai chỉ hiển thị tên Workspace và email đã che một phần.
5. Template hệ thống hiển thị cho mọi Workspace và không đếm vào quota/giới hạn số template.
6. Không giới hạn số template mỗi Workspace trong lần này.
7. Gửi thử không tính quota nhưng vẫn dùng SMTP chung, giới hạn 10 lần/giờ/người dùng.
8. Ảnh chèn vào nội dung là URL công khai trên S3; ảnh bị xóa khỏi S3 thì mail cũ không hiển thị ảnh (chấp nhận).
9. Retention xóa địa chỉ nhận và nội dung đã render sau 12 tháng, giữ số liệu tổng.
10. SMTP hiện là Gmail dùng chung; cap 450 chỉ là biên an toàn, đổi nhà cung cấp thì chỉnh env.

## 14. Rủi ro

| Rủi ro | Giảm thiểu |
|---|---|
| Gmail đánh dấu spam / khóa tài khoản SMTP | Cap, throttle, unsubscribe, Reply-To rõ ràng, theo dõi `FAILED` |
| XSS / phishing qua HTML do user nhập | Sanitize allow-list, escape biến, chỉ ảnh từ bucket hệ thống |
| Tệp độc hại | Allow-list + magic bytes; ghi rõ không quét virus |
| Gửi trùng khi crash | `event_key` unique; at-least-once ghi rõ |
| Phạm vi lớn so với 5 task Jira | Tách task con, làm theo thứ tự §12 |
| Worker đơn instance | Dùng `SKIP LOCKED` sẵn; ghi rõ giới hạn đa instance khi scale |

## Addendum B — Kỹ thuật (2026-10-28): drag-drop block builder + multi-scope broadcast — ĐÃ TRIỂN KHAI (2026-10-29)

> Chi tiết kỹ thuật cho Addendum B (nghiệp vụ, B1-B10) đã ghi ở [spec.md](spec.md#addendum-b-2026-10-28-drag-drop-block-builder--multi-scope-broadcast--đề-xuất-chưa-chốt). Đã triển khai; xem B.12 cho API thực tế (khác đề xuất ban đầu ở B.2) và B.13 cho frontend. Quyết định chính thức vẫn chờ chủ task xác nhận.

### B.1 Schema thay đổi (Mongo — `mail_templates`)

`MailTemplateDocument.java` thêm field:

| Field | Kiểu | Ghi chú |
|---|---|---|
| `scope` | `MailTemplateScope` (enum mới, 6 giá trị) | Thay `type` (giữ `type` tạm thời cho backward-compat đọc, xem bảng map dưới) |
| `agencyId` | `String?` | Set cho `AGENCY_INTERNAL`/`AGENCY_CLIENT`; null cho scope còn lại |
| `layoutJson` | `String` | Danh sách block (B9), nguồn thật của nội dung — thay vai trò input trực tiếp của `bodyHtml` |
| `bodyHtml` | `String` (giữ nguyên) | Trở thành **render-cache**: backend render từ `layoutJson` → ghi lại `bodyHtml` mỗi lần save, dùng để preview nhanh và làm snapshot lúc gửi (D17 cũ không đổi: field tên vẫn `bodyHtml`) |

**Map backward-compat `type` → `scope`** (migration 1-lần, rõ ràng không mơ hồ):
- `type = SYSTEM_DEFAULT` → `scope = ADMIN_SYSTEM_BROADCAST`, `agencyId = null` (Admin đã là chủ sở hữu duy nhất của SYSTEM_DEFAULT, đúng khớp quyền B5)
- `type = CUSTOM` → `scope = WORKSPACE_MANAGER`, `agencyId = null` (CUSTOM hiện tại luôn gắn `workspaceId`, đúng khớp D1 cũ)
- `type` field **giữ lại** sau migration (không xoá cột) để `MailTemplateServiceImpl`/`MailSendService` cũ còn đọc được trong lúc chuyển đổi code dần; enum `MailTemplateType` thêm Javadoc `@Deprecated` trỏ sang `scope`, xoá hẳn ở 1 PR dọn dẹp sau khi toàn bộ nhánh code chuyển xong (không nằm trong phạm vi B1-B10).

**Sửa 2026-10-28, sau khi xác minh validator thật** (bản đầu thiếu bước này — đã thiếu sót): `init-mongo.js:380-413` có `$jsonSchema` validator với `validationAction: 'error'`, chặn cứng `required: [..., 'type', ...]` + `type: { enum: ['SYSTEM_DEFAULT','CUSTOM'] }` + `bodyHtml` bắt buộc `minLength: 1`. Thêm field mới **không đủ** — phải nới validator trước, nếu không insert/update sẽ bị Mongo reject ngay ở tầng DB. Migration theo đúng pattern DRY_RUN đã có của repo (`docs/database/migration-mongo/2026-10-18-post-schedule-fields.js`), đặt tại `docs/database/migration-mongo/2026-10-28-mail-template-scope.js`:
1. Đọc validator hiện tại qua `getCollectionInfos`, thêm `scope: {enum: [6 giá trị mới]}` (optional, không vào `required` — giữ `type` cũ cũng optional dần theo B.1), `agencyId: {bsonType: ['string','null']}`, `layoutJson: {bsonType: ['string','null']}` vào `properties`; **bỏ** `bodyHtml` khỏi `required` (đổi `minLength: 1` → cho phép rỗng, vì B.1 coi `bodyHtml` là render-cache có thể trống tới khi save lần đầu).
2. Chạy `collMod` cập nhật validator (DRY_RUN mặc định, cần cờ `APPLY=true` giống file mẫu).
3. Sau khi validator nới xong, chạy bước backfill data (vòng `forEach` cập nhật `scope`/`agencyId`/`layoutJson` cho document cũ) **trong cùng file**, chỉ chạy khi `APPLY=true`:
```javascript
db.mail_templates.find({ scope: { $exists: false } }).forEach(doc => {
  const scope = doc.type === "SYSTEM_DEFAULT" ? "ADMIN_SYSTEM_BROADCAST" : "WORKSPACE_MANAGER";
  db.mail_templates.updateOne({ _id: doc._id }, {
    $set: { scope, agencyId: null, layoutJson: JSON.stringify({ version: 1, blocks: [] }) }
  });
});
db.mail_templates.createIndex({ scope: 1, workspaceId: 1 });
db.mail_templates.createIndex({ scope: 1, agencyId: 1 });
```
`layoutJson` rỗng cho template cũ — xem B.7 (rủi ro migration) cho cách UI xử lý. `init-mongo.js` (dùng cho môi trường tạo mới từ đầu) cũng cần cập nhật song song để khớp validator mới, tránh lệch giữa môi trường fresh-seed và môi trường đã migrate.

**Migration Postgres bổ sung** (sửa 2026-10-28, sau khi xác minh schema thật — bản đầu giả định sai "không cần đổi schema"):
- `mail_send_quota.scope` hiện là `VARCHAR(16) CHECK (scope IN ('SYSTEM','WORKSPACE'))` — CHECK constraint cứng **chặn** giá trị `AGENCY` mới. Cần `ALTER TABLE mail_send_quota DROP CONSTRAINT <tên constraint cũ>, ADD CONSTRAINT mail_send_quota_scope_check CHECK (scope IN ('SYSTEM','WORKSPACE','AGENCY'))`. `scope_id VARCHAR(64)` đã đủ dài chứa UUID, không cần đổi.
- `mail_suppressions.workspace_id` hiện `UUID NOT NULL` — **không thể** dùng `workspace_id = NULL` làm khoá cho suppression phạm vi hệ thống (ADMIN_SYSTEM_BROADCAST) như ý tưởng ban đầu. Thay bằng: `ALTER TABLE mail_suppressions ALTER COLUMN workspace_id DROP NOT NULL;` + `CREATE UNIQUE INDEX mail_suppressions_system_email_idx ON mail_suppressions (email_lower) WHERE workspace_id IS NULL;` (giữ unique constraint hiện có `(workspace_id, email_lower)` cho các dòng có `workspace_id`, thêm index riêng cho dòng `workspace_id IS NULL`).
- Đặt 2 ALTER trên trong cùng migration SQL `docs/database/migrations/2026-10-28-mail-template-scope-postgres.sql`, chạy trước khi deploy code đọc `scope=AGENCY`/suppression hệ thống.

### B.2 API contract mới/sửa

**Sửa `POST/PATCH /api/v1/workspaces/{id}/mail-templates[/{tid}]`** — request thêm `layoutJson` (bắt buộc khi tạo mới), bỏ `bodyHtml` khỏi input (chỉ output):
```json
POST /api/v1/workspaces/{id}/mail-templates
{
  "name": "Thông báo chiến dịch",
  "subject": "Cập nhật {{campaignName}}",
  "layoutJson": "{\"version\":1,\"blocks\":[{\"id\":\"b1\",\"type\":\"header\"},{\"id\":\"b2\",\"type\":\"heading\",\"props\":{\"text\":\"Xin chào\",\"align\":\"left\"}}]}",
  "scope": "WORKSPACE_MANAGER",
  "attachmentIds": []
}
→ 201 { "success": true, "data": { "id", "scope", "layoutJson", "bodyHtml" (rendered), ... } }
```

**Mới `GET/POST /api/v1/agencies/{agencyId}/mail-templates`** — kho riêng cho `AGENCY_INTERNAL`/`AGENCY_CLIENT`, cùng shape response, thêm query `?scope=AGENCY_INTERNAL|AGENCY_CLIENT` bắt buộc (không cho list lẫn 2 scope trong 1 call, tránh nhầm kho).

**Mới `POST /api/v1/admin/mail-templates` mở rộng** — thêm `scope: "ADMIN_SYSTEM_BROADCAST" | "TRANSACTIONAL_AUTO"` bắt buộc trong body (trước đây ngầm định luôn SYSTEM_DEFAULT).

**Sửa `POST .../mail-templates/{tid}/send`** — request thêm optional `recipients` giờ **không bắt buộc** khi scope tự suy ra được (B3); nếu client không gửi `recipients`, backend tự lấy theo scope rồi vẫn áp cùng pipeline `rejected[]`/quota/preview. Response giữ nguyên `202 {batchId,...}`.

**Thay đổi so với đề xuất**: endpoint `suggested-recipients` **không** được xây. Thay bằng `recipient-preview` (B.12) và việc backend tự suy người nhận khi `recipients` rỗng (B3).

### B.3 Error code mới

| Mã | HTTP | Tình huống |
|---|---|---|
| `INVALID_SCOPE` | 400 | `scope` không nằm trong 6 giá trị hợp lệ, hoặc không khớp endpoint gọi (vd gửi `AGENCY_INTERNAL` qua endpoint Workspace) |
| `AGENCY_SCOPE_FORBIDDEN` | 403 | Không phải Agency OWNER của `agencyId` mà cố tạo/sửa/gửi template `AGENCY_INTERNAL`/`AGENCY_CLIENT` |
| `ADMIN_SCOPE_FORBIDDEN` | 403 | Không phải Admin mà cố tạo/sửa template `ADMIN_SYSTEM_BROADCAST`/`TRANSACTIONAL_AUTO` |
| `BLOCK_SCHEMA_INVALID` | 400 | `layoutJson` parse lỗi, hoặc chứa `type` không nằm trong 9 block B9, hoặc thiếu field bắt buộc của 1 block (vd `cta_button` thiếu `label`) |
| `LAYOUT_EMPTY` | 400 | `layoutJson.blocks` rỗng (tương đương rule cũ "cần ít nhất 1 khối") |
| `TRANSACTIONAL_RECIPIENT_INVALID` | 400 | `TRANSACTIONAL_AUTO` enqueue thiếu đúng 1 user cụ thể (không phải danh sách) |

### B.4 Recipient lookup theo scope (sửa 2026-10-28, sau khi xác minh `MailRecipientLookup.java` thật)

**Tên method bản đầu sai** — `MailRecipientLookup` thật chỉ có 2 method: `candidates(UUID workspaceId, String q, int limit)` (search/autocomplete, trả `List<Candidate(email,name,source)>`) và `internalEmails(UUID workspaceId)` (trả `Set<String>` — gộp CHUNG member + client liên kết workspace trong 1 UNION query, **không tách riêng** 2 nhóm). Không có `clientsOfWorkspace()`/`membersOfWorkspace()` như bản đầu viết.

```
resolveRecipients(template):
  switch template.scope:
    CAMPAIGN_BROADCAST    -> campaign = mediaCampaignRepository.findById(campaignId)
                              workspaceId = workspaceMediaPackageRepository.findById(campaign.workspaceMediaPackageId).workspaceId
                              return mailRecipientLookup.clientsOnly(workspaceId)            // MỚI — tách riêng Client-only từ internalEmails(), vì CAMPAIGN_BROADCAST chỉ nhắm Client, không phải member nội bộ
    WORKSPACE_MANAGER     -> return mailRecipientLookup.internalEmails(workspaceId)          // tái dùng nguyên — gộp member+client đúng ý "thông báo workspace" (D3 cũ coi cả 2 là "trong Workspace")
    AGENCY_INTERNAL       -> return agencyMemberRepository.findByAgencyId(agencyId)
                                .map(m -> emailOf(m.getUserId()))                           // tái dùng nguyên, đã có
    AGENCY_CLIENT         -> workspaces = workspaceRepository.findByAgencyId(agencyId)
                              return workspaces.flatMap(w -> mailRecipientLookup.clientsOnly(w.getId()))
                                .distinct()                                                  // MỚI — dùng chung method clientsOnly() mới ở trên, gộp qua nhiều workspace
    ADMIN_SYSTEM_BROADCAST-> return userRepository.findAllActive()                           // MỚI — toàn hệ thống, cần xác nhận nguồn (UserRepository hay riêng view)
    TRANSACTIONAL_AUTO    -> return [singleUserEmail]                                        // không qua resolver này, caller truyền thẳng 1 email khi enqueue
```

**Việc mới cần viết trong `MailRecipientLookup`**: method `clientsOnly(UUID workspaceId)` — tách riêng phần `client_profiles` khỏi UNION hiện có của `internalEmails()` (query hiện tại gộp `workspace_members`+`users` và `workspace_members`+`client_profiles` bằng UNION — tách bằng cách chỉ giữ nhánh thứ 2, không viết lại từ đầu).

### B.5 Worker/quota (`MailDeliveryService` / `MailQuotaService`)

- `MailQuotaService.tryConsume(workspaceId, day)` hiện khoá cứng theo `workspaceId` — thêm overload `tryConsume(scope, scopeId, day)` nhận `scopeId` là `workspaceId` HOẶC `agencyId` HOẶC hằng số `"SYSTEM"` tuỳ scope; bảng `mail_send_quota` đã có cột `scope`/`scope_id` tổng quát sẵn (§4.2) — không cần đổi schema Postgres, chỉ đổi code gọi.
- `ADMIN_SYSTEM_BROADCAST`/`TRANSACTIONAL_AUTO`: **không** áp quota per-workspace (vì không gắn `workspaceId`) — chỉ áp quota `SYSTEM` (450/ngày hiện có); `AGENCY_INTERNAL`/`AGENCY_CLIENT`: áp quota mới theo `agencyId` (cap riêng, đề xuất mặc định bằng `MAIL_QUOTA_WORKSPACE_PER_DAY` dùng chung config, không thêm env mới trừ khi cần tách).
- **Cap 200/lần** (`MAIL_MAX_RECIPIENTS_PER_SEND`, chốt 2026-10-28): `ADMIN_SYSTEM_BROADCAST` **không áp** cap này — gửi toàn hệ thống có thể vượt xa 200, vẫn đi qua `mail_deliveries` hàng loạt bình thường, bị giới hạn tự nhiên bởi throttle 20 mail/phút (D5 cũ) nên không burst, chỉ mất lâu hơn để gửi hết. Các scope còn lại giữ nguyên cap 200.
- **Unsubscribe cho `ADMIN_SYSTEM_BROADCAST`** (chốt 2026-10-28): **có** chèn footer + `List-Unsubscribe` như đối tượng "ngoài" (`externalAudience = true`) dù gửi nội bộ hệ thống — tránh bị Gmail đánh dấu spam khi gửi khối lượng lớn, user có quyền tắt thông báo loại này; suppression dùng `mail_suppressions.workspace_id IS NULL` làm khoá đặc biệt cho scope hệ thống (cần ALTER nullable trước — xem B.1 "Migration Postgres bổ sung"), không đụng suppression của từng Workspace (unique index riêng cho nhánh `workspace_id IS NULL`).
- `MailDeliveryService.process()` dòng tính `externalAudience` — mở rộng: với `AGENCY_INTERNAL` thì "trong" = thuộc `agency_members` của đúng `agencyId` (không chèn unsubscribe); với `ADMIN_SYSTEM_BROADCAST` luôn coi là "ngoài" (chèn unsubscribe, theo quyết định trên).
- `TRANSACTIONAL_AUTO` không qua `mail_batches`/CSV — enqueue thẳng 1 `mail_deliveries` row với `batchId` tự sinh kind=`TRANSACTIONAL`, tái dùng `deliverNext()` loop sẵn có (không viết worker riêng).

### B.6 Test plan bổ sung

| Tầng | Nội dung mới |
|---|---|
| JUnit (service) | `scope` × quyền (6 scope × role sai → 403 đúng mã); `layoutJson` parse lỗi → `BLOCK_SCHEMA_INVALID`; migration map `type`→`scope` idempotent; render engine 9 block → HTML đúng escape |
| JUnit (recipient) | Mỗi scope trả đúng tập email kỳ vọng (mock `AgencyMemberRepository`/`WorkspaceRepository`/`MailRecipientLookup`); `AGENCY_CLIENT` dedupe qua nhiều workspace |
| JUnit (worker) | Quota theo `agencyId`/`SYSTEM` không lẫn với `workspaceId`; `ADMIN_SYSTEM_BROADCAST` bỏ qua cap 200 nhưng vẫn throttle 20/phút; `TRANSACTIONAL_AUTO` không rơi vào `mail_batches` |
| Vitest | Drag-drop reorder block giữ đúng thứ tự `layoutJson`; validate block props client-side trước submit |
| Playwright E2E | Tạo template bằng block builder → preview → gửi (mock) cho từng kho (Agency builder riêng, Workspace builder cũ, Admin console) |
| Integration live | Seed template cũ (`type=CUSTOM`) → chạy migration → load lại qua API mới vẫn đúng `scope=WORKSPACE_MANAGER` |

### B.7 Rủi ro / migration an toàn

- Template cũ có `bodyHtml` TipTap tự do (HTML tuỳ ý, không map được sang 9 block cố định) — **không** cố gắng tự động convert HTML → block (rủi ro render sai/mất định dạng). Đề xuất: sau migration B.1, `layoutJson` của các bản ghi cũ để rỗng (`blocks: []`); FE khi mở 1 template cũ trong block builder hiển thị banner "Mẫu này soạn trước khi có trình kéo-thả — vui lòng tạo lại bằng khối mới" và khoá nút Lưu cho tới khi người dùng thêm ít nhất 1 block thật (dùng lại rule `LAYOUT_EMPTY` sẵn có), **không** thêm block `legacy_html` đặc biệt để tránh vòng đời block-type thứ 10 không nằm trong B9 đã chốt.
- Đổi `type` → `scope` là thay đổi có khả năng breaking cho FE hiện tại nếu đã có code đọc field `type` — vì FE chưa code (B10: backend-first), rủi ro này bằng 0 trong lần triển khai này, chỉ cần backend tự nhất quán.

### B.8 Rate-limit API (bổ sung 2026-10-28, sửa lại 2026-10-28 sau khi xác minh chuẩn repo)

**Không cần code mới** — đã xác minh: rate-limit theo chuẩn repo nằm ở **`brandhub-api-gateway`** (Spring Cloud Gateway), không phải trong từng service. Route `business-protected` (`application.yml:86-93`, pattern `Path=/api/v1/**`) đã áp sẵn filter `JwtAuthFilter` + `RateLimit` (`RateLimitGatewayFilterFactory.java:21-48`, Redis INCR+EXPIRE theo `X-User-Id`, trả 429 kèm header `X-RateLimit-*`/`Retry-After`) cho **mọi** route REST đã xác thực — bao gồm sẵn `/api/v1/workspaces/{id}/mail-templates*`, `/send`, `/suggested-recipients` vì đều khớp `/api/v1/**`. Route public mới nếu có (vd endpoint public khác ngoài `/public/mail/unsubscribe` đã có sẵn `mail-public` route, `application.yml:53-59`) thì khai báo route riêng trong `api-gateway` kèm filter `RateLimit`, theo đúng mẫu `mail-public`.

`ChatRateLimiter` (business-service) là **ngoại lệ cố ý**, chỉ áp cho đường WebSocket/STOMP (`/ws/chat`) — nơi gateway không thể áp HTTP filter lên từng frame sau khi đã nâng cấp kết nối, không phải mẫu chuẩn cho REST endpoint. **Không nhân bản `ChatRateLimiter` cho mail-template** (bản B.8 trước đó đề xuất `MailApiRateLimiter` — sai chuẩn, đã loại bỏ). Nếu sau này có endpoint non-HTTP cho mail-template (không có trong B1-B10), mới cân nhắc limiter riêng ở service.

### B.9 Xác nhận lại trước khi Admin gửi broadcast quy mô lớn (bổ sung 2026-10-28)

**Chưa có pattern re-auth/OTP/confirm-token sẵn trong hệ thống** (đã rà `AuthController`/`AdminController`, không tìm thấy) — thiết kế mới, đơn giản nhất, không thêm hạ tầng OTP mới:
- `POST .../mail-templates/{tid}/send` khi `scope = ADMIN_SYSTEM_BROADCAST` **và** số recipient suy ra được > 1000 (ngưỡng cấu hình `mail.admin-broadcast-confirm-threshold`, mặc định 1000) → yêu cầu thêm field `confirmPassword` trong request. **Xác minh 2026-10-28**: không có method `verifyPassword()` export sẵn ở `AuthController`/`AuthServiceImpl` để gọi lại — `AuthServiceImpl` tự gọi `passwordEncoder.matches(rawPassword, user.getPasswordHash())` trực tiếp nhiều chỗ (vd dòng 201, 388), không bọc thành API public riêng. Service gửi mail (`MailSendService` hoặc tương đương) **tự inject** `PasswordEncoder` (Spring bean có sẵn) + repository lấy `passwordHash` của user hiện tại, gọi thẳng `passwordEncoder.matches(confirmPassword, currentUser.getPasswordHash())` — không gọi qua `AuthServiceImpl`. Thiếu/sai `confirmPassword` → 403 `ADMIN_BROADCAST_CONFIRMATION_REQUIRED` kèm `recipientCount` để FE hiển thị cảnh báo trước khi hỏi lại mật khẩu.
- Dưới ngưỡng 1000 recipient: gửi bình thường, không yêu cầu xác nhận thêm — tránh phiền Admin cho broadcast nhỏ.
- Không áp dụng `confirmPassword` cho `send-test` (đồng bộ, 1 người, không rủi ro quy mô).

### B.11 Sanitize block props (bổ sung 2026-10-28, bắt buộc kỹ thuật — không phải tùy chọn)

Khi render `layoutJson` → `bodyHtml`, mọi field string trong block props **phải** HTML-escape trước khi chèn vào template (áp dụng tương đương mức độ nghiêm ngặt của sanitize allow-list cũ D14, dù không còn dùng TipTap):
- `heading.text`, `paragraph.text`, `contact_strip` nội dung tĩnh, `cta_button.label`, `image_banner.imageAlt`: escape HTML entity chuẩn (`&lt;`, `&gt;`, `&amp;`, `&quot;`, `&#39;`) trước khi nội suy vào HTML — ngăn injection qua text field tưởng chừng vô hại.
- `cta_button.custom_url`, `image_banner` URL: validate scheme **chỉ cho phép** `http://`/`https://` (khi `url_type = custom`/ảnh tuỳ ý); từ chối `javascript:`, `data:`, `vbscript:`, hoặc scheme khác → `BLOCK_SCHEMA_INVALID` (B.3). URL ảnh từ bucket hệ thống (upload qua `/images`) không cần validate scheme (đã kiểm soát nguồn).
- Validate này nằm trong cùng tầng với `BLOCK_SCHEMA_INVALID` (B.3), chạy ở backend lúc save **và** lúc render (không chỉ FE), vì `layoutJson` có thể bị gửi thẳng qua API bỏ qua FE.

**Chưa chốt — cần chủ task duyệt**: toàn bộ B.1-B.11 ở trạng thái đề xuất (2 điểm "mở" ban đầu ở B.5 — unsubscribe cho ADMIN_SYSTEM_BROADCAST, cap 200 — đã chốt 2026-10-28; B.8-B.11 bổ sung sau rà soát bảo mật/rate-limit riêng, dựa trên `ChatRateLimiter` có sẵn tái dùng cho B.8, thiết kế mới cho B.9 vì chưa có pattern sẵn). Sau khi duyệt sẽ merge vào mục "Quyết định đã chốt" tương ứng và bắt đầu code backend theo B10 (nghiệp vụ, ở `spec.md`, nói thứ tự triển khai backend-first).

### B.12 Triển khai thực tế (2026-10-29)

| Endpoint | Quyền | Ghi chú |
|---|---|---|
| `GET/POST/PATCH/DELETE /api/v1/agencies/{agencyId}/mail-templates` | Agency OWNER | Kho `AGENCY_INTERNAL`/`AGENCY_CLIENT`, CRUD |
| `GET /api/v1/agencies/{agencyId}/mail-templates/{tid}/recipient-preview` | Agency OWNER | `{ total, sample[10] }` |
| `POST /api/v1/workspaces/{id}/mail-templates/{tid}/send` | OWNER/MANAGER/CREATOR của Workspace | Mẫu Agency: Workspace phải thuộc Agency và người gửi là Agency OWNER |
| `POST /api/v1/workspaces/{id}/mail-templates/{tid}/preview` | như trên | Owner agency xem trước được mẫu Agency (`findPreviewable`) |
| `POST /api/v1/admin/mail-templates/{tid}/send` | ADMIN (rule `/api/v1/admin/**`) | `ADMIN_SYSTEM_BROADCAST`, batch `workspace_id` null, cần `confirmPassword` khi vượt ngưỡng (B.9) |
| `POST /api/v1/admin/mail-templates/{tid}/send-test` | ADMIN | Gửi 1 bản tới chính Admin |
| `GET /api/v1/admin/mail-templates/{tid}/recipient-preview` | ADMIN | `{ total, sample[10] }` |

**Mã nguồn chính (backend)**: `MailSendService` (`send`/`sendSystem`/`deliver`, `previewSystemRecipients`/`previewAgencyRecipients`, `sendTestSystem`), `MailTemplateServiceImpl.findPreviewable`, `MailBlockRenderer`, `UnsubscribeTokenService` (token `system`), `MailSuppressionStore` (danh sách chặn hệ thống), `UserNotificationService.mailBatchFinished` (không link khi không có Workspace).

**Quy tắc bảo mật đã áp dụng**
- Đường Workspace không bao giờ tự suy ra người nhận cho `ADMIN_SYSTEM_BROADCAST`, vẫn áp cap 200/lần và không có nhánh xác nhận mật khẩu admin; `TRANSACTIONAL_AUTO` bị ẩn khỏi Workspace (truy vấn danh sách loại trừ và `findVisible` từ chối).
- Admin gửi bằng đường riêng; cap và xác nhận mật khẩu (B.9) chỉ áp ở đó.
- Quyền Agency dùng `agency_members.role = OWNER` (khớp với CRUD Agency).
- Mọi chuỗi trong block đều HTML-escape; URL chỉ cho `http(s)` (B.11).

**Migration đã chạy**: Mongo `2026-10-28-mail-template-scope.js` (đã sửa lỗi `required: []` khiến MongoDB từ chối) đã APPLY trên Atlas dùng chung, 4 document được backfill `scope`; Postgres `2026-10-28-mail-template-scope-postgres.sql` đã chạy trên DB Docker local. Staging/production (nếu có) cần chạy riêng.

### B.13 Frontend

- **Web**: `pages/mail-templates/blocks.ts` (kiểu block, validate, render preview), `components/BlockBuilder.tsx` (palette, kéo thả HTML5 + nút lên/xuống/xoá, animation GSAP Flip, tôn trọng `prefers-reduced-motion`), `TemplateFormDialog` dựa trên builder và có chọn scope, trang Agency `/agency/:id/mail-templates` (mục sidebar chỉ cho Owner agency), `AdminBroadcastDialog` (gửi, gửi thử, xem trước người nhận, xác nhận mật khẩu), `SendMailDialog` chế độ Agency (ẩn ô người nhận, hiện số người). TipTap `MailBodyEditor` đã xoá.
- **Mobile**: `MailTemplatesScreen`/`MailSendScreen` (xem và gửi, không có kéo thả), nhóm theo scope gồm cả mẫu Agency, mẫu Agency hiện số người nhận.
- **Phân quyền trang**: [mobile-nav-role-parity](../../mobile-nav-role-parity/spec.md).
