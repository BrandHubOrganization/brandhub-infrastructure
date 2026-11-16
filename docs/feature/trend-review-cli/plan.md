# Plan
1. Nhánh `feature/DA-1238-trend-review-cli` (ai-service) tạo từ develop. Áp phần diff trend của `215d8ab`, bỏ phần video/retrain.
2. `llm_service.generate_trend_review` là điểm gọi Claude duy nhất cho review/đặt tên. Thêm nhánh `_trend_review_cli` (subprocess, JSON output) và `trend_review_ready()`.
3. `label_check` và `trend_naming` dùng `trend_review_ready()` thay cho kiểm tra `anthropic_api_key`.
4. Dockerfile cài native CLI bản cố định 2.1.287 (không cần Node).
5. Config: `TREND_REVIEW_TRANSPORT`, `CLAUDE_CLI_PATH`, `CLAUDE_CLI_TIMEOUT_SECONDS` (mặc định 180 s).
