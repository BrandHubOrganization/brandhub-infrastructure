# Sprint 6 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer |
| Sprint | Sprint 6 |
| Ngày nộp | Chưa cập nhật |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-AI03-04 | [DA-596](https://letritrung2605.atlassian.net/browse/DA-596) | Test RAG Accuracy for Brand Knowledge Base | Chưa xác nhận | ✅ Done |
| DA-AI04-03 | [DA-225](https://letritrung2605.atlassian.net/browse/DA-225) | Integrate fallback when Groq is rate-limited or quality fails — triển khai Gemini thay Claude | 🔴 Critical | ✅ Done |
| DA-AI05-01 | [DA-739](https://letritrung2605.atlassian.net/browse/DA-739) | Aggregate and Select Required Scraping APIs on Apify & Scrape Creators | Chưa xác nhận | ✅ Done |
| DA-AI05-02 | [DA-740](https://letritrung2605.atlassian.net/browse/DA-740) | Demo Crawled Social Media Data on Google Sheets | Chưa xác nhận | ✅ Done |
| DA-AI05-03 | [DA-741](https://letritrung2605.atlassian.net/browse/DA-741) | Complete End-to-End Social Media Crawl Workflow via N8N or Custom Code | Chưa xác nhận | ✅ Done |
| DA-AI05-04 | [DA-742](https://letritrung2605.atlassian.net/browse/DA-742) | Host and Set Up ChromaDB or Neo4j Database Instance for Storing Raw Data | Chưa xác nhận | ✅ Done |
| DA-AI05-05 | [DA-743](https://letritrung2605.atlassian.net/browse/DA-743) | Message Queue / Buffer Layer Integration (Redis Queue / Kafka) | Chưa xác nhận | ✅ Done |

**Tổng:** 7 tasks | Done: 7 | In Review: 0 | In Progress: 0 | To Do: 0

**Căn cứ trạng thái:** ảnh Jira được cung cấp. Chi tiết kỹ thuật dưới đây đối chiếu với mã nguồn hiện tại; trạng thái Done không thay thế cho biên bản chạy test hoặc số liệu benchmark.

---

## 3. Chi tiết công việc đã làm cho 7 task Done

Các đường dẫn trong phần này tính từ repository `brandhub-ai-service`, trừ khi ghi rõ khác.

### [DA-AI03-04] — Test RAG Accuracy for Brand Knowledge Base

**Jira status:** Done  
**Phạm vi:** đánh giá độ chính xác truy xuất RAG và mức độ bám sát tài liệu thương hiệu của câu trả lời.

**Nội dung nghiệm thu theo task:**

- Bộ đánh giá gồm 3 tài liệu thương hiệu thực tế dạng PDF/DOCX và 20 câu hỏi benchmark.
- Mục tiêu retrieval precision ≥ 85%.
- Kiểm tra LLM trả lời từ context truy xuất, không tự bổ sung thông tin thiếu căn cứ.
- Theo dõi Context Relevance và Faithfulness với ngưỡng mục tiêu ≥ 0.85.

**Kết quả và minh chứng:** task đã chuyển Done trên Jira. Chưa có bảng kết quả, danh sách tài liệu và câu hỏi benchmark trong nguồn dùng để lập report; các ngưỡng trên là tiêu chí nghiệm thu, không phải số đo đã xác nhận.

**Ghi chú bàn giao:** bổ sung link dataset và kết quả từng câu hỏi để team có thể chạy lại, đối chiếu precision và faithfulness.

---

### [DA-AI04-03] — Integrate fallback when Groq is rate-limited or quality fails

**Jira status:** Done  
**Phạm vi:** bổ sung cơ chế dự phòng cho sinh nội dung khi Groq gặp lỗi tạm thời hoặc trả nội dung không đạt chất lượng.

**File liên quan:**

- `app/services/llm_service.py`
- `app/services/gemini_client.py`
- `app/core/clients.py`, `app/core/config.py`
- `app/api/v1/endpoints/content.py`, `app/models/content_models.py`
- `tests/DA-AI04-03/test_llm_fallback.py`, `tests/DA-AI04-03/test_content_endpoint.py`

**Công việc đã thực hiện:**

- Triển khai Groq → Gemini fallback một lần khi lỗi kết nối, HTTP 408/429/5xx hoặc output rỗng, chỉ có khoảng trắng, bị cắt hay không đạt quality check.
- Giữ nguyên prompt khi chuyển provider; kiểm tra chất lượng cả kết quả Gemini.
- Không fallback cho lỗi request/xác thực không phù hợp; lỗi model 404 được báo ra để xử lý cấu hình.
- Thêm `POST /api/v1/ai/content/generate`, xác thực bằng `X-Internal-Key`, kiểm tra prompt và trả nội dung qua trường `text`.
- Cho phép chọn `provider` theo từng request trên Swagger: mặc định `groq`, có thể chọn `gemini`; lựa chọn không thay đổi cấu hình chung của service.
- Bổ sung log provider, loại lỗi và HTTP status upstream, không ghi API key hoặc prompt.
- Viết test cho fallback, chất lượng output, chọn provider, xác thực, validation và OpenAPI; thêm comment giải thích testcase.
- Kiểm tra trực tiếp Groq: model `llama-3.3-70b-versatile` trả 404 `model_not_found` với key hiện tại; `openai/gpt-oss-20b` trả 200 và `finish_reason=stop`. Đã cập nhật model trong cấu hình local.

**Kết quả đạt được:** đã có service fallback và API để thử trên Swagger. Chưa có kết quả chạy toàn bộ pytest được xác nhận trong phiên làm việc do môi trường công cụ không tìm thấy Python.

**Thay đổi so với mô tả Jira:** Jira ghi Claude 3.5 Sonnet, nhưng triển khai thực tế dùng Gemini; biến `CLAUDE_FALLBACK_MODEL` không còn sử dụng và đã được xóa khỏi `.env`. Cần cập nhật mô tả/acceptance criteria trên Jira để thống nhất với deliverable.

---

### [DA-AI05-01] — Aggregate and Select Required Scraping APIs on Apify & Scrape Creators

**Jira status:** Done  
**Phạm vi:** tích hợp các nguồn API phục vụ thu thập dữ liệu mạng xã hội theo hướng API-first của Sprint 5.

**File liên quan:**

- `app/services/scrapers/base.py`
- `app/services/scrapers/apify_scrapers.py`
- `app/services/scrapers/scrape_creators.py`
- `app/services/scrapers/scrape_creators_post.py`
- `app/services/scrapers/facebook_comments.py`

**Công việc thể hiện trong mã nguồn:** xây dựng các adapter cho Apify và ScrapeCreators, tách phần gọi nguồn dữ liệu khỏi pipeline xử lý; có module riêng cho bài đăng và bình luận Facebook.

**Kết quả đạt được:** mã nguồn có các adapter phục vụ tích hợp crawler. Cần đính kèm bảng API/actor đã chọn và thông tin quota thực tế khi bàn giao để làm rõ chi phí vận hành.

---

### [DA-AI05-02] — Demo Crawled Social Media Data on Google Sheets

**Jira status:** Done  
**Phạm vi:** demo dữ liệu mạng xã hội đã crawl bằng Google Sheets để team xem và đối chiếu output.

**Kết quả và minh chứng:** ảnh Jira xác nhận task Done; chưa có URL Google Sheets hoặc ảnh dữ liệu demo kèm theo report.

**Ghi chú bàn giao:** bổ sung link Sheet có quyền xem, nguồn crawl và thời điểm lấy dữ liệu. Không ghi số lượng bản ghi hoặc kết quả demo khi chưa có dữ liệu đối chiếu.

---

### [DA-AI05-03] — Complete End-to-End Social Media Crawl Workflow

**Jira status:** Done  
**Phạm vi:** triển khai workflow bằng custom code, kết nối thu thập dữ liệu với tầng message queue và lưu trữ.

**File liên quan:**

- `app/api/v1/endpoints/facebook_crawl.py`
- `app/services/trend_pipeline.py`
- `app/services/trend_envelope.py`
- `app/services/trend_scheduler.py`, `app/services/trend_runtime.py`
- `app/services/trend_cold_storage.py`

**Công việc thể hiện trong mã nguồn:**

- Tổ chức luồng xử lý theo batch: nhận raw posts → phân loại trùng lặp bằng Redis → tạo envelope → publish queue → backup snapshot lên S3.
- Publish toàn bộ batch, gồm bản ghi trùng, để consumer nhận đủ các lần crawl; số lượng trùng được thống kê riêng.
- Có scheduler/runtime và các endpoint Facebook crawl để kích hoạt, theo dõi run, lấy kết quả.
- Khi backup S3 thất bại, ghi cảnh báo và tiếp tục; dữ liệu đã publish không bị coi là chưa xử lý chỉ vì lỗi backup.

**Kết quả đạt được:** các bước chính của workflow đã có trong mã nguồn. Cần lưu log một lần chạy end-to-end cùng dữ liệu đầu vào/đầu ra làm minh chứng nghiệm thu.

---

### [DA-AI05-04] — Host and Set Up ChromaDB or Neo4j Database Instance

**Jira status:** Done  
**Phạm vi:** chuẩn bị các dịch vụ dữ liệu phục vụ AI và trend pipeline.

**File liên quan:**

- `docker-compose.ai-dev.yml`
- `app/core/clients.py`
- `app/services/trend_cold_storage.py`

**Công việc thể hiện trong cấu hình:**

- Khai báo ChromaDB, Neo4j, Redis và RabbitMQ trong Docker Compose, có volume lưu dữ liệu và network dùng chung.
- Tách profile chạy dependencies với profile chạy cả AI service.
- Khởi tạo ChromaDB HTTP client theo cấu hình host/port.

**Kết quả đạt được:** có cấu hình dựng môi trường local phục vụ tích hợp. Riêng pipeline raw hiện backup lên S3; chưa có căn cứ từ phần code đã đối chiếu để khẳng định raw posts đã được ghi vào ChromaDB/Neo4j. Cần làm rõ khác biệt này trong nghiệm thu task.

---

### [DA-AI05-05] — Message Queue / Buffer Layer Integration

**Jira status:** Done  
**Phạm vi:** kết nối crawler với tầng xử lý tiếp theo qua message queue.

**File liên quan:**

- `app/services/trend_publisher.py`
- `app/services/trend_stream_publisher.py`
- `app/services/trend_dedup.py`
- `app/services/trend_pipeline.py`
- `app/core/clients.py`

**Công việc thể hiện trong mã nguồn:**

- Dùng RabbitMQ topic exchange `crawler.raw`, queue `crawler.posts`, binding `*.post` và routing key theo platform.
- Khai báo exchange/queue durable và gửi message persistent.
- Retry publish tối đa 3 lần với khoảng chờ 1 giây; báo lỗi khi hết lượt thử.
- Dùng Redis để phân loại bản ghi trùng; kết nối queue và Redis với pipeline xử lý batch.

**Kết quả đạt được:** có publisher và buffer phục vụ bàn giao dữ liệu cho consumer downstream.

**Thay đổi so với tên task:** triển khai thực tế dùng RabbitMQ cho message queue và Redis cho dedup, không phải Redis Queue/Kafka. Cần đồng bộ mô tả Jira với kiến trúc này.

---

## 4. Tasks chưa hoàn thành / chưa chuyển review

Theo ảnh Jira, cả 7 task đều Done; không có task đang In Progress hoặc In Review trong danh sách được cung cấp.

Các phần cần bổ sung để report đủ minh chứng:

- Kết quả benchmark RAG trên 3 tài liệu và 20 câu hỏi.
- Link Google Sheets demo dữ liệu crawl.
- Kết quả chạy pytest và log workflow end-to-end.
- Xác nhận phạm vi lưu raw data của DA-AI05-04; cập nhật Jira cho các thay đổi Claude → Gemini và queue → RabbitMQ.

---

## 5. Đóng góp ngoài tasks chính

- Bổ sung API sinh nội dung trên Swagger để kiểm tra provider thuận tiện hơn.
- Cho phép chọn Groq/Gemini theo request, tránh phải sửa `.env` và restart chỉ để chuyển provider.
- Bổ sung log chẩn đoán upstream và xác định lỗi model Groq bằng request thật.
- Dọn cấu hình Claude không còn sử dụng; bổ sung comment testcase để hỗ trợ review và bảo trì.

---

## 6. Học được gì trong sprint này

1. **Cấu hình model phải được kiểm chứng bằng API:** tên model trong file mẫu không bảo đảm còn khả dụng với tài khoản hiện tại.
2. **Fallback cần phân loại lỗi:** lỗi rate limit/kết nối khác với lỗi model hoặc xác thực; chuyển provider cho mọi lỗi có thể che giấu cấu hình sai.
3. **Lựa chọn provider phải độc lập theo request:** không thay đổi settings dùng chung khi xử lý request đồng thời.
4. **Message queue và dedup có vai trò khác nhau:** pipeline có thể thống kê trùng nhưng vẫn cần chuyển toàn bộ snapshot cho downstream.
5. **Trạng thái Done cần đi cùng minh chứng:** benchmark, link demo và log chạy lại giúp team xác nhận kết quả thay vì chỉ dựa vào trạng thái Jira.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

- Đồng bộ acceptance criteria khi thay provider hoặc hạ tầng so với thiết kế ban đầu.
- Đính kèm kết quả test và demo khi chuyển task sang Done để người nhận bàn giao có thể kiểm tra lại.

### 7.2 Về tài liệu

- Bổ sung hướng dẫn gọi API content, lựa chọn provider và xác thực Swagger.
- Ghi rõ raw data lưu ở đâu, dữ liệu nào đi vào ChromaDB/Neo4j và consumer nào chịu trách nhiệm xử lý.
- Đồng bộ model mặc định giữa `.env.example`, settings và Docker Compose sau khi kiểm chứng model khả dụng.

### 7.3 Đề xuất cho sprint tiếp theo

- Hoàn thiện bộ minh chứng RAG và theo dõi precision/faithfulness khi thay model hoặc tài liệu.
- Chạy lại bộ test DA-AI04-03 và smoke test cả Groq/Gemini trên môi trường tích hợp.
- Xác nhận luồng crawler → queue → consumer → storage bằng một phiên chạy có dữ liệu đối chiếu.
- Theo dõi quota API, lỗi upstream và queue backlog để phát hiện sớm gián đoạn.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | Chưa tự chấm | 7 task Done theo ảnh Jira; chưa có thời điểm hoàn thành để đối chiếu deadline |
| Chất lượng deliverable | Chưa tự chấm | Có mã nguồn và test; cần bổ sung kết quả kiểm thử, benchmark và demo |
| Giao tiếp với team | Chưa tự chấm | Cần xác nhận bàn giao và cập nhật các thay đổi phạm vi trên Jira |
| Chủ động xử lý blocker | Chưa tự chấm | Đã xử lý cấu hình model không khả dụng, bổ sung log và tùy chọn provider |
| **Tổng** | **Chưa tự chấm /20** | Thành viên xác nhận điểm trước khi nộp |

---

*Deadline nộp theo mẫu Sprint 6: 2026-08-11 | Ngày nộp thực tế: chưa cập nhật.*
