# 10 — Ma Trận Phân Quyền Toàn Hệ Thống (Roles & Permissions Matrix — 141 FRs)

> [<< 09 - Admin Management](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/09-admin-management.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 11 - Data Entities & Glossary >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/11-data-entities-glossary.md)
>
> Tài liệu này đối chiếu chính xác quyền hạn của **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)** trên toàn bộ **141 Yêu cầu Chức năng (`3.2.1` – `3.10.14`)**, đồng thời quy định rõ ma trận quyền trên **Trình soạn chia phần (`TaskSection`)** và **Chế độ Không gian Cá nhân (`workspaceMode = "PERSONAL"`)**.

---

## 1. Quy ước Ký hiệu trong Ma trận

- **`✔`**: Có quyền thực hiện chính thức (được kiểm tra ở cả Backend `@PreAuthorize` / Policy và hiển thị trên UI).
- **`✔ (P)`**: Mở khóa trực tiếp trong chế độ `workspaceMode = "PERSONAL"` (nơi chủ không gian nắm đồng thời vai trò `Owner` và `Manager`).
- **`👁`**: Chỉ có quyền xem (Read-only).
- **`—`**: Không áp dụng / Không có quyền truy cập.

---

## 2. Ma trận Phân quyền trên Toàn bộ 141 FR Chuẩn (`3.2.1` – `3.10.14`)

### 2.1. Nhóm `3.2 Authentication & Authorization` (9 FRs) & `3.3 User & Client Profile` (4 FRs)

| Mã FR | Tên Chức năng Chuẩn | `Guest` | `Owner` | `Manager` | `Creator` | `Client` | `Admin` |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| `3.2.1` | Register Account | ✔ | — | — | — | — | — |
| `3.2.2` | Login | ✔ | — | — | — | — | — |
| `3.2.3` | Social Login (Google) | ✔ | — | — | — | — | — |
| `3.2.4` | Verify Email | ✔ | ✔ | ✔ | ✔ | ✔ | — |
| `3.2.5` | Forgot Password | ✔ | — | — | — | — | — |
| `3.2.6` | Change Password | — | ✔ | ✔ | ✔ | ✔ | ✔ |
| `3.2.7` | Setup Two-Factor Authentication | — | ✔ | ✔ | ✔ | ✔ | ✔ |
| `3.2.8` | Logout | — | ✔ | ✔ | ✔ | ✔ | ✔ |
| `3.2.9` | Delete Account | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.3.1` | View User Profile | — | ✔ | ✔ | ✔ | ✔ | ✔ |
| `3.3.2` | Update User Profile | — | ✔ | ✔ | ✔ | ✔ | ✔ |
| `3.3.3` | View Client Profile | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.3.4` | Update Client Profile | — | ✔ | ✔ | — | ✔ | — |

### 2.2. Nhóm `3.4 Agency & Workspace` (26 FRs)

