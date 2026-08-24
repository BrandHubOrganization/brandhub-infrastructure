# Test — User Settings Expansion

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Vào Settings từ Sidebar | click "Thiết lập" (section Hệ thống) | navigate đúng `/settings`, hiện cho mọi role (không riêng ADMIN) | ☐ |
| 2 | Dropdown Navbar vẫn hoạt động | click "Thiết lập" từ avatar dropdown | vẫn navigate đúng `/settings` (2 lối vào song song) | ☐ |
| 3 | Đổi theme sáng→tối | click toggle tab General | UI đổi ngay, giữ nguyên qua reload | ☐ |
| 4 | Đổi ngôn ngữ Việt→Anh | click toggle tab General | toàn bộ UI đổi ngôn ngữ ngay, giữ qua reload | ☐ |
| 5 | Gửi OTP link phone | nhập số điện thoại hợp lệ | 200, OTP gửi (kiểm tra log dev nếu không có SMS thật) | ☐ |
| 6 | Xác nhận OTP đúng | nhập đúng mã 6 số | 200, phone hiển thị đã liên kết | ☐ |
| 7 | Xác nhận OTP sai | nhập sai mã | lỗi rõ ràng, không crash | ☐ |
| 8 | Gỡ liên kết phone (còn cách đăng nhập khác) | có mật khẩu/OAuth khác | 200, phone gỡ thành công | ☐ |
| 9 | Gỡ liên kết phone (phương thức cuối) | không mật khẩu, không OAuth khác | lỗi `LAST_LOGIN_METHOD`, không cho gỡ | ☐ |
| 10 | Link Google đúng email | chọn tài khoản Google cùng email hiện tại | redirect về `/settings?linked=google`, `linkedProviders` cập nhật, toast success | ☐ |
| 11 | Link Google sai email | chọn tài khoản Google khác email hiện tại | redirect `/settings?error=email_mismatch`, toast lỗi rõ ràng, KHÔNG tạo/link user nào | ☐ |
| 12 | Unlink Google (còn cách đăng nhập khác) | có mật khẩu | 200, provider gỡ khỏi `linkedProviders` | ☐ |
| 13 | Unlink Google (phương thức cuối) | không mật khẩu, không phone, không provider khác | lỗi `LAST_LOGIN_METHOD` | ☐ |
| 14 | Login-mode OAuth không đổi hành vi | login bằng Google như cũ (chưa từng có tài khoản) | vẫn tạo user mới + redirect `/oauth-callback?token=` như trước khi sửa | ☐ |
| 15 | i18n VI/EN | chuyển ngôn ngữ trên toàn bộ Settings | không hardcode text mới, key khớp cả 2 file | ☐ |
| 16 | Light/Dark mode | chuyển theme trên toàn bộ 5 tab | không vỡ contrast | ☐ |
| 17 | `tsc --noEmit` | chạy sau khi sửa | không lỗi type | ☐ |
| 18 | `eslint` | chạy sau khi sửa | không lỗi trên file đã sửa | ☐ |
| 19 | `mvn compile` + `mvn test` | chạy sau khi sửa backend | không lỗi, test case link-mode pass | ☐ |
