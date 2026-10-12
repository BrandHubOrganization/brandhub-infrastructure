# Plan — Mail Template (FR 3.6.28 – 3.6.32)

> Trạng thái: **SPEC CHỐT (2026-10-12) — mọi câu hỏi nghiệp vụ, quy tắc quota và 10 giả định đã được chủ task đồng ý. Chưa viết code.**
> Jira: DA-998 (View), DA-999 (Create), DA-1000 (Update), DA-1001 (Delete), DA-1002 (Send) + task mở rộng DA-1256 (Attachments), DA-1257 (Scheduling/Quota/Unsubscribe), DA-1258 (History/Notifications), DA-1259 (Admin templates + Broadcast picker) — epic DA-939.
> Tài liệu liên quan: 5 `spec.md` cùng cấp (đã cập nhật phần "Quyết định 2026-10-12"), `BA/05-content-task-workflow.md` §9.
> Nguồn đã đối chiếu: spec/report3/sequence của 5 FR, ERD + DBML + database-strategy, `MailServiceImpl`, `AdminEmailOutbox`, `AdminNotificationService`, `ClientProfile`, `WorkspaceMember`, `application.yml`.

---

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

## 4. Mô hình dữ liệu

### 4.1 MongoDB — `mail_templates` (theo ERD hiện có, bổ sung trường)
| Trường | Kiểu | Ghi chú |
|---|---|---|
| `_id` | ObjectId | |
| `workspaceId` | string / null | `null` với `SYSTEM_DEFAULT` |
| `name` | string ≤120 | bắt buộc |
| `subject` | string ≤200 | bắt buộc, được chứa biến |
| `bodyHtml` | string ≤100KB | bắt buộc, đã sanitize |
| `type` | `SYSTEM_DEFAULT` \| `CUSTOM` | |
| `attachments` | array `{attachmentId, name, contentType, size, s3Key}` | mặc định gắn kèm (D9) |
| `clonedFromId` | string | truy vết |
| `createdBy` | string | user id |
| `createdAt`, `updatedAt` | date | |
| `deletedAt` | date | soft delete; mọi truy vấn lọc `deletedAt = null` |

Index: `{workspaceId:1, deletedAt:1, createdAt:-1}`, `{type:1, deletedAt:1}`.

### 4.2 PostgreSQL (cùng DB với `admin_email_outbox`, để enqueue transactional và `FOR UPDATE SKIP LOCKED`)

**`mail_batches`** — một lần bấm gửi
`id uuid pk`, `workspace_id`, `template_id`, `template_name`, `sent_by uuid`, `kind` (`SEND`/`TEST`), `status` (`SCHEDULED`/`QUEUED`/`SENDING`/`COMPLETED`/`CANCELLED`/`FAILED`), `subject`, `body_html` (snapshot chưa gắn biến), `attachments jsonb` (snapshot), `scheduled_at`, `timezone`, `total`, `accepted`, `rejected_count`, `sent_count`, `failed_count`, `suppressed_count`, `created_at`, `completed_at`.

**`mail_deliveries`** — một người nhận
`id uuid pk`, `batch_id fk`, `recipient`, `recipient_name`, `variables jsonb`, `rendered_subject`, `rendered_body_html`, `external_audience boolean` (có chèn footer unsubscribe hay không), `status` (`PENDING`/`SENT`/`FAILED`/`SUPPRESSED`), `attempts int`, `last_error`, `next_attempt_at`, `sent_at`, `event_key unique` (`MAIL:{batchId}:{lower(email)}`, idempotent).

**`mail_send_quota`** — `day date`, `scope` (`SYSTEM`/`WORKSPACE`), `scope_id`, `sent_count int`, PK `(day, scope, scope_id)`. "Ngày" tính theo `Asia/Ho_Chi_Minh`.

**`mail_suppressions`** — `id`, `workspace_id`, `email_lower`, `reason` (`UNSUBSCRIBED`), `created_at`, unique `(workspace_id, email_lower)`.

**`mail_attachments`** (tệp tạm trước khi gắn) — `id`, `workspace_id`, `uploaded_by`, `name`, `content_type`, `size`, `s3_key`, `kind` (`FILE`/`IMAGE`), `created_at`, `bound boolean`; job dọn tệp chưa gắn quá 24h.

Migration đặt ở `docs/database/migrations/` (SQL cho Postgres, JS cho Mongo, kèm cập nhật `init-postgres-v2.sql`, `init-mongo.js`, ERD, DBML — cùng pattern các migration 2026-10-xx).

## 5. API

Tiền tố `/api/v1`. Mọi response bọc `{success, data, error, requestId}`.

