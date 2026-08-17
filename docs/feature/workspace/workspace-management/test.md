# Test — Quản lý Workspace (Create / Settings / Members)

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Tạo workspace hợp lệ | name + industry | 201, workspace mới, user thành OWNER | ☐ |
| 2 | Tạo workspace thiếu name | industry only | 400 VALIDATION_ERROR | ☐ |
| 3 | Slug trùng | 2 workspace cùng tên | slug thứ 2 tự thêm suffix, không lỗi | ☐ |
| 4 | Sửa settings (OWNER) | timezone mới | 200, lưu đúng jsonb | ☐ |
| 5 | Sửa settings (VIEWER) | role không đủ quyền | 403 INSUFFICIENT_ROLE | ☐ |
| 6 | Xem danh sách member | workspace có 3 member | 200, trả đúng 3 record | ☐ |
| 7 | Mời member mới | email chưa từng join | 201, tạo invitation, gửi email | ☐ |
| 8 | Mời email đã là member | email active sẵn | 409 ALREADY_MEMBER | ☐ |
| 9 | Xoá member (không phải OWNER cuối) | memberId hợp lệ | 200, isActive=false | ☐ |
| 10 | Xoá OWNER cuối cùng | memberId là OWNER duy nhất | 409 LAST_OWNER_CANNOT_BE_REMOVED | ☐ |
| 11 | Frontend: tạo workspace UI | điền form, submit | redirect vào workspace mới | ☐ |
| 12 | Frontend: ẩn nút mời/xoá | user role VIEWER | không thấy nút mời/xoá trên Members page | ☐ |
| 13 | Frontend: WorkspacePage danh sách thật | có ≥1 workspace | hiển thị đúng data API, không còn hardcode | ☐ |
| 14 | i18n VI/EN | chuyển ngôn ngữ trên 3 trang mới | không còn chuỗi tiếng Việt/Anh hardcode, key khớp cả 2 file | ☐ |
| 15 | Light/Dark mode | chuyển theme trên 3 trang mới + WorkspacePage | không vỡ contrast/màu sắc | ☐ |