| Mã FR | Tên Chức năng Chuẩn | `Guest` | `Owner` | `Manager` | `Creator` | `Client` | `Admin` |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| `3.4.1` | Create Agency *(gồm cả Personal Studio Bootstrap)* | — | ✔ | ✔ (Bootstrap) | ✔ (Bootstrap) | — | — |
| `3.4.2` | View Agency List | — | ✔ | ✔ | ✔ | — | — |
| `3.4.3` | View Agency Detail | — | ✔ | ✔ | ✔ | — | — |
| `3.4.4` | Update Agency Profile | — | ✔ | — | — | — | — |
| `3.4.5` | Delete Agency | — | ✔ | — | — | — | — |
| `3.4.6` | View Agency Members | — | ✔ | ✔ | ✔ | — | — |
| `3.4.7` | View Agency Organization Chart | — | ✔ | ✔ | ✔ | — | — |
| `3.4.8` | Invite Agency Member | — | ✔ | — | — | — | — |
| `3.4.9` | Accept Agency Invitation | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.4.10` | Decline Agency Invitation | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.4.11` | Remove Agency Member | — | ✔ | — | — | — | — |
| `3.4.12` | List Workspace | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.4.13` | Create Workspace *(`AGENCY` hoặc `PERSONAL`)* | — | ✔ | — | — | — | — |
| `3.4.14` | View Workspace Dashboard | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.4.15` | Update Workspace *(gồm đổi `workspaceMode`)* | — | ✔ | ✔ | — | — | — |
| `3.4.16` | Delete Workspace | — | ✔ | — | — | — | — |
| `3.4.17` | Archive Workspace | — | ✔ | ✔ | — | — | — |
| `3.4.18` | Restore Workspace | — | ✔ | ✔ | — | — | — |
| `3.4.19` | Save Workspace Template | — | ✔ | ✔ | — | — | — |
| `3.4.20` | View Workspace Templates | — | ✔ | ✔ | — | — | — |
| `3.4.21` | Apply Workspace Template | — | ✔ | ✔ | — | — | — |
| `3.4.22` | Delete Workspace Template | — | ✔ | ✔ | — | — | — |
| `3.4.23` | View Workspace Members | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.4.24` | Add Workspace Member | — | ✔ | ✔ | — | — | — |
| `3.4.25` | Update Workspace Member Role | — | ✔ | ✔ | — | — | — |
| `3.4.26` | Remove Workspace Member | — | ✔ | ✔ | — | — | — |

### 2.3. Nhóm `3.5 Media Package & Media Campaign` (13 FRs)

| Mã FR | Tên Chức năng Chuẩn | `Guest` | `Owner` | `Manager` | `Creator` | `Client` | `Admin` |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| `3.5.1` | Create Media Package | — | ✔ | — | — | — | — |
| `3.5.2` | View Template Media Package | 👁 (`/s/:token`) | ✔ | ✔ | — | ✔ | — |
| `3.5.3` | Request Media Package | — | — | ✔ | — | ✔ | — |
| `3.5.4` | Approve Media Package | — | ✔ | ✔ | — | — | — |
| `3.5.5` | Create Media Campaign | — | ✔ (P) | ✔ | — | — | — |
| `3.5.6` | View Media Campaign | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.5.7` | Update Media Campaign | — | ✔ (P) | ✔ | — | — | — |
| `3.5.8` | Approve Media Campaign *(Deploy)* | — | ✔ (P) | ✔ | — | ✔ | — |
| `3.5.9` | Complete Media Campaign | — | ✔ (P) | ✔ | — | — | — |
| `3.5.10` | Create Content Request | — | — | — | — | ✔ | — |
| `3.5.11` | Track Request Status | — | — | ✔ | — | ✔ | — |
| `3.5.12` | Update Request | — | — | ✔ | — | ✔ | — |
| `3.5.13` | Cancel Request | — | — | — | — | ✔ | — |

### 2.4. Nhóm `3.6 Content & Workflow` (35 FRs)

