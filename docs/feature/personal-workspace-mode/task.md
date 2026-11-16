# Tasks — Chế độ Không gian Cá nhân & Tác giả Độc lập (Hybrid Personal Studio + Solo Workspace Mode)

> Bước ③ theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md` (AC1–AC18) + `plan.md`.
> Mỗi đầu việc ghi rõ `→ plan §x, spec ACy` để đối chiếu. Thực hiện tuần tự từ T1 đến T6; kết thúc mỗi nhóm phải chạy kiểm thử xanh trước khi sang nhóm tiếp theo.

---

## Kiểm tra Kỹ thuật Trước Khi Triển khai (Pre-Flight Impact Matrix)

| Thành phần / Dịch vụ | Mức độ ảnh hưởng | Chiến lược bảo toàn |
| :--- | :--- | :--- |
| PostgreSQL (`agencies`, `workspaces`) | Không cần chạy DDL bắt buộc | Tận dụng cột JSONB `workspaces.settings` (`NOT NULL DEFAULT '{}'`) và `agencies.logo_icon` đã có sẵn; tương thích ngược 100% với mọi bản ghi hiện hữu (AC2). |
| MongoDB (`tasks`, `task_sections`, `posts`) | Tái sử dụng 100% | Dùng chung `TaskDocument`, `TaskCatalog` (8 loại `TaskType`), `TaskSectionDocument` và `PostDocument`. |
| `brandhub-ai-service` | Không ảnh hưởng | Ví AI Credit (`agency_credit_wallets`) gắn theo `agency_id` của `Personal Hub Agency` nên giữ nguyên hoàn toàn giao thức gọi AI và trừ credit. |
| `brandhub-publisher-service` | Không ảnh hưởng | `PostSchedulePublishJob` kiểm tra `task.status == FINISHED && lastSubmission.outcome == APPROVED`; cơ chế `self-approve` thiết lập đúng bộ trạng thái này nên xuất bản tự động ngay. |

---

## T1. Backend Foundation — Enum `WorkspaceMode`, JSONB Helper & Bootstrap 1 Chạm (→ plan §1.1, §1.2 | spec AC1–AC5)

- [x] **T1.1** Tạo enum `src/main/java/com/brandhub/business/model/enums/WorkspaceMode.java` gồm 2 giá trị `AGENCY` và `PERSONAL` kèm phương thức `isPersonal()` (→ plan §1.1, spec AC2).
- [x] **T1.2** Tạo class tiện ích `src/main/java/com/brandhub/business/service/impl/WorkspaceSettingsHelper.java`:
  - `extractMode(String settingsJson)`: trả về `WorkspaceMode.PERSONAL` nếu JSON chứa `"workspaceMode": "PERSONAL"`, ngược lại luôn fallback an toàn về `WorkspaceMode.AGENCY` (kể cả khi `settingsJson` là `null`, `""`, `"{}"` hoặc JSON lỗi).
  - `isPersonalDefault(String settingsJson)`: đọc cờ `"isPersonalDefault"`.
  - `writeMode(String existingSettingsJson, WorkspaceMode mode, Boolean isPersonalDefault)`: cập nhật không phá hủy (`non-destructive merge`) trên `ObjectNode` để bảo toàn mọi cấu hình khác trong `workspaces.settings` (→ plan §1.1, spec §11.2, §11.3).
- [x] **T1.3** Bổ sung mã lỗi mới vào `src/main/java/com/brandhub/business/exception/ErrorCode.java`:
  - `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` (`409 Conflict`)
  - `TASK_SELF_APPROVE_NOT_ALLOWED` (`400 Bad Request`) (→ spec §10).
- [x] **T1.4** Mở rộng các DTO Workspace:
  - `dto/workspace/CreateWorkspaceRequest.java`: thêm `WorkspaceMode workspaceMode`; cho phép `managerId` và `brandName` tùy chọn khi `workspaceMode == PERSONAL` (nếu `managerId == null`, tự gán `managerId = currentUserId`; nếu `brandName` trống, lấy bằng `name`).
  - `dto/workspace/UpdateWorkspaceRequest.java`: thêm `WorkspaceMode workspaceMode`.
  - `dto/workspace/PersonalBootstrapRequest.java` (Mới): `String name`, `String brandName`.
  - `dto/workspace/WorkspaceResponse.java`: thêm `WorkspaceMode workspaceMode` và `Boolean isPersonalDefault`, ánh xạ tự động trong `fromEntity(...)` (→ plan §1.1, spec AC2, AC3, §9.1).
- [x] **T1.5** Cài đặt `bootstrapPersonalWorkspace(UUID currentUserId, PersonalBootstrapRequest request)` trong `WorkspaceService` & `WorkspaceServiceImpl` và thêm endpoint `POST /api/v1/workspaces/personal/bootstrap` trong `WorkspaceController`:
  - Tìm kiếm Workspace `PERSONAL` đang `ACTIVE` của user; nếu đã có thì trả về ngay (Idempotent 100%).
  - Nếu chưa có: tìm hoặc tạo `Personal Hub Agency` (`logoIcon = "personal-studio"`, khởi tạo ví AI Credit + gói `Basic`), tạo `Workspace` (`workspaceMode = PERSONAL`, `isPersonalDefault = true`) và gán `currentUser` làm `MANAGER` (→ plan §1.2, spec AC1, §7.1, §9.3.1).
- [x] **T1.6** Cập nhật `WorkspaceServiceImpl.updateWorkspace(...)`:
  - Hỗ trợ chuyển đổi `workspaceMode` giữa `PERSONAL` và `AGENCY`.
  - Khi chuyển `AGENCY → PERSONAL`, kiểm tra xem có thành viên `Client` đang `ACTIVE` hoặc có Task/Section đang chờ `Client` duyệt không; nếu có thì chặn với `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` (→ plan §1.2, spec AC4, AC5, §7.2).
- [x] **T1.7** Viết Unit Test `WorkspaceSettingsHelperTest` và `PersonalWorkspaceBootstrapServiceTest` kiểm chứng AC1–AC5, chạy `mvn test -Dtest=WorkspaceSettingsHelperTest,PersonalWorkspaceBootstrapServiceTest` pass xanh.

---

## T2. Backend Workflow — Chiến dịch Cá nhân, Công việc Độc lập & Tự duyệt 1 Chạm (→ plan §1.3, §1.4 | spec AC6–AC10)

- [x] **T2.1** Cập nhật `MediaCampaignServiceImpl` và `CampaignPlanValidator`:
  - Khi Workspace có `workspaceMode == PERSONAL`:
    - Tự động khởi tạo ngầm (lazy-init) một bản ghi `WorkspaceMediaPackage` nội bộ tự do (`status = APPROVED`) nếu `workspace.getWorkspaceMediaPackageId() == null`, giúp tạo và triển khai Chiến dịch cá nhân mà không cần bước chốt Gói dịch vụ với `Client`.
    - Bỏ kiểm tra giới hạn trần số lượng hạng mục theo gói khi `workspaceMode == PERSONAL`.
    - Mọi Task sinh từ chiến dịch cá nhân mặc định có `requiresClientApproval = false` và `assigneeId = currentUserId` nếu chưa chọn người phụ trách (→ plan §1.3, spec AC6, §7.3).
- [x] **T2.2** Tạo DTO `CreateStandaloneTaskRequest` và cài đặt API Tạo Công việc Độc lập `POST /api/v1/workspaces/{workspaceId}/tasks/standalone` trong `TaskWorkflowController` / `TaskWorkflowService`:
  - Cho phép `Owner`, `Manager`, `Creator` tạo trực tiếp bất kỳ loại công việc nào trong **8 loại `TaskType` chuẩn** (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`).
  - Tự động gắn vào chiến dịch cá nhân mặc định của Workspace (lazy-create nếu chưa có) để hiển thị đồng bộ trên Lịch và Timeline.
  - Tự động sinh danh sách Subtask chuẩn theo `TaskCatalog.roles(type)` và gán cho `assigneeId` khi `initRoleSubtasks = true`.
  - Khởi tạo sẵn `PostDocument` nháp nếu loại công việc là `POST` hoặc `SHORT_VIDEO` (→ plan §1.4, spec AC7, §7.4, §9.3.2).
