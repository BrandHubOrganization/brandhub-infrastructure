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
| C8 | Explore API trả displayName; tìm theo tên mới vẫn ra keyword | pass (unit) |
| C9 | Tách mixed: chuyện chồng bài bị loại, chuyện hợp lệ thành trend riêng, có cache | pass (unit) |
| C10 | Test trend/pipeline | 137 pass |
| C11 | Replay 14, 16, 17/11 với Claude CLI | 3 ngày COMPLETED, 61/98/98 trend, khoảng 40% mixed trước khi tách |
| C12 | Replay 17/11 sau khi tách mixed | 51 trend, 22% mixed; tách ra 4 trend |
| C13 | Danh sách: 40 trend hiển thị, không còn ra mắt, đám cưới, hàn quốc, chuẩn bị | pass (API) |
| C14 | Lịch sử manchester united: 16/11 có 7 bài, tương tác 513; 17/11 có 5 bài, tương tác 799 | pass (API) |
| C15 | API bài nguồn chỉ trả link https và các trường cho phép | pass (unit) |
| C16 | Replay 16-17/11 với tên ngắn (v3) | ngày 17/11: 83 trend, hiện 60, ẩn 23 mixed; tên dài nhất 53 ký tự; rank liên tục |
