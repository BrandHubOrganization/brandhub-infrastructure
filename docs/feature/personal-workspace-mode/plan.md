# Plan — Kế hoạch Triển khai Chế độ Không gian Cá nhân (Hybrid Personal Studio + Solo Workspace Mode)

> Bước ② theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md`.
> Kiến trúc mục tiêu: **Hybrid (Auto-provisioned Personal Hub `Agency` + `Workspace` với `workspaceMode: "PERSONAL" | "AGENCY"`)**.

---

## 0. Quyết định Kiến trúc & Bảo toàn Dữ liệu (Zero-Breaking Schema Strategy)

### 0.1. Lưu trữ `workspaceMode` và `isPersonalHub` ở đâu để không phá vỡ DB?
1. **Ở tầng `Workspace` (`workspaces` table — PostgreSQL)**:
   - Bảng `workspaces` đã có sẵn cột `settings` kiểu `jsonb NOT NULL DEFAULT '{}'` ([Workspace.java#L53-L56](file:///d:/ProjectCode/BrandHub/brandhub-business-service/src/main/java/com/brandhub/business/model/Workspace.java#L53-L56)).
   - Chúng ta lưu trực tiếp khóa `"workspaceMode": "PERSONAL" | "AGENCY"` bên trong JSONB `workspaces.settings` và ánh xạ ra trường `workspaceMode` trên `WorkspaceResponse` / `CreateWorkspaceRequest` / `UpdateWorkspaceRequest`.
   - **Lợi ích**: Không cần chạy `ALTER TABLE` thêm cột bắt buộc, không làm hỏng bất kỳ dữ liệu hay migration cũ nào của các thành viên khác; mọi bản ghi `workspaces` hiện hữu chưa có khóa `workspaceMode` trong `settings` tự động fallback về `"AGENCY"`.
2. **Ở tầng `Agency` (`agencies` table — PostgreSQL)**:
   - Để đánh dấu đâu là `Personal Hub` mặc định của người dùng (nhằm tránh tạo trùng nhiều Personal Agency khi bấm nút *"Không gian Cá nhân"*), chúng ta có 2 lựa chọn tương thích ngược 100%:
     - Dùng quy ước định danh trong `logoIcon` / `tagline` hoặc thêm cột tùy chọn `is_personal BOOLEAN NOT NULL DEFAULT FALSE` (additive migration) hoặc lưu trong metadata. Để an toàn tuyệt đối cho cả môi trường chưa chạy SQL migration mới, Backend hỗ trợ đọc/ghi qua helper kiểm tra `logoIcon == "personal-studio"` kết hợp cờ cấu hình trong `workspaces.settings.isPersonalHub = true`.

---

## 1. Thiết kế Backend (`brandhub-business-service`)

### 1.1. Mở rộng DTO & Helper cho `WorkspaceMode`
- **Mới** `model/enums/WorkspaceMode.java`:
  ```java
  public enum WorkspaceMode {
      AGENCY,
      PERSONAL
  }
  ```
- **Helper đọc/ghi `workspaces.settings` JSONB**:
  - Trong `WorkspaceServiceImpl` (hoặc `WorkspaceSettingsHelper`), parse JSON `workspace.getSettings()`:
    - `extractWorkspaceMode(String settingsJson)` → trả về `WorkspaceMode.PERSONAL` nếu `"PERSONAL".equalsIgnoreCase(node.path("workspaceMode").asText())`, ngược lại trả về `WorkspaceMode.AGENCY`.
    - `mergeWorkspaceMode(String settingsJson, WorkspaceMode mode)` → cập nhật trường `"workspaceMode"` trong JSONB mà giữ nguyên mọi khóa cấu hình khác trong `settings`.
- **Cập nhật DTO**:
  - `CreateWorkspaceRequest.java`:
    - Thêm `private WorkspaceMode workspaceMode;` (nullable, mặc định `AGENCY`).
    - Cho phép `managerId` là `null` khi người gọi là `Owner` (nếu `managerId == null`, tự động gán `managerId = currentUserId`).
  - `UpdateWorkspaceRequest.java`:
    - Thêm `private WorkspaceMode workspaceMode;` để cho phép nâng cấp/chuyển đổi chế độ giữa `PERSONAL` và `AGENCY`.
  - `WorkspaceResponse.java`:
    - Thêm `private WorkspaceMode workspaceMode;` (luôn trả về `"AGENCY"` hoặc `"PERSONAL"`).

### 1.2. Endpoint Bootstrap Không gian Cá nhân 1 chạm (`POST /api/v1/workspaces/personal/bootstrap`)
- Trong `WorkspaceController.java` & `WorkspaceService.java`:
  - Thêm endpoint `POST /api/v1/workspaces/personal/bootstrap` (Body tùy chọn: `{ "name": "Không gian cá nhân của tôi" }`).
  - Logic xử lý trong `@Transactional`:
    1. Tìm trong danh sách `Workspace` mà `currentUser` đang là `OWNER` hoặc `MANAGER` (thuộc `Agency` do `currentUser` làm `ownerId`) xem đã có Workspace nào mang `workspaceMode == PERSONAL` và `status == ACTIVE` chưa.
    2. Nếu **đã tồn tại**: trả về ngay `WorkspaceResponse` của Workspace cá nhân đó (idempotent 100%, gọi nhiều lần không tạo rác).
    3. Nếu **chưa tồn tại**:
       - Kiểm tra xem `currentUser` đã có `Agency` cá nhân (`logoIcon = "personal-studio"` hoặc tên mặc định) chưa; nếu chưa thì tạo mới `Agency` (`ownerId = currentUserId`, `name = "Personal Studio — " + displayName`, `category = OTHER`, `companySize = SOLO`, `logoIcon = "personal-studio"`), thêm `AgencyMember` cho `currentUser` và khởi tạo gói/ví mặc định.
       - Tạo mới `Workspace` với `settings = {"workspaceMode":"PERSONAL","isPersonalDefault":true}`, `timezoneConfig = "Asia/Ho_Chi_Minh"`.
       - Thêm `WorkspaceMember` cho `currentUser` với role `MANAGER` (đồng thời user là `OWNER` của Agency).
       - Trả về `WorkspaceResponse` hoàn chỉnh.

### 1.3. Mở khóa Chiến dịch & Công việc không cần `MediaPackage` ở chế độ `PERSONAL`
1. **Khởi tạo Chiến dịch cá nhân (`MediaCampaignService` / `CampaignPlanValidator`)**:
   - Hiện tại: Khi tạo hoặc triển khai `MediaCampaign`, hệ thống kiểm tra `workspace.getWorkspaceMediaPackageId() != null` và đối chiếu số lượng hạng mục công việc với `WorkspaceMediaPackage`.
   - Cập nhật cho `workspaceMode == PERSONAL`:
     - Cho phép khởi tạo bản nháp và triển khai (`deploy`) `MediaCampaign` ngay cả khi `workspaceMediaPackageId == null` (hoặc tự động tạo một `WorkspaceMediaPackage` nội bộ tự do ngầm nếu DB có ràng buộc FK `NOT NULL` trên `media_campaigns.workspace_media_package_id`).
     - Bỏ qua bước kiểm tra giới hạn trần số lượng theo gói (`CampaignPlanValidator`) khi `workspaceMode == PERSONAL`, cho phép người dùng cá nhân tự do thêm/bớt bất kỳ hạng mục nào trong 8 loại Task.
2. **Tạo Công việc độc lập (`Standalone Task` — `TaskController` / `TaskWorkflowService`)**:
   - Cho phép `Owner` / `Manager` / `Creator` trong Workspace tạo trực tiếp `Task` mới (`POST /api/v1/workspaces/{workspaceId}/tasks`) với:
     - `type`: 1 trong 8 loại (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`).
     - `name`, `description`, `dueDate`, `assigneeId` (mặc định `currentUserId`).
     - `sourceType = "manual"`, `requiresClientApproval = false` (mặc định khi `workspaceMode == PERSONAL`).
     - Tự động khởi tạo danh mục Subtask theo vai trò (`TaskCatalog`) hoặc cho phép làm trực tiếp trên Task cha.

