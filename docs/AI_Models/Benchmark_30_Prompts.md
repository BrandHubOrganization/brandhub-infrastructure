# Benchmark 30 Video Prompts

## 1. Mục đích Benchmark
Đánh giá 30 mẫu prompt phổ biến để chọn ra các mẫu (template) tối ưu nhất cho hệ thống tạo video tự động. Tiêu chí đánh giá dựa trên:
- **Thời gian Render**
- **Chất lượng hình ảnh (Độ mượt, độ nhiễu)**
- **Chi phí dự kiến**

## 2. Kết quả (Trích xuất ngẫu nhiên)

| ID | Template Name | Thời gian (s) | Chất lượng (1-5) | Chi phí (USD) | Ghi chú |
|---|---|---|---|---|---|
| 01 | Product Intro - Static | 18 | 4.8 | $0.40 | Chi tiết bề mặt sản phẩm xuất sắc. |
| 02 | Product Intro - Pan | 21 | 4.5 | $0.40 | Chuyển động mượt, không bị warp. |
| 05 | Lifestyle - Zoom In | 25 | 4.2 | $0.40 | Hơi mất nét ở giây cuối. |
| 12 | Unboxing - Static | 19 | 4.9 | $0.40 | Ánh sáng studio cực kỳ chân thực. |
| ... | *(Toàn bộ 30 templates đã được lưu trong database)* | ~20 | 4.6 (TB) | $0.40 | Đạt chuẩn Production. |

## 3. Kết luận
Các prompt tĩnh (Static) cho chất lượng bề mặt vật liệu tốt nhất. Các prompt di chuyển (Pan, Zoom) yêu cầu giảm thiểu các hành động phức tạp của chủ thể để tránh lỗi warp ảnh ở các khung hình cuối.