| Mã FR | Tên Chức năng Chuẩn | `Guest` | `Owner` | `Manager` | `Creator` | `Client` | `Admin` |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| `3.6.1` | View Post List *(8 loại TaskType)* | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.6.2` | View Post Detail *(3-Mode Peek)* | 👁 (`/s/:token`) | ✔ | ✔ | ✔ | ✔ (Chỉ phần `O`) | — |
| `3.6.3` | Create Post *(gồm Standalone Task)* | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.4` | Update Post *(theo quyền `SectionPolicy`)* | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.5` | Delete Post | — | ✔ | ✔ | — | — | — |
| `3.6.6` | Submit Post for Approval | — | — | ✔ | ✔ | — | — |
| `3.6.7` | Approve Post *(gồm `Self-Approve`)* | — | ✔ (P) | ✔ | — | ✔ (Cấp `Client`) | — |
| `3.6.8` | Reject Post *(Return kèm ghi chú)* | — | ✔ (P) | ✔ | — | ✔ (Cấp `Client`) | — |
| `3.6.9` | Approval Sequence | — | ✔ (P) | ✔ | — | ✔ | — |
| `3.6.10` | View Content Calendar | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.6.11` | View Material Library | 👁 (`/s/:token`) | ✔ | ✔ | ✔ | ✔ (`clientVisible`) | — |
| `3.6.12` | Upload Material | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.6.13` | Update Material | — | ✔ | ✔ | ✔ | — | — |
| `3.6.14` | Delete Material | — | ✔ | ✔ | — | — | — |
| `3.6.15` | Connect Google Drive | — | ✔ | ✔ | — | — | — |
| `3.6.16` | Sync Google Drive Folder | — | ✔ | ✔ | — | — | — |
| `3.6.17` | Disconnect Google Drive | — | ✔ | ✔ | — | — | — |
| `3.6.18` | Apply Watermark | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.19` | Download Material | 👁 (`/s/:token`) | ✔ | ✔ | ✔ | ✔ | — |
| `3.6.20` | Create Hashtag Collection | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.21` | View Hashtag Collection | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.6.22` | Update Hashtag Collection | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.23` | Delete Hashtag Collection | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.24` | Apply Hashtags to Post | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.25` | Create Survey Form | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.26` | View Survey Responses *(Guest điền form)* | ✔ (Điền form) | ✔ | ✔ | ✔ | ✔ | — |
| `3.6.27` | Create Online Meeting Link | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.6.28` | Create Mail Template | — | ✔ | ✔ | ✔ | — | — |
| `3.6.29` | View Mail Templates | — | ✔ | ✔ | ✔ | — | — |
| `3.6.30` | Update Mail Template | — | ✔ | ✔ | ✔ | — | — |
| `3.6.31` | Delete Mail Template | — | ✔ | ✔ | — | — | — |
| `3.6.32` | Send Mail from Template *(và Newsletter)* | — | ✔ | ✔ | ✔ (`EMAIL_SEND`) | — | — |
| `3.6.33` | Check Compliance Content | — | ✔ | ✔ | ✔ | — | — |
| `3.6.34` | View Content History | — | ✔ | ✔ | ✔ | — (Ẩn lịch sử nháp) | — |
| `3.6.35` | Chat Realtime | — | ✔ | ✔ | ✔ | ✔ | — |

### 2.5. Nhóm `3.7 AI Features` (19 FRs)

| Mã FR | Tên Chức năng Chuẩn | `Guest` | `Owner` | `Manager` | `Creator` | `Client` | `Admin` |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| `3.7.1` | View Trending Topics Suggestions | — | ✔ | ✔ | ✔ | — | — |
| `3.7.2` | View AI Trend Knowledge Graph | — | ✔ | ✔ | ✔ | — | — |
| `3.7.3` | View Brand Knowledge Documents | — | ✔ | ✔ | ✔ | — | — |
| `3.7.4` | Upload Brand Knowledge Document | — | ✔ | ✔ | ✔ | — | — |
| `3.7.5` | Delete Brand Knowledge Document | — | ✔ | ✔ | — | — | — |
| `3.7.6` | Generate Caption | — | ✔ | ✔ | ✔ | — | — |
| `3.7.7` | Generate Ambassador | — | ✔ | ✔ | ✔ | — | — |
| `3.7.8` | View Image Style Template | — | ✔ | ✔ | ✔ | — | — |
| `3.7.9` | Generate Image | — | ✔ | ✔ | ✔ | — | — |
| `3.7.10` | View Video Style Template | — | ✔ | ✔ | ✔ | — | — |
| `3.7.11` | Generate Video | — | ✔ | ✔ | ✔ | — | — |
| `3.7.12` | Export File | — | ✔ | ✔ | ✔ | — | — |
| `3.7.13` | Crawl Schedule Config | — | — | — | — | — | ✔ |
| `3.7.14` | Suggest Hashtag Trend | — | ✔ | ✔ | ✔ | — | — |
| `3.7.15` | View Collaborator Directory | — | ✔ | ✔ | ✔ | — | — |
| `3.7.16` | Create Collaborator Profile | — | ✔ | ✔ | — | — | — |
| `3.7.17` | Update Collaborator Profile | — | ✔ | ✔ | — | — | — |
| `3.7.18` | Remove Collaborator Profile | — | ✔ | ✔ | — | — | — |
| `3.7.19` | Recommend Collaborator | — | ✔ | ✔ | ✔ | — | — |

### 2.6. Nhóm `3.8 Publishing & Social` (15 FRs)

| Mã FR | Tên Chức năng Chuẩn | `Guest` | `Owner` | `Manager` | `Creator` | `Client` | `Admin` |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| `3.8.1` | Connect Social Account | — | ✔ (P) | ✔ | — | ✔ | — |
| `3.8.2` | Disconnect Account | — | ✔ (P) | ✔ | — | ✔ | — |
| `3.8.3` | View Dashboard Post | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.8.4` | View Posted Detail | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.8.5` | Preview Post | 👁 (`/s/:token`) | ✔ | ✔ | ✔ | ✔ | — |
| `3.8.6` | Schedule Platform Post | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.7` | Track Post Status | — | ✔ | ✔ | ✔ | ✔ | — |
| `3.8.8` | Publish Facebook Post | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.9` | Publish Facebook Reels | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.10` | Publish Facebook Stories | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.11` | Publish Instagram Post | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.12` | Publish Instagram Reels | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.13` | Publish Instagram Stories | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.14` | Publish TikTok Video | — | ✔ (P) | ✔ | ✔ | — | — |
| `3.8.15` | Publish Threads Post | — | ✔ (P) | ✔ | ✔ | — | — |

### 2.7. Nhóm `3.9 Subscription & Billing` (6 FRs) & `3.10 Admin Functions` (14 FRs)

