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
