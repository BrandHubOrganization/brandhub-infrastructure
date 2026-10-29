# UC — Send Email via Template

| | |
|---|---|
| FR Code | 3.6.32 |
| Feature | Send Email via Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | OWNER, MANAGER, CREATOR (đã chốt 2026-10-12) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã chốt nghiệp vụ 2026-10-12 — xem plan.md, chưa code |

## Quyết định đã chốt (2026-10-12)

> Nguồn chuẩn: [plan.md](plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

- **Phạm vi**: template theo **Workspace**. **Role**: OWNER, MANAGER, CREATOR (CLIENT không). Sửa/xóa template của Workspace: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin sửa/xóa.
- **Người nhận**: danh sách `recipients: [{email, name?, variables?}]` dán/upload CSV lúc gửi, tối đa **200/lần**; có thể là người ngoài Workspace. Rỗng → 400 `VALIDATION_ERROR`.
- **Gửi async qua outbox**: `POST .../{tid}/send` → `202 {batchId, status, total, accepted, rejected[], scheduledAt}` (thay cho `200 {messageId}`). Tiến trình/kết quả xem ở `GET .../mail-batches/{bid}`.
- **Biến**: `{{x}}`; thiếu biến ở một dòng → dòng đó vào `rejected[]`, các dòng khác vẫn gửi; giá trị luôn HTML-escape.
- **Giới hạn**: 450/ngày toàn hệ thống, 100/ngày/Workspace, 20 mail/phút. Gửi ngay vượt quota còn lại → 429 `MAIL_QUOTA_EXCEEDED`; hẹn giờ thì nhận và **dời sang ngày sau** khi hết quota.
- **Hẹn giờ**: `scheduledAt` từ now+5 phút đến now+30 ngày, snapshot nội dung, hủy được trước giờ gửi, không sửa lịch.
- **Gửi thử** `POST .../{tid}/send-test`: đồng bộ tới email người dùng, không tính quota; SMTP lỗi → **502** `EMAIL_SERVICE_UNAVAILABLE` (502 chỉ áp dụng ở đây; lỗi từng người trong lô là trạng thái `FAILED` + retry tối đa 5 lần).
- **Chống spam**: người nhận **ngoài** Workspace được chèn footer + `List-Unsubscribe`; hủy đăng ký theo Workspace gửi qua `GET/POST /api/v1/public/mail/unsubscribe?token=`; người đã hủy bị bỏ qua (`SUPPRESSED`).
- **Điểm vào**: trang template và nút "Gửi email" trên trang Client (tự điền `contact_email`, `{{clientName}}`).
- **Thông báo**: notification trong app cho người tạo khi lô hoàn tất/lỗi.
- **Reply-To** là email người gửi; From là `MAIL_FROM` hệ thống.

## 1. Objective

Gửi email thực tế dựa trên Mail Template đã chọn.

## 2. User Story

Là một Member,
tôi muốn gửi email cho Client dựa trên mẫu đã tạo,
để tiết kiệm thời gian soạn email lặp lại.

## 3. Acceptance Criteria

- Chọn Template + người nhận (Client trong Workspace) → điền các placeholder (nếu template có biến động, ví dụ {{clientName}}) → gửi.

## 4. UI / UX

- Nút 'Gửi Email' trong Mail Template detail, hoặc trực tiếp từ trang Client.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/workspaces/{id}/mail-templates/{templateId}/send
{ "recipientEmail": "string", "variables"?: {...} }
→ 200 { "success": true, "data": { "messageId" } }
```

## 6. Error Handling

- Gửi lỗi (email service down) → 502 `EMAIL_SERVICE_UNAVAILABLE`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Gửi email thành công, log lại lịch sử gửi.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

## Phụ lục — đặc tả đã chốt cho FR này

> Tách từ bộ tài liệu Mail Template gộp trước đây; đây là phần áp dụng cho FR 3.6.32. Các mục dùng chung (quyết định, UI, API, lỗi) được giữ nguyên ở mọi FR để mỗi thư mục đọc độc lập.

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

#### 4.5 Send (3.6.32 — DA-1002)
- AC-S1: `recipients` rỗng → 400 `VALIDATION_ERROR`; >200 → 400.
- AC-S2: Email sai định dạng hoặc trùng (không phân biệt hoa thường) bị đưa vào `rejected[]`, không làm hỏng cả lô.
- AC-S3: Dòng thiếu biến bắt buộc vào `rejected[]` với `MISSING_VARIABLE:x`; mail không bao giờ chứa `{{...}}` còn nguyên.
- AC-S4: Giá trị biến luôn được HTML-escape.
- AC-S5: Gửi ngay trả `202 {batchId}`; vượt quota còn lại hôm nay → 429 `MAIL_QUOTA_EXCEEDED` kèm số còn lại.
- AC-S6: Gửi thử gửi **đồng bộ** tới email người dùng, không tính quota; lỗi SMTP → 502 `EMAIL_SERVICE_UNAVAILABLE`.
- AC-S7: Preview hiển thị subject/body đã render và danh sách biến còn thiếu.
- AC-S8: Người nhận trong Workspace (Client/thành viên) không chèn footer; người ngoài có footer + `List-Unsubscribe`; người đã hủy bị bỏ qua (`SUPPRESSED`).
- AC-S9: Lỗi từng người trong lô có trạng thái `FAILED`, retry tối đa 5 lần với backoff, không chặn các người khác.
- AC-S10: Đính kèm mặc định của template được dùng nếu không chỉ định; `attachmentIds: []` = không đính kèm.
- AC-S11: Reply-To là email người gửi, From là `MAIL_FROM` hệ thống.

#### 4.6 Hẹn giờ và hủy (DA-1257)
- AC-H1: `scheduledAt` ngoài [now+5 phút, now+30 ngày] → 400 `MAIL_SCHEDULE_OUT_OF_RANGE`.
- AC-H2: Lô hẹn giờ lưu snapshot subject/body/đính kèm; sửa/xóa template sau đó không đổi nội dung.
- AC-H3: Hủy chỉ áp dụng cho lô `SCHEDULED`; lô khác → 409 `MAIL_BATCH_NOT_CANCELLABLE`.
- AC-H4: Đến giờ nếu hết quota ngày thì delivery giữ `PENDING` và gửi tiếp ngày kế (múi giờ `Asia/Ho_Chi_Minh`).

#### 4.7 Unsubscribe (DA-1257)
- AC-X1: Link hủy trong footer mở trang công khai (vi/en); xác nhận thì thêm vào suppression của Workspace gửi.
- AC-X2: Token ký HMAC; token sai/giả mạo → 400, không lộ thông tin; thao tác idempotent.
- AC-X3: Hủy ở Workspace A không chặn Workspace B và không ảnh hưởng Broadcast Admin.

#### 4.8 Lịch sử và thông báo (DA-1258)
- AC-L1: OWNER/MANAGER/CREATOR xem danh sách lô, chi tiết từng người nhận (phân trang, lọc theo trạng thái).
- AC-L2: Người tạo nhận notification trong app khi lô hoàn tất hoặc lỗi.
- AC-L3: Quá 12 tháng, địa chỉ và nội dung đã render bị xóa, số liệu tổng được giữ.
- AC-L4: UI hiển thị quota đã dùng/giới hạn hôm nay.

#### 4.10 Admin (DA-1259)
- AC-M1: Admin CRUD template hệ thống (`type = SYSTEM_DEFAULT`, `workspaceId = null`).
- AC-M2: Seed 4 mẫu: Chào mừng Client mới, Yêu cầu duyệt nội dung, Thông báo chiến dịch/khuyến mãi, Báo cáo hiệu quả định kỳ.
- AC-M3: Form soạn Broadcast có "Chọn mẫu" chỉ sao chép subject/body; worker 3.10.1 không đổi.

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
| A3 | A new template keeps an autosaved draft (localStorage, 7 days); closing keeps it, saving clears it. Editing an existing template asks before discarding changes. The send dialog keeps the unsent recipient list per template. |
| A4 | The send dialog can add recipients from Workspace members and Client contacts, and from saved recipient groups (max 50 groups, 200 recipients each); the current list can be saved as a group. |
| A5 | Send history refreshes itself while a batch is queued or sending; a finished batch with failed emails can be re-sent (failed rows only); the recipients of a batch can be exported as CSV (formula cells neutralised). |
| A6 | A Workspace page lists unsubscribed addresses; OWNER/MANAGER can re-subscribe an address. |

API additions: `GET/DELETE /workspaces/{id}/mail-suppressions`, `GET /workspaces/{id}/mail-recipients?q=`, `GET/POST /workspaces/{id}/mail-recipient-groups`, `DELETE .../{groupId}`, `POST /mail-batches/{bid}/resend-failed`, `GET /mail-batches/{bid}/export.csv`.
Data: Mongo collection `mail_recipient_groups` (migration `2026-10-13-create-mail-recipient-groups-collection.js`).

### Addendum B (2026-10-28): drag-drop block builder + multi-scope broadcast — ĐÃ TRIỂN KHAI (2026-10-29), chờ chủ task xác nhận chính thức

> Yêu cầu nghiệp vụ mới từ chủ task; khác với trình soạn TipTap tự do (D14) và phạm vi chỉ-Workspace (D1) đã chốt ở trên. B1-B10 đã được triển khai đủ ở backend, web và mobile theo chỉ đạo của chủ task (2026-10-29); các điểm bổ sung phát sinh khi triển khai ghi ở B11-B16 bên dưới. D1-D18 chỉ được ghi đè sau khi chủ task xác nhận chính thức.

| ID | Thay đổi đề xuất | Lý do |
|---|---|---|
| B1 | **Trình soạn**: thay TipTap rich-text tự do (D14) bằng **drag-drop block builder** — palette khối cố định (header, heading, paragraph, cta_button, image_banner, divider, spacer, footer...), sắp xếp bằng kéo-thả dạng sortable-list (tham khảo cơ chế BienSoDep `EmailBuilder.jsx` + `EmailBlockSchema.cs`, không copy code — stack khác C#/EF Core). `bodyHtml` không còn là input trực tiếp của người dùng; backend render HTML từ `layoutJson` (danh sách block + props), cùng cách `EmailBlockSchema` làm. | Đồng bộ trải nghiệm soạn giữa Agency và Admin, tránh HTML tự do khó kiểm soát khi mở rộng ra nhiều scope gửi. |
| B2 | **Phạm vi mở rộng** (thay D1): ngoài `type = SYSTEM_DEFAULT \| CUSTOM` theo Workspace, thêm field `scope` phân **6** giá trị: `CAMPAIGN_BROADCAST`, `ADMIN_SYSTEM_BROADCAST`, `AGENCY_INTERNAL`, `WORKSPACE_MANAGER`, `AGENCY_CLIENT`, `TRANSACTIONAL_AUTO`. Mỗi scope có kho template riêng (không gộp chung danh sách) — field `agencyId` mới, song song `workspaceId` hiện có (theo đúng pattern `Workspace.agencyId` đã dùng ở brandhub-business-service), set cho `AGENCY_INTERNAL`/`AGENCY_CLIENT`, null cho scope còn lại. | Khớp 6 use-case chủ task chốt: campaign gửi đối tượng truyền thông, Admin broadcast toàn hệ thống, Agency owner/manager gửi member nội bộ, Workspace manager gửi member workspace, Agency gửi Client đối tác, hệ thống tự gửi email giao dịch. |
| B3 | **Người nhận theo scope** (mở rộng D3; nguồn xác nhận 2026-10-28 sau khi đọc model Campaign): recipient **tự động suy ra theo scope** thay vì luôn dán/CSV thủ công — `CAMPAIGN_BROADCAST`: `MediaCampaign` **không có** field audience riêng, suy ra Client qua chuỗi `MediaCampaign.workspaceMediaPackageId` → `WorkspaceMediaPackage.workspaceId` (1-1) → `client_profiles` của workspace đó, **tái dùng cùng nguồn** `MailRecipientLookup` đã dùng cho `WORKSPACE_MANAGER` (khác mục đích/kho template, trùng nguồn dữ liệu — không cần field/entity mới); `ADMIN_SYSTEM_BROADCAST` lấy toàn bộ user hệ thống; `AGENCY_INTERNAL` lấy qua `AgencyMemberRepository.findByAgencyId` (đã có sẵn, tái dùng được); `WORKSPACE_MANAGER` lấy `workspace_members` (đã có qua `MailRecipientLookup`); `AGENCY_CLIENT` lấy client active trên mọi workspace của agency (method gộp **chưa có**, cần viết mới — chưa có sẵn trong `AgencyService`). Danh sách gợi ý tự động vẫn **cho sửa tay/bỏ chọn** trước khi gửi thật, giữ cơ chế `rejected[]`/preview/gửi-thử hiện có. | Chủ task chốt "tự động theo scope, cả 2" ở vòng brainstorm — không bắt agency tự gõ tay toàn bộ recipient mỗi lần, nhưng vẫn cho kiểm soát cuối trước khi gửi thật. |
| B4 | **Mobile**: thêm view mobile (Expo/RN) — chỉ xem danh sách template theo scope có quyền, chọn template, xem preview, chọn/sửa recipient gợi ý, bấm gửi. **Không** build/kéo-thả block trên mobile. | Chủ task chốt rõ: mobile chỉ xem+gửi, builder kéo-thả chỉ làm trên web. |
| B5 | **Quyền theo scope mới** (sửa 2026-10-28, khớp `docs/ba/10-roles-permissions-matrix.md` §1.1): `ADMIN_SYSTEM_BROADCAST` chỉ Admin hệ thống tạo/sửa/gửi (không phải Workspace OWNER/MANAGER/CREATOR như D2); `AGENCY_INTERNAL`/`AGENCY_CLIENT` chỉ **Agency OWNER** — Agency-level (Tầng 1 roles-matrix) chỉ có role OWNER, không có MANAGER riêng ở tầng này (MANAGER chỉ tồn tại ở Workspace-level, Tầng 2); dùng check `agency.getOwnerId().equals(currentUserId)` như các FR Agency-level khác, không dùng `@RequireRole` của Workspace. `CAMPAIGN_BROADCAST`/`WORKSPACE_MANAGER` giữ nguyên quyền Workspace D2. | Mỗi scope có chủ sở hữu rõ ràng, tránh lẫn quyền Agency-level và Workspace-level vốn đã tách bảng ở backend; sửa lại sau khi đối chiếu roles-matrix phát hiện B5 bản đầu ghi sai "Agency MANAGER" không tồn tại ở tầng này. **Cập nhật 2026-10-29:** quyền Agency-level của `AGENCY_*` mở cho Manager Workspace — xem B20. |
| B6 | **`MailTemplateType` kỹ thuật**: logic hiện tại (`MailTemplateServiceImpl`, `MailSendService`) so sánh nhị phân `== SYSTEM_DEFAULT` else CUSTOM ở nhiều nơi — mở rộng thành 5+ giá trị **bắt buộc** đổi các nhánh này thành kiểm tra permission/ownership tường minh theo `scope`, không dùng type-equality ngầm định nữa, nếu không mọi scope mới sẽ rơi nhầm vào nhánh CUSTOM cũ. | Phát hiện khi rà code hiện có — rủi ro breaking nếu chỉ thêm giá trị enum mà không sửa logic nhánh. |
| B7 | **Gửi** (bổ sung D4/D11 riêng cho 3.6.32): `CAMPAIGN_BROADCAST`/`ADMIN_SYSTEM_BROADCAST`/`AGENCY_INTERNAL` dùng chung engine `MailDeliveryService`/`MailDeliveryStore` hiện có (queue-claim, lease, retry-backoff, quota) — không viết queue mới; chỉ thêm nhánh tính quota/suppression theo `scope` thay vì luôn theo `workspaceId` (vd `ADMIN_SYSTEM_BROADCAST` không áp quota per-workspace). | Tránh viết lại hạ tầng gửi đã hoàn thiện và có test; chỉ mở rộng điểm tính scope. |
| B8 | **`TRANSACTIONAL_AUTO`** (scope thứ 6, bổ sung 2026-10-28 sau rà soát đối tượng dùng): Admin soạn template bằng block builder cho sự kiện hệ thống tự động trigger (billing thất bại, sắp hết hạn Subscription, cảnh báo bảo mật...) — **không ai bấm gửi tay**; hệ thống tự enqueue khi sự kiện xảy ra, dùng người nhận = 1 user cụ thể (không phải danh sách), không qua batch/CSV/scope-recipient của B3. Không thay thế `AdminEmailOutbox` hiện có (giữ nguyên cho các luồng đã dùng nó) — chỉ các luồng mới dùng `TRANSACTIONAL_AUTO` muốn soạn bằng block builder thay vì hard-code HTML trong code mới đi qua nhánh này. | Rà soát theo `docs/ba/10-roles-permissions-matrix.md`: email giao dịch tự động (FR 3.9 Subscription) không khớp mô hình "người dùng chủ động chọn recipient rồi gửi" của 5 scope B2 ban đầu — chủ task xác nhận đưa vào phạm vi. |

| B9 | **Block palette** (chốt 2026-10-28, sửa paragraph 2026-10-28): 9 block cơ bản — `header` (logo+tên Agency/Workspace, không props), `heading` (text+align), `paragraph` (**plain textarea, không rich-text** — không bold/italic/link, giữ đúng tinh thần B1 thay hẳn TipTap bằng block cố định đơn giản, tránh kéo trình soạn rich-text trở lại), `image_banner` (ảnh + alt + link đích), `cta_button` (label+url_type: site/campaign/client/custom), `divider` (đường kẻ, không props), `spacer` (height_px), `contact_strip` (liên hệ Agency/Workspace, không props), `footer` (không props, tự chèn unsubscribe nếu `externalAudience`). **Không** đưa vào các block đặc thù biển số (`plate_block`, `stars`, `video_banner` của BienSoDep) — không hợp bối cảnh BrandHub. | Chủ task chốt dùng bộ cơ bản, bỏ phần đặc thù domain khác. |
| B10 | **Thứ tự triển khai** (chốt 2026-10-28): Backend trước — block schema (`layoutJson` + 9 block type ở B9) + render engine + mở rộng `MailTemplateType`/`scope`/`agencyId` (B2, B6) + API theo 6 scope (B5) hoàn thiện và test trước; FE web (drag-drop builder, B1) và FE mobile (view/send, B4) code sau khi API ổn định — cùng pattern đã làm với `MailDeliveryService` ở giai đoạn trước. | Chủ task chốt backend-first, tránh FE phải đổi theo khi schema backend còn thay đổi. |
| B11 | **Đường gửi theo scope** (bổ sung 2026-10-29): `WORKSPACE_MANAGER`/`CAMPAIGN_BROADCAST` gửi qua `/workspaces/{id}/mail-templates/{tid}/send`; `AGENCY_INTERNAL`/`AGENCY_CLIENT` gửi qua **cùng endpoint Workspace đó** khi Workspace thuộc đúng Agency của template và người gửi là **Agency OWNER** (người khác nhận `TEMPLATE_NOT_FOUND`); `ADMIN_SYSTEM_BROADCAST` do Admin hệ thống gửi qua `POST /api/v1/admin/mail-templates/{tid}/send` (không cần Workspace, `mail_batches.workspace_id` = null); `TRANSACTIONAL_AUTO` không ai gửi tay. | Mỗi scope có đúng một đường gửi đúng chủ; không bắt Admin làm member của một Workspace. |
| B12 | **Chặn lạm dụng mẫu hệ thống trong Workspace** (bổ sung 2026-10-29, sửa lỗ hổng): qua endpoint Workspace, mẫu `ADMIN_SYSTEM_BROADCAST` (kể cả 4 mẫu mặc định) **luôn cần danh sách người nhận tường minh**, vẫn áp cap 200/lần và không dùng nhánh xác nhận mật khẩu admin; không bao giờ tự suy ra "mọi user đang hoạt động". Mẫu `TRANSACTIONAL_AUTO` không hiện và không gửi được từ Workspace. Chỉ đường Admin mới bỏ cap và yêu cầu xác nhận mật khẩu khi vượt ngưỡng (B9). | Trước đó mọi OWNER/MANAGER/CREATOR có thể gửi cho toàn bộ user hệ thống bằng recipients rỗng. |
| B13 | **Xem trước người nhận** (thay `suggested-recipients` đề xuất ở plan B.2): `GET /api/v1/admin/mail-templates/{tid}/recipient-preview` và `GET /api/v1/agencies/{agencyId}/mail-templates/{tid}/recipient-preview` trả `{ total, sample[10] }` — chỉ số lượng và 10 địa chỉ mẫu, không trả toàn bộ danh sách. Web và mobile hiển thị "Sẽ gửi tới N người" trước khi gửi. | Người gửi biết quy mô trước khi bấm gửi; không lộ toàn bộ danh sách email. |
| B14 | **Gửi thử cho Admin**: `POST /api/v1/admin/mail-templates/{tid}/send-test` gửi một bản đã render tới email của chính Admin, dùng chung giới hạn tần suất gửi thử. Chỉ nhận `ADMIN_SYSTEM_BROADCAST`. | Admin kiểm tra nội dung trước khi gửi toàn hệ thống. |
| B15 | **Huỷ đăng ký cấp hệ thống**: token unsubscribe của batch không có Workspace mang dấu `system` thay vì workspaceId; huỷ đăng ký ghi vào danh sách chặn cấp hệ thống (`mail_suppressions.workspace_id` null, unique index `uq_mail_suppressions_system_email`); worker kiểm danh sách này trước khi gửi. Thông báo "gửi xong" của batch không có Workspace không kèm link. | Email broadcast hệ thống phải có link huỷ đăng ký dùng được. |
| B16 | **Phân quyền trang theo role** (nav): nguồn sự thật là `brandhub-web/src/routes/access.ts`; sidebar web và menu/màn mobile cùng lọc theo bảng này (xem [mobile-nav-role-parity](../../mobile-nav-role-parity/spec.md)). Mục "Mẫu email" của Agency hiện cho Owner agency và Manager của một Workspace thuộc Agency (B20). | Mỗi role chỉ thấy đúng các trang của vùng portal mình. |
| B17 | **Giới hạn khối khi lưu/render** (bổ sung 2026-10-29, vá lỗ hổng): `spacer.heightPx` phải trong 0-200 (tránh khoảng trống khổng lồ); `heading.align` nếu có chỉ nhận `left`/`center`/`right` (tránh chèn CSS vào thuộc tính `style`). Sai trả `BLOCK_SCHEMA_INVALID`; web chặn cùng ngưỡng ở `validateBlocks`. Mẫu cũ vi phạm sẽ không lưu lại được cho đến khi sửa. | Renderer là chốt chặn an toàn cho nội dung mail; ràng buộc chạy ở backend vì `layoutJson` có thể gửi thẳng qua API. |
| B18 | **Vá lỗ hổng rà soát 2026-10-29**: (1) `CAMPAIGN_BROADCAST` chỉ suy ra người nhận từ campaign thuộc đúng Workspace đang gửi, `campaignId` sai định dạng hoặc của Workspace khác trả `VALIDATION_ERROR`; (2) token huỷ đăng ký trong footer dùng workspace của **batch** (null với scope không-Workspace) để khớp danh sách chặn mà worker kiểm tra — huỷ đăng ký từ mail agency nay ghi vào danh sách chặn hệ thống; (3) cờ `external` tính một lần cho cả footer và `external_audience`; (4) `TRANSACTIONAL_AUTO` ẩn khỏi get/clone/preview của Workspace (trước đó chỉ ẩn ở list và send). | Phát hiện khi viết test biên; mỗi mục có test hồi quy trong `MailSendServiceTest`/`MailTemplateServiceImplTest`. |
| B19 | **Quyết định nghiệp vụ 2026-10-29 (chủ task xác nhận)**: (1) **Agency OWNER = `agency.ownerId`** cho cả CRUD, xem trước và gửi (trước đó đường gửi dùng `agency_members` role OWNER); (2) **Huỷ đăng ký ở mail agency chặn riêng theo Agency**: `mail_suppressions.agency_id`, token `agency:<id>`, worker kiểm danh sách của đúng Agency, không chặn broadcast hệ thống — cần chạy `2026-10-29-mail-suppressions-agency-postgres.sql`; (3) **Insert delivery theo lô 500** cho broadcast lớn; (4) **Admin xem/huỷ/gửi lại batch không thuộc Workspace**: `GET /api/v1/admin/mail-batches`, `/{id}`, `POST /{id}/cancel`, `/{id}/resend-failed` và view "Đợt gửi email hệ thống" trong Admin console (không có export CSV). Sửa kèm lỗi NPE khi thành viên Workspace truyền id batch không thuộc Workspace vào cancel/resend. | Trả lời 4 câu hỏi sau đợt rà soát; migration chưa chạy trên môi trường nào. |
| B20 | **Xác nhận nghiệp vụ B1-B16 và quyền mẫu Agency (chủ task, 2026-10-29)**: (1) B1/B9 giữ API nhận `bodyHtml` cho mẫu cũ, mẫu mới dùng `layoutJson`; (2) **`AGENCY_INTERNAL`/`AGENCY_CLIENT`**: Agency OWNER (`agency.ownerId`) **và Manager của một Workspace thuộc Agency** được xem/tạo/sửa/xoá **mọi** mẫu của Agency và gửi chúng; Creator và Manager workspace khác Agency không dùng được (`TEMPLATE_NOT_FOUND`/`AGENCY_SCOPE_FORBIDDEN`); (3) **phạm vi người nhận**: Owner gửi toàn Agency (AGENCY_CLIENT = Client mọi Workspace; AGENCY_INTERNAL = member Agency); Manager chỉ gửi **trong Workspace của mình** (AGENCY_CLIENT = Client Workspace đó; AGENCY_INTERNAL = member Workspace đó) để giữ cách ly giữa Workspace; xem trước người nhận cho Manager bắt buộc `workspaceId`; (4) B8 `TRANSACTIONAL_AUTO` chỉ là kho mẫu Admin soạn, trigger billing làm sau theo từng FR. | Trả lời câu hỏi xác nhận B1-B16; thay B5 (chỉ Owner) và mở rộng B11. Triển khai: `AgencyMailAccess` backend. |
| B21 | **Layout email và liên kết nút CTA (2026-10-29)**: (1) email dựng từ khối render thành khung email-safe (bảng, style inline, thẻ 600px, viền cam, nút CTA dạng bảng; header/contact_strip/footer có nội dung thật dùng `{{workspaceName}}`/`{{senderName}}`) và **không** đi qua `HtmlSanitizer.sanitize` (bộ lọc cắt table/style) mà chỉ qua `filterImages` (giữ allow-list host ảnh); mẫu viết tay (bodyHtml cũ) vẫn qua `sanitize`; sửa riêng tiêu đề của mẫu có `layoutJson` thì dựng lại từ layout; (2) `cta_button` loại `site`/`campaign`/`client` dùng biến dựng sẵn `{{ctaSiteUrl}}`/`{{ctaCampaignUrl}}`/`{{ctaClientUrl}}` điền lúc gửi: app, `/workspaces/{id}/campaigns`, `/workspaces/{id}/portal` (về app khi không có Workspace), cột CSV không ghi đè được. | Mail trước đó đến dưới dạng chữ thô và nút CTA không dẫn đi đâu. Mẫu đã lưu trước đây giữ HTML cũ cho đến khi lưu lại. |
| B22 | **Danh sách hủy đăng ký hệ thống/agency và nhãn batch (2026-10-29, chủ task xác nhận)**: (1) Admin xem và bỏ chặn danh sách hệ thống (`GET/DELETE /api/v1/admin/mail-suppressions?email=`); Agency OWNER và Manager Workspace thuộc agency xem và bỏ chặn danh sách của agency (`GET/DELETE /api/v1/agencies/{id}/mail-suppressions`); danh sách Workspace giữ như cũ; (2) **mọi lần bỏ chặn** (cả Workspace) ghi `audit_logs` (`DELETE`, `MAIL_SUPPRESSION`, `resourceId` = `system`/`agency:<id>`/`workspace:<id>`, `oldValue` gồm email, lựa chọn ban đầu, thời điểm huỷ đăng ký); (3) batch hệ thống trả thêm `scope`, `agencyId`, `agencyName` và lọc được theo `scope` (`GET /api/v1/admin/mail-batches?scope=`); (4) xem trước server hiển thị link nút CTA là `#`; ô Người nhận đọc `email, tên` trên cùng một dòng. Chính sách người nhận của Manager giữ nguyên: được nhập địa chỉ tuỳ ý (tối đa 200). | Người nhận đã chủ động từ chối nên bỏ chặn phải có dấu vết kiểm toán. |

**Trạng thái**: B1-B16 đã triển khai và có unit test (backend 170, web 70, mobile 140). **Chưa** chạy thử trên giao diện thật (trình duyệt/thiết bị) và **chưa** kiểm migration trên staging. Chủ task cần xác nhận chính thức B1-B16 trước khi gộp vào mục "Quyết định đã chốt" và cập nhật D1/D3/D14.
