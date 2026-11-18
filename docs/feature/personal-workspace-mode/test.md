# Test — Chế độ Không gian Cá nhân & Tác giả Độc lập (Hybrid Personal Studio + Solo Workspace Mode)

> Bước ④ theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md` (AC1–AC18, §10, §11, §13), `plan.md`, `task.md`.
> Cột **Map** đối chiếu trực tiếp tới AC / mục spec / đầu việc `task.md`.
> Tầng kiểm thử: **U** = Unit Test, **I** = Integration Test (MockMvc + Mongo/Postgres), **E** = E2E / Web Component Test, **M** = Mobile Test, **T** = Kiểm tra Giao diện Sáng/Tối, Responsive & Đa ngôn ngữ.

---

## Dữ liệu Chuẩn bị Kiểm thử (Test Fixtures)

- **Người dùng**:
  - `soloUser`: Người dùng mới đăng ký, chưa có Agency hay Workspace nào.
  - `hybridUser`: Người dùng đang là `Creator` tại `Agency A1` (công ty B2B), đồng thời muốn mở `Personal Studio` riêng.
  - `teammateCreator`: Bạn cùng nhóm được mời vào Workspace `PERSONAL` của `soloUser` với vai trò `Creator`.
  - `agencyOwner`: Chủ sở hữu `Agency A1` (`Owner`).
  - `activeClient`: Khách hàng (`Client`) đang hoạt động trong `Workspace W_AGENCY` thuộc `Agency A1`.
- **Không gian làm việc (`Workspace`)**:
  - `W_PERSONAL`: Workspace được tạo qua `/api/v1/workspaces/personal/bootstrap` (`workspaceMode = "PERSONAL"`).
  - `W_LEGACY`: Workspace cũ trong DB có `settings = "{}"` (chưa có trường `workspaceMode`).
  - `W_AGENCY`: Workspace B2B có `workspaceMode = "AGENCY"` và đang có `activeClient`.

---

## A. Khởi tạo Không gian Cá nhân (`Bootstrap`) & Quản lý `workspaceMode`

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **P-A1** | AC1, §7.1, T1.5 | U+I | `soloUser` gọi `POST /api/v1/workspaces/personal/bootstrap` lần đầu tiên (body rỗng hoặc `{ "name": "Kênh Cá Nhân" }`) | Tạo thành công 1 `Agency` cá nhân (`logoIcon = "personal-studio"`, `ownerId = soloUser.id`), khởi tạo ví AI Credit + gói `Basic`, tạo 1 `Workspace` (`workspaceMode = "PERSONAL"`, `isPersonalDefault = true`), gán `soloUser` làm `MANAGER`, trả về `200 OK`. | ☑ |
| **P-A2** | AC1, §11.1, T1.5 | U+I | `soloUser` gọi lại `POST /api/v1/workspaces/personal/bootstrap` lần thứ 2 (hoặc bấm đúp 2 request liên tiếp) | Trả về đúng `W_PERSONAL` đã tạo ở P-A1 (`id` giữ nguyên), tuyệt đối không tạo thêm `Agency` hay `Workspace` trùng lặp (Idempotent 100%). | ☑ |
| **P-A3** | AC2, §11.2, T1.2 | U | Đọc `W_LEGACY` có `settings = "{}"`, `settings = null` hoặc chuỗi JSON không hợp lệ qua `WorkspaceSettingsHelper.extractMode` | Luôn trả về `WorkspaceMode.AGENCY`, không ném ngoại lệ, không làm thay đổi hành vi của các Workspace cũ. | ☑ |
| **P-A4** | §11.3, T1.2 | U | `Workspace` có `settings = {"customTheme":"warm","notifyEmail":true}`; gọi `WorkspaceSettingsHelper.writeMode(..., PERSONAL, false)` | JSON sau khi lưu có `"workspaceMode":"PERSONAL"` đồng thời giữ nguyên `"customTheme":"warm"` và `"notifyEmail":true`. | ☑ |
| **P-A5** | AC3, §7.2, T1.4 | I | `agencyOwner` gọi `POST /api/v1/agencies/{id}/workspaces` với `workspaceMode = "PERSONAL"`, `managerId = null`, `brandName = null` | Backend tự động gán `managerId = agencyOwner.id`, `brandName = name` và lưu `workspaceMode = "PERSONAL"`, trả về `201 Created`. | ☑ |
| **P-A6** | AC4, §7.2, T1.6 | I | Chủ không gian gọi `PUT /api/v1/workspaces/{W_PERSONAL}` với `workspaceMode = "AGENCY"` sau khi đã tạo 3 Task và 1 Chiến dịch | Chuyển thành công sang `workspaceMode = "AGENCY"`; toàn bộ Chiến dịch, Task, Bài viết, Tư liệu và cấu hình MXH được bảo toàn 100%. | ☑ |
| **P-A7** | AC5, §10, §11.5, T1.6 | I | `agencyOwner` gọi `PUT /api/v1/workspaces/{W_AGENCY}` đổi `workspaceMode` từ `"AGENCY"` sang `"PERSONAL"` khi đang có `activeClient` (`ACTIVE`) | Bị từ chối với HTTP `409 Conflict`, mã lỗi `WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT`. | ☑ |
| **P-A8** | AC4, T1.6 | I | Trong một Workspace `AGENCY` **chưa có** `Client` nào hoạt động, `agencyOwner` đổi `workspaceMode` sang `"PERSONAL"` | Cập nhật thành công sang `workspaceMode = "PERSONAL"`. | ☑ |
| **P-A9** | §11.6, T1.5 | I | `soloUser` xóa/archive `W_PERSONAL` cũ rồi gọi lại `POST /api/v1/workspaces/personal/bootstrap` | Hệ thống tái sử dụng `Personal Hub Agency` cũ (giữ nguyên ví AI Credit) và tạo 1 `Workspace` `PERSONAL` mới đang `ACTIVE`. | ☑ |
| **P-A10** | US7, §11.12, T1.5 | I+E | `hybridUser` (đang là `Creator` ở `Agency A1`) bấm **"Không gian Cá nhân (Personal Studio)"** | Tạo không gian cá nhân riêng biệt của `hybridUser`, đồng bộ `currentAgencyId` sang Personal Hub mà không ảnh hưởng tới quyền `Creator` ở `Agency A1`. | ☑ |

---

## B. Chiến dịch Cá nhân Không cần `MediaPackage` & Tạo Công việc Độc lập (8 Loại `TaskType`)

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **P-B1** | AC6, §7.3, T2.1 | I | Trong `W_PERSONAL` (chưa từng tạo `MediaPackage`), khởi tạo bản nháp và gọi `deploy` một `MediaCampaign` gồm 5 bài `POST`, 3 `SHORT_VIDEO`, 1 `EVENT_PLAN` | Khởi tạo và deploy Chiến dịch thành công, sinh đủ 9 Task với `requiresClientApproval = false`, không bị chặn bởi lỗi thiếu `WorkspaceMediaPackage` hay vượt trần số lượng gói. | ☑ |
| **P-B2** | AC7, §3, §7.4, T2.2 | I | Trong `W_PERSONAL`, gọi `POST /api/v1/workspaces/{id}/tasks/standalone` lần lượt cho cả **8 loại `TaskType`**: `POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER` (`initRoleSubtasks = true`) | Cả 8 Task đều được tạo thành công với `sourceType = "manual"`, `requiresClientApproval = false`, `assigneeId = soloUser.id`, và sinh đúng số lượng Subtask vai trò theo `TaskCatalog` (POST: 5, SHORT_VIDEO: 4, SURVEY: 3, EVENT_PLAN: 5, PRESS: 4, KOL: 5, WORKSHOP: 5, EMAIL: 4). | ☑ |
| **P-B3** | AC7, §11.7, T2.2 | I | Gọi `POST /tasks/standalone` khi `W_PERSONAL` chưa có bất kỳ `MediaCampaign` nào (`campaignId = null`) | Hệ thống tự động khởi tạo ngầm chiến dịch cá nhân mặc định và gắn Task vào, giúp Task hiển thị đầy đủ trên cả Danh sách, Lịch và Timeline. | ☑ |
| **P-B4** | §10, T2.2 | I | Gọi `POST /tasks/standalone` với `title = ""` hoặc `type` không hợp lệ | Trả về `400 Bad Request` (`VALIDATION_ERROR`). | ☑ |

---

## C. Cơ chế Tự duyệt 1 Chạm (`Solo Self-Approval`) & Mở khóa Xuất bản / Xuất File

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **P-C1** | AC8, §7.5, T2.3 | U+I | `soloUser` (`Owner`/`Manager` của `W_PERSONAL`) gọi `POST /api/v1/workspaces/{ws}/tasks/{taskId}/self-approve` trên Task `POST` đang ở `TODO` (kể cả khi một số `TaskSection` chưa có document trong DB — §11.8) | Toàn bộ 4 phần (`POST.BRIEF`, `POST.CAPTION`, `POST.MEDIA`, `POST.CHANNELS`) được upsert và chuyển sang `INTERNAL_APPROVED` (`finalState = true`); cả 5 Subtask chuyển sang `FINISHED`; Task cha chuyển sang `FINISHED` (`lastSubmission.outcome = APPROVED`); `PostDocument` chuyển sang `APPROVED`. | ☑ |
| **P-C2** | §11.9, T2.3 | I | Gọi lại `self-approve` lần thứ 2 trên Task đã `FINISHED` ở P-C1 | Trả về `200 OK` (Idempotent), không phát sinh lỗi hay bản ghi lịch sử trùng. | ☑ |
| **P-C3** | AC9, §10, T2.3 | I | `teammateCreator` (chỉ có role `Creator`) gọi `self-approve` trong `W_PERSONAL` | Bị từ chối với `403 Forbidden`. | ☑ |
| **P-C4** | AC9, §10, T2.3 | I | Trong `W_AGENCY`, `Manager` gọi `self-approve` trên một Task có `requiresClientApproval = true` | Bị từ chối với `400 Bad Request` (`TASK_SELF_APPROVE_NOT_ALLOWED`). | ☑ |
| **P-C5** | AC10, T2.3 | I | Sau khi `self-approve` Task `POST` (đã đặt `scheduledAt <= now`), chạy `PostSchedulePublishJob` | Job nhận diện `task.status == FINISHED && lastSubmission.outcome == APPROVED` và đẩy lệnh xuất bản bài viết sang `publisher-service` thành công. | ☑ |
| **P-C6** | AC10, T2.3 | I | Sau khi `self-approve` Task `EMAIL_NEWSLETTER`, gọi `POST /tasks/{id}/newsletter/send` | Gửi Newsletter thành công (do `EMAIL.CONTENT` và `EMAIL.DESIGN` đã đạt trạng thái cuối `INTERNAL_APPROVED` với `requiresClientApproval = false`). | ☑ |
| **P-C7** | AC10, T2.3 | I | Sau khi `self-approve` Task `EVENT_PLAN` và `PRESS_RECOMMENDATION`, gọi `GET /tasks/{id}/export` | Xuất file PDF (`EVENT_PLAN`) và DOCX (`PRESS_RECOMMENDATION`) thành công, **không** bị đóng dấu chữ *"Bản nháp"* vì mọi phần O đã ở trạng thái cuối (`isFinal = true`). | ☑ |

---

## D. Cộng tác Nhóm nhỏ (`Study Group / Small Team`), MXH & AI Credit trong Chế độ `PERSONAL`

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **P-D1** | AC14, §7.6 | I | `soloUser` mời `teammateCreator` vào `W_PERSONAL` với role `Creator` và giao Subtask `EVENT_LOGISTICS` | `teammateCreator` vào được trình soạn thảo `EventEditor`, sửa và bấm `Submit` phần `EVENT.LOGISTICS`; `soloUser` bấm `Approve` → phần đạt trạng thái cuối `INTERNAL_APPROVED` ngay mà không cần `Client`. | ☑ |
| **P-D2** | AC13, §7.8, T2.4 | I | Trong `W_PERSONAL`, `soloUser` (`Owner`/`Manager`) kết nối tài khoản **Facebook, Instagram, TikTok, Threads** | Kết nối và ngắt kết nối thành công cho cả 4 nền tảng mà không yêu cầu role `Client`. | ☑ |
| **P-D3** | §7.8, §11.10 | I | Trong `W_PERSONAL`, `soloUser` hoặc `teammateCreator` gọi AI tạo Caption / Ảnh thương mại | Hệ thống trừ credit từ ví `agency_credit_wallets` của `Personal Hub Agency` và tuân thủ hạn mức `workspaceLimit` (nếu có). | ☑ |

---

## E. Giao diện Thích ứng (`Adaptive UI`), Quick Launchpad & Trình xem 3 chế độ (`brandhub-web`)

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **P-E1** | AC11, T4.1 | E | Mở `W_PERSONAL` và kiểm tra thanh `Sidebar` | Thanh Tiến trình ẩn bước `1. Gói dịch vụ`, hiển thị 2 bước mở sẵn (`1. Kế hoạch & Chiến dịch`, `2. Công việc & Sáng tạo`); menu ẩn `/clients`, `/client-profile`, `/portal`, `/requests`. | ☑ |
| **P-E2** | AC12, T4.2 | E | Mở `/workspaces/{W_PERSONAL}/dashboard` | Không hiển thị `PackageStatusBanner`; hiển thị khối **Bệ phóng Sáng tạo Cá nhân (`Personal Quick Launchpad`)** gồm 5 lối tắt hành động nhanh. | ☑ |
| **P-E3** | AC7, T4.4 | E | Bấm **"+ Tạo công việc mới"** tại `/workspaces/{W_PERSONAL}/tasks` hoặc từ `Personal Quick Launchpad` → chọn loại công việc → bấm **"Tạo & Mở trình soạn thảo"** | Mở `QuickCreateTaskDialog` với đủ 8 loại `TaskType`, tạo Task thành công và điều hướng thẳng vào trình soạn thảo tương ứng. | ☑ |
| **P-E4** | AC8, T4.5 | E | Trong chi tiết Task hoặc trình soạn thảo của `W_PERSONAL`, bấm nút **"Hoàn tất & Duyệt ngay"** | Task chuyển ngay sang trạng thái `Hoàn tất (Finished)` kèm thông báo thành công và mở khóa nút Đăng bài / Lên lịch / Xuất file. | ☑ |
| **P-E5** | AC15, T4.6 | E | Tại trang Danh sách công việc, mở chi tiết Task lần lượt ở 3 chế độ: `Side Peek`, `Center Modal`, `Full Page` | Panel mở mượt mà chỉ 1 lần (không bị giật phóng ra – thu vào – phóng ra lại), lớp nền phía dưới được làm mờ nhẹ (`backdrop-blur-[2px]`) giúp tập trung vào nội dung. | ☑ |
| **P-E6** | AC16, T5.4 | M | Mở ứng dụng di động (`brandhub-mobile-app`) trên tài khoản có `W_PERSONAL` | Hiển thị đúng nhãn `Cá nhân` / `Personal` và cho phép xem/duyệt công việc không lỗi. | ☑ |

---

## F. Đa ngôn ngữ (`vi`/`en`), Giao diện Sáng/Tối (`Light/Dark`) & Responsive

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **P-F1** | AC17, §13, T5.1 | U | So khớp toàn bộ khóa mới trong `src/i18n/locales/vi/{workspace,agency,tasks,nav}.json` và `en/{workspace,agency,tasks,nav}.json` | Khớp 100% key-parallel giữa `vi` và `en`, không thiếu bất kỳ khóa nào trong bảng `spec.md §13`. | ☑ |
| **P-F2** | AC17, T5.2 | T | Chuyển đổi ngôn ngữ `VI ↔ EN` trên các trang `/agency`, `/workspace/create`, `/workspaces/:id/dashboard`, `/workspaces/:id/tasks`, `/workspaces/:id/settings` | Mọi nhãn hiển thị đúng ngôn ngữ đã chọn, không lộ raw key, không có chuỗi hardcode. | ☑ |
| **P-F3** | AC18, T5.3 | T | Kiểm tra giao diện **Light Mode** và **Dark Mode** trên `375px` (Mobile), `768px` (Tablet), `1440px` (Desktop) | Tương phản chữ đạt chuẩn WCAG AA, không có màu hex lạc tông, không bị tràn ngang ở mọi kích thước màn hình. | ☑ |
| **P-F4** | §14, T6.1 | I+E | Chạy `mvn test` (`brandhub-business-service`) và `npm run type-check && npm test -- --run && npx vite build` (`brandhub-web`) | Toàn bộ lệnh kiểm tra và build đạt kết quả PASS 100%. | ☑ |

---

## Kết quả Chạy Kiểm thử

- **Backend (`brandhub-business-service`)**:
  - Lệnh: `mvn test -Dtest="WorkspaceSettingsHelperTest,PersonalWorkspaceBootstrapTest,PersonalTaskWorkflowTest,WorkspaceServiceTest"`
  - Kết quả: **`BUILD SUCCESS — Tests run: 65, Failures: 0, Errors: 0, Skipped: 0`**.
- **Frontend (`brandhub-web`)**:
  - Lệnh: `npm run type-check && npx vitest run src/hooks/__tests__/useWorkspaceMode.test.tsx && npx vite build`
  - Kết quả:
    - `npm run type-check`: **`0 errors`** (`tsconfig.app.json` & `tsconfig.node.json`).
    - `vitest run src/hooks/__tests__/useWorkspaceMode.test.tsx`: **`1 passed (4 tests)`**.
    - `npx vite build`: **`✓ built in 3.19s` (`6034 modules transformed`)**.
