# Kế hoạch Kỹ thuật: Dashboard Post View & Track Detail (DA-E52-07)

## 1. Kiến trúc Tổng thể & Phân rã
Tính năng bao gồm:
- **Backend (`brandhub-business-service`):**
  - Mở rộng model MongoDB `PostDocument` với các trường lưu trữ chỉ số tương tác (`reaction_count`, `comment_count`, `share_count`, `platform_post_url`, `engagement_updated_at`).
  - Nâng cấp `PostResponse` Java Record chứa đầy đủ metrics.
  - Xây dựng các DTO: `PostDashboardResponse`, `PostCommentResponse`, `PostScheduleResponse`.
  - Cập nhật `PostService` & `PostServiceImpl` hiện thực hóa logic:
    - Kiểm tra `POST_NOT_FOUND` khi bài chưa được xuất bản.
    - Rate-limiting cache cho số liệu tương tác (TTL 10 phút).
    - Tính toán dashboard KPIs, platform breakdown và recent posts.
    - Lấy danh sách comments và lịch trình bài đăng theo múi giờ.
  - Cập nhật `PostController` tiếp nhận các endpoint RESTful chuẩn.
- **Frontend (`brandhub-web`):**
  - Đồng bộ `postDetailService.ts` và `postDashboardService.ts` kết nối tới các endpoint thật.
  - Đảm bảo giao diện hiển thị đúng cả Light/Dark mode và đa ngôn ngữ.

---

## 2. Các File Sẽ Chạm Tới & Tạo Mới

### 2.1. Backend (`brandhub-business-service`)
- `com.brandhub.business.document.PostDocument`: Bổ sung fields lưu trữ tương tác và cache timestamp.
- `com.brandhub.business.dto.response.PostResponse`: Mở rộng trường trả về.
- `com.brandhub.business.dto.response.PostDashboardResponse`: DTO kết quả dashboard.
- `com.brandhub.business.dto.response.PostCommentResponse`: DTO danh sách comment.
- `com.brandhub.business.dto.response.PostScheduleResponse`: DTO lịch bài đăng.
- `com.brandhub.business.service.PostService` & `PostServiceImpl`: Hiện thực nghiệp vụ caching và tổng hợp dữ liệu.
- `com.brandhub.business.controller.PostController`: Cung cấp các endpoint `dashboard`, `comments`, `schedule`, `detail`.

### 2.2. Frontend (`brandhub-web`)
- `src/pages/publish/services/postDetailService.ts`: Kết nối endpoint thực tế `/api/v1/workspaces/{workspaceId}/posts/{postId}/detail`.
- `src/pages/publish/services/postDashboardService.ts`: Kết nối endpoint thực tế `/api/v1/workspaces/{workspaceId}/posts/dashboard`.

---

## 3. Thứ tự Triển khai (Build Sequence)
1. Cập nhật `PostDocument` và các DTO Response (Java Records).
2. Viết logic nghiệp vụ trong `PostServiceImpl` (hàm tính toán KPI, cache metrics, xử lý 404 cho bài chưa publish).
3. Đăng ký các route endpoint trong `PostController`.
4. Viết Unit & Integration test kiểm chứng trong `PostServiceImplTest` và `PostControllerTest`.
5. Kiểm tra tích hợp với frontend `brandhub-web`.

---

## 4. Ràng buộc Kỹ thuật Meta Graph API & Fallback Policy
- **Chỉ hỗ trợ Page & Business Account:** Meta cấm đọc post/comment từ profile cá nhân; tất cả flow đều qua Page Access Token.
- **Quyền hạn cần thiết:** `pages_read_engagement`, `pages_read_user_content`, `instagram_basic`, `instagram_manage_comments`.
- **Cơ chế Cache TTL 10 phút:** Mọi thao tác lấy metrics được lưu và kiểm tra hạn cache qua `PostDocument.engagementUpdatedAt`, hạn chế tối đa nguy cơ vượt hạn mức 200 req/giờ của Meta.
- **Graceful Fallback:** Khi Meta API rate limit hoặc token hết hạn (mã lỗi 190), hệ thống không báo lỗi 500 ra UI mà fallback trả về bản ghi tương tác lưu gần nhất trong MongoDB.
