# spec — People avatars everywhere (web)

## Objective
Mọi chỗ trên web hiển thị một **người** (assignee, reporter, tác giả comment, người gửi chat, thành viên trong picker/danh sách) dùng ảnh avatar thay cho 2 chữ viết tắt. Đối tác (partner: báo, TV, banner) dùng hình khối minh họa. Mục tiêu: giao diện sinh động, đồng nhất.

## User Story
Là Owner/Manager/Creator/Client, tôi nhìn timeline, danh sách task, chat, picker thành viên và nhận ra người qua ảnh của họ.

## Acceptance Criteria
1. Người có `avatarUrl` → hiển thị ảnh đã upload.
2. Người chưa có ảnh, hoặc ảnh lỗi tải → ảnh minh họa DiceBear `notionists` sinh offline theo tên (cùng tên = cùng hình ở mọi màn hình).
3. Đối tác → DiceBear `shapes` theo tên đối tác.
4. API bổ sung avatar ở các payload còn thiếu: thành viên workspace, thành viên chat directory, tác giả comment task và danh sách mention comment.
5. Không gọi dịch vụ ngoài; không lộ dữ liệu user ra bên thứ ba.
6. **i18n:** không có text hiển thị mới; `alt` = tên người (dữ liệu, không phải chuỗi UI). Không đổi `vi.json`/`en.json`.
7. **Light/Dark:** ảnh minh họa có nền pastel cố định trong chính ảnh nên đọc được ở cả hai theme; khung ảnh dùng token `bg-muted`. Không thêm token màu.

## UI States
- Có ảnh → ảnh. Không ảnh → minh họa. Ảnh lỗi → minh họa. Chưa gán người → giữ icon "chưa gán" (nét đứt) như hiện tại.

## Edge Cases
Tên rỗng → seed `?`. Tên trùng nhau → cùng minh họa (chấp nhận). Đổi tên → minh họa đổi (chấp nhận, ghi chú ceiling).

## Definition of Done
tsc + lint sạch, test backend xanh, kiểm tra trên trình duyệt các màn: task list/board/timeline, chat, members, collaborators.

## Out of Scope
Logo workspace / client profile / agency (là thương hiệu, đã có logo uploader). Mobile app. Mockup mạng xã hội trong editor. Landing page.
