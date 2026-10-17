# UC — Add Comments On Task

| | |
|---|---|
| FR Code | 3.6.3 |
| Feature | Add Comments On Task |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR, CLIENT, MANAGER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã triển khai ứng dụng 2026-10-17; đã kiểm tra cô lập, chờ kiểm thử S3/inbox thật và team review |

## 1. Objective

Chốt thực thi 2026-10-17: không có QC/review chéo; Owner tham gia bằng membership Manager thực tế trong Workspace. Bình luận Task tách biệt nhận xét duyệt nội dung trong task_approvals. Theo yêu cầu người dùng, không thêm/commit file test dưới src.

Cho phép nhận xét, yêu cầu chỉnh sửa trên Task — dùng chung cho cả 3 role tham gia.

## 2. User Story

Là một Creator, Client, hoặc Manager,
tôi muốn bình luận trên 1 Task,
để trao đổi/yêu cầu chỉnh sửa trực tiếp trong luồng công việc.

## 3. Acceptance Criteria

- Textarea nhập comment, hỗ trợ mention (@user), có thể đính kèm ảnh/link tham khảo.
- Comment hiển thị theo timeline, kèm tên + role người comment + timestamp.
- Vẫn cho tạo comment mới trên Task COMPLETED/CANCELLED nếu người dùng còn quyền Workspace/Task. Comment không mở lại Task, Campaign hoặc vòng approval.
- Ảnh cho phép JPEG/PNG/WebP, tối đa 5 ảnh mỗi comment và 5 MB mỗi ảnh; kiểm tra ở UI và API, định dạng thực chứ không chỉ tên file.
- Q13 confirmed 2026-10-14: Client active được xem và bình luận mọi Task cùng Workspace, kể cả Task
  thủ công và Task cũ, không phân biệt nội bộ/thường. Lịch sử bình luận và ảnh đã ATTACHED cũng theo quyền
  Workspace; upload DRAFT vẫn chỉ chủ upload được preview. Không mở quyền người ngoài hoặc đã rời Workspace.
- Mention chỉ tới người có quyền Task và đang hoạt động trong Workspace; không coi một URL ảnh bất kỳ là attachment đã có quyền sử dụng.
- Thông báo in-app tới người được mention, Creator phụ trách và Manager của Workspace; bỏ trùng, bỏ tác giả và chỉ gửi người còn quyền Task. Client chỉ nhận khi được mention (Q11 confirmed); không gửi email hoặc thông báo mọi Client trong Workspace. Không lấy người QC lịch sử làm người nhận.

## 4. UI / UX

- Bình luận nằm dưới thông tin Task trong hộp chi tiết hiện có; không đổi layout/editor của thành viên khác.
- Nút Nhắc tên mở ngay danh sách tìm thành viên; chọn để thêm tên và người nhận thông báo. Nút ảnh mở trình chọn JPEG/PNG/WebP, có tiến trình tải, xem trước và bỏ ảnh nháp.
- Gõ `@` ở đầu dòng hoặc sau khoảng trắng ngay trong bình luận mở gợi ý thành viên; gõ tiếp để tìm. Không mở khi nhập email. Chọn bằng chuột hoặc ↑/↓ + Enter; Escape đóng gợi ý, không đóng Task. Giữ con trỏ trong ô nhập, thay đúng đoạn @ đang gõ, không xóa phần văn bản phía sau và không gửi bình luận khi Enter đang chọn tên. Khi đang gõ bộ chữ tiếng Việt (IME), Enter không chọn tên/gửi nhầm. Chỉ tên được chọn từ gợi ý mới thêm User ID mention; không tự biến mọi @text thành thông báo.
- Theo yêu cầu UX bổ sung: dropdown nổi bám vị trí dấu @ đang nhập, không chiếm chỗ thành một khối dưới ô. Tự tránh mép/đổi hướng khi thiếu chỗ. Thành viên hiển thị tên, vai trò và initials (API hiện không trả avatar); không bịa ảnh đại diện.
- Trong ô soạn, mention đã chọn là nhãn inline có nền nổi bật, gắn User ID, không phải đoạn @text tùy ý. Xóa/cắt nhãn sẽ bỏ người nhận nếu không còn nhãn nào của người đó; Undo khôi phục cả nhãn và liên kết. Không còn danh sách chip nhắc tên rời bên dưới. Copy/paste vào ô chỉ nhận văn bản, không nhận HTML/mention ID giả. Sau khi gửi vẫn giữ contract plain text + mentions User IDs hiện tại; chưa bổ sung vị trí/nhãn snapshot cho lịch sử comment cũ trong đợt UI này.
- Giữ nội dung/ảnh hợp lệ khi gửi lỗi; retry cùng nội dung không tạo trùng. Hiển thị xác nhận trước khi đóng nếu có bản nháp chưa gửi, dùng dialog của ứng dụng, không dùng thông báo mặc định trình duyệt.
- Timeline có tải lịch sử cũ và Làm mới; đợt này không mở rộng thành comment realtime qua WebSocket.

