# Task — 3.7.2 Generate Caption

- [x] Migration `ai_credit_usages`, `ai_caption_generations`: 2 lần DB test, backup, 2 lần DB dev; gộp vào 2 init SQL, dựng DB trắng thành công.
- [x] Credit dùng chung `AiCreditService` (+ DB test).
- [x] Bước 1 — bối cảnh: thông tin thương hiệu, bài đã đăng, task, trend, mục tiêu; RAG phía AI service.
- [x] Bước 2 — 3 phương án (prompt có goal/examples/knowledge/trend).
- [x] Bước 3 — kiểm tra: con số không nguồn, dùng trend, cảm xúc PhoBERT, hook tuân thủ 3.6.33.
- [x] Bước 4 — refine (6 kiểu + góp ý), adapt nhiều nền tảng, ghi lựa chọn.
- [x] Dialog dùng chung trong Content Writing View và Trình soạn Nội dung.
- [x] Sửa map tone FRIENDLY/PLAYFUL của panel cũ.
- [x] Cập nhật `vi/editor.json` + `en/editor.json`; kiểm tra light/dark.
- [x] Ghi chú tích hợp cho Tuấn / Lộc / Trung (plan.md + javadoc).
- [x] Kiểm chứng và sửa RAG theo metadata tenant thực tế `clientId`.
- [x] Credit + lịch sử generation rollback cùng nhau khi lưu thất bại.
- [x] Bản adapt bị `BLOCKED` không chèn được; generation mới không giữ bản adapt cũ.
- [x] Kiểm tra refine dùng nền tảng của kết quả đã tạo.
- [x] Trình soạn mở được trước khi chèn AI: không đọc nội dung TipTap khi chưa khởi tạo.
- [x] Chạy lại kiểm thử và cập nhật bằng chứng hoàn tất; lỗi toàn hệ thống ngoài caption được ghi riêng trong test.md.
- [ ] Nối 3.6.33 (Tuấn), 3.9.5/3.9.6 (Tuấn), Task brief (Lộc), Knowledge Base thật.
- [ ] Nối hashtag từ trend thật và hợp nhất panel AI tạo nhanh cũ (Lộc).
