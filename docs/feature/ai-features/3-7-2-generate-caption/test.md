# Test — 3.7.2 Generate Caption

- [x] Nhập chủ đề, giọng điệu, nền tảng, độ dài → 3 phương án để chọn/chỉnh sửa.
- [x] Chủ đề < 10 ký tự → 400, không gọi AI.
- [x] Mỗi lần tạo trừ credit riêng (tạo lại = trừ lần nữa); ghi `ai_credit_usages` + `ai_credit_ledgers`.
- [x] Hết credit agency hoặc chạm hạn mức Owner đặt → 402 `INSUFFICIENT_AI_CREDIT`, không gọi AI.
- [x] AI lỗi → 502 `AI_SERVICE_UNAVAILABLE`, không trừ credit.
- [x] Giá cấu hình: phí cố định + theo ký tự; đặt 0 → miễn phí.
- [x] "Chèn" chèn tại con trỏ; "Thay toàn bộ" thay nội dung qua Yjs; caption vẫn chỉnh sửa được.
- [x] Đổi VI/EN, light/dark không vỡ UI.

## Kết quả (2026-10-08)

- `AiCaptionServiceTest` 4/4, `AiCreditDatabaseTest` 2/2 (PostgreSQL test DB).
- Smoke API thật (Creator `user1@gmail.com`, workspace Dev Creator): 3 caption tiếng Việt qua Gemini trong 12.6s, `creditsUsed=1`, còn 199/200; ledger tháng 2026-10 = 1.
- Smoke UI thật: mở dialog, chọn TikTok/Ngắn, tạo, "Thay toàn bộ" → caption + hashtag vào editor và preview.
- Ghi chú môi trường: key Groq trong `.env` không còn hợp lệ (`invalid_api_key`) nên dev dùng `LLM_PROVIDER=gemini`; cần key Groq mới nếu muốn quay lại Groq.