## 5. API Contract

```
POST /api/v1/workspaces/{id}/tasks/{taskId}/comments
{ "content": "string", "mentions"?: ["User UUID"], "attachmentIds"?: ["owned upload ID"], "clientRequestId": "UUID" }
→ 201 { "success": true, "data": { "id", "content", "authorId", "createdAt" } }

GET /api/v1/workspaces/{id}/tasks/{taskId}/comments?limit=30&cursor=...
→ 200 { "success": true, "data": { "items": [{...}], "nextCursor": "string|null" } }

GET /api/v1/workspaces/{id}/tasks/{taskId}/comment-members?search=&page=0
→ 200 { "success": true, "data": { "items": [{ "userId", "displayName", "role" }], "hasMore": false } }

POST /api/v1/workspaces/{id}/tasks/{taskId}/comment-uploads (multipart file)
→ 201 { "success": true, "data": { "id", "name", "contentType", "byteSize" } }

GET /api/v1/workspaces/{id}/tasks/{taskId}/comment-uploads/{id}/content
→ 200 private image bytes, Cache-Control: no-store
```

attachmentIds thay arbitrary URL để kiểm tra ownership; clientRequestId chống gửi trùng. Tác giả/role lấy phía server. content bắt buộc không rỗng, tối đa 10.000 ký tự, lưu plain text; HTTP(S) link an toàn do UI render. Không dùng Chat Workspace thay lịch sử bình luận theo Task. Chi tiết phân trang và giới hạn kỹ thuật xem [setup](../task-comments-implementation-2026-10-17.md).

## 6. Error Handling

- Không có quyền truy cập Task này (không thuộc Workspace) → 403 `FORBIDDEN`.

## 7. Edge Cases

- Client comment trên Task không yêu cầu Client duyệt → vẫn cho phép nếu còn active cùng Workspace. Cờ requiresClientApproval chỉ cấu hình duyệt kết quả, không quyết định quyền bình luận.
- Task terminal vẫn được comment; người bị gỡ khỏi Workspace không được gửi/xem tiếp dù từng tham gia thread.

## 8. Definition of Done

- Comment tạo/hiển thị đúng thứ tự thời gian.

## Out of Scope

- Edit/xóa comment sau khi đã gửi (không có trong CSV, có thể bổ sung sau).

## i18n và theme

Composer/timeline/mention/upload dùng `tasks.comments.*`; lỗi API dùng `tasks.workflow.errors.*` vi/en song song trong `src/i18n/locales/{vi,en}/tasks.json`. Semantic light/dark, bàn phím và layout mobile. Có loading/empty/forbidden/upload progress/error/success; lỗi upload/submit giữ draft, retry không tạo comment trùng. Xem [plan](plan.md), [task](task.md), [test](test.md).

## Tham chiếu BA

[05-content-task-workflow.md](../../../ba/05-content-task-workflow.md), [roadmap](../task-detail-assignment-comments-roadmap.md).
