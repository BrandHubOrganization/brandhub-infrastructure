# Tác vụ nền AI caption / image / video

Ngày 17/11/2026. Phạm vi đã được người dùng chốt: chỉ tạo caption, ảnh thương mại và video AI. Không thay ambassador, character-sheet, refine/adapt, RAG, crawl/replay, product-video hoặc auto-edit.

## Mục tiêu và nghiệm thu

- Server nhận việc bền vững rồi trả 202; thông báo đúng “Đã nhận yêu cầu”. Người dùng có thể đổi trang hoặc đóng tab; mở lại lấy job từ server.
- Khay tác vụ hiện hữu theo dõi trạng thái thật; không giả lập phần trăm cho ba luồng mới.
- Thông báo hoàn thành là phần tử bấm được, mở thẳng preview, không yêu cầu nút Xem kết quả. Inbox có deep link để mở lại sau; click trong ứng dụng giữ nguyên trang đang chỉnh.
- Caption preview chỉ đọc/copy; image/video dùng lại lightbox chat (zoom/rotate/video controls), không tự chèn, thay thế hoặc publish bài.
- Mỗi job thuộc actor + workspace, kiểm tra quyền lúc nhận/đọc/thực thi; không mở rộng quyền Client. Cùng key/input trả job cũ; key cũ khác input conflict.
- Credit reservation và job tạo nguyên tử trong PostgreSQL. Dùng nguyên generation/credit/moderation/draft/history hiện có. Mất phản hồi provider không được tự sinh lần gọi trả phí khác.
- Sau restart, job chưa dispatch tiếp tục; job đang có kết quả/provider identity được đối soát; unknown giữ trạng thái cần đối soát. Không khẳng định hủy provider khi chỉ ngừng theo dõi.
- VI/EN key song song; dùng theme tokens BrandHub, kiểm tra light/dark, keyboard và responsive.

## Contract

POST /api/v1/workspaces/{workspaceId}/ai/jobs: kind CAPTION|CONTENT|IMAGE|VIDEO|VIDEO_DIRECT, input JSON đúng DTO hiện hữu, Idempotency-Key. CONTENT là caption legacy; VIDEO_DIRECT là video endpoint generic, không phải loại tính năng thêm.
GET /api/v1/ai/jobs: danh sách job của caller (summary không input/result), có cursor.
GET /api/v1/ai/jobs/{id}: trạng thái và kết quả theo quyền hiện tại.
Job: QUEUED, RUNNING, RECONCILIATION_REQUIRED, SUCCEEDED, FAILED. Không thêm cancel trả phí trong đợt này.

## Ngoài phạm vi

Không đổi prompt/model/credit policy; không migration/deploy production tự động; không thay data/model trend. Upload có bytes tham chiếu được snapshot trong job trước response, không hứa upload tiếp khi file vẫn chỉ ở RAM của tab.
