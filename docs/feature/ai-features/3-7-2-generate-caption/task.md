# Task — 3.7.2 Generate Caption

- [x] Migration `ai_credit_usages`: 2 lần DB test, backup, 2 lần DB dev; gộp vào 2 init SQL, dựng DB trắng thành công.
- [x] `AiCreditService` + `AiCreditDatabaseTest` (gói Basic mặc định, ledger, hạn mức cứng Creator, hoàn credit 1 lần, tháng theo giờ VN).
- [x] `AiCaptionService` + `AiCaptionServiceTest` (3 phương án, chỉ trừ khi thành công, 502 không trừ, 402 chặn trước khi gọi AI, giá cấu hình/miễn phí).
- [x] `AiCaptionController` (MANAGER/CREATOR).
- [x] Web: dialog AI caption trong Content Writing View, chèn / thay toàn bộ, hiện credit còn lại.
- [x] Cập nhật `vi/editor.json` + `en/editor.json`.
- [x] Kiểm tra light/dark mode.
- [x] Smoke live: Creator thật tạo caption, chèn vào editor.