### 5.1 Template (Workspace)
| Method | Path | Mô tả |
|---|---|---|
| GET | `/workspaces/{id}/mail-templates?includeSystem=true&q=&page=&size=` | List: `id, name, subject (preview 120 ký tự), type, attachmentCount, createdAt` |
| GET | `/workspaces/{id}/mail-templates/{tid}` | Chi tiết đầy đủ (kể cả template hệ thống) |
| POST | `/workspaces/{id}/mail-templates` | `{name, subject, bodyHtml, attachmentIds?, cloneFromId?}` → `201 {id,...}`. Trống `subject`/`bodyHtml` → 400 `VALIDATION_ERROR`; `cloneFromId` thiếu `name/subject/bodyHtml` thì lấy từ nguồn |
| PATCH | `/workspaces/{id}/mail-templates/{tid}` | `{name?, subject?, bodyHtml?, attachmentIds?}` → `200`. Template hệ thống → 403 `SYSTEM_TEMPLATE_READ_ONLY` |
| DELETE | `/workspaces/{id}/mail-templates/{tid}` | Soft delete → `200 null` |
| POST | `/workspaces/{id}/mail-templates/{tid}/preview` | `{variables?, recipient?}` → `{subject, bodyHtml, missingVariables[]}` |
| POST | `/workspaces/{id}/mail-templates/{tid}/send-test` | `{variables?}` → gửi **đồng bộ** tới email người dùng; không tính quota; SMTP lỗi → 502 |
| POST | `/workspaces/{id}/mail-templates/{tid}/send` | Xem 5.2 |

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

### 5.4 Tệp
| Method | Path | Mô tả |
|---|---|---|
| POST | `/workspaces/{id}/mail-templates/attachments` | multipart `file` → `{attachmentId, name, size, contentType}`. Loại ngoài allow-list hoặc magic bytes không khớp, >5MB → 400/413 `MAIL_ATTACHMENT_INVALID` |
| POST | `/workspaces/{id}/mail-templates/images` | multipart ảnh → `{url}` (URL công khai trên S3) để TipTap chèn |

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

## 6. Luồng nghiệp vụ

### 6.1 CRUD template (3.6.28–31)
1. Member mở `/workspaces/:id/mail-templates` → list gồm template của Workspace + (tùy chọn) template hệ thống, lọc `deletedAt = null`.
2. Tạo: form tên/subject/TipTap/đính kèm; "Dùng mẫu hệ thống" chọn nguồn để clone rồi sửa; backend sanitize `bodyHtml`, kiểm `attachmentIds` thuộc Workspace.
3. Sửa: PATCH từng phần; template hệ thống không sửa được từ Workspace.
4. Xóa: confirm → `deletedAt = now`. Lô đã gửi/đã hẹn **không bị ảnh hưởng** (snapshot).

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

## 8. Biến, HTML, tệp

- **Cú pháp**: `{{ten_bien}}`, chỉ `[A-Za-z0-9_]`. Biến built-in: `workspaceName`, `senderName`, `clientName` (khi gửi từ trang Client), `name` (từ cột CSV `name`). Biến khác phải có giá trị (từ CSV dòng hoặc `variables` chung).
- **Giá trị biến** luôn bị HTML-escape khi chèn. Subject cũng render biến (escape thô).
- **Sanitize** (jsoup allow-list): `p, br, b, strong, i, em, u, a[href http/https/mailto], ul, ol, li, h1–h3, blockquote, img[src https], span, div`; bỏ `script`, `style`, event handler, `javascript:`. Ảnh chỉ nhận URL thuộc bucket của hệ thống.
- **Tệp**: allow-list `pdf, png, jpg, jpeg, gif, docx, xlsx, pptx`; kiểm magic bytes (Tika-core); từ chối `exe, zip, html, js...`; 5MB/tệp, ≤3 tệp, tổng ≤10MB. Lưu S3 khóa riêng theo Workspace.
- **Giới hạn nội dung**: subject ≤200 ký tự, body ≤100KB sau sanitize.
- **Footer unsubscribe** (chỉ với người ngoài): đoạn text song ngữ vi/en + link; token HMAC từ `MAIL_UNSUBSCRIBE_SECRET`.

## 9. Frontend (web-dashboard)

| Trang / thành phần | Nội dung |
|---|---|
| `/workspaces/:id/mail-templates` | List + tìm kiếm, nút Tạo, hành động Sửa/Xóa/Gửi; chip "Hệ thống" |
| Form tạo/sửa | Tên, subject, TipTap (nút chèn biến, ảnh), đính kèm, "Dùng mẫu hệ thống" |
| Modal Gửi | Template, người nhận (dán, upload CSV có map cột), biến tự phát hiện, đính kèm bật/tắt, preview, gửi thử, hẹn giờ; hiển thị quota còn lại |
| Trang lô `/workspaces/:id/mail-templates/batches` | Danh sách lô, chi tiết người nhận, Hủy lịch |
| Trang Client | Nút "Gửi email" mở modal Gửi |
| Admin console | Trang "Mẫu email hệ thống" (CRUD) |
| Form Broadcast 3.10.1 | Nút "Chọn mẫu" (sao chép nội dung) |
| i18n/route | `vi`/`en`, mục sidebar, `ROUTE_ACCESS` OWNER/MANAGER/CREATOR |

Thêm thư viện FE: parser CSV (papaparse hoặc parser nhỏ tự viết). BE: `jsoup`, `tika-core`.

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
