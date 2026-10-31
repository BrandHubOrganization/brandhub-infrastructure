# Test Specification — FR 3.7.1: View Trending Topics Suggestions

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.1` |
| **Function Name** | View Trending Topics Suggestions |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `trend_snapshot_cache.get_trends()` (42 LOC) |
| **Unit Test File** | `brandhub-ai-service/tests/unit/services/test_trend_snapshot_cache.py` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Retrieve ranked trending topics and keywords for a workspace using BM25 anomaly detection and Neo4j Personalized PageRank |
| **Preconditions** | Can connect with server; Caller is Owner, Manager, or Creator in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `all`, `limit` = `20` | 200 - up to 20 trends ordered by score desc | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Redis trend cache populated | `period` = `6h`, `category` = `all`, `limit` = `20` | 200 - live 6h trends | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Redis trend cache populated | `period` = `7d`, `category` = `all`, `limit` = `20` | 200 - weekly aggregate via get_weekly_top_trends | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `fashion`, `limit` = `10` | 200 - only category fashion trends | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `all`, `limit` = `10`, `date` = `2026-09-14` | 200 - trends for given date key | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Live 6h key empty, daily key populated | `period` = `6h`, `category` = `all`, `limit` = `20` | 200 - fallback to daily key when live key empty | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Redis trend cache populated | `period` = `unknown`, `category` = `all`, `limit` = `20` | 200 - treated as 24h daily key | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `all`, `limit` = `1` | 200 - exactly 1 trend | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `all`, `limit` = `100` | 200 - at most 100 trends | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Cache has 3 trends | `period` = `24h`, `category` = `all`, `limit` = `20` | 200 - fewer items than limit when cache has less | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `all`, `limit` = `20`, `date` = `null` | 200 - defaults to current UTC date | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Redis trend cache is empty | `period` = `24h`, `category` = `all`, `limit` = `20` | 200 - empty list, no error (empty state) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `nonexistent`, `limit` = `20` | 200 - empty list | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `all`, `limit` = `0` | 422 Validation error (limit < 1) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Redis trend cache populated | `period` = `24h`, `category` = `all`, `limit` = `101` | 422 Validation error (limit > 100) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Redis connection fails | `period` = `24h`, `category` = `all`, `limit` = `20` | 200 - empty list, no exception raised | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — 3.7.1 View Trending Topics

- [x] Danh sách trend hiển thị keyword, điểm, độ lan tỏa, trạng thái, lĩnh vực, rủi ro thương hiệu, dư luận, siêu trend.
- [x] Đổi khoảng 6h/24h/7d gọi lại API với `period` tương ứng.
- [x] Lọc lĩnh vực trả đúng trend của lĩnh vực; danh sách lĩnh vực không mất khi đang lọc.
- [x] Cache rỗng → empty state, không hiện lỗi.
- [x] `period`/`limit` sai → 400 trước khi gọi AI service.
- [x] Hiển thị nguồn crawl + lịch (FR 3.7.9); AI service không trả được cấu hình → trend vẫn hiện.
- [x] Đổi VI/EN không vỡ UI; light/dark không vỡ màu; 390px không tràn ngang.

## Kết quả (2026-10-05)

- `AiTrendControllerTest` 3/3; Playwright `tests/e2e/ai/trends.spec.ts` 2/2.
- Smoke live: user dev gọi `/api/v1/ai/trending-topics` → 200, `items: []` (Redis chưa có trend vì crawler local tắt), `crawl` đúng cấu hình.

## Bổ sung 2026-10-05 — dữ liệu thật, lĩnh vực theo topic, biểu đồ

- [x] Lĩnh vực = nhãn topic T2 (12 nhãn PhoBERT), hiển thị tên VI/EN (`aiStudio.trends.topicName.*`).
- [x] "Tất cả lĩnh vực" hiện biểu đồ cột ngang "Lĩnh vực đang nổi" (tổng điểm trend theo topic, tooltip số trend/đang lên, bảng ẩn cho trình đọc màn hình); bấm cột để lọc; chọn 1 lĩnh vực thì ẩn biểu đồ.
- [x] Business trả `topicStats` (`AiTrendControllerTest`).
- [x] Creator trong workspace thấy menu "Xu hướng".
- [x] Dữ liệu thật: `brandhub-ai-service/scripts/dev_seed_trends_from_local.py ../crawler-social/output 3000` chạy T0→T7 trên 3.000 bài crawl thật → 28 trend, 5 lĩnh vực (Thể thao 13, Thời sự 7, Công nghệ 4, Giải trí 3, Tài chính 1); kiểm tra bằng ảnh chụp đăng nhập Creator thật.

## Bổ sung 2026-10-05 — popup bài viết khi hover

- [x] T7 trả `post_items` (port từ bản demo `trend-pipeline`): tối đa 10 bài/trend, nhiều like trước, nội dung cắt 300 ký tự.
- [x] Hover (hoặc focus bàn phím) vào thẻ trend → popup danh sách bài: tác giả, giờ đăng, nội dung, like/bình luận/chia sẻ, link "Mở bài".
- [x] Business lọc trend trùng từ khóa (cache ngày giữ mỗi lần crawl một bản) — `AiTrendControllerTest`.
- [x] Sửa adapter Facebook: `timestamp` dạng chuỗi ISO của crawler-social trước đây bị đọc thành "bây giờ" → mọi bài coi là đăng hôm nay, T4 gắn mọi trend "Mới". Sau sửa: 14 trend với trạng thái đang lên/đang giảm theo ngày đăng thật (`test_facebook_adapter_dates.py`).
- [x] E2E hover popup; ảnh chụp đăng nhập Creator thật.

## Bổ sung 2026-10-05 — chi tiết trend khi bấm thẻ (giống bản demo trend-pipeline)

- [x] Bấm thẻ (hoặc Enter/Space) mở hộp chi tiết: đường phát triển số bài theo ngày (T4 `momentum.days/counts`, tooltip có thay đổi so với hôm trước, bảng ẩn cho trình đọc màn hình), cảm xúc tác giả (`emotion_dist`), độ lan tỏa/dư luận/rủi ro, hashtag, 10 bài.
- [x] Nút "Sao chép từ khóa" không mở hộp chi tiết.
- [x] Business trả `growth` + `emotionDist` (`AiTrendControllerTest`); e2e bấm thẻ; ảnh chụp dữ liệu thật ("đinh hồng vinh" 12/9→18/9).