### 1.4. Cơ chế Tự duyệt 1 chạm (`Solo Self-Approval`)
1. **Duyệt nhanh cấp Task (`POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/self-approve` hoặc mở rộng `TaskApprovalService`)**:
   - Khi Task có `requiresClientApproval = false` (hoặc nằm trong Workspace `PERSONAL`) và người gọi là `Owner` hoặc `Manager` của Workspace:
     - Cho phép chuyển thẳng Task sang trạng thái hoàn tất đã duyệt (`status = FINISHED`, `reviewStep = null`, `lastSubmission = APPROVED`) và tự động đồng bộ mọi `TaskSection` sang `INTERNAL_APPROVED` + mọi `Subtask` sang `FINISHED`.
     - Nhờ đó, với bài đăng (`POST` / `SHORT_VIDEO`) hoặc bản tin (`EMAIL_NEWSLETTER`), người dùng cá nhân có thể bấm **"Hoàn tất & Sẵn sàng đăng"** chỉ bằng 1 cú click và sử dụng ngay tính năng **Đăng ngay (Publish Now)** hoặc **Lên lịch đăng (Schedule)**.

---

## 2. Thiết kế Frontend (`brandhub-web`)

### 2.1. Types, Services & Store (`workspaceMode`)
- Cập nhật `src/types/workspace.ts`:
  - Thêm `export type WorkspaceMode = "AGENCY" | "PERSONAL";`
  - Thêm `workspaceMode?: WorkspaceMode;` vào `Workspace`, `CreateWorkspacePayload`, `UpdateWorkspacePayload`.
