# Danh sách Công việc (Task Checklist): Dashboard Post View & Track Detail (DA-E52-07)

## Checklist Phân rã Thực thi

### Phase 1: Entity & DTOs (Backend)
- [x] **TASK-1:** Cập nhật `PostDocument.java`:
  - Thêm `platformPostUrl`, `reactionCount`, `commentCount`, `shareCount`, `engagementUpdatedAt`.
- [x] **TASK-2:** Mở rộng `PostResponse.java`:
  - Thêm các trường `platformPostUrl`, `reactionCount`, `commentCount`, `shareCount`, `engagementUpdatedAt`.
- [x] **TASK-3:** Tạo mới các Java Record DTOs:
  - `PostDashboardResponse.java` (KPIs, platform breakdown, recent posts).
  - `PostCommentResponse.java` (authorName, content, commentedAt).
  - `PostScheduleResponse.java` (postId, platform, scheduledAt).

---

### Phase 2: Service Layer & Caching (Backend)
- [x] **TASK-4:** Cập nhật `PostService.java` & `PostServiceImpl.java`:
  - Hiện thực `getPostTrackDetail(workspaceId, postId)`: Trả về 404 `POST_NOT_FOUND` nếu post chưa ở trạng thái `PUBLISHED`.
  - Hiện thực cơ chế cache tương tác (TTL 10 phút) tránh rate-limit API mạng xã hội.
  - Hiện thực `getDashboard(workspaceId, dateRange, platform, status)`: Tổng hợp số liệu KPI và danh sách bài viết từ MongoDB.
  - Hiện thực `getComments(workspaceId, postId)`: Lấy danh sách bình luận kèm fallback.
  - Hiện thực `getSchedule(workspaceId, month)`: Lấy danh sách bài viết đã lên lịch.

---

### Phase 3: Controller Layer & REST Endpoints (Backend)
- [x] **TASK-5:** Mở rộng `PostController.java`:
  - `GET /api/v1/workspaces/{workspaceId}/posts/{postId}`
  - `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/detail`
  - `GET /api/v1/workspaces/{workspaceId}/posts/dashboard`
  - `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/comments`
  - `GET /api/v1/workspaces/{workspaceId}/posts/schedule`
  - Áp dụng `@RequireRole` bảo mật chặt chẽ cho từng endpoint.

---

### Phase 4: Frontend Service Integration (Frontend)
- [x] **TASK-6:** Đồng bộ hóa `postDetailService.ts` và `postDashboardService.ts` trong `brandhub-web` để gọi trực tiếp các API backend mới.

---

### Phase 5: Kiểm thử & Hoàn thiện
- [x] **TASK-7:** Viết Unit Test cho `PostServiceImplTest` kiểm thử các trường hợp:
  - Xem bài đã xuất bản trả về đúng metrics và platformUrl.
  - Xem bài chưa xuất bản hoặc không tồn tại ném `POST_NOT_FOUND` (404).
  - Hoạt động của bộ đệm cache tương tác (không ghi đè số liệu khi chưa hết TTL).
  - Tính toán dashboard KPIs đúng theo bộ lọc.
