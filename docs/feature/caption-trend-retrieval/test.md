# Kế hoạch kiểm chứng

Trạng thái: chưa chạy test triển khai; hiện mới có tài liệu kế hoạch.

## Dữ liệu và retrieval

1. TrendId hợp lệ nối đúng Neo4j và Chroma; tên giống nhau nhưng khác ngày/category không lẫn. Post ID có prefix và không prefix được normalize đúng.
2. Loại run running/failed/interrupted/test và private/replay namespace; batch failed không thành evidence dù còn vector. Run partial đã publish chỉ lấy phần thành công và có nhãn partial.
3. Bản ghi v2 thiếu run/time/source không được tự gắn vào publication mới. Upsert run sau không làm snapshot cũ âm thầm thay nội dung; cache invalidates khi revision đổi.
4. Window 7 ngày theo thời điểm gen; kiểm tra ranh giới UTC/Vietnam, publishedAt thiếu/crawledAt fallback được đánh dấu. Moment/format vẫn dùng expiry policy hiện hữu.
5. Chroma empty/missing collection/model dimension mismatch/query timeout, Neo4j timeout và publication lookup unavailable: trạng thái rõ, không tạo collection rỗng, không lấy trend khác.
6. Query đúng metadata filter, giới hạn graph và top-k, không duplicate cùng post. Embedding dùng cùng model/prefix/dimension với index.

## Caption và quyền truy cập

7. Ba variant đúng schema/platform/language, giữ brand voice, task và moderation. Không gắn giá/khuyến mãi từ post người khác vào sản phẩm brand.
8. Nguồn chứa “ignore instructions”, token giả hoặc yêu cầu tiết lộ context không điều khiển system prompt. Caption không sao chép nguyên văn dài từ nguồn.
9. Workspace A không đọc brand KB/snapshot generation của B; frontend không thay client_id hoặc gửi raw Cypher/filter.
10. Response hiển thị source references hợp lệ ngoài caption, phân biệt retrieved context với bằng chứng cho từng claim. Không log cookie, key, full prompt hoặc toàn văn bài nguồn.
11. Refine/adapt/idempotent retry giữ đúng context snapshot và không double-charge. Caller cũ gen thường không cần trend context mới.

## UX và vận hành

12. UI đủ loading/used/partial/insufficient/unavailable, nguồn có ngày/link, hành động chọn lại/gen thường. Kiểm tra vi/en, light/dark, mobile và keyboard.
13. Bộ đánh giá đề xuất 30–50 brief Việt/Anh, đa ngành/platform: đúng trend, trend không phù hợp, nguồn cũ, sensitive và không có dữ liệu. Review thủ công độ liên quan, grounding, brand fit, originality; không tự báo tỉ lệ chất lượng khi chưa đánh giá.
14. Đo retrieval p50/p95, số chunks/context tokens, cache hit, RAM và caption concurrency trên môi trường tương tự EC2; chạy cùng một crawler. Không hứa giới hạn AI 4.5 GiB đủ cho mọi concurrent load khi chưa đo.
15. CI AI/Business/Web, integration với DB thật và feature-flag rollback. Ngân sách retrieval khoảng 5 giây/context 2.000 tokens chỉ là điểm khởi đầu cần review theo phép đo.