| Mã FR | Tên Chức năng Chuẩn | `Guest` | `Owner` | `Manager` | `Creator` | `Client` | `Admin` |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| `3.9.1` | Upgrade Plan | — | ✔ | 👁 | 👁 | 👁 | — |
| `3.9.2` | Make Payment (SePay) | — | ✔ | — | — | — | — |
| `3.9.3` | View Invoice History | — | ✔ | — | — | — | ✔ |
| `3.9.4` | View AI Credit Tracking | — | ✔ (Toàn Agency) | ✔ (Workspace mình) | ✔ (Workspace mình) | — | — |
| `3.9.5` | Buy Credit | — | ✔ | — | — | — | — |
| `3.9.6` | Set Credit *(Trần `workspaceLimit`)* | — | ✔ | — | — | — | — |
| `3.10.1` | View User List | — | — | — | — | — | ✔ |
| `3.10.2` | View User Detail | — | — | — | — | — | ✔ |
| `3.10.3` | Update User Status | — | — | — | — | — | ✔ |
| `3.10.4` | Content Moderation Queue | — | — | — | — | — | ✔ |
| `3.10.5` | Update User Violation Status | — | — | — | — | — | ✔ |
| `3.10.6` | View Subscription Plan List | — | — | — | — | — | ✔ |
| `3.10.7` | Create Subscription Plan | — | — | — | — | — | ✔ |
| `3.10.8` | Update Subscription Plan | — | — | — | — | — | ✔ |
| `3.10.9` | Delete Subscription Plan | — | — | — | — | — | ✔ |
| `3.10.10` | View AI Credit Price List | — | — | — | — | — | ✔ |
| `3.10.11` | Update AI Credit Price | — | — | — | — | — | ✔ |
| `3.10.12` | Import AI Credit Price CSV | — | — | — | — | — | ✔ |
| `3.10.13` | View Revenue Dashboard | — | — | — | — | — | ✔ |
| `3.10.14` | Export Report File PDF | — | — | — | — | — | ✔ |

---

## 3. Ma trận Phân quyền Chi tiết Cấp Phần Soạn thảo (`SectionPolicy` — 8 Loại `TaskType`)

Bên trong một Công việc (`TaskDocument`), quyền thao tác trên từng phần nội dung (`TaskSection`) được kiểm soát chặt chẽ tại Backend bởi `SectionPolicy.java`:

| Đối tượng trong Công việc | Sửa phần mình sở hữu (`canEdit`) | Sửa các phần khác | Xem phần nội bộ (`I`) | Duyệt / Trả lại phần (`canApprove` / `canReturn`) | Mở lại phần đã duyệt (`canReopen`) | Khôi phục phiên bản cũ (`canRestore`) | Tự duyệt 1 chạm (`Self-Approve` ở chế độ `PERSONAL`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Chủ không gian `PERSONAL` (`Owner` / `Manager`)** | ✔ | ✔ (Mọi phần) | ✔ | ✔ | ✔ | ✔ | **✔ (1 chạm hoàn tất toàn bộ Task & Sections)** |
| **`Manager` của Workspace `AGENCY`** | ✔ | ✔ (Mọi phần trước khi đóng) | ✔ | ✔ (Cấp nội bộ `INTERNAL_APPROVED`) | ✔ | ✔ | ✔ (Chỉ khi `requiresClientApproval = false`) |
| **Điều phối viên (`assigneeId` của Task cha)** | ✔ | ✔ (Mọi phần trước khi nộp) | ✔ | ✖ | ✖ | ✔ | ✖ (Nếu là `Creator` trong `AGENCY`) |
| **Chủ phần (`Creator` nhận Subtask có `subtaskRole`)** | ✔ (Khi phần ở `DRAFT` / `RETURNED`) | ✖ (Chỉ đọc) | ✔ | ✖ | ✖ | ✔ (Khi phần ở `DRAFT` / `RETURNED`) | ✖ |
| **`Supervisor` của Subtask** | Theo vai trò khác | ✖ | ✔ | ✔ (Cấp nội bộ cho phần thuộc Subtask mình giám sát) | ✖ | ✖ | ✖ |
| **`Creator` nhận Subtask tự do (`subtaskRole = null`)** | ✖ | ✖ (Chỉ đọc) | ✔ | ✖ | ✖ | ✖ | ✖ |
| **`Creator` khác trong Workspace (không tham gia Task)** | ✖ | ✖ (Chỉ đọc phần `O`) | **✖ (Ẩn phần `I`)** | ✖ | ✖ | ✖ | ✖ |
| **`Client` (Khách hàng)** | ✖ | ✖ | **✖ (Ẩn hoàn toàn ở Backend)** | ✔ (Cấp `Client`, chỉ phần `O` đã `INTERNAL_APPROVED`) | ✖ | **✖ (Không xem lịch sử nháp)** | ✖ |
