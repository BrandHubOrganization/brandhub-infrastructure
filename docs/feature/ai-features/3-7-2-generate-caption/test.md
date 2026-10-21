# Test — 3.7.2 Generate Caption

- [x] Chủ đề, mục tiêu, giọng điệu, nền tảng, độ dài, trend → 3 phương án để chọn/chỉnh sửa.
- [x] Bối cảnh tự thêm (thương hiệu, bài cũ, task, trend) được gửi lên AI và hiện "AI đã dùng: ...".
- [x] Con số không có trong chủ đề/thông tin thương hiệu bị đánh dấu "Cần xác nhận".
- [x] Phương án có dùng từ khoá trend được gắn "Có dùng trend"; trend rủi ro cao có cảnh báo.
- [x] Cảm xúc PhoBERT hiển thị; model lỗi → bỏ qua, không chặn caption.
- [x] Tuân thủ hiện "Chưa kiểm tra" cho tới khi nối 3.6.33; `BLOCKED` khoá nút chèn.
- [x] Refine: 6 kiểu + góp ý tự do (custom không có góp ý → 400); Adapt: mỗi nền tảng 1 bản.
- [x] Ghi lựa chọn 1 lần (lần 2 → 400).
- [x] Mỗi lần tạo/refine/adapt trừ credit riêng; AI lỗi → 502 không trừ; hết credit → 402 trước khi gọi AI.
- [x] Đổi VI/EN, light/dark không vỡ UI.

## Kết quả (2026-10-08)

Các kết quả dưới đây do Claude ghi trước khi hết giới hạn phiên; lần kiểm chứng tiếp nối được ghi riêng ở cuối file.

- AI service `test_caption_service.py` 6/6 (không gọi mạng, PhoBERT được giả lập).
- Business `AiCaptionServiceTest` 7/7, `AiCreditDatabaseTest` 2/2.
- Smoke API thật (Creator `user1@gmail.com`, trend thật "đinh hồng vinh"): 3 phương án đều dùng trend, 0 con số không nguồn, cảm xúc PhoBERT (vui 49% / trung lập 70%), tuân thủ NOT_CHECKED; refine "ngắn lại" và adapt TikTok/Threads chạy; ghi lựa chọn lần 2 → 400; `ai_credit_usages` ghi CAPTION / CAPTION_REFINE / CAPTION_ADAPT.
- Smoke UI thật: dialog trong Content Writing View hiện đủ mục tiêu, trend, "AI đã dùng", tín hiệu và công cụ chỉnh sửa.
- Lần gọi đầu khoảng 27s (nạp PhoBERT), các lần sau nhanh hơn.

## Kiểm chứng tiếp nối

- [x] RAG chỉ trả các document có metadata `clientId` của workspace đang dùng.
- [x] PostgreSQL: insert history thất bại → ledger/usages không tăng.
- [x] Bản adapt `BLOCKED` → nút Chèn disabled; handler cũng từ chối bản BLOCKED.
- [x] Generate lại sau adapt → bản adapt cũ không còn hiển thị.
- [x] Đổi nền tảng trên form sau generate → refine vẫn gửi nền tảng của caption đã tạo.
- [x] Trình soạn khởi tạo không có lỗi `schema.nodes` và nhận đúng caption AI.

### Kết quả tiếp nối ngày 2026-10-08

| Kiểm tra | Kết quả |
|---|---|
| AI `pytest tests/unit/services/test_caption_service.py -q` | 7 passed; có test RAG theo metadata tenant thực tế |
| Business `mvn -o -Dtest=AiCaptionServiceTest,AiCreditDatabaseTest test` | 10 tests, 0 failures/errors, gồm rollback khi lưu history thất bại trên PostgreSQL test |
| Web `playwright test tests/e2e/ai tests/e2e/editor --workers=2` | 15 passed, gồm 4 regression caption và các luồng editor/trend cũ |
| Web `npm run build` | Thành công (typecheck + Vite) |
| Web `npm run lint` | 0 errors, 80 warnings trên toàn repo; không coi warnings là đã xử lý |
| UI tiếng Anh/light và tiếng Việt/dark | Đã chụp và đọc ảnh dialog, key VI/EN song song, không có lỗi JavaScript; dùng API fixture, không gọi LLM |
| Runtime | Business 8081, AI 8082 và web 3000 trả HTTP 200. Creator qua gateway lấy credit HTTP 200; refine `custom` thiếu góp ý và generate topic quá ngắn trả 400 trước LLM |

**Regression RED → GREEN:** RAG từng trả `[]` do lọc `client_id` thay vì `clientId`; history thất bại từng làm credit giảm 200 → 199; adapt BLOCKED có nút Chèn vẫn enabled; tạo lại còn bản adapt cũ; refine gửi sai platform mới chọn trên form. Các test nay qua. Trình soạn cũng từng trắng vì effect gọi `getText()` khi TipTap chưa có schema; đã chặn cho đến khi editor khởi tạo.

### Giới hạn của bộ test toàn hệ thống

- Backend chạy đầy đủ: **405 tests, 0 failures, 11 errors, 9 skipped** — build toàn bộ test chưa xanh. 11 errors thuộc `WorkspaceControllerIntegrationTest` (6) và `WorkspaceTemplateControllerIntegrationTest` (5), do thiếu mock `ClientProfileRepository`/`WorkspaceRepository` trong test context. Lần chạy của Claude trước tiếp nối cũng có đúng hai nhóm lỗi này; không sửa ngoài phạm vi caption.
- AI chạy `pytest -q`: dừng ở **9 lỗi collection** do thiếu `moto`, `pytest_httpx` và các module `scripts.colab`, `scripts.run_commercial_benchmark`, `sdxl_runtime_worker`. Các file lỗi: `tests/integration/api/test_documents.py`, `tests/unit/api/test_ip_adapter_model_ambassador.py`, `tests/unit/services/test_cold_storage.py`, `test_cold_storage_transformed.py`, `test_sdxl_client.py`, `test_sdxl_inpaint_client.py`, `tests/unit/test_benchmark_runner.py`, `tests/unit/test_sdxl_runtime_mock.py`, `tests/unit/utils/test_s3.py`. Không coi toàn bộ AI suite là đã pass.
- Không gọi lại LLM live trong lần tiếp nối; kiểm tra tín hiệu PhoBERT/RAG dùng test double ở ranh giới ngoài. Smoke LLM live của Claude được giữ riêng ở phần kết quả trước đó.

**Bằng chứng:** log, ảnh và bản sao trước sửa ở `F:/LEARN/DA/.tmp/claude-caption-continuation-20261008/`. Phần phụ thuộc và hợp nhất panel cũ còn mở được ghi trong `plan.md`/`task.md`. Chưa commit/push phần tiếp nối.
