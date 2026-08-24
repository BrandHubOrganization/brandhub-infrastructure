# Test — User Settings Page

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Vào trang Settings từ Navbar | click "Thiết lập" | navigate đúng `/settings`, không còn về `/` | ☐ |
| 2 | Load profile ban đầu | mount trang | hiện đúng fullName/email/timezone hiện tại từ `GET /users/me` | ☐ |
| 3 | Sửa fullName hợp lệ | đổi tên, submit | 200, toast success, Navbar/Sidebar hiện tên mới ngay không cần F5 | ☐ |
| 4 | Sửa fullName trống | xoá hết field, submit | chặn submit hoặc 400, không crash | ☐ |
| 5 | Email hiển thị read-only | xem tab Profile | field email không sửa được | ☐ |
| 6 | Upload avatar hợp lệ | file JPEG < 5MB | 200, avatar hiển thị đổi ngay ở Settings lẫn Navbar | ☐ |
| 7 | Upload avatar sai định dạng | file .pdf | chặn client-side hoặc 400 từ BE, toast lỗi rõ ràng | ☐ |
| 8 | Upload avatar quá dung lượng | file > 5MB | chặn client-side hoặc 413 từ BE, toast lỗi rõ ràng | ☐ |
| 9 | Đổi mật khẩu đúng | mật khẩu hiện tại đúng + mật khẩu mới khớp | 200, toast success, vẫn ở trang Settings (không redirect) | ☐ |
| 10 | Đổi mật khẩu sai mật khẩu hiện tại | mật khẩu hiện tại sai | lỗi từ BE, toast hiển thị đúng | ☐ |
| 11 | Mật khẩu mới không khớp xác nhận | 2 field khác nhau | chặn submit phía client, không gọi API | ☐ |
| 12 | Route `/change-password` cũ | truy cập trực tiếp URL cũ | không còn tồn tại (404 hoặc redirect, tuỳ router config) | ☐ |
| 13 | i18n VI/EN | chuyển ngôn ngữ trên trang Settings | không còn chuỗi hardcode, key khớp cả 2 file | ☐ |
| 14 | Light/Dark mode | chuyển theme | không vỡ contrast trên cả 3 tab | ☐ |
| 15 | `tsc --noEmit` | chạy sau khi sửa | không lỗi type | ☐ |
| 16 | `eslint` | chạy sau khi sửa | không lỗi trên file đã sửa | ☐ |