- Cập nhật `src/services/workspaceService.ts`:
  - Thêm `bootstrapPersonal(name?: string): Promise<AxiosResponse<ApiResponse<Workspace>>>` gọi `POST /api/v1/workspaces/personal/bootstrap`.
- Tạo hook tiện ích `useWorkspaceMode(workspaceId?: string)`:
  - Trả về `{ workspaceMode, isPersonalMode, workspace, isLoading }` để mọi component trong Workspace (`Sidebar`, `ProgressStepper`, `Dashboard`, `CampaignPage`, `TasksPage`, `TaskWorkflowContent`, `Editor`) đọc được tức thì.

### 2.2. Trải nghiệm Khởi tạo & Chuyển đổi Không gian Cá nhân
1. **Tại trang Hub `/agency` & `/workspace` (`src/pages/agency/index.tsx`)**:
   - Bổ sung thẻ / nút nổi bật **"Không gian Cá nhân (Personal Studio)"** trên thanh công cụ và trong Empty State khi người dùng mới chưa có dữ liệu.
   - Bấm vào sẽ gọi `workspaceService.bootstrapPersonal()` → tự động set `currentAgencyId` + điều hướng thẳng vào `/workspaces/{id}/dashboard`.
   - Trên mỗi thẻ `WorkspaceCardItem`, hiển thị nhãn phân biệt rõ ràng: Badge **`Cá nhân (Personal)`** hoặc **`Agency`**.
2. **Tại trang Tạo Workspace (`src/pages/workspace/create.tsx`)**:
   - Thêm bộ chọn trực quan ở đầu form:
     - **Chế độ Cá nhân / Dự án độc lập (`PERSONAL`)**: Form rút gọn (chỉ cần nhập Tên dự án, Lĩnh vực, Múi giờ; tự động gán bản thân làm người quản lý, ẩn các trường thông tin doanh nghiệp rườm rà).
     - **Chế độ Khách hàng Agency (`AGENCY`)**: Giữ nguyên form đầy đủ như hiện tại.
3. **Tại trang Cài đặt Workspace (`src/pages/workspace/settings.tsx`)**:
   - Thêm thẻ **"Chế độ vận hành Không gian làm việc (Workspace Mode)"**: cho phép chuyển đổi linh hoạt giữa `Cá nhân / Dự án tự thân (PERSONAL)` và `Khách hàng Agency (AGENCY)` chỉ bằng 1 nút bấm.

