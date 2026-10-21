# FR 3.9.4 — Lịch sử thanh toán
Owner hiện tại xem lịch sử theo agency; owner cũ/non-owner không truy cập được. Lịch sử lấy từ billing_orders, không lấy toàn bộ tài khoản ngân hàng. Cursor created_at+id, limit 20 (max 100); lọc status/kind/from/to ISO offset, sort DESC ổn định. Detail có payer UUID lưu trên order, snapshot gói, amount dạng chuỗi, kỳ, payment records, fulfillment và review reason. Không tự bịa payer name snapshot hoặc VAT invoice.
Receipt plain-text UTF-8 chỉ tải khi FULFILLED + có payment VERIFIED khớp amount; ghi rõ không phải hóa đơn thuế. Pending/review không có receipt. IDOR order khác agency hoặc non-owner trả 404.
SePay API v2 là tra cứu theo yêu cầu trong detail: bearer token server-only, tìm transaction_content=provider_order_code; xác minh lại mã nguyên vẹn, tiền vào, account_number khớp và timestamp sau tạo đơn. Trả metadata tối thiểu, không số dư/người chuyển/full payload. Numeric webhook id không coi là UUID v2. Không mutate/cấp gói khi GET; không gọi SePay trong DB transaction. Thiếu token/API lỗi không làm hỏng lịch sử nội bộ. Phân trang provider minh bạch, không khẳng định không có giao dịch nếu response chưa hoàn chỉnh.
UI thay mock invoices bằng API, empty/error/retry, filter, cursor next/back, detail inline, receipt download; VI/EN, theme tokens, mobile scroll. Trang plans có link lịch sử.
Nguồn: https://developer.sepay.vn/vi/sepay-api/v2/gioi-thieu ; /giao-dich/danh-sach ; /giao-dich/chi-tiet ; /xac-thuc. Đây là history/read-only, không triển khai reconciliation mutation/refund hay thay webhook.

## Sidebar navigation correction
Owner navigation correction: agency-level sidebar must expose Plans and Payment history when an agency is selected. Billing routes keep owner-only access; hide entries inside workspaces and for non-owners. Existing i18n labels reused.

## Right-side detail drawer
Order Details opens a right-side sliding panel, 1/3 viewport width at >=1024px and full width on mobile/tablet. Full height, internal scroll; table remains usable. Close button/Escape restores focus. Preserve local/provider/receipt behavior and admin/owner authorization.
