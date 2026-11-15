# Spec — Chế độ Không gian Cá nhân & Tác giả Độc lập (Hybrid Personal Studio + Solo Workspace Mode)

> Bước ① theo `docs/rule/feature-workflow.md`.
> Kiến trúc đã chọn: **Phương án 4 (Hybrid: Shadow Personal Hub + Workspace-Level Mode `PERSONAL | AGENCY`)**.
> Tuân thủ tuyệt đối 6 Role chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`) và không phá vỡ 141 FR hiện hữu.

---

## 1. Bối cảnh & Mục tiêu (Objective)

Hiện tại BrandHub được thiết kế theo mô hình thuần B2B Agency 3 tầng (`User → Agency → Workspace`) và quy trình hợp đồng 3 bước (`1. Gói dịch vụ → 2. Chiến dịch → 3. Công việc`) kèm luồng phê duyệt đa cấp (`Creator → Manager → Client`). Điều này tạo ra 4 rào cản lớn cho **người làm truyền thông cá nhân (Solo Creator, Freelancer, Sinh viên làm đồ án/bài tập môn học, Chủ shop nhỏ)**:

1. **Rào cản khởi tạo**: Muốn sử dụng bất kỳ công cụ nào (Tạo bài đăng, AI Studio, Khám phá xu hướng, Lịch nội dung, Thư viện), người dùng bắt buộc phải khai báo thành lập Công ty (`Agency`) rồi tạo `Workspace` và gán `Manager`.
2. **Rào cản hợp đồng (`Media Package`)**: Luồng tạo chiến dịch và công việc đang buộc phải có `WorkspaceMediaPackage` (chốt gói với `Client`). Người làm cá nhân không bán gói dịch vụ cho chính mình nên bị chặn ngay từ bước 1.
3. **Rào cản phê duyệt đa cấp (`Creator → Manager → Client`)**: Công việc (`Task` / `TaskSection`) yêu cầu nộp duyệt nội bộ và chờ `Client` duyệt mới hoàn tất hoặc xuất bản. Người dùng cá nhân vừa là người soạn thảo vừa là người quyết định cuối cùng, cần cơ chế **Tự hoàn tất / Xuất bản ngay (1-Click Self-Approve)**.
4. **Rào cản giao diện B2B**: Thanh điều hướng (`Sidebar`) và màn hình tổng quan hiển thị nhiều mục chỉ dành cho công ty (*Hồ sơ công ty, Thành viên công ty, Quản lý gói truyền thông, Cổng Khách hàng, Yêu cầu nội dung*), gây rối cho người dùng cá nhân.

### Mục tiêu của giải pháp Hybrid:
1. **Khởi tạo 1 chạm (Zero-Friction Personal Studio Bootstrap)**: Cung cấp lối vào **"Không gian Cá nhân (Personal Studio)"** tự động tạo ngầm (hoặc kích hoạt 1 chạm) một `Agency` cá nhân ẩn (`isPersonalHub = true`) và một `Workspace` cá nhân (`workspaceMode = PERSONAL`), gán người dùng làm `Owner` kiêm `Manager`.
2. **Chế độ `workspaceMode = PERSONAL` ngay ở cấp `Workspace`**:
   - Cho phép một người dùng vừa tham gia các `Workspace` của công ty (`AGENCY`), vừa sở hữu một hoặc nhiều `Workspace` cá nhân (`PERSONAL`) cho dự án riêng, kênh MXH cá nhân hoặc bài tập nhóm.
   - Bỏ qua bước bắt buộc `1. Gói dịch vụ (Media Package)` và `Client`.
   - Hỗ trợ **2 luồng làm việc linh hoạt**:
     - **Luồng Chiến dịch cá nhân (Personal Campaign)**: Lập kế hoạch chiến dịch truyền thông (Mục tiêu, Ý tưởng, Timeline) không cần Gói dịch vụ → Sinh danh sách Công việc (`Task`).
     - **Luồng Công việc độc lập (Standalone / Quick Task)**: Tạo trực tiếp bất kỳ loại công việc nào trong 8 loại (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`) ngay tại bảng Công việc mà không cần tạo Chiến dịch trước.
3. **Cơ chế Tự duyệt 1 chạm (Solo Self-Approval) & Cộng tác nhóm nhỏ (Study Group / Small Team)**:
   - Mặc định mọi Task trong `PERSONAL` workspace có `requiresClientApproval = false`.
   - Khi người thực hiện là `Owner` hoặc `Manager` của `PERSONAL` workspace, họ có thể bấm **"Hoàn tất ngay (Complete & Approve)"** để đưa Task / Phần (`TaskSection`) thẳng sang trạng thái hoàn tất (`FINISHED` / `INTERNAL_APPROVED`) và mở khóa đăng bài / lên lịch xuất bản ngay lập tức.
   - Vẫn cho phép mời thêm bạn cùng nhóm (với role `Creator`) vào `PERSONAL` workspace để làm bài tập nhóm hoặc dự án nhỏ (không cần `Client` và không cần `Media Package`).
