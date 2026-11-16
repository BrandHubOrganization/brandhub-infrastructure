# Test
| ID | Case | Kết quả |
|---|---|---|
| C1 | CLI gọi `-p`, `--tools ""`, đúng model, prompt qua stdin, không có ANTHROPIC_API_KEY | pass (unit) |
| C2 | stdout không phải JSON, `is_error`, kết quả rỗng thì raise `LLMQualityError` | pass (unit) |
| C3 | Không có binary thì `trend_review_ready()` = False | pass (unit) |
| C4 | Test trend cũ (label_check, naming, neo4j, trend_fit, transport) | 62 pass |
| C5 | Gọi thật `claude -p` trên máy dev (Haiku) | pass: trả tên đầy đủ "Sơn Tùng MV Chúng Ta Của Tương Lai được fan khen đẹp" |
| C6 | Docker build cài CLI trong image | chưa chạy (Docker local tắt). CI build sẽ kiểm tra |
| C7 | Trên EC2: tên trend hiện đầy đủ | chờ T5/T6 |