- [x] **T2.3** Cài đặt API Tự duyệt & Hoàn tất 1 chạm `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/self-approve` trong `TaskApprovalController` / `TaskApprovalService` & `SectionService`:
  - Kiểm tra quyền `Owner` / `Manager` và điều kiện `workspaceMode == PERSONAL || !task.getRequiresClientApproval()` (vi phạm trả `FORBIDDEN` hoặc `TASK_SELF_APPROVE_NOT_ALLOWED` — AC9).
  - Upsert và chuyển nguyên tử toàn bộ `TaskSection` của Task sang `INTERNAL_APPROVED` (`finalState = true`), tăng `revision` và ghi `TaskSectionEventDocument`.
  - Chuyển toàn bộ `Subtask` chưa hủy sang `FINISHED`.
  - Chuyển `TaskDocument` sang `FINISHED` (`reviewStep = null`, `lastSubmission.outcome = APPROVED`) và đồng bộ `PostDocument` sang `APPROVED` (sẵn sàng đăng ngay / lên lịch) (→ plan §1.4, spec AC8, AC9, AC10, §7.5, §9.3.3).
- [x] **T2.4** Kiểm tra quyền kết nối Tài khoản Mạng xã hội (`SocialAccountController` / `SocialAccountService`) trong Workspace `PERSONAL`: đảm bảo `Owner` và `Manager` thực hiện OAuth kết nối/ngắt kết nối cho cả 4 nền tảng (**Facebook, Instagram, TikTok, Threads**) mà không cần role `Client` (→ spec AC13).
- [x] **T2.5** Viết Unit & Integration Test cho T2 (`StandaloneTaskAndSelfApproveTest`), chạy `mvn test` toàn bộ `brandhub-business-service` pass xanh.