4. **Giao diện thích ứng (Adaptive UI) & Nâng cấp mượt lên Agency (Seamless Scale-Up)**:
   - Khi đang ở `Workspace` có `workspaceMode = PERSONAL`, `Sidebar`, `ProgressStepper` và `Dashboard` tự động ẩn các thành phần B2B dư thừa và hiển thị giao diện tối ưu cho cá nhân.
   - Bất kỳ lúc nào, `Owner` có thể bấm **"Chuyển sang chế độ Agency / Khách hàng"** trong Cài đặt Workspace để bật lại đầy đủ quy trình `Gói dịch vụ → Chiến dịch → Công việc` và cổng `Client` mà **giữ nguyên 100% dữ liệu bài viết, tư liệu, lịch sử AI và cấu hình mạng xã hội**.

---

## 2. Thuật ngữ & Bảo toàn Chuẩn Hệ Thống

| Thuật ngữ | Định nghĩa | Quy tắc bảo toàn |
| :--- | :--- | :--- |
| **Role hệ thống** | `Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin` | **Giữ nguyên tuyệt đối 6 tên chuẩn.** Không thêm role mới như `PersonalUser` hay `SoloCreator`. Trong Personal Workspace, chủ sở hữu nắm đồng thời role `Owner` (cấp Agency) và `Manager` (cấp Workspace). |
| **Personal Hub (`isPersonalHub`)** | Bản ghi `Agency` được đánh dấu `isPersonalHub = true` (lưu trong metadata/cấu hình), đại diện cho không gian tài khoản cá nhân của `Owner`. | Bảo toàn khóa ngoại `agency_id` cho Ví AI Credit (`agency_credit_wallets`), Gói cước (`subscriptions`), Hóa đơn (`invoices`) và Định mức Newsletter. |
| **Chế độ Không gian (`workspaceMode`)** | Thuộc tính trong `workspaces.settings` (`jsonb`): nhận giá trị `"AGENCY"` (mặc định cho mọi workspace hiện có) hoặc `"PERSONAL"`. | Mọi workspace cũ không có trường này mặc định hiểu là `"AGENCY"` (tương thích ngược 100%). |
| **Công việc độc lập (`Standalone Task`)** | `Task` được tạo trực tiếp trong Workspace với `sourceType = "manual"` và `campaignId = null`. | Dùng chung toàn bộ trình soạn thảo 8 loại nội dung, Subtask theo vai trò (`TaskCatalog`) và lịch xuất bản. |

---

## 3. Đặc tả Nghiệp vụ Chi tiết (Functional Specifications)

### 3.1. Khởi tạo nhanh Không gian Cá nhân (Personal Studio Bootstrap)
1. **Điểm chạm giao diện**:
   - Trên trang `/agency` (Hub quản lý Agency & Workspace) và trên thanh chuyển đổi nhanh ở góc trên bên trái (`SidebarHeader`): bổ sung nút nổi bật **"Không gian Cá nhân (Personal Studio)"** (hoặc tạo mới Workspace với tùy chọn **"Cá nhân / Dự án độc lập"**).
   - Khi người dùng mới đăng ký tài khoản và chưa có bất kỳ Agency hay Workspace nào, màn hình chào mừng hiển thị 2 lựa chọn rõ ràng:
     - **Lựa chọn 1 — Bắt đầu Cá nhân (Personal Studio)**: Dành cho cá nhân làm truyền thông, nhà sáng tạo nội dung, freelancer, sinh viên làm bài tập/đồ án (1 chạm vào thẳng).
     - **Lựa chọn 2 — Thiết lập Công ty Truyền thông (Agency B2B)**: Dành cho công ty truyền thông quản lý nhiều khách hàng và gói dịch vụ.
