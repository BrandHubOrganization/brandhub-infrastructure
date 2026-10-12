# Plan — Send Email via Template (FR 3.6.32)

> Nguồn chuẩn dùng chung cho cả 5 FR: [../3-6-28-32-mail-template/](../3-6-28-32-mail-template/) (spec, plan, task, test gộp). File này lấy đúng phần của FR 3.6.32 để mỗi FR có đủ bộ 4 tài liệu (`spec.md`, `plan.md`, `task.md`, `test.md`) theo `docs/rule/feature-workflow.md`. Khi có khác biệt, bản gộp là bản đúng.

- **Jira:** DA-1002
- **Mục tiêu:** Gửi email theo mẫu tới danh sách người nhận: hàng đợi, hạn mức, hẹn giờ/hủy, hủy đăng ký, lịch sử, Admin.
- **Spec:** [spec.md](spec.md) · **Sequence:** [report4_sequence.puml](report4_sequence.puml)

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
