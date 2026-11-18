# Spec: Claude CLI cho review và đặt tên trend

## Vấn đề
- Tên trend trên web chỉ có khoảng 2 từ. Lý do: code đặt tên bằng Claude ở T7 (`trend_naming.py`) chỉ nằm ở commit local `215d8ab` và chưa từng lên develop. BE dùng `display_name` nếu có, nếu không thì dùng `keyword`.
- Owner muốn chạy Claude qua CLI trên EC2, dùng gói Claude của mình thay cho API key.

## Phạm vi
- Khôi phục phần trend của commit `215d8ab`: kiểm tra nhãn cảm xúc/chủ đề, đặt tên T7, `display_name`/`name_status`, export retrain idempotent.
- Thêm `TREND_REVIEW_TRANSPORT=api|cli`. Khi chọn `cli`, gọi `claude -p` trong container ai-service, đăng nhập bằng `CLAUDE_CODE_OAUTH_TOKEN`.
- Không làm: tạo content khi user request (vẫn theo `LLM_PROVIDER`), retrain PhoBERT hằng tháng, video edit.

## Yêu cầu
- R1: `cli` phải xóa `ANTHROPIC_API_KEY`/`ANTHROPIC_BASE_URL` khỏi môi trường của CLI để tiền tính vào gói của owner.
- R2: Mỗi lần gọi là 1 lượt: không tool, không MCP, không lưu session, system prompt ngắn.
- R3: CLI lỗi, timeout hoặc trả JSON sai thì pipeline giữ nhãn PhoBERT và keyword, không dừng.
- R4: Không có binary `claude` thì bỏ qua bước review/đặt tên.
- R5: Mặc định vẫn là `api`.

## Ràng buộc
- `cli` chỉ dùng khi một mình owner dùng web. Có người dùng khác thì chuyển về `api`.
- Token là secret, chỉ để trong `.env` trên EC2, không commit.

## Bổ sung 17/11/2026
- R6: Trang Explore trends (`/ai/trends/explore`) trả thêm `displayName`. `keyword` vẫn là khóa để tra lịch sử. Ô tìm kiếm khớp cả hai.
- R7: Trend `mixed` (T4 gom nhiều chuyện vào một keyword): Claude chia thành các chuyện riêng. Mỗi chuyện có ít nhất 2 bài, các chuyện không trùng bài, mỗi chuyện có ít nhất 2 trích dẫn nguyên văn từ 2 bài khác nhau. Mỗi chuyện thành một trend có chủ đề, cảm xúc và bài lấy từ chính bài của nó. Bài lẻ bị bỏ. Không tách được thì giữ trend gốc.
- R8: Neo4j driver kiểm tra kết nối trước khi dùng lại (`liveness_check_timeout`). Aura tự cắt kết nối rảnh sau các bước Claude/PhoBERT chạy lâu, gây `SessionExpired`.
- R9: Explore trends ẩn các trend `name_status=mixed` (bài trùng một từ nhưng không liên quan). Dữ liệu lịch sử trong Neo4j không có trạng thái này nên vẫn hiển thị.
- R10: Biểu đồ lịch sử có thêm đường "tương tác trung bình mỗi bài" = expm1(engagement_score), tính trên like + share của các bài chứa từ khóa chính. Các node cũ cũng tính được.
- R11: Mục bài nguồn hiển thị dạng thẻ (tác giả, nội dung, like/share/comment), lấy `post_items` từ snapshot hiện tại. Ngày cũ không có trong snapshot thì hiển thị danh sách link như trước.
- R12: Tên trend 5-10 từ, tối đa 60 ký tự, kiểu tiêu đề báo: chuyện chính + điểm khiến người xem quan tâm. Chỉ thêm từ cảm xúc khi bài thể hiện rõ. Tên dài hơn 80 ký tự bị loại.
- R13: Explore trends đánh số rank liên tục trên danh sách đang hiển thị. Lịch sử trend mặc định 7 ngày. Trend chỉ có 1 ngày dữ liệu hiện ghi chú "trend mới" cùng dải tóm tắt cảm xúc và tương tác.
