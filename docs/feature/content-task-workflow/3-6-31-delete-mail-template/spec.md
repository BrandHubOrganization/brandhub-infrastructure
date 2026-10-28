# UC — Delete Mail Template

| | |
|---|---|
| FR Code | 3.6.31 |
| Feature | Delete Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | OWNER, MANAGER, CREATOR (đã chốt 2026-10-12) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã chốt nghiệp vụ 2026-10-12 — xem plan.md, chưa code |

## Quyết định đã chốt (2026-10-12)

> Nguồn chuẩn: [plan.md](plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

- **Phạm vi**: template theo **Workspace**. **Role**: OWNER, MANAGER, CREATOR (CLIENT không). Sửa/xóa template của Workspace: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin sửa/xóa.
- **Soft delete** bằng `deletedAt` (không `repository.delete()`); không có khôi phục.
- Xóa template **không** hủy lô đã hẹn (đã snapshot) và không xóa lịch sử gửi.
- Quyền: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin (`DELETE /api/v1/admin/mail-templates/{tid}`).

## 1. Objective

Xóa mẫu email vừa tạo hoặc mẫu đang dùng.

## 2. User Story

Là một Member,
tôi muốn xóa mẫu email không còn dùng,
để giữ danh sách gọn gàng.

## 3. Acceptance Criteria

- Xóa Mail Template (đề xuất soft delete để nhất quán với pattern xóa khác trong hệ thống).

## 4. UI / UX

- Nút Delete trong list Mail Template, confirm dialog.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/workspaces/{id}/mail-templates/{templateId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Xóa thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)

## Phụ lục — đặc tả đã chốt cho FR này

> Tách từ bộ tài liệu Mail Template gộp trước đây; đây là phần áp dụng cho FR 3.6.31. Các mục dùng chung (quyết định, UI, API, lỗi) được giữ nguyên ở mọi FR để mỗi thư mục đọc độc lập.

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

#### 4.4 Delete (3.6.31 — DA-1001)
- AC-D1: Xóa mềm (`deletedAt`), có hộp thoại xác nhận.
- AC-D2: Lịch sử gửi và lô đã hẹn không bị ảnh hưởng.
- AC-D3: Quyền như AC-U3.

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

### Addendum B (2026-10-28): drag-drop block builder + multi-scope broadcast — ĐÃ TRIỂN KHAI (2026-10-29), chờ chủ task xác nhận chính thức

> Yêu cầu nghiệp vụ mới từ chủ task; khác với trình soạn TipTap tự do (D14) và phạm vi chỉ-Workspace (D1) đã chốt ở trên. B1-B10 đã được triển khai theo chỉ đạo của chủ task (2026-10-29). D1-D18 chỉ được ghi đè sau khi chủ task xác nhận chính thức.

| ID | Thay đổi đề xuất | Lý do |
|---|---|---|
| B1 | **Trình soạn**: thay TipTap rich-text tự do (D14) bằng **drag-drop block builder** — palette khối cố định (header, heading, paragraph, cta_button, image_banner, divider, spacer, footer...), sắp xếp bằng kéo-thả dạng sortable-list (tham khảo cơ chế BienSoDep `EmailBuilder.jsx` + `EmailBlockSchema.cs`, không copy code — stack khác C#/EF Core). `bodyHtml` không còn là input trực tiếp của người dùng; backend render HTML từ `layoutJson` (danh sách block + props), cùng cách `EmailBlockSchema` làm. | Đồng bộ trải nghiệm soạn giữa Agency và Admin, tránh HTML tự do khó kiểm soát khi mở rộng ra nhiều scope gửi. |
| B2 | **Phạm vi mở rộng** (thay D1): ngoài `type = SYSTEM_DEFAULT \| CUSTOM` theo Workspace, thêm field `scope` phân **6** giá trị: `CAMPAIGN_BROADCAST`, `ADMIN_SYSTEM_BROADCAST`, `AGENCY_INTERNAL`, `WORKSPACE_MANAGER`, `AGENCY_CLIENT`, `TRANSACTIONAL_AUTO`. Mỗi scope có kho template riêng (không gộp chung danh sách) — field `agencyId` mới, song song `workspaceId` hiện có (theo đúng pattern `Workspace.agencyId` đã dùng ở brandhub-business-service), set cho `AGENCY_INTERNAL`/`AGENCY_CLIENT`, null cho scope còn lại. | Khớp 6 use-case chủ task chốt: campaign gửi đối tượng truyền thông, Admin broadcast toàn hệ thống, Agency owner/manager gửi member nội bộ, Workspace manager gửi member workspace, Agency gửi Client đối tác, hệ thống tự gửi email giao dịch. |
| B3 | **Người nhận theo scope** (mở rộng D3; nguồn xác nhận 2026-10-28 sau khi đọc model Campaign): recipient **tự động suy ra theo scope** thay vì luôn dán/CSV thủ công — `CAMPAIGN_BROADCAST`: `MediaCampaign` **không có** field audience riêng, suy ra Client qua chuỗi `MediaCampaign.workspaceMediaPackageId` → `WorkspaceMediaPackage.workspaceId` (1-1) → `client_profiles` của workspace đó, **tái dùng cùng nguồn** `MailRecipientLookup` đã dùng cho `WORKSPACE_MANAGER` (khác mục đích/kho template, trùng nguồn dữ liệu — không cần field/entity mới); `ADMIN_SYSTEM_BROADCAST` lấy toàn bộ user hệ thống; `AGENCY_INTERNAL` lấy qua `AgencyMemberRepository.findByAgencyId` (đã có sẵn, tái dùng được); `WORKSPACE_MANAGER` lấy `workspace_members` (đã có qua `MailRecipientLookup`); `AGENCY_CLIENT` lấy client active trên mọi workspace của agency (method gộp **chưa có**, cần viết mới — chưa có sẵn trong `AgencyService`). Danh sách gợi ý tự động vẫn **cho sửa tay/bỏ chọn** trước khi gửi thật, giữ cơ chế `rejected[]`/preview/gửi-thử hiện có. | Chủ task chốt "tự động theo scope, cả 2" ở vòng brainstorm — không bắt agency tự gõ tay toàn bộ recipient mỗi lần, nhưng vẫn cho kiểm soát cuối trước khi gửi thật. |
| B4 | **Mobile**: thêm view mobile (Expo/RN) — chỉ xem danh sách template theo scope có quyền, chọn template, xem preview, chọn/sửa recipient gợi ý, bấm gửi. **Không** build/kéo-thả block trên mobile. | Chủ task chốt rõ: mobile chỉ xem+gửi, builder kéo-thả chỉ làm trên web. |
| B5 | **Quyền theo scope mới** (sửa 2026-10-28, khớp `docs/ba/10-roles-permissions-matrix.md` §1.1): `ADMIN_SYSTEM_BROADCAST` chỉ Admin hệ thống tạo/sửa/gửi (không phải Workspace OWNER/MANAGER/CREATOR như D2); `AGENCY_INTERNAL`/`AGENCY_CLIENT` chỉ **Agency OWNER** — Agency-level (Tầng 1 roles-matrix) chỉ có role OWNER, không có MANAGER riêng ở tầng này (MANAGER chỉ tồn tại ở Workspace-level, Tầng 2); dùng check `agency.getOwnerId().equals(currentUserId)` như các FR Agency-level khác, không dùng `@RequireRole` của Workspace. `CAMPAIGN_BROADCAST`/`WORKSPACE_MANAGER` giữ nguyên quyền Workspace D2. | Mỗi scope có chủ sở hữu rõ ràng, tránh lẫn quyền Agency-level và Workspace-level vốn đã tách bảng ở backend; sửa lại sau khi đối chiếu roles-matrix phát hiện B5 bản đầu ghi sai "Agency MANAGER" không tồn tại ở tầng này. |
| B6 | **`MailTemplateType` kỹ thuật**: logic hiện tại (`MailTemplateServiceImpl`, `MailSendService`) so sánh nhị phân `== SYSTEM_DEFAULT` else CUSTOM ở nhiều nơi — mở rộng thành 6+ giá trị **bắt buộc** đổi các nhánh này thành kiểm tra permission/ownership tường minh theo `scope`, không dùng type-equality ngầm định nữa, nếu không mọi scope mới sẽ rơi nhầm vào nhánh CUSTOM cũ. | Phát hiện khi rà code hiện có — rủi ro breaking nếu chỉ thêm giá trị enum mà không sửa logic nhánh. |
| B8 | **`TRANSACTIONAL_AUTO`** (scope thứ 6, bổ sung 2026-10-28 sau rà soát đối tượng dùng): Admin soạn template bằng block builder cho sự kiện hệ thống tự động trigger (billing thất bại, sắp hết hạn Subscription, cảnh báo bảo mật...) — **không ai bấm gửi tay**; hệ thống tự enqueue khi sự kiện xảy ra, dùng người nhận = 1 user cụ thể (không phải danh sách), không qua batch/CSV/scope-recipient của B3. Không thay thế `AdminEmailOutbox` hiện có (giữ nguyên cho các luồng đã dùng nó) — chỉ các luồng mới dùng `TRANSACTIONAL_AUTO` muốn soạn bằng block builder thay vì hard-code HTML trong code mới đi qua nhánh này. | Rà soát theo `docs/ba/10-roles-permissions-matrix.md`: email giao dịch tự động (FR 3.9 Subscription) không khớp mô hình "người dùng chủ động chọn recipient rồi gửi" của 5 scope B2 ban đầu — chủ task xác nhận đưa vào phạm vi. |

| B9 | **Block palette** (chốt 2026-10-28, sửa paragraph 2026-10-28): 9 block cơ bản — `header` (logo+tên Agency/Workspace, không props), `heading` (text+align), `paragraph` (**plain textarea, không rich-text** — không bold/italic/link, giữ đúng tinh thần B1 thay hẳn TipTap bằng block cố định đơn giản, tránh kéo trình soạn rich-text trở lại), `image_banner` (ảnh + alt + link đích), `cta_button` (label+url_type: site/campaign/client/custom), `divider` (đường kẻ, không props), `spacer` (height_px), `contact_strip` (liên hệ Agency/Workspace, không props), `footer` (không props, tự chèn unsubscribe nếu `externalAudience`). **Không** đưa vào các block đặc thù biển số (`plate_block`, `stars`, `video_banner` của BienSoDep) — không hợp bối cảnh BrandHub. | Chủ task chốt dùng bộ cơ bản, bỏ phần đặc thù domain khác. |
| B10 | **Thứ tự triển khai** (chốt 2026-10-28): Backend trước — block schema (`layoutJson` + 9 block type ở B9) + render engine + mở rộng `MailTemplateType`/`scope`/`agencyId` (B2, B6) + API theo 6 scope (B5) hoàn thiện và test trước; FE web (drag-drop builder, B1) và FE mobile (view/send, B4) code sau khi API ổn định — cùng pattern đã làm với `MailDeliveryService` ở giai đoạn trước. | Chủ task chốt backend-first, tránh FE phải đổi theo khi schema backend còn thay đổi. |

**Trạng thái**: B1-B10 đã triển khai ở backend, web và mobile; các điểm bổ sung B11-B16 (đường gửi theo scope, chặn lạm dụng mẫu hệ thống, xem trước người nhận, gửi thử, huỷ đăng ký cấp hệ thống, phân quyền trang) ghi ở [3-6-32-send-email-via-template/spec.md](../3-6-32-send-email-via-template/spec.md). Chủ task vẫn cần xác nhận chính thức trước khi gộp vào mục "Quyết định đã chốt" và cập nhật D1/D3/D14.