### 2.3. Giao diện Thích ứng (Adaptive Sidebar, Stepper & Dashboard)
1. **Thanh Tiến trình (`src/components/layout/sidebar/SidebarProgressSection.tsx`)**:
   - Khi `isPersonalMode === true`:
     - Ẩn bước `1. Gói dịch vụ`.
     - Chỉ hiển thị 2 bước luôn mở khóa: `1. Kế hoạch / Chiến dịch` và `2. Công việc & Sáng tạo`.
2. **Menu Điều hướng (`src/components/layout/sidebar/sidebarNavConfig.ts` & `SidebarNavSections.tsx`)**:
   - Thêm thuộc tính `hideInPersonalMode?: boolean` vào `NavItem`:
     - Ẩn các mục chỉ dành cho mô hình có `Client`: `/clients`, `/client-profile`, `/portal`, `/requests`.
3. **Bảng điều khiển (`src/pages/workspace/dashboard.tsx`)**:
   - Khi `isPersonalMode === true`:
     - Ẩn `PackageStatusBanner` (banner nhắc chọn gói dịch vụ).
     - Hiển thị **Personal Quick Launchpad (Bệ phóng Sáng tạo Cá nhân)** gồm 5 lối tắt hành động nhanh:
       1. *Viết bài đăng mới (`POST`)*
       2. *Tạo kịch bản & Video ngắn (`SHORT_VIDEO`)*
       3. *Lập kế hoạch Sự kiện / Bài tập lớn (`EVENT_PLAN` / `WORKSHOP`)*
       4. *Khám phá xu hướng (`Trend Explorer`)*
       5. *Kết nối tài khoản MXH (`Facebook, Instagram, TikTok, Threads`)*

### 2.4. Tạo Công việc Trực tiếp & Tự duyệt 1 chạm trên UI
1. **Trang Danh sách Công việc (`src/pages/tasks/index.tsx`)**:
   - Thêm nút **"+ Tạo công việc"** trên thanh công cụ chính, mở hộp thoại chọn nhanh 1 trong 8 loại công việc (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`), nhập tiêu đề + hạn hoàn thành → tạo xong mở ngay trong trình xem 3 chế độ (`Side Peek` / `Center Modal` / `Full Page`).
2. **Chi tiết Công việc & Trình soạn thảo (`TaskWorkflowContent.tsx`, `TaskEditorControls.tsx`, `task-editor/index.tsx`)**:
   - Khi `isPersonalMode === true` (hoặc `requiresClientApproval === false` và user là `Owner`/`Manager`):
     - Hiển thị nút **"Hoàn tất & Duyệt ngay (Self-Approve)"** để chốt công việc chỉ với 1 chạm, mở khóa ngay nút **"Đăng bài / Lên lịch"** mà không phải qua các bước chờ duyệt trung gian.

---

## 3. Chiến lược Kiểm thử & Đảm bảo Chất lượng
1. **Backend Unit & Integration Tests (`brandhub-business-service`)**:
   - Kiểm thử `bootstrapPersonal`: gọi lần 1 tạo mới Agency + Workspace `PERSONAL`; gọi lần 2 trả lại đúng Workspace cũ (idempotent).
   - Kiểm thử tạo Workspace mới với `workspaceMode = PERSONAL` khi không truyền `managerId` (tự gán `Owner` làm `Manager`).
   - Kiểm thử tạo Task độc lập và `selfApprove` chuyển thẳng sang `FINISHED` + đồng bộ `TaskSection` sang `INTERNAL_APPROVED`.
   - Kiểm thử chuyển đổi qua lại `PERSONAL ↔ AGENCY` bảo toàn 100% dữ liệu.
2. **Frontend Type-check, Unit Tests & Build (`brandhub-web`)**:
   - Đảm bảo `npm run type-check`, `npm test -- --run` và `npx vite build` xanh 100%.
   - Kiểm tra song ngữ `vi` / `en` cho toàn bộ khóa mới trong `workspace.json`, `agency.json`, `tasks.json`, `nav.json`.
