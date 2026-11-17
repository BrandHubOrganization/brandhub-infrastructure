# Plan
1. Nhánh `feature/DA-1238-trend-review-cli` (ai-service) tạo từ develop. Áp phần diff trend của `215d8ab`, bỏ phần video/retrain.
2. `llm_service.generate_trend_review` là điểm gọi Claude duy nhất cho review/đặt tên. Thêm nhánh `_trend_review_cli` (subprocess, JSON output) và `trend_review_ready()`.
3. `label_check` và `trend_naming` dùng `trend_review_ready()` thay cho kiểm tra `anthropic_api_key`.
4. Dockerfile cài native CLI bản cố định 2.1.287 (không cần Node).
5. Config: `TREND_REVIEW_TRANSPORT`, `CLAUDE_CLI_PATH`, `CLAUDE_CLI_TIMEOUT_SECONDS` (mặc định 180 s).
6. `workspace_trends.py` thêm `displayName`; web `workspace-trends` hiển thị `displayName || keyword` (nhánh web `feature/DA-1238-trend-display-name`).
7. `trend_naming.split_mixed`: batch 3 nhóm, mỗi nhóm tối đa 40 bài (nhiều like nhất), cache `trend_names/split_<hash>.json`. `FusionStep._split` dựng lại trend con bằng `_assemble(posts=...)`. Điểm trend con = điểm cụm × (số bài của chuyện / số bài của cụm), vì anomaly tính theo term chứ không theo bài.
8. `app/utils/neo4j.py`: `liveness_check_timeout=60`, `max_connection_lifetime=300`.