2. **Hành vi Backend (`POST /api/v1/workspaces/personal/bootstrap`)**:
   - Kiểm tra xem người dùng hiện tại đã có `Agency` nào mang cờ `isPersonalHub = true` (hoặc tạo tự động) và `Workspace` mang `workspaceMode = "PERSONAL"` chưa:
     - Nếu **đã có**: trả về ngay `{ agencyId, workspaceId, created: false }`.
     - Nếu **chưa có**:
       1. Tạo (hoặc dùng lại) 1 `Agency` thuộc quyền sở hữu của user (`ownerId = currentUser.id`, tên mặc định: `"Không gian của <DisplayName>"`, `companySize = SOLO` hoặc tương đương, đánh dấu `isPersonalHub = true`).
       2. Khởi tạo ví AI Credit / Subscription mặc định (gói `Basic`) cho `Agency` này theo đúng luồng chuẩn hiện hành.
       3. Tạo 1 `Workspace` mặc định thuộc `Agency` đó với `settings.workspaceMode = "PERSONAL"`, `name = req.name || "Dự án cá nhân của tôi"`.
       4. Thêm bản ghi `WorkspaceMember` gán `currentUser` làm `MANAGER` (đồng thời là `OWNER` của Agency).
       5. Trả về `{ agencyId, workspaceId, created: true }` để Frontend điều hướng thẳng vào `/workspaces/{workspaceId}/dashboard` hoặc `/workspaces/{workspaceId}/tasks`.

### 3.2. Phân loại `workspaceMode` khi Tạo & Cập nhật Workspace
1. **Khi tạo Workspace mới (`POST /api/v1/agencies/{agencyId}/workspaces`)**:
   - Request payload bổ sung trường tùy chọn `workspaceMode?: "AGENCY" | "PERSONAL"` (mặc định `"AGENCY"`, hoặc `"PERSONAL"` nếu tạo từ Personal Hub).
   - Nếu `workspaceMode === "PERSONAL"`:
     - Nếu người gọi là `Owner` và không truyền `managerId`, hệ thống **tự động gán chính `Owner` làm `Manager`** của Workspace đó (không bắt buộc người dùng phải chọn người quản lý từ dropdown).
     - Lưu `{"workspaceMode": "PERSONAL"}` vào cột `workspaces.settings` (`jsonb`).
2. **Chuyển đổi chế độ Workspace (`PATCH /api/v1/workspaces/{workspaceId}/mode`)**:
   - Cho phép `Owner` / `Manager` chuyển đổi `workspaceMode` giữa `"PERSONAL"` và `"AGENCY"`:
     - **Từ `"PERSONAL"` → `"AGENCY"` (Scale-up lên Đội nhóm/Khách hàng)**: Mở khóa ngay bước `1. Gói dịch vụ`, cho phép mời `Client`, bật tùy chọn `requiresClientApproval` cho các công việc mới. Toàn bộ Chiến dịch, Công việc, Bài viết, Thư viện tư liệu giữ nguyên 100%.
     - **Từ `"AGENCY"` → `"PERSONAL"`**: Chỉ cho phép khi Workspace hiện chưa có `Client` đang hoạt động (hoặc cảnh báo rõ ràng rằng giao diện sẽ ẩn các mục dành cho `Client`).

### 3.3. Luồng Chiến dịch & Công việc trong Chế độ `PERSONAL`
1. **Tiến trình (Progress Stepper trên Sidebar)**:
   - Ở `workspaceMode = "AGENCY"`: Hiển thị 3 bước như hiện tại (`1. Gói dịch vụ → 2. Chiến dịch → 3. Công việc`).
   - Ở `workspaceMode = "PERSONAL"`: Rút gọn thành **2 bước linh hoạt**:
     - `1. Chiến dịch & Kế hoạch` (Tùy chọn — không khóa, không bắt buộc phải có Gói dịch vụ).
     - `2. Công việc & Sáng tạo` (Luôn mở sẵn — người dùng có thể bấm vào tạo việc ngay lập tức).
