# Studio Plans — Test

| # | AC | Kịch bản | Input | Mong đợi | Kết quả |
|---|---|---|---|---|---|
| 1 | AC1 | Tạo công ty Personal qua chooser | user mới, bấm "Cá nhân" | subscription = STUDIO_FREE, ví credit tồn tại | PASS — STUDIO_FREE ACTIVE, ví 100 credit (API, form tạo công ty companyType=PERSONAL) |
| 2 | AC1 | Tạo công ty Agency | form `?type=AGENCY` | subscription = BASIC | PASS — BASIC ACTIVE |
| 3 | AC2 | Migration | công ty Personal đang BASIC; công ty Personal đang PLUS | lần lượt STUDIO_FREE; PLUS giữ nguyên | PASS — DB thử: Personal (logo personal-studio) BASIC→STUDIO_FREE; Personal PLUS giữ PLUS; Agency BASIC giữ |
| 4 | AC2 | Migration chạy lần 2 | — | không thay đổi dòng nào | PASS — chạy 2 migration lần 2, hash agency_subscriptions/plan versions/cycle prices/agencies không đổi |
| 5 | AC3 | Catalog theo dòng | `GET /billing/plans?agencyId=<personal>` | đúng 3 gói STUDIO_*, productLine=STUDIO | PASS — STUDIO_FREE/PLUS/PRO, productLine STUDIO, newsletter 0 |
| 6 | AC3 | Catalog không agencyId | `GET /billing/plans` | BASIC/PLUS/ENTERPRISE như cũ | PASS — BASIC/PLUS/ENTERPRISE (Enterprise 500 GB); agencyId Agency trả giống hệt |
| 7 | AC4 | Mua khác dòng | công ty Agency đặt STUDIO_PLUS | BILLING_ORDER_CONFLICT | PASS — BILLING_ORDER_CONFLICT |
| 8 | AC4 | Mua khác dòng | công ty Personal đặt PLUS | BILLING_ORDER_CONFLICT | PASS — BILLING_ORDER_CONFLICT |
| 9 | AC5 | Free → Plus | STUDIO_FREE, UPGRADE STUDIO_PLUS 1 tháng | đơn 99.000đ; sau webhook: STUDIO_PLUS, 900 credit | PASS — đơn 99.000đ; webhook → STUDIO_PLUS, +900 credit. Lỗi tìm thấy & đã sửa: paidAt SePay đi trước đồng hồ server → kỳ thành FUTURE, gói chưa đổi tới lượt scheduler |
| 10 | AC5 | Free → Pro trực tiếp | UPGRADE STUDIO_PRO 12 tháng | đơn 2.869.000đ; credit cấp theo tháng | PASS — đơn 2.869.000đ, kỳ 365 ngày, chỉ cấp 2.400 tháng đầu |
| 11 | AC5 | Hạ cấp | STUDIO_PRO, UPGRADE STUDIO_PLUS | BILLING_ORDER_CONFLICT | PASS — BILLING_ORDER_CONFLICT |
| 12 | AC5 | Gia hạn | STUDIO_PLUS, RENEWAL STUDIO_PLUS 3 tháng | kỳ FUTURE bắt đầu khi kỳ hiện tại hết | PASS — kỳ FUTURE starts_at = current_period_end |
| 13 | AC6 | Proration quote | Plus 1 tháng trả 99.000đ, còn 15/30 ngày, lên Pro 1 tháng | credit 49.000, amount 250.000 | PASS — quote price 299.000 / credit 49.000 / amount 250.000 (kỳ Plus chỉnh về ngày 15/30 trong DB) |
| 14 | AC6 | Proration fulfill | thanh toán đơn #13 | kỳ Plus ENDED tại paidAt, kỳ Pro CURRENT từ paidAt, 2.400 credit cấp ngay | PASS — đơn 250.000đ; kỳ Plus ENDED đúng lúc kỳ Pro bắt đầu, Pro CURRENT, +2.400 credit ngay, credit Plus giữ |
| 15 | AC6 | Phần trừ ≥ giá | Plus 12 tháng mới mua, lên Pro 1 tháng | BILLING_ORDER_CONFLICT (chọn chu kỳ dài hơn) | PASS — order + quote BILLING_ORDER_CONFLICT "choose a longer billing cycle" |
| 16 | AC6 | Có kỳ FUTURE | Plus đã gia hạn trước, lên Pro | BILLING_ORDER_CONFLICT | PASS — quote + order BILLING_ORDER_CONFLICT |
| 17 | AC6 | Idempotency | gửi lại cùng Idempotency-Key | trả lại cùng đơn | PASS — cùng key trả cùng orderId; payload khác → BILLING_ORDER_CONFLICT |
| 18 | AC7 | Hết hạn | STUDIO_PLUS hết kỳ, lifecycle advance | STUDIO_FREE, thông báo "Gói Studio đã hết hạn" | PASS — scheduler chuyển STUDIO_FREE EXPIRED, thông báo "Gói Studio đã hết hạn" |
| 19 | AC8 | Giới hạn không gian | STUDIO_FREE có 1 không gian, tạo thêm | PLAN_LIMIT | PASS — WORKSPACE_LIMIT_REACHED |
| 20 | AC8 | Khôi phục vượt giới hạn | Free, 1 active + 1 trong thùng rác, khôi phục | PLAN_LIMIT | PASS — xoá ws1, tạo ws2, khôi phục ws1 → WORKSPACE_LIMIT_REACHED |
| 21 | AC8 | Lách qua chế độ Personal | công ty Agency BASIC đủ slot, tạo ws PERSONAL rồi chuyển AGENCY | PLAN_LIMIT | PASS — Agency BASIC đã có 1 ws: tạo ws chế độ PERSONAL bị chặn ngay (WORKSPACE_LIMIT_REACHED), nên không còn đường chuyển sang AGENCY |
| 22 | AC9 | Thành viên Plus | STUDIO_PLUS mời Creator | PLAN_LIMIT | PASS — EXCEEDS_PLAN_LIMIT |
| 23 | AC9 | Thành viên Pro | STUDIO_PRO mời Creator thứ 1, 2, 3 | 2 lần đầu OK, lần 3 PLAN_LIMIT | PASS — lời mời 1, 2 OK; lời mời 3 EXCEEDS_PLAN_LIMIT |
| 24 | AC10 | planCode danh sách công ty | `GET /agencies` | công ty Personal hiện STUDIO_FREE / STUDIO_PLUS | PASS — STUDIO_PRO / STUDIO_FREE / BASIC đúng từng công ty |
| 25 | AC11 | Admin revenue | trang doanh thu admin | có nhóm STUDIO_* sau Agency | PASS — API /admin/revenue: nhóm STUDIO_FREE, STUDIO_PLUS, STUDIO_PRO sau BASIC/PLUS/ENTERPRISE (trang admin web chưa mở bằng trình duyệt) |
| 26 | UI | Trang Gói Personal | mở `/subscription/plans` ở công ty Personal | 3 thẻ Studio, không có ma trận Agency | PASS — 3 thẻ Studio, không ma trận Agency, badge Gói hiện tại, toggle 1/3/6/12. Đã sửa: dung lượng hiện 2,14/5,36/32,21 GB → 2/5/30 GB; en "1 personal spaces" → số ít |
| 27 | UI | Thẻ Pro khi đang Plus | — | hiện "Trả chênh lệch ~Xđ" khớp quote | PASS — "Trả chênh lệch ~250.000 ₫" = quote; 3 tháng ~800.000, 12 tháng ~2.820.000 |
| 28 | i18n | Đổi ngôn ngữ vi ↔ en | trang Gói + checkout | không còn key thô, không vỡ layout | PASS — vi/en trang Gói + hộp thanh toán không còn key thô. Đã sửa en "Plus activates after…" → "Your plan activates…" |
| 29 | Theme | Light ↔ Dark | trang Gói + checkout | chữ/nền đủ tương phản, không màu cứng lạc theme | PASS — xem ảnh light/dark trang Gói + hộp thanh toán, chữ đủ tương phản |
| 31 | AC12 | Enterprise 500 GB | catalog + entitlement Enterprise | storage 500 GB; thuê bao cũ giữ 1 TB tới hết kỳ | PASS — catalog ENTERPRISE 500 GB; quota thực tế: thuê bao ENTERPRISE v2 = 1 TB, v3 = 500 GB |
| 32 | AC13a | Tạo không gian trong công ty Personal | mở `/workspaces/create?agencyId=<personal>` | không có chọn chế độ / mời khách hàng; tạo xong vào dashboard, mode PERSONAL | PASS — không chọn chế độ / mời khách hàng, vào /workspaces/{id}/dashboard, settings.workspaceMode=PERSONAL. Đã sửa: ẩn gợi ý "chuyển sang chế độ Agency trong Cài đặt" ở công ty Personal |
| 33 | AC13b | Tạo task ở trang Công việc Personal | QuickCreate không chọn chiến dịch | task không có campaignId; không có banner nghiệm thu | PASS — QuickCreate có ô chiến dịch tuỳ chọn; task Mongo không có campaignId; không banner chiến dịch |
| 34 | AC13c | Cài đặt không gian Personal | mở trang cài đặt | không có khối chuyển Personal/Agency | PASS — không có khối chuyển chế độ; tour trang bỏ qua bước workspaceDetail.mode (5 bước chạy hết) |
| 30 | Build | `mvn clean test`, `npx tsc --noEmit` | — | xanh | PASS — mvn clean test 2125 run / 0 fail (136 skip opt-in); StudioBillingPostgresTest 16/16; tsc --noEmit sạch |
