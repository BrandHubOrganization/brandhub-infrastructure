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

> Nguồn chuẩn: [../3-6-28-32-mail-template/plan.md](../3-6-28-32-mail-template/plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

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
