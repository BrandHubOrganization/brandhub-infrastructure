# Tasks — Chế độ Không gian Cá nhân & Tác giả Độc lập (Hybrid Personal Studio + Solo Workspace Mode)

> Bước ③ theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md` + `plan.md`.
> Mỗi đầu việc đối chiếu trực tiếp tới mục tương ứng trong `plan.md` và `spec.md`.

---

## T1. Backend — Mô hình `WorkspaceMode` & Bootstrap Không gian Cá nhân (→ plan §1.1, §1.2)

- [ ] T1.1 Tạo enum `com.brandhub.business.model.enums.WorkspaceMode` (`AGENCY`, `PERSONAL`) và helper đọc/ghi trường `"workspaceMode"` trong JSONB `workspaces.settings` (mặc định fallback `"AGENCY"` cho toàn bộ dữ liệu cũ).
- [ ] T1.2 Mở rộng `CreateWorkspaceRequest`, `UpdateWorkspaceRequest` và `WorkspaceResponse` với trường `workspaceMode`; cho phép `CreateWorkspaceRequest.managerId` để trống khi người tạo là `Owner` (tự động gán chính `Owner` làm `Manager`).
- [ ] T1.3 Bổ sung phương thức `bootstrapPersonalWorkspace(UUID userId, String customName)` trong `WorkspaceService` / `WorkspaceServiceImpl` và endpoint `POST /api/v1/workspaces/personal/bootstrap` trong `WorkspaceController`:
  - Tự động tìm Workspace `PERSONAL` đang hoạt động của user; nếu chưa có thì khởi tạo ngầm `Agency` cá nhân (`logoIcon = "personal-studio"`) + gói mặc định + `Workspace` (`workspaceMode = PERSONAL`) + gán user làm `Manager`.
- [ ] T1.4 Bổ sung endpoint / hỗ trợ trong `PATCH /api/v1/workspaces/{workspaceId}` để chuyển đổi `workspaceMode` giữa `PERSONAL` và `AGENCY` (Scale-up từ Cá nhân lên Đội nhóm/Agency giữ nguyên 100% dữ liệu).

## T2. Backend — Mở khóa Chiến dịch, Công việc độc lập & Tự duyệt 1 chạm (→ plan §1.3, §1.4)

- [ ] T2.1 Cập nhật luồng Chiến dịch (`MediaCampaignService` / `CampaignPlanValidator`): khi Workspace ở chế độ `PERSONAL`, cho phép khởi tạo và triển khai Chiến dịch truyền thông mà không cần chốt `WorkspaceMediaPackage` của `Client`, tự do thêm hạng mục thuộc 8 loại Task chuẩn.
- [ ] T2.2 Đảm bảo API tạo Công việc trực tiếp (`POST /api/v1/workspaces/{workspaceId}/tasks`) hỗ trợ tạo đủ 8 loại Task (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`) với `sourceType = "manual"`, `requiresClientApproval = false` mặc định khi `workspaceMode == PERSONAL`, và tự động khởi tạo danh mục Subtask chuẩn (`TaskCatalog`).
- [ ] T2.3 Bổ sung cơ chế **Tự duyệt 1 chạm (`Self-Approve / Quick Complete`)** trong `TaskApprovalService` / `SectionService`: cho phép `Owner`/`Manager` trong Workspace `PERSONAL` (hoặc task có `requiresClientApproval = false`) bấm hoàn tất ngay để chuyển Task sang `FINISHED` (`APPROVED`) và đồng bộ các `TaskSection` sang `INTERNAL_APPROVED`, mở khóa tính năng đăng bài / lên lịch xuất bản ngay lập tức.
- [ ] T2.4 Viết Unit & Integration Test cho T1 và T2, đảm bảo `mvn test` pass xanh.

## T3. Frontend — Types, Service, Hook `useWorkspaceMode` & Luồng Bootstrap (→ plan §2.1, §2.2)

- [ ] T3.1 Cập nhật `src/types/workspace.ts` (`WorkspaceMode = "AGENCY" | "PERSONAL"`, thêm `workspaceMode` vào `Workspace`, `CreateWorkspacePayload`, `UpdateWorkspacePayload`) và `src/services/workspaceService.ts` (`bootstrapPersonal`).
- [ ] T3.2 Tạo hook `src/hooks/useWorkspaceMode.ts` đọc trạng thái `workspaceMode` / `isPersonalMode` của Workspace hiện tại.
- [ ] T3.3 Cập nhật trang Hub `/agency` (`src/pages/agency/index.tsx`), `WorkspaceCardItem.tsx` và `WorkspaceEmptyState.tsx`:
  - Thêm nút/thẻ nổi bật **"Không gian Cá nhân (Personal Studio)"** gọi `bootstrapPersonal` 1 chạm và điều hướng thẳng vào Workspace.
  - Hiển thị badge phân loại **`Cá nhân`** / **`Agency`** trên thẻ Workspace.
- [ ] T3.4 Cập nhật trang Tạo Workspace (`src/pages/workspace/create.tsx`) và Cài đặt Workspace (`src/pages/workspace/settings.tsx`):
  - Cho phép chọn loại Không gian (`Cá nhân / Dự án độc lập` vs `Khách hàng Agency`) ngay lúc tạo (tự động ẩn trường chọn Manager bắt buộc khi chọn Cá nhân).
  - Cho phép chuyển đổi chế độ `PERSONAL ↔ AGENCY` trong trang Cài đặt Workspace.

## T4. Frontend — Giao diện Thích ứng (Sidebar, Stepper, Dashboard, Tạo Task nhanh & Tự duyệt) (→ plan §2.3, §2.4)

- [ ] T4.1 Cập nhật `SidebarProgressSection.tsx`, `sidebarNavConfig.ts` và `SidebarNavSections.tsx`:
  - Khi `isPersonalMode === true`: ẩn bước `1. Gói dịch vụ` trên thanh Tiến trình; mở khóa sẵn `Chiến dịch` và `Công việc`; ẩn các mục chỉ dành cho `Client` (`/clients`, `/client-profile`, `/portal`, `/requests`).
- [ ] T4.2 Cập nhật `src/pages/workspace/dashboard.tsx`:
  - Khi `isPersonalMode === true`: ẩn banner cảnh báo thiếu gói dịch vụ (`PackageStatusBanner`) và hiển thị cụm **Bệ phóng Sáng tạo Cá nhân (Personal Quick Launchpad)** để tạo nhanh Bài đăng, Video ngắn, Sự kiện/Bài tập, Khám phá xu hướng, Kết nối MXH.
- [ ] T4.3 Cập nhật trang Danh sách Công việc (`src/pages/tasks/index.tsx`) và hộp thoại Tạo Công việc nhanh (`QuickCreateTaskDialog`):
  - Cho phép tạo trực tiếp bất kỳ loại công việc nào trong 8 loại nội dung ngay tại bảng Công việc mà không cần qua Chiến dịch hay Gói dịch vụ.
- [ ] T4.4 Cập nhật `TaskWorkflowContent.tsx` và thanh điều khiển trình soạn thảo (`TaskEditorControls.tsx`):
  - Hiển thị nút **"Hoàn tất & Duyệt ngay (Self-Approve)"** trong chế độ `PERSONAL` để người dùng cá nhân chốt bài và đăng lên mạng xã hội chỉ với 1 chạm.
- [ ] T4.5 Bổ sung đầy đủ khóa ngôn ngữ song ngữ `vi` / `en` (`workspace.json`, `agency.json`, `tasks.json`, `nav.json`), chạy `npm run type-check`, `npm test -- --run` và `npx vite build`.
