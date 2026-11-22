# Admin Plan Editor — test

| # | AC | Kịch bản | Mong đợi | PASS |
|---|---|---|---|---|
| 1 | AC1 | Admin mở `/admin?view=plans` | 6 gói, 2 dòng, đúng số liệu DB || PASS (E2E) |
| 2 | AC2 | Tăng credit PLUS 5000→6000, lý do | Bản mới v+1, bản cũ `is_sellable=false`, log NEW_VERSION || PASS (E2E Studio Plus v2) |
| 3 | AC2 | Lưu không đổi gì | `PLAN_UNCHANGED` || PASS (unit) |
| 4 | AC3 | Giá BASIC ≠ 0 / thiếu giá 12 tháng gói trả phí | `VALIDATION_ERROR` || PASS (unit) |
| 5 | AC4 | Gửi `expectedVersion` cũ | `PLAN_VERSION_CONFLICT` || PASS (unit) |
| 6 | AC5 | Tắt bán STUDIO_PRO | Trang chọn gói không cho thanh toán; log DISABLE_SALE || Dialog OK, chưa bấm xác nhận |
| 7 | AC5 | Tắt bán BASIC | `PLAN_SALE_LOCKED` || PASS (unit) |
| 8 | AC6 | Mở lịch sử PLUS | Phiên bản mới→cũ + người sửa, lý do || PASS (E2E) |
| 9 | AC7 | Agency đang ở PLUS bản cũ | Hạn mức/credit vẫn theo bản cũ || PASS (SQL local) |
| 10 | AC8 | Guest mở landing | Giá/hạn mức khớp DB; đổi gói → landing đổi || PASS (E2E, gọi thẳng Business) |
| 11 | — | Không phải Admin gọi API admin | 403 || chưa test |
| 12 | AC9 | Đổi vi/en | Không vỡ UI, không lộ key || chưa test |
| 13 | AC10 | Đổi light/dark | Đủ tương phản || PASS (E2E dark) |