---

## T3. Frontend Core — Types, Services, Hook `useWorkspaceMode` & Luồng Bootstrap (→ plan §2.1, §2.2 | spec AC1, AC3, AC4, AC5)

- [x] **T3.1** Mở rộng `src/types/workspace.ts` (`WorkspaceMode = "AGENCY" | "PERSONAL"`, thêm `workspaceMode` và `isPersonalDefault` vào `Workspace`, `CreateWorkspacePayload`, `UpdateWorkspacePayload`) và `src/services/workspaceService.ts` (`bootstrapPersonal`) (→ plan §2.1).
- [x] **T3.2** Mở rộng `src/services/taskWorkflowService.ts` với 2 phương thức `createStandaloneTask(workspaceId, payload)` và `selfApproveTask(workspaceId, taskId, note)` (→ plan §2.1).
- [x] **T3.3** Tạo hook `src/hooks/useWorkspaceMode.ts` trả về `{ workspaceMode, isPersonalMode, workspace, isLoading }` cho mọi trang bên trong Workspace (→ plan §2.1).
- [x] **T3.4** Cập nhật trang `/agency` (`src/pages/agency/index.tsx`), `WorkspaceCardItem.tsx` và `WorkspaceEmptyState.tsx`:
  - Thêm thẻ / nút nổi bật **"Không gian Cá nhân (Personal Studio)"** gọi `workspaceService.bootstrapPersonal()`, tự động cập nhật `currentAgencyId` và chuyển thẳng vào `/workspaces/:id/dashboard`.
  - Hiển thị badge phân loại **`Cá nhân`** / **`Agency`** trên từng `WorkspaceCardItem` (→ plan §2.2, spec AC1, §7.1).
- [x] **T3.5** Cập nhật trang Tạo Workspace (`src/pages/workspace/create.tsx`) và Cài đặt Workspace (`src/pages/workspace/settings.tsx`):
  - Tại trang tạo mới: thêm bộ chọn chế độ `Cá nhân / Dự án độc lập (PERSONAL)` vs `Khách hàng Agency (AGENCY)` (tự động ẩn trường chọn Manager bắt buộc khi chọn `PERSONAL`).
  - Tại trang cài đặt: thêm khối chuyển đổi chế độ `PERSONAL ↔ AGENCY` kèm xử lý thông báo lỗi `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT` (→ plan §2.2, spec AC3, AC4, AC5, §7.2).

---

## T4. Frontend Adaptive UI — Sidebar, Quick Launchpad, Tạo Task Nhanh, Tự Duyệt & 3-Mode Peek (→ plan §2.3, §2.4 | spec AC6–AC15)

- [x] **T4.1** Cập nhật `src/components/layout/sidebar/SidebarProgressSection.tsx`, `sidebarNavConfig.ts` và `SidebarNavSections.tsx`:
  - Khi `isPersonalMode === true`: ẩn bước `1. Gói dịch vụ` trên thanh Tiến trình; hiển thị 2 bước luôn mở khóa (`1. Kế hoạch & Chiến dịch`, `2. Công việc & Sáng tạo`); ẩn các mục `/clients`, `/client-profile`, `/portal`, `/requests` trên menu Sidebar (→ plan §2.3, spec AC11, §7.7).
- [x] **T4.2** Tạo component `src/pages/workspace/components/PersonalQuickLaunchpad.tsx` và tích hợp vào `src/pages/workspace/dashboard.tsx`:
  - Khi `isPersonalMode === true`: ẩn `PackageStatusBanner`, hiển thị **Bệ phóng Sáng tạo Cá nhân** gồm 5 lối tắt hành động nhanh (*Viết bài đăng MXH, Kịch bản & Video ngắn, Sự kiện/PR/Workshop, Khám phá Xu hướng AI, Kết nối Kênh MXH*) (→ plan §2.3, spec AC12, §7.7).
