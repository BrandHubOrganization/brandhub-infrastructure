# Test — Workspace Context & Role Display

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Login lần đầu, chưa có active workspace lưu | user có 2 workspace | active workspace = workspace đầu tiên trong danh sách API | ☐ |
| 2 | Đổi workspace qua dropdown | click workspace khác trong Sidebar | badge role đổi đúng theo `MemberRole` tại workspace mới, không reload trang | ☐ |
| 3 | Active workspace lưu qua reload | reload trang (F5) | vẫn đúng workspace đã chọn trước đó, không về workspace đầu tiên | ☐ |
| 4 | Active workspace id không còn hợp lệ | localStorage trỏ workspace đã bị remove | fallback về workspace đầu tiên trong danh sách mới, không lỗi | ☐ |
| 5 | User role = CLIENT ở workspace hiện tại | vào Sidebar | chỉ thấy dashboard/requests/portal/calendar/library, không thấy `/workspace`, `/editor` | ☐ |
| 6 | User role = OWNER | vào Sidebar | chỉ thấy quản lý tổng quan (dashboard/analytics/workspace/clients/social-accounts/subscription/reports), không thấy công cụ content | ☐ |
| 6b | User role = CREATOR | vào Sidebar | chỉ thấy công cụ content (editor/templates/hashtag/calendar/library/publish/ai-studio), không thấy clients/analytics | ☐ |
| 7 | SystemRole = ADMIN | vào Sidebar bất kỳ MemberRole nào | thấy "Admin Panel", độc lập với MemberRole workspace hiện tại | ☐ |
| 8 | SystemRole = USER (không phải admin hệ thống) | vào Sidebar | không thấy "Admin Panel" dù MemberRole = OWNER | ☐ |
| 9 | Badge role không còn dropdown chọn được | click vào badge "Role: ..." trong Navbar | không mở menu, không đổi được role — chỉ hiển thị | ☐ |
| 10 | Không còn code role simulator | grep `handleRoleSimulation`/`ROLE_LABELS` trong Navbar.tsx | không còn tồn tại trong codebase | ☐ |
| 11 | User 0 workspace (mới đăng ký) | login lần đầu, chưa tạo/join workspace nào | Sidebar dropdown rỗng, badge role ẩn, không crash | ☐ |
| 12 | `GET /workspaces` lỗi mạng | mock lỗi network | Sidebar switcher rỗng, toast lỗi, không crash toàn trang | ☐ |
| 13 | `GET /workspaces/{id}/members` lỗi | mock lỗi network | badge role ẩn (không toast), Sidebar vẫn render | ☐ |
| 14 | `GET /users/me` lỗi | mock lỗi network | Admin Panel ẩn (fail-safe), không crash | ☐ |
| 15 | i18n VI/EN | chuyển ngôn ngữ | label role/menu đổi đúng theo `workspace.roles.*`, không hardcode text mới | ☐ |
| 16 | Light/Dark mode | chuyển theme | Sidebar/Navbar giữ đúng contrast, không vỡ token màu | ☐ |
| 17 | `tsc --noEmit` | chạy sau khi sửa | không lỗi type | ☐ |
| 18 | `eslint` | chạy sau khi sửa | không lỗi trên file đã sửa | ☐ |