2. **Tạo Chiến dịch không cần Gói dịch vụ (Package-less Personal Campaign)**:
   - Trong `workspaceMode = "PERSONAL"`, khi người dùng vào trang **Chiến dịch truyền thông (`/workspaces/:id/campaigns`)**:
     - Không hiển thị màn hình chặn *"Chưa có gói dịch vụ (Media Package)"*.
     - Nếu chưa có chiến dịch, hệ thống hiển thị nút **"Khởi tạo Kế hoạch / Chiến dịch cá nhân"** (hoặc tự động khởi tạo bản nháp chiến dịch cá nhân khi người dùng nhập Mục tiêu / Ý tưởng / Hạng mục công việc).
     - Cho phép thêm tự do bất kỳ hạng mục công việc nào thuộc 8 loại (`POST`, `SHORT_VIDEO`, `SURVEY`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`) vào kế hoạch chiến dịch mà không bị giới hạn bởi trần số lượng của `MediaPackage` (vì không gắn hợp đồng trọn gói của khách hàng).
3. **Tạo Công việc độc lập (Standalone / Quick Task Creation)**:
   - Tại trang **Danh sách công việc (`/workspaces/:id/tasks`)**, ở chế độ `PERSONAL`:
     - Hiển thị nút CTA chính **"+ Tạo công việc mới"** (và thanh chọn nhanh loại nội dung: *Bài đăng, Video ngắn, Kế hoạch sự kiện, Khảo sát, Workshop, Thông cáo báo chí, KOL/Influencer, Email/Bản tin*).
     - Cho phép tạo trực tiếp `Task` (`sourceType = "manual"`, `requiresClientApproval = false`, `assigneeId = currentUser.id` mặc định) mà không cần thông qua Chiến dịch hay Yêu cầu nội dung (`ContentRequest`).

### 3.4. Quy trình Tự duyệt 1 chạm (Solo Self-Approval)
1. **Cấp Task (`TaskApprovalService`)**:
   - Trong `workspaceMode = "PERSONAL"`, mọi Task tạo mới mặc định có `requiresClientApproval = false`.
   - Khi `Owner` hoặc `Manager` (hoặc người làm trùng với `Manager` của Workspace) bấm hoàn tất/duyệt:
     - Hỗ trợ thao tác **1 chạm (Quick Complete / Self-Approve)**: Nếu Task đang ở `TODO` hoặc `IN_PROGRESS` và người bấm là `Owner`/`Manager`, cho phép chuyển thẳng sang `FINISHED` (kèm `lastSubmission.outcome = APPROVED`) để mở khóa tính năng **Đăng bài ngay / Lên lịch đăng (`PostSchedulePublishJob`)**.
2. **Cấp Phần soạn thảo (`SectionService` — Subtask theo vai trò)**:
   - Trong `workspaceMode = "PERSONAL"`, nếu người dùng không chia nhỏ cho người khác thì bản thân họ giữ quyền điều phối (`Owner`/`Manager`) trên mọi phần (`SectionPolicy.canEdit = true`, `canApprove = true`).
   - Vì `requiresClientApproval = false`, trạng thái cuối của mọi phần (cả `OUTPUT` và `INTERNAL`) đều dừng ở `INTERNAL_APPROVED` (không bao giờ rơi vào trạng thái chờ `Client` duyệt).
   - Cung cấp nút **"Duyệt & Hoàn tất tất cả các phần"** dành cho `Owner`/`Manager` trong chế độ `PERSONAL` để chốt nhanh toàn bộ nội dung bài viết/sự kiện/bản tin chỉ bằng 1 cú nhấp chuột.

### 3.5. Giao diện Thích ứng (Adaptive Sidebar & Dashboard cho `PERSONAL`)
1. **Thanh điều hướng bên trái (`Sidebar` / `sidebarNavConfig.ts`)**:
   - Khi đang ở Workspace có `workspaceMode = "PERSONAL"`:
     - **Hiển thị**:
       - *Tổng quan*: Bảng điều khiển (`/dashboard`), Kế hoạch / Chiến dịch (`/campaigns`), Trao đổi nhóm (`/chat` — hữu ích khi làm bài tập nhóm).
       - *Sáng tạo*: Danh sách công việc (`/tasks`), Khám phá xu hướng (`/trends`), Lịch nội dung (`/calendar`), và các công cụ AI Video / Product Video / Video Space khi mở task video.
       - *Nội dung*: Mẫu Email (`/mail-templates`), Thư viện nội dung (`/library`).
       - *Cài đặt Không gian*: Cài đặt chung & Chuyển đổi chế độ (`/settings`), Thành viên cộng tác (`/members` — để mời bạn cùng nhóm nếu cần), Tài khoản Mạng xã hội (`/social-accounts`).
     - **Tự động ẩn (để tránh rối)**:
       - Bước `1. Gói dịch vụ` trên thanh Tiến trình.
       - Mục `Khách hàng (/clients)`, `Hồ sơ Khách hàng (/client-profile)`, `Cổng Khách hàng (/portal)`.
       - Mục `Yêu cầu Nội dung (/requests)` (do luồng này chỉ dành cho `Client` gửi yêu cầu cho Agency).
       - Nếu Workspace chỉ có 1 thành viên duy nhất (Solo 100%), ẩn luôn mục `Duyệt bài (/task-approvals)` (hoặc chỉ hiện khi Workspace cá nhân có mời thêm thành viên `Creator` khác).
2. **Màn hình Bảng điều khiển (`WorkspaceDashboard`)**:
   - Khi ở chế độ `PERSONAL`, ẩn `PackageStatusBanner` (banner cảnh báo chưa chọn gói dịch vụ khách hàng) và thay bằng **Thanh Công Cụ Khởi Tạo Nhanh (Personal Quick Launchpad)**:
     - Tạo Bài đăng MXH mới
     - Tạo Video ngắn / Kịch bản AI
     - Lập Kế hoạch Sự kiện / Bài tập lớn
     - Khám phá Xu hướng (Trend Explorer)
     - Kết nối Kênh MXH (Facebook, Instagram, TikTok, Threads)

### 3.6. Ví AI Credit & Gói cước (Subscription & Billing)
- **Tái sử dụng 100% hạ tầng hiện tại**:
  - Personal Hub vẫn là một `Agency` hợp lệ trong DB nên có sẵn 1 ví `agency_credit_wallets` và gói `Basic` miễn phí ban đầu.
  - Người dùng cá nhân sử dụng AI (Tạo nội dung, Đại sứ thương hiệu, Ảnh thương mại, Video) được trừ credit từ ví này theo đúng bảng giá của `Admin`.
  - Khi hết credit hoặc muốn nâng cấp lên gói `Plus` / `Enterprise` qua SePay / PayOS (VietQR), người dùng cá nhân thực hiện thanh toán y hệt luồng hiện có mà không cần viết nhánh thanh toán mới.

---

## 4. Tiêu chí Nghiệm thu (Acceptance Criteria — AC)

- **AC1 (Bootstrap 1 chạm)**: Người dùng bấm vào *"Không gian Cá nhân (Personal Studio)"* lần đầu tiên sẽ được hệ thống tự động tạo `Agency` cá nhân (`isPersonalHub = true`) + `Workspace` (`workspaceMode = "PERSONAL"`) và chuyển thẳng vào không gian làm việc mà không phải điền form thành lập công ty hay chọn Manager.
- **AC2 (Tương thích ngược 100%)**: Toàn bộ Agency và Workspace hiện có trong DB mặc định hoạt động ở chế độ `workspaceMode = "AGENCY"`, không bị thay đổi bất kỳ hành vi, dữ liệu hay phân quyền nào.
- **AC3 (Ẩn Gói dịch vụ & Mở khóa Công việc)**: Trong Workspace `PERSONAL`, thanh Tiến trình ở Sidebar không hiển thị bước `1. Gói dịch vụ`; bước `Chiến dịch` và `Công việc` luôn ở trạng thái mở khóa.
- **AC4 (Tạo Task trực tiếp không cần Package/Campaign)**: Trong Workspace `PERSONAL`, người dùng có thể bấm **"+ Tạo công việc mới"** tại trang `/workspaces/:id/tasks` để tạo bất kỳ loại Task nào trong 8 loại nội dung chuẩn và mở trình soạn thảo ngay.
- **AC5 (Tạo Chiến dịch cá nhân không cần Package)**: Trong Workspace `PERSONAL`, người dùng có thể khởi tạo và triển khai Chiến dịch truyền thông tại `/workspaces/:id/campaigns` mà không cần có `WorkspaceMediaPackage`, và không bị chặn bởi giới hạn số lượng hạng mục của gói.
- **AC6 (Tự duyệt 1 chạm — Self-Approval)**: Trong Workspace `PERSONAL`, mọi Task mới mặc định `requiresClientApproval = false`. Người dùng (`Owner`/`Manager`) có thể bấm hoàn tất/duyệt nhanh 1 chạm cho Task hoặc `TaskSection` để chuyển thẳng sang trạng thái hoàn tất (`FINISHED` / `INTERNAL_APPROVED`) và đăng bài/lên lịch đăng ngay.
- **AC7 (Sidebar & Dashboard tinh gọn)**: Trong Workspace `PERSONAL`, Sidebar tự động ẩn các mục dành riêng cho `Client` (`Khách hàng`, `Cổng Khách hàng`, `Yêu cầu nội dung`), và Dashboard hiển thị cụm nút **Khởi tạo nhanh (Quick Launchpad)** thay vì cảnh báo thiếu Gói dịch vụ.
- **AC8 (Hỗ trợ nhóm nhỏ & Nâng cấp lên Agency)**: Người dùng trong Workspace `PERSONAL` vẫn có thể mời bạn cùng nhóm làm `Creator` hoặc bấm chuyển đổi Workspace sang chế độ `"AGENCY"` trong phần Cài đặt mà giữ nguyên 100% dữ liệu.
- **AC9 (Song ngữ VI/EN & Dark/Light Mode)**: Toàn bộ nhãn giao diện mới có đầy đủ khóa dịch tiếng Việt (`vi`) và tiếng Anh (`en`), hiển thị chuẩn trên cả giao diện Sáng/Tối và Mobile/Tablet/Desktop.