- [x] **T4.3** Cập nhật trang Chiến dịch (`src/pages/campaign/index.tsx`):
  - Khi `isPersonalMode === true`: bỏ màn hình chặn thiếu `MediaPackage`, cho phép khởi tạo và triển khai Chiến dịch cá nhân ngay lập tức (→ plan §1.3, spec AC6, §7.3).
- [x] **T4.4** Tạo hộp thoại `src/pages/tasks/components/QuickCreateTaskDialog.tsx` và tích hợp vào thanh công cụ `src/pages/tasks/index.tsx` cùng `PersonalQuickLaunchpad`:
  - Cho phép chọn trực quan đủ **8 loại `TaskType`**, nhập tiêu đề, hạn hoàn thành, độ ưu tiên, mô tả và chọn **"Tạo công việc"** hoặc **"Tạo & Mở trình soạn thảo"** (→ plan §2.3, spec AC7, §7.4).
- [x] **T4.5** Bổ sung nút **"Hoàn tất & Duyệt ngay (Self-Approve)"** trong `TaskWorkflowContent.tsx`, `TaskApprovalSection.tsx` và thanh công cụ trình soạn thảo (`TaskEditorControls.tsx`):
  - Cho phép `Owner`/`Manager` trong Workspace `PERSONAL` (hoặc khi `requiresClientApproval === false`) hoàn tất và duyệt công việc chỉ bằng 1 cú click, mở khóa ngay nút **Đăng bài / Lên lịch / Gửi bản tin / Xuất file** (→ plan §2.3, spec AC8, AC10, §7.5).
- [x] **T4.6** Đảm bảo trải nghiệm mở chi tiết 3 chế độ (`Side Peek` | `Center Modal` | `Full Page` qua `src/components/ui/peek-mode.tsx`) hoạt động mượt mà trên toàn bộ danh sách công việc, subtask và bảng quản trị, không bị giật animation và có lớp nền mờ tập trung (`backdrop-blur-[2px]`) (→ plan §2.4, spec AC15).

---

## T5. Đa ngôn ngữ (`vi`/`en`), Giao diện Sáng/Tối (`Light/Dark`) & Ứng dụng Mobile (→ plan §3, §5 | spec AC16–AC18)

- [x] **T5.1** Khai báo đầy đủ và đồng bộ 100% khóa ngôn ngữ mới trong `src/i18n/locales/vi/{workspace,agency,tasks,nav}.json` và `src/i18n/locales/en/{workspace,agency,tasks,nav}.json` theo đúng bảng tại `spec.md §13` (→ spec AC17).
- [x] **T5.2** Kiểm tra không có chuỗi tiếng Việt / tiếng Anh hardcode trong toàn bộ các file JSX/TSX mới hoặc vừa sửa; kiểm tra đối xứng key giữa `vi` và `en` (→ spec AC17).
- [x] **T5.3** Rà soát toàn bộ giao diện mới ở cả **Light Mode** và **Dark Mode** trên 3 kích thước màn hình (`375px` Mobile, `768px` Tablet, `1440px` Desktop): đảm bảo chỉ dùng semantic token (`bg-background`, `bg-card`, `text-foreground`, `border-border`, `brand-orange`), độ tương phản đạt chuẩn WCAG AA, không tràn ngang (→ spec AC18).
- [x] **T5.4** Cập nhật `brandhub-mobile-app` (`src/types/workspace.ts`, nhãn i18n `vi`/`en` và badge `Cá nhân` trên màn hình Workspace / Task Detail) (→ plan §3, spec AC16).

---

## T6. Kiểm thử Tổng thể & Đồng bộ Tài liệu BA (→ spec §14, `test.md`)

- [x] **T6.1** Chạy toàn bộ test suite Backend (`mvn test`) và Frontend (`npm run type-check`, `npm test -- --run`, `npx vite build`), cập nhật kết quả vào `test.md`.
- [x] **T6.2** Rà soát và cập nhật toàn bộ bộ tài liệu BA trong `brandhub-infrastructure/docs/ba/` (`00-overview.md` → `12-state-machines.md` và `use-cases/00-index.md`) để khớp 100% với **141 FR chuẩn (`3.2.1`–`3.10.14`)**, **6 Role chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**, và các tính năng mới nhất của dự án.
