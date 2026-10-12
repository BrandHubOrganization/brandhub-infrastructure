# UC — Update Mail Template

| | |
|---|---|
| FR Code | 3.6.30 |
| Feature | Update Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | OWNER, MANAGER, CREATOR (đã chốt 2026-10-12) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã chốt nghiệp vụ 2026-10-12 — xem plan.md, chưa code |

## Quyết định đã chốt (2026-10-12)

> Nguồn chuẩn: [plan.md](plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

- **Phạm vi**: template theo **Workspace**. **Role**: OWNER, MANAGER, CREATOR (CLIENT không). Sửa/xóa template của Workspace: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin sửa/xóa.
- **Method**: **PATCH** (không phải PUT), trường `bodyHtml`; thêm `attachmentIds?`.
- Template hệ thống từ Workspace → 403 `SYSTEM_TEMPLATE_READ_ONLY`. Sửa template của người khác chỉ OWNER/MANAGER. Template không tồn tại → 404 `TEMPLATE_NOT_FOUND`.
- Sửa template **không** ảnh hưởng lô đã gửi hoặc đã hẹn (snapshot).

## 1. Objective

Chỉnh sửa lại mẫu email vừa tạo hoặc mẫu có sẵn.

## 2. User Story

Là một Member,
tôi muốn sửa lại mẫu email đã tạo,
để cập nhật nội dung phù hợp hơn.

## 3. Acceptance Criteria

- Sửa `name`, `subject`, `body`.

## 4. UI / UX

- Nút Edit trong list Mail Template.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/mail-templates/{templateId}
{ "name"?, "subject"?, "body"? }
→ 200 { "success": true, "data": { ...updated template... } }
```

## 6. Error Handling

- Không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Update thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

## Phụ lục — đặc tả đã chốt cho FR này

> Tách từ bộ tài liệu Mail Template gộp trước đây; đây là phần áp dụng cho FR 3.6.30. Các mục dùng chung (quyết định, UI, API, lỗi) được giữ nguyên ở mọi FR để mỗi thư mục đọc độc lập.

### 1. Objective

Cho phép thành viên Workspace soạn **mẫu email có biến**, đính kèm tệp/ảnh, rồi **gửi** (ngay hoặc hẹn giờ) cho Client hoặc danh sách người nhận. Hệ thống phải bảo vệ tài khoản SMTP dùng chung khỏi bị đánh dấu spam (giới hạn tốc độ, unsubscribe). Admin quản trị thư viện mẫu hệ thống để Workspace clone và để soạn Broadcast (FR 3.10.1).

### 2. User Stories

- Là **CREATOR/MANAGER/OWNER**, tôi muốn xem, tạo, sửa, xóa mẫu email của Workspace để chuẩn hóa nội dung gửi cho Client.
- Là **thành viên Workspace**, tôi muốn gửi một mẫu cho Client (hoặc cho danh sách target customer của chiến dịch) và điền các biến như `{{clientName}}` để không phải soạn lại email lặp lại.
- Là **thành viên Workspace**, tôi muốn xem trước, gửi thử cho chính mình và hẹn giờ gửi để tránh gửi sai.
- Là **người nhận ngoài hệ thống**, tôi muốn có cách hủy đăng ký để không nhận thêm email.
- Là **Admin**, tôi muốn quản lý thư viện mẫu hệ thống và dùng chúng khi soạn Broadcast.

### 3. Quyết định nghiệp vụ (đã chốt 2026-10-12)

| # | Chủ đề | Quyết định |
|---|---|---|
| D1 | Phạm vi | Template theo **Workspace** |
| D2 | Quyền | OWNER, MANAGER, CREATOR dùng cả 5 chức năng; CLIENT không. Sửa/xóa: người tạo hoặc OWNER/MANAGER |
| D3 | Người nhận | Dán/upload CSV lúc gửi, tối đa 200/lần, cho phép người ngoài Workspace |
| D4 | Gửi | Async qua outbox, trả 202; worker gửi nền |
| D5 | Giới hạn | 450/ngày toàn hệ thống, 100/ngày/Workspace, 20 mail/phút |
| D6 | Chống spam | Footer unsubscribe + suppression list theo Workspace; chỉ áp cho người ngoài Workspace |
| D7 | Biến thiếu | Loại dòng đó, gửi phần còn lại |
| D8–D9 | Tệp | Đính kèm + ảnh nội dung; 5MB/tệp, ≤3 tệp, ≤10MB; allow-list + magic bytes; mặc định gắn template, chỉnh được lúc gửi |
| D10–D11 | Hẹn giờ | 5 phút – 30 ngày, snapshot, hủy được, không sửa; hết quota thì dời ngày sau |
| D12–D13 | Lịch sử | OWNER/MANAGER/CREATOR xem toàn bộ, giữ 12 tháng; notification trong app cho người tạo |
| D14 | Trình soạn | TipTap rich-text, backend sanitize |
| D15–D16 | Admin | CRUD mẫu hệ thống + seed 4 mẫu; Broadcast 3.10.1 chỉ sao chép nội dung |
| D17 | Kỹ thuật | Soft delete, PATCH, `bodyHtml`, Reply-To = email người gửi |
| D18 | Điểm vào | Trang template và nút trên trang Client |

#### 4.3 Update (3.6.30 — DA-1000)
- AC-U1: PATCH một phần `name/subject/bodyHtml/attachmentIds`; trường không gửi giữ nguyên.
- AC-U2: Template hệ thống từ Workspace → 403 `SYSTEM_TEMPLATE_READ_ONLY`.
- AC-U3: Sửa template của người khác chỉ OWNER/MANAGER; template không tồn tại → 404 `TEMPLATE_NOT_FOUND`.
- AC-U4: Sửa không ảnh hưởng lô đã gửi/đã hẹn.

#### 4.9 Tệp đính kèm (DA-1256)
- AC-A1: Chỉ nhận `pdf, png, jpg, gif, docx, xlsx, pptx`; kiểm magic bytes; từ chối còn lại (400 `MAIL_ATTACHMENT_INVALID`).
- AC-A2: 5MB/tệp, tối đa 3 tệp, tổng 10MB.
- AC-A3: Tệp tải lên mà chưa gắn bị dọn sau 24 giờ.

### 5. UI / UX

| Màn hình | Nội dung |
|---|---|
| `/workspaces/:id/mail-templates` | Bảng danh sách, tìm kiếm, nút Tạo, hành động Sửa/Xóa/Gửi/Dùng mẫu |
| Form tạo/sửa | Tên, subject, TipTap (chèn biến, ảnh), đính kèm, "Dùng mẫu hệ thống" |
| Modal Gửi | Chọn template, dán/upload CSV (map cột), biến tự phát hiện, bật/tắt đính kèm, preview, gửi thử, hẹn giờ, hiển thị quota |
| `/workspaces/:id/mail-templates/batches` | Danh sách lô, chi tiết người nhận, nút Hủy lịch |
| Trang Client | Nút "Gửi email" mở modal Gửi, điền sẵn `contact_email` và `{{clientName}}` |
| Admin console | Quản lý mẫu hệ thống |
| Form Broadcast 3.10.1 | Nút "Chọn mẫu" |
| Trang unsubscribe công khai | Xác nhận/kết quả, vi/en, không cần đăng nhập |

#### 5.1 UI States
Mỗi màn hình có: loading (skeleton), empty ("Chưa có mẫu email", "Chưa có lịch sử gửi"), error có nút thử lại, giữ nguyên dữ liệu form khi lỗi gửi, disabled khi đang gửi để tránh bấm đúp, trạng thái quota hết (khóa nút gửi ngay, vẫn cho hẹn giờ).

#### 5.2 i18n
Namespace mới `mailTemplate` trong `vi.json` và `en.json` (key song song, không hardcode chuỗi): `mailTemplate.list.*`, `mailTemplate.form.*`, `mailTemplate.send.*`, `mailTemplate.batches.*`, `mailTemplate.errors.*`, `mailTemplate.unsubscribe.*`, `admin.mailTemplate.*`; cập nhật `nav` (mục sidebar) và `broadcast.pickTemplate`.

#### 5.3 Light/Dark mode
Dùng token theme sẵn có; không thêm màu cố định. Chip "Hệ thống", trạng thái lô (`SENT`/`FAILED`/`PENDING`/`SUPPRESSED`) dùng token trạng thái hiện có kèm biến thể dark. Vùng preview email hiển thị trên nền trắng cố định (mô phỏng hộp thư) có viền theo token.

### 6. API Contract
Xem [plan.md §5](plan.md#5-api). Tóm tắt endpoint: `GET/POST /workspaces/{id}/mail-templates`, `GET/PATCH/DELETE .../{tid}`, `POST .../{tid}/preview|send-test|send`, `POST .../attachments|images`, `GET .../mail-batches[/{bid}]`, `POST .../mail-batches/{bid}/cancel`, `GET .../mail-quota`, `GET/POST /public/mail/unsubscribe`, `/admin/mail-templates[/{tid}]`.

### 7. Error Handling

| Tình huống | HTTP | Mã |
|---|---|---|
| Không có quyền | 403 | `FORBIDDEN` |
| Sửa/xóa template hệ thống từ Workspace | 403 | `SYSTEM_TEMPLATE_READ_ONLY` |
| Template/lô không tồn tại | 404 | `TEMPLATE_NOT_FOUND` |
| Thiếu subject/body, recipients rỗng/quá 200, tất cả bị loại | 400 | `VALIDATION_ERROR` |
| Hẹn giờ ngoài khoảng | 400 | `MAIL_SCHEDULE_OUT_OF_RANGE` |
| Tệp sai loại/kích thước | 400/413 | `MAIL_ATTACHMENT_INVALID` |
| Hủy lô không ở trạng thái `SCHEDULED` | 409 | `MAIL_BATCH_NOT_CANCELLABLE` |
| Vượt quota (gửi ngay) | 429 | `MAIL_QUOTA_EXCEEDED` |
| SMTP lỗi khi gửi thử | 502 | `EMAIL_SERVICE_UNAVAILABLE` |

### 8. Edge Cases

- CSV có BOM, dấu ngoặc kép, dòng trống, email trùng khác hoa thường, email có khoảng trắng.
- Cột CSV trùng tên biến built-in (`workspaceName`): giá trị dòng không ghi đè biến hệ thống.
- Gửi cho Client từ trang Client: `clientName` tự điền.
- Template bị xóa giữa lúc mở modal và lúc bấm gửi → 404, không tạo lô.
- Hai người cùng gửi gần hết quota: cập nhật quota nguyên tử, không vượt cap.
- Worker crash giữa lúc gửi và commit → có thể gửi trùng một lần (at-least-once, ghi nhận); `event_key` chặn trùng khi enqueue lại.
- Ngày quota luôn tính theo `Asia/Ho_Chi_Minh` (không DST).
- Người nhận vừa là Client vừa nằm trong suppression: Client được coi là trong Workspace nên vẫn gửi.
- Tệp S3 bị xóa trước giờ gửi của lô hẹn: delivery `FAILED` với lỗi rõ ràng, không gửi mail thiếu tệp.

### 10. Definition of Done

- Cả 9 nhóm AC ở mục 4 có test pass (JUnit, Vitest, Playwright, integration live).
- Gửi thật qua SMTP giả thấy đủ header `Reply-To`, `List-Unsubscribe`, tệp đính kèm.
- Không còn mâu thuẫn giữa spec, ERD/DBML, BA §9 và code.
- vi/en song song, light/dark kiểm tra xong, không có hex/rgb cứng.
- Jira DA-998..1002 và DA-1256..1259 chuyển In review sau khi merge.

### 11. Out of Scope

- Contact List lưu sẵn; cá nhân hóa `{{fullName}}` cho Broadcast; sửa lịch đã hẹn; quét virus; thống kê mở/click; giới hạn theo gói Subscription; hàng đợi tách service; đa instance worker.

### Addendum A (2026-10-13): usability enhancements

Scope added after the first live review. No change to the approved rules above.

| ID | Behaviour |
|---|---|
| A7 | Removing an attachment from a template (or deleting the template) releases it for the orphan sweep unless another template or a pending batch still references it. |

API additions: `GET/DELETE /workspaces/{id}/mail-suppressions`, `GET /workspaces/{id}/mail-recipients?q=`, `GET/POST /workspaces/{id}/mail-recipient-groups`, `DELETE .../{groupId}`, `POST /mail-batches/{bid}/resend-failed`, `GET /mail-batches/{bid}/export.csv`.
Data: Mongo collection `mail_recipient_groups` (migration `2026-10-13-create-mail-recipient-groups-collection.js`).
