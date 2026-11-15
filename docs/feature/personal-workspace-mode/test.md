# Test — Chế độ Không gian Cá nhân & Tác giả Độc lập (Hybrid Personal Studio + Solo Workspace Mode)

> Bước ④ theo `docs/rule/feature-workflow.md`. Dựa trên `spec.md` (AC1–AC9), `plan.md`, `task.md`.
> Tầng kiểm thử: **U** = Unit Test, **I** = Integration Test (Backend MockMvc / Service), **W** = Web Component / Build Test.

---

## A. Khởi tạo Không gian Cá nhân & Quản lý `workspaceMode`

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **P-A1** | AC1, T1.3 | U+I | Người dùng mới gọi `POST /api/v1/workspaces/personal/bootstrap` lần đầu | Hệ thống tự động tạo `Agency` cá nhân (`ownerId = userId`, `logoIcon = "personal-studio"`) + `Workspace` (`workspaceMode = PERSONAL`), gán user làm `Manager` và trả về `200 OK` kèm `workspaceMode = "PERSONAL"`. | ☐ |
| **P-A2** | AC1, T1.3 | U+I | Gọi lại `POST /api/v1/workspaces/personal/bootstrap` lần thứ 2 trên cùng tài khoản | Trả về đúng `Workspace` cá nhân đã tạo ở P-A1, không tạo trùng Agency hay Workspace mới (idempotent). | ☐ |
| **P-A3** | AC2, T1.1 | U | Đọc danh sách `Workspace` hiện có từ DB (có `settings = "{}"` chưa chứa `workspaceMode`) | `WorkspaceResponse.workspaceMode` luôn trả về `"AGENCY"`, không gây lỗi parse JSON và không làm thay đổi hành vi của Workspace cũ. | ☐ |
| **P-A4** | AC1, T1.2 | I | `Owner` gọi `POST /api/v1/agencies/{id}/workspaces` với `workspaceMode = "PERSONAL"` và `managerId = null` | Hệ thống tự động lấy `currentUserId` làm `managerId`, tạo Workspace thành công với `workspaceMode = "PERSONAL"`. | ☐ |
| **P-A5** | AC8, T1.4 | I | `Owner` gọi `PATCH /api/v1/workspaces/{id}` đổi `workspaceMode` từ `"PERSONAL"` sang `"AGENCY"` | Cập nhật thành công `workspaceMode = "AGENCY"`; toàn bộ Task, Bài viết, Thư viện tư liệu và lịch sử AI trong Workspace được giữ nguyên 100%. | ☐ |

---

## B. Tạo Công việc Độc lập, Chiến dịch Cá nhân & Tự duyệt 1 chạm (Self-Approval)

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **P-B1** | AC4, T2.2 | I | Trong Workspace `PERSONAL` (chưa có `MediaPackage` và chưa có `MediaCampaign`), gọi tạo trực tiếp Task loại `POST`, `SHORT_VIDEO`, `EVENT_PLAN`, `WORKSHOP` | Tạo Task thành công với `sourceType = "manual"`, `requiresClientApproval = false`, sinh đủ danh mục Subtask vai trò chuẩn (`TaskCatalog`). | ☐ |
| **P-B2** | AC5, T2.1 | I | Trong Workspace `PERSONAL`, khởi tạo và triển khai `MediaCampaign` khi chưa có Gói dịch vụ khách hàng | Khởi tạo và deploy Chiến dịch thành công, sinh danh sách Task tương ứng mà không bị chặn bởi lỗi thiếu `WorkspaceMediaPackage`. | ☐ |
| **P-B3** | AC6, T2.3 | U+I | Trong Workspace `PERSONAL`, `Owner`/`Manager` gọi `POST /api/v1/workspaces/{wsId}/tasks/{taskId}/self-approve` trên một Task đang ở `TODO` hoặc `IN_PROGRESS` | Task chuyển thẳng sang `FINISHED` (`lastSubmission.outcome = APPROVED`), toàn bộ `TaskSection` chuyển sang `INTERNAL_APPROVED`, mở khóa tính năng xuất bản / lên lịch đăng bài ngay. | ☐ |
| **P-B4** | AC8 | I | Trong Workspace `PERSONAL`, `Owner` mời thêm 1 thành viên vào Agency và gán làm `Creator` trong Workspace | Thành viên `Creator` truy cập được Workspace, nhận Task/Subtask và sử dụng công cụ AI theo ngân sách của Workspace bình thường. | ☐ |

---

## C. Giao diện Thích ứng (Adaptive UI) & Đa ngôn ngữ (`brandhub-web`)

| ID | Map | Tầng | Bước / Input | Kết quả mong đợi | KQ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **P-C1** | AC3, AC7, T4.1 | W | Mở một Workspace có `workspaceMode = "PERSONAL"` | Sidebar ẩn bước `1. Gói dịch vụ` trên thanh Tiến trình; bước `Chiến dịch` và `Công việc` mở sẵn; ẩn các menu `/clients`, `/client-profile`, `/portal`, `/requests`. | ☐ |
| **P-C2** | AC7, T4.2 | W | Xem trang `/workspaces/:id/dashboard` ở chế độ `PERSONAL` | Không hiển thị cảnh báo thiếu gói dịch vụ (`PackageStatusBanner`); hiển thị **Bệ phóng Sáng tạo Cá nhân (Personal Quick Launchpad)**. | ☐ |
| **P-C3** | AC4, AC6, T4.3, T4.4 | W | Tại `/workspaces/:id/tasks`, bấm **"+ Tạo công việc"**, chọn loại nội dung, mở chi tiết và bấm **"Hoàn tất & Duyệt ngay"** | Tạo Task thành công, mở ngay trong bảng chi tiết (hỗ trợ đủ 3 chế độ `Side Peek`, `Center Modal`, `Full Page`) và duyệt hoàn tất chỉ với 1 cú nhấp chuột. | ☐ |
| **P-C4** | AC9, T4.5 | W | Chuyển đổi ngôn ngữ `VI` ↔ `EN` và chế độ `Light` ↔ `Dark` | Toàn bộ nhãn mới hiển thị đúng ngôn ngữ, không sót raw key, `npm run type-check`, `npm test -- --run` và `npx vite build` đạt 100%. | ☐ |
