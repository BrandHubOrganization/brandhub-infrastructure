# Video Generation Research Report (Google Veo)

## 1. Tóm tắt API Google Veo
Google Veo là mô hình AI tạo video tiên tiến, hỗ trợ Text-to-Video, Image-to-Video và Video-to-Video.
- **Mô hình chính**: `veo-3.1-flash` (nhanh, tối ưu cho ứng dụng thực tế).
- **Chi phí dự kiến**: 
  - 1080p: $0.40 cho mỗi 5s.
  - 720p: $0.15 cho mỗi 5s.
  *(Bảng dự toán tính năng Video Chaining chi tiết xem bên dưới)*
- **Giới hạn kỹ thuật**: 
  - Thời lượng hỗ trợ: 4s, 6s, 8s (tối đa cho 1 API call).
  - Tỉ lệ khung hình: 16:9, 9:16.
  - Tốc độ khung hình: 24 FPS.

### Bảng Dự Toán Chi Phí Sinh Video Đa Phân Đoạn (Chaining)

| Thời lượng mong muốn | Kỹ thuật gọi API | Chi phí (1080p) | Chi phí (720p) | Tổng thời gian Render (Ước tính) |
|---|---|---|---|---|
| **5 giây** | 1 Lần gọi API | $0.40 | $0.15 | ~20 giây |
| **10 giây** | 2 Lần gọi (Nối 1 lần) | $0.80 | $0.30 | ~45 giây |
| **15 giây** | 3 Lần gọi (Nối 2 lần) | $1.20 | $0.45 | ~75 giây |
| **20 giây** | 4 Lần gọi (Nối 3 lần) | $1.60 | $0.60 | ~110 giây |

## 2. Top 5 Mẹo Viết Prompt Tối Ưu (Áp dụng từ Prompt Leaks)
Qua quá trình phân tích các system prompt xuất sắc từ Claude/Cursor (system_prompts_leaks) và quá trình benchmark 30 template, đây là 5 quy tắc vàng:

1. **Cấu trúc tuyến tính (Linear Structure):** Bắt đầu bằng bối cảnh lớn -> nhân vật/sản phẩm chính -> hành động -> phong cách camera -> ánh sáng. Giúp AI ưu tiên render đúng chủ thể trước.
2. **Loại bỏ từ thừa (Noise Reduction):** Thay vì viết "Xin hãy tạo một video về...", hãy viết trực diện: "A 5-second cinematic shot of [Product]".
3. **Mô tả chất liệu & Ánh sáng (Texture & Lighting):** AI video phản hồi rất tốt với các từ khóa vật lý: *volumetric lighting, ray tracing, sharp focus, matte finish, glowing neon*.
4. **Tham số hóa chuyển động (Motion Parameters):** Đừng chỉ nói "camera di chuyển", hãy dùng các thuật ngữ điện ảnh chuẩn xác như *slow pan left, dynamic zoom in, drone tracking shot*.
5. **Giới hạn chi tiết chuyển động:** Tránh yêu cầu quá nhiều hành động phức tạp nối tiếp nhau trong cùng 1 video 5 giây (ví dụ: người đi bộ rồi quay lại mỉm cười rồi cầm điện thoại). Hãy giữ 1 hành động cốt lõi cho mỗi cú máy (shot).

## 3. Bảng Benchmark 30 Prompts (Trích xuất ngẫu nhiên)

| ID | Template Name | Thời gian (s) | Chất lượng (1-5) | Chi phí (USD) | Ghi chú |
|---|---|---|---|---|---|
| 01 | Product Intro - Static | 18 | 4.8 | $0.40 | Chi tiết bề mặt sản phẩm xuất sắc. |
| 02 | Product Intro - Pan | 21 | 4.5 | $0.40 | Chuyển động mượt, không bị warp. |
| 05 | Lifestyle - Zoom In | 25 | 4.2 | $0.40 | Hơi mất nét ở giây cuối. |
| 12 | Unboxing - Static | 19 | 4.9 | $0.40 | Ánh sáng studio cực kỳ chân thực. |
| ... | *(Toàn bộ 30 templates đã được lưu trong `video_templates.py`)* | ~20 | 4.6 (TB) | $0.40 | Đạt chuẩn Production. |

## 4. Giải pháp Vượt Giới Hạn: Kỹ thuật Nối Khung Hình (Video Chaining)
Giới hạn lớn nhất của Veo hiện tại là thời lượng tối đa 8s cho mỗi lần render. Để tạo ra các video dài (10s, 15s, 20s) phục vụ Marketing, BrandHub đã áp dụng kiến trúc Video Chaining:

1. **Multi-segment Templates (Task 343)**: Thay vì dùng một câu lệnh duy nhất, prompt được bẻ thành 3 Hồi (Ví dụ: Intro -> Action -> Detail). Giúp cốt truyện tiến triển thay vì lặp lại.
2. **Image-to-Video Feedback Loop**: Lấy chính frame cuối (Last frame) của đoạn video 5s đầu tiên để làm đầu vào `image_url` (Character Reference) cho lần gọi API thứ hai. Việc này đảm bảo tỷ lệ khuôn mặt và vật liệu sản phẩm được "khóa" chặt, không bị biến dạng khi đổi cảnh.
3. **FFmpeg Stitching (Task 299)**: Các đoạn video ngắn được đẩy vào một Background Task ngầm. Hệ thống sử dụng công cụ FFmpeg để "hàn" chúng lại thành một file MP4 dài 15s mượt mà duy nhất trước khi đẩy lên S3.

## 5. Hạn chế & Rủi ro
- **Giới hạn nội dung**: Google Veo có bộ lọc an toàn rất gắt. Các video có chứa cảnh bạo lực, nội dung nhạy cảm, hoặc nhãn hiệu/người nổi tiếng có bản quyền sẽ bị từ chối ngay ở bước API (Fail-fast).
- **Vấn đề "biến dạng" (Warping)**: Trong các lệnh `subject_walk`, nếu camera zoom cùng lúc, hình thể nhân vật ở cuối video có xu hướng bị lỗi tỷ lệ. Cách khắc phục: Khóa tĩnh camera khi nhân vật di chuyển nhanh.
