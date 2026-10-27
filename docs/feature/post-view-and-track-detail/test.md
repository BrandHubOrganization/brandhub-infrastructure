# Kịch bản Kiểm chứng (Test Cases): Dashboard Post View & Track Detail (DA-E52-07)

## Bảng Kịch bản Kiểm thử

| Mã Test Case | Tên Kịch Bản | Dữ liệu Đầu vào (Input) | Kết quả Kỳ vọng (Expected Output) |
|---|---|---|---|
| **TC-POST-01** | Lấy chi tiết bài viết đã xuất bản | `workspaceId`, `postId` (bài có status `PUBLISHED`) | HTTP 200, response chứa: `platformPostUrl` hợp lệ, `reactionCount`, `commentCount`, `shareCount`, `engagementUpdatedAt`. |
| **TC-POST-02** | Bài viết không tồn tại | `workspaceId`, `postId` không có trong DB | HTTP 404 với error code `POST_NOT_FOUND`. |
| **TC-POST-03** | Bài viết chưa xuất bản yêu cầu track detail | `workspaceId`, `postId` có status `DRAFT` hoặc `PENDING_REVIEW` | HTTP 404 với error code `POST_NOT_FOUND`. |
| **TC-POST-04** | Bộ đệm tương tác (Cache Rate-limit) | Gọi liên tiếp 2 lần trong vòng 10 phút không kèm `refresh=true` | Lần 2 trả về ngay số liệu cache, không gọi lại nền tảng, `engagementUpdatedAt` giữ nguyên. |
| **TC-POST-05** | Dashboard Post Summary | `workspaceId`, `filters` (platform, status) | HTTP 200, trả về `kpis` (totalPosts, scheduledCount, successRate), `platformBreakdown`, và danh sách `recentPosts`. |
| **TC-POST-06** | Danh sách Comment của bài viết | `workspaceId`, `postId` đã xuất bản | HTTP 200, trả về mảng danh sách comment gồm `authorName`, `content`, `commentedAt`. |
| **TC-POST-07** | Lịch đăng bài theo tháng | `workspaceId`, `month=2026-10` | HTTP 200, trả về mảng các bài viết có `scheduledAt` nằm trong tháng yêu cầu. |
