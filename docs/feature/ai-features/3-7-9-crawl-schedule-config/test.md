# Test Specification — FR 3.7.13: Crawl Schedule Config

> Note: This specification maps to official **FR 3.7.13 — Crawl Schedule Config** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-7-13-crawl-schedule-config/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.13` |
| **Function Name** | Crawl Schedule Config |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Admin, Owner` |
| **Target Class & Method** | `AdminCrawlConfigService.update()` (32 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminCrawlConfigServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Update cron schedule, target sources, industry keywords, and batch limits for the background AI Trend Crawler |
| **Preconditions** | Can connect with server; Caller is Admin or Owner |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is ADMIN | `method` = `GET` | 200 - {schedule, sourcePages, postsPerRun} | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is ADMIN | `schedule` = `0 */6 * * *` | 200 - updated config with new cron | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is ADMIN | `schedule` = `interval 30m` | 200 - updated config with interval | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is ADMIN | `sourcePages` = `2 pages` | 200 - updated sourcePages | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is ADMIN | `postsPerRun` = `50` | 200 - updated postsPerRun | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is ADMIN | `schedule` = `0 0 * * *`, `sourcePages` = `1 page`, `postsPerRun` = `20` | 200 - all fields updated | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is ADMIN | `schedule` = `null`, `sourcePages` = `null`, `postsPerRun` = `null` | 200 - config unchanged (partial patch) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is ADMIN; Crawler is running | `postsPerRun` = `30` | 200 - applied from next run, running job not stopped | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is ADMIN | `postsPerRun` = `1` | 200 - min postsPerRun accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is ADMIN | `postsPerRun` = `max allowed` | 200 - max postsPerRun accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is ADMIN | `sourcePages` = `1 page` | 200 - single source page | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is ADMIN | `schedule` = `invalid cron` | 400 INVALID_SCHEDULE | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is ADMIN | `schedule` = `empty` | 400 INVALID_SCHEDULE | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is ADMIN | `postsPerRun` = `0` | 400 Validation error (postsPerRun must be >= 1) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is ADMIN | `postsPerRun` = `-5` | 400 Validation error (postsPerRun negative) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is ADMIN | `sourcePages` = `empty list` | 400 Validation error (sourcePages empty) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is not ADMIN | `schedule` = `0 */6 * * *` | 403 FORBIDDEN | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is not ADMIN | `method` = `GET` | 403 FORBIDDEN | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.13`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — 3.7.9 Crawl Schedule Config

- [x] ADMIN xem cấu hình + trạng thái crawler; USER gọi API → 403.
- [x] Cron sai (61 phút, thiếu trường) → 400 `INVALID_SCHEDULE`, không gọi AI service, không audit.
- [x] Interval < 15 hoặc > 10080 → `INVALID_SCHEDULE`.
- [x] Chọn cron xoá interval và ngược lại; trường không gửi giữ giá trị cũ.
- [x] Page phải https, bỏ trùng/khoảng trắng, tối đa 50; số bài 10–1000.
- [x] Lưu → tick kế tiếp dùng page/số bài mới; đổi lịch dời lần chạy kế tiếp, không dừng job đang chạy.
- [x] Mỗi lần lưu ghi audit `UPDATE AI_CRAWL_CONFIG` (before/after).
- [x] Đổi VI/EN, light/dark không vỡ UI.

## Kết quả (2026-10-05)

- AI service: `test_crawl_config.py` 4/4 + `test_scheduler.py` 10/10.
- Business: `AdminCrawlConfigServiceTest` 4/4.
- Playwright `tests/e2e/admin/crawl-config.spec.ts` 2/2.
- Smoke live (dev): GET 200, USER 403, cron sai 400 `INVALID_SCHEDULE`, PATCH cron + page + 150 bài → 200, trang trend nhận `crawl` mới, audit 2 dòng; đã khôi phục cấu hình cũ.
- Giới hạn: crawler local đang tắt (`TREND_CRAWLER_ENABLED=false`, chưa có API key scraper) nên chưa chạy tick thật; tick được kiểm bằng unit test.

## Bổ sung 2026-10-05 — nhật ký crawl

- [x] Chia đều `postsPerRun` cho các page, dừng khi hết cursor; page lỗi/private ghi lỗi, page khác vẫn chạy (`test_crawl_config.py`, không gọi mạng thật).
- [x] Chỉ một lần crawl tại một thời điểm; nhật ký giữ kết quả (fakeredis).
- [x] Business `AdminCrawlConfigServiceTest` 5/5 (chạy ngay, audit, 409 khi đang chạy, map nhật ký).
- [x] E2E: nhật ký hiển thị trang/bài/lỗi/credit, nút dev bắt đầu crawl; Creator thấy menu "Xu hướng" trong workspace.
- [x] Smoke thật (key ScrapeCreators của người dùng): 2 page trong `crawler-social/data/current_batch.json` → `vietnamoi.vn` 2 bài, `diadiemanuong.vn` bị ScrapeCreators báo "Profile is private"; nhấn lần 2 khi đang chạy → `CRAWL_ALREADY_RUNNING`. Tốn khoảng 3 credit.
- Giới hạn: nguồn có sẵn `tiktok-trending` trả 0 bài (parser cũ không khớp định dạng ScrapeCreators) — chưa sửa vì không thuộc phạm vi và mỗi lần thử tốn credit.

## Bổ sung 2026-10-05 — card tiến độ

- [x] Card bên phải form: tổng bài đã cào + số bài từng page, cập nhật mỗi 3 giây khi đang crawl (page chưa tới lượt có vòng quay), hết crawl thì hiện lần gần nhất.
- [x] AI service ghi tiến độ sau mỗi page (`update_run`, chỉ ghi khi run còn chạy).
- [x] Trạng thái crawler liệt kê nguồn `facebook-pages` khi có key ScrapeCreators.
