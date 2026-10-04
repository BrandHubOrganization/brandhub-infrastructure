# Task — 3-10-8-update-user

- [x] Đối chiếu spec và quyết định ngày 2026-10-01.
- [x] Viết plan kỹ thuật và kịch bản test trước code.
- [x] `GET/PATCH /api/v1/admin/users/{id}` với `rowVersion` (409 khi xung đột) và lý do bắt buộc 5–2000 ký tự.
- [x] Email bất biến (`EMAIL_IMMUTABLE`); không đổi vai trò của chính mình hoặc ADMIN khác; chủ Agency không thành ADMIN (`USER_ROLE_PROTECTED`).
- [x] Đổi gói chỉ áp dụng kỳ sau (`subscription_plan_changes` PENDING, `payment_required`), không đổi quota/MRR hiện tại; `""` hủy yêu cầu đang chờ.
- [x] Thẻ phạt chỉ xem (sửa qua FR 3.10.5). Audit UPDATE ghi diff trước/sau.
- [x] UI dialog chỉnh sửa, khóa vai trò kèm lý do, gửi lại email kích hoạt cho tài khoản chờ; locale VI/EN; light/dark.
- [x] Chạy test/build; ghi kết quả trong test.md.
- [ ] Review độc lập diff trước khi push.
