# Edit video gọi thẳng server Edit_Video

## Objective
Chat "Claude edit" trong Video Space chạy trên server Edit_Video riêng (`brandhub-edit-video`, tự bật khi có request), không qua worker ai-service nữa.

## User Story
Là creator, tôi nhắn yêu cầu edit trong Video Space, Claude trên server mới tự xem clip, tự quyết có hỏi lại không, rồi trả video; tôi xem ngay trong chat và đưa vào timeline.

## Acceptance Criteria
- Gửi tin nhắn đầu: các clip của project được upload lên Edit_Video qua gateway, kèm yêu cầu.
- Tin nhắn sau (trả lời câu hỏi hoặc sửa tiếp) nối tiếp lượt trước (`parent_id`); chỉ gửi clip mới chưa gửi.
- Chat hiện tiến độ (`progress`), câu hỏi (`NEEDS_INPUT`), video khi `COMPLETED`, lỗi khi `FAILED`.
- Máy edit đang ngủ: lần gửi chờ máy dậy (tối đa 5 phút) rồi mới upload.
- Nút đưa vào timeline dùng MP4 kết quả (không có lớp sửa được).
- API key Edit_Video chỉ nằm ở gateway, không xuống trình duyệt.
- i18n / Light-Dark: không thêm text hay màu mới; giao diện chat giữ nguyên.

## API Contract
Gateway `/api/v1/edit-video/**` (JWT + RateLimit) → Edit_Video `/**`, gateway gắn `X-API-Key`:
- `GET /api/v1/edit-video/health`
- `POST /api/v1/edit-video/v1/edits` multipart `instruction`, `files[]`, `parent_id?` → `202 {id, status}`
- `GET /api/v1/edit-video/v1/edits/{id}` → `{status, summary, questions, error, has_video, progress, created_at}`
- `GET /api/v1/edit-video/v1/edits/{id}/video` → MP4

Editor (iframe) giữ nguyên hợp đồng cũ `/auto-edits`; trang web chính dịch sang API trên.

## Error Handling / Edge Cases
- 502/503/504 hoặc lỗi mạng khi health: chờ `Retry-After` (tối đa 30 giây/lần), quá 5 phút báo lỗi gửi.
- Lượt bị mất trên server (404): hiện FAILED.
- Đổi trình duyệt: lịch sử chat lưu ở trình duyệt nên không thấy lượt cũ.

## Definition of Done
Gateway có route + test; web có adapter + test; gửi 1 clip thật trên web local nhận được video.

## Out of Scope
Credit AI và lịch sử job ở business; lớp timeline sửa được (TIMELINE.json); phân quyền xem job theo user (id job ngẫu nhiên 128 bit); route gateway prod (Tuấn cấu hình qua nginx `/edit-video/` để có waker).
