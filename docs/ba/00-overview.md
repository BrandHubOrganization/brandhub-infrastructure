# BrandHub — Tổng quan Nghiệp vụ Hệ thống (BA Overview)

> Tài liệu này là **cổng vào trung tâm (Single Source of Truth)** cho toàn bộ đặc tả nghiệp vụ (Business Analysis — BA) của dự án **BrandHub**.
> Được đồng bộ hóa 100% với **Baseline 141 Yêu cầu Chức năng Nguyên tử (`3.2.1`–`3.10.14`)**, **141 Use Cases (`UC-001`–`UC-141`)**, **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)** theo `AGENTS.md`, và toàn bộ các tính năng chuyên sâu trong `docs/feature/`.

---

## 1. Tầm nhìn Sản phẩm & Hai Chế độ Vận hành (Hybrid B2B Agency & Personal Studio)

**BrandHub** là nền tảng quản trị truyền thông đa kênh và sáng tạo nội dung tích hợp AI (AI-Powered Media & Content Operations Platform). Để phục vụ trọn vẹn cả doanh nghiệp truyền thông lẫn cá nhân làm nội dung, hệ thống vận hành theo **Kiến trúc Lai (Hybrid Architecture)** trên cùng một nền tảng dữ liệu:

| Chế độ Không gian (`workspaceMode`) | Đối tượng mục tiêu | Đặc trưng Quy trình Nghiệp vụ |
| :--- | :--- | :--- |
| **`AGENCY` (Chế độ Công ty Truyền thông — B2B)** | Các Agency truyền thông/marketing, doanh nghiệp quản lý nhiều thương hiệu khách hàng (`Client`), đội ngũ phân tầng chuyên môn hóa. | Quy trình hợp đồng 3 bước chặt chẽ: **`1. Gói dịch vụ (Media Package) → 2. Chiến dịch (Media Campaign) → 3. Công việc (Task & Role Subtask)`**. Có Cổng Khách hàng (`Client Portal`), luồng yêu cầu nội dung (`Content Request`) và phê duyệt 2 cấp (`Manager/Supervisor → Client`). |
| **`PERSONAL` (Chế độ Không gian Cá nhân & Nhóm nhỏ — Solo / Study Group)** | Nhà sáng tạo nội dung độc lập (Solo Creator), Freelancer, Sinh viên làm đồ án/bài tập nhóm ngành Truyền thông/Marketing, Chủ shop/thương hiệu cá nhân. | Khởi tạo 1 chạm (**Personal Studio Bootstrap**). **Bỏ qua bước Gói dịch vụ (`Media Package`) và không cần `Client`**. Cho phép lập **Chiến dịch cá nhân tự do** hoặc **Tạo trực tiếp Công việc độc lập (8 loại Task)**, hỗ trợ **Tự duyệt 1 chạm (`Self-Approve`)** để đăng bài/gửi bản tin/xuất file ngay, vẫn mời được bạn cùng nhóm làm `Creator` và có thể nâng cấp (`Scale-up`) lên chế độ `AGENCY` bất kỳ lúc nào mà giữ nguyên 100% dữ liệu. |

---

## 2. 6 Vai trò Hệ thống Chuẩn (Canonical System Roles)

Toàn bộ mã nguồn, API, cơ sở dữ liệu, biểu đồ UML và tài liệu báo cáo bắt buộc sử dụng **đúng 6 tên Role chuẩn** dưới đây (tuyệt đối không dùng tên thừa hoặc tự đặt tên role mới):

| Role chuẩn | Enum Code | Phạm vi | Trách nhiệm cốt lõi |
| :--- | :--- | :--- | :--- |
| **`Guest`** | `GUEST` | Công khai (Unauthenticated) | Xem trang chủ, đăng ký tài khoản, đăng nhập, quên mật khẩu, và xem các trang chia sẻ công khai qua `ShareLink` (`/s/:token` cho Gói dịch vụ, Bài đăng, Tài liệu, Khảo sát). |
| **`Owner`** | `OWNER` | Cấp `Agency` (bao gồm cả `Personal Hub`) | Sở hữu `Agency` hoặc `Personal Studio`. Quản lý hồ sơ công ty, nhân sự, mẫu email, gói cước (`Subscription`), ví AI Credit tổng (`Agency Wallet`), phân bổ trần AI Credit cho từng `Workspace` (`workspaceLimit`), tạo `Workspace` và cấu hình gói truyền thông mẫu. |
| **`Manager`** | `MANAGER` | Cấp `Workspace` | Quản lý toàn diện một `Workspace`: chốt Gói dịch vụ & Chiến dịch, quản lý thành viên Workspace, tạo/phân công Công việc & Subtask theo vai trò, duyệt nội bộ (`INTERNAL_APPROVED`), tự duyệt 1 chạm (`Self-Approve` ở chế độ `PERSONAL`), kết nối MXH và quản lý thư viện/bản tin. |
| **`Creator`** | `CREATOR` | Cấp `Workspace` | Thực thi sáng tạo nội dung trên **8 loại Công việc** và các phần chuyên môn (`TaskSection`), sử dụng bộ công cụ AI Studio (Caption, Image, Video, Ambassador, Trend, Brand Knowledge), nộp duyệt phần công việc và xuất bản nội dung. |
| **`Client`** | `CLIENT` | Cấp `Workspace` (Chỉ ở chế độ `AGENCY`) | Đại diện thương hiệu khách hàng trong mô hình B2B: xem tiến độ chiến dịch trên `Client Portal`, gửi `Content Request`, kết nối tài khoản MXH của thương hiệu, và phê duyệt/trả lại các phần đầu ra (`OUTPUT` sections → `CLIENT_APPROVED`). |
| **`Admin`** | `ADMIN` | Toàn hệ thống (Platform) | Quản trị người dùng, kiểm duyệt nội dung vi phạm (`Content Moderation Queue`), cấu hình bảng giá AI Credit & gói cước, quản lý nguồn cào xu hướng đa nền tảng (`Trend Crawler Pipeline`), giám sát sức khỏe máy chủ và báo cáo doanh thu SePay. |

---

## 3. Cấu trúc Phân cấp & Bản đồ 141 Yêu cầu Chức năng (141 Atomic CRUD FRs)

Hệ thống gồm chính xác **141 Functional Requirements (`3.2.1`–`3.10.14`)** tương ứng 1-đối-1 với **141 Use Cases (`UC-001`–`UC-141`)** chia thành **9 miền nghiệp vụ (Functional Domains)**:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         NỀN TẢNG BRANDHUB (ADMIN)                            │
│    9. Admin Functions (3.10.1–3.10.14 | 14 FRs): Users, Moderation,          │
│       Subscriptions, AI Credit Pricing, Crawler Pipeline, Revenue Reports    │
└──────────────────────────────────────┬───────────────────────────────────────┘
                                       │
          ┌────────────────────────────┴────────────────────────────┐
          ▼                                                         ▼
┌─────────────────────────────────────────┐       ┌─────────────────────────────────────────┐
│        AGENCY B2B (CÔNG TY)             │       │    PERSONAL HUB (STUDIO CÁ NHÂN)        │
│  Owner quản lý Agency, Nhân sự,         │       │  Tự động khởi tạo 1 chạm cho mỗi User   │
│  Ví AI Credit tổng, Gói cước (3.9.1-6)  │       │  Có sẵn Ví AI Credit & Gói Basic        │
└────────────────────┬────────────────────┘       └────────────────────┬────────────────────┘
                     │                                                 │
                     ▼                                                 ▼
┌─────────────────────────────────────────┐       ┌─────────────────────────────────────────┐
│   WORKSPACE [workspaceMode = AGENCY]    │       │  WORKSPACE [workspaceMode = PERSONAL]   │
│  1. Gói dịch vụ (3.5.1–3.5.4)           │◄─────►│  • Không cần Gói dịch vụ / Client       │
│  2. Chiến dịch (3.5.5–3.5.9)            │ Scale │  • Chiến dịch cá nhân tự do             │
│  3. Yêu cầu nội dung (3.5.10–3.5.13)    │  Up   │  • Tạo Task độc lập 8 loại (1 chạm)     │
│  4. Công việc & Duyệt 2 cấp (3.6.1–35)  │       │  • Tự duyệt 1 chạm (Self-Approve)       │
│  5. AI Studio & MXH (3.7.1–19, 3.8.1–15)│       │  • Hỗ trợ mời bạn cùng nhóm (Creator)   │
└─────────────────────────────────────────┘       └─────────────────────────────────────────┘
```

### Bảng Tổng hợp 9 Miền Nghiệp vụ & Dẫn chiếu Tài liệu BA

| STT | Mục SRS | Tên Miền Nghiệp vụ (Domain) | Dãy mã FR | Số lượng FR | Dãy mã UC | File Tài liệu BA Chi tiết |
| :-: | :-: | :--- | :-: | :-: | :-: | :--- |
| — | — | Cấu trúc Tổ chức & Kiến trúc Hybrid (`AGENCY` vs `PERSONAL`) | — | — | — | [01-organization-structure.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/01-organization-structure.md) |
| 1 | `3.2` | **Authentication & Authorization** *(Xác thực & Phân quyền)* | `3.2.1` – `3.2.9` | **9** | `UC-001` – `UC-009` | [02-authentication-profile.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/02-authentication-profile.md) |
| 2 | `3.3` | **User & Client Profile** *(Hồ sơ Cá nhân & Khách hàng)* | `3.3.1` – `3.3.4` | **4** | `UC-010` – `UC-013` | [02-authentication-profile.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/02-authentication-profile.md) |
| 3 | `3.4` | **Agency & Workspace** *(Công ty, Không gian làm việc & Personal Studio)* | `3.4.1` – `3.4.26` | **26** | `UC-014` – `UC-039` | [03-agency-workspace-management.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/03-agency-workspace-management.md) |
| 4 | `3.5` | **Media Package & Media Campaign** *(Gói truyền thông, Chiến dịch & Yêu cầu)* | `3.5.1` – `3.5.13` | **13** | `UC-040` – `UC-052` | [04-media-package-campaign.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/04-media-package-campaign.md) |
| 5 | `3.6` | **Content & Workflow** *(8 loại Công việc, Subtask theo vai trò, Duyệt theo phần, Tư liệu, Mail, Chat)* | `3.6.1` – `3.6.35` | **35** | `UC-053` – `UC-087` | [05-content-task-workflow.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/05-content-task-workflow.md) |
| 6 | `3.7` | **AI Features** *(Xu hướng, Đồ thị tri thức, RAG Thương hiệu, Sinh Caption/Ảnh/Video/Đại sứ, Danh bạ KOL)* | `3.7.1` – `3.7.19` | **19** | `UC-088` – `UC-106` | [06-ai-features.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/06-ai-features.md) |
| 7 | `3.8` | **Publishing & Social** *(Kết nối MXH, Lên lịch & Xuất bản 4 nền tảng: FB, IG, TikTok, Threads)* | `3.8.1` – `3.8.15` | **15** | `UC-107` – `UC-121` | [07-publishing-social-collaborator.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/07-publishing-social-collaborator.md) |
| 8 | `3.9` | **Subscription & Billing** *(Nâng cấp gói, Thanh toán SePay/PayOS VietQR, Ví AI Credit & Trần Workspace)* | `3.9.1` – `3.9.6` | **6** | `UC-122` – `UC-127` | [08-subscription-billing.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/08-subscription-billing.md) |
| 9 | `3.10` | **Admin Functions** *(Quản trị người dùng, Kiểm duyệt, Gói cước, Giá AI Credit, Crawler, Doanh thu)* | `3.10.1` – `3.10.14` | **14** | `UC-128` – `UC-141` | [09-admin-management.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/09-admin-management.md) |
| **Tổng** | | **9 Miền Nghiệp vụ Chuẩn** | **`3.2.1` – `3.10.14`** | **141** | **`UC-001` – `UC-141`** | |

### Các Tài liệu Tham chiếu Chéo (Cross-Cutting BA References)
- [10-roles-permissions-matrix.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/10-roles-permissions-matrix.md) — Ma trận phân quyền chi tiết cho 6 Role chuẩn trên toàn bộ 141 FR và 2 chế độ `AGENCY` / `PERSONAL`.
- [11-data-entities-glossary.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/11-data-entities-glossary.md) — Từ điển thực thể dữ liệu (PostgreSQL, MongoDB, Neo4j, Redis) và quan hệ khóa ngoại.
- [12-state-machines.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/12-state-machines.md) — Toàn bộ máy trạng thái (State Machines) của Gói dịch vụ, Chiến dịch, Công việc, Phần soạn thảo (`TaskSection`), Bài đăng MXH, Gói cước và Kiểm duyệt.
- [use-cases/00-index.md](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/use-cases/00-index.md) — Danh mục Use Cases chi tiết.

---

## 4. 8 Loại Công việc Chuẩn (`TaskType`) & Kiến trúc Trình soạn Chia phần (`TaskSection`)

Mọi công việc trong hệ thống (dù tạo từ Chiến dịch Agency, Chiến dịch Cá nhân hay Tạo độc lập `Standalone Task`) đều thuộc **1 trong 8 loại `TaskType` chuẩn** dưới đây:

1. **`POST`** — Bài đăng mạng xã hội (5 vai trò subtask / 4 phần: `POST.BRIEF`, `POST.CAPTION`, `POST.MEDIA`, `POST.CHANNELS`).
2. **`SHORT_VIDEO`** — Video ngắn TikTok / Reels (4 vai trò subtask / 5 phần: `VIDEO.SCRIPT`, `VIDEO.SHOOT`, `VIDEO.EDIT`, `VIDEO.CAPTION`, `VIDEO.CHANNELS`).
3. **`SURVEY`** — Biểu mẫu khảo sát trực tuyến (3 vai trò subtask / 3 phần: `SURVEY.FORM`, `SURVEY.DISTRIBUTION`, `SURVEY.REPORT`).
4. **`EVENT_PLAN`** — Kế hoạch tổ chức sự kiện (5 vai trò subtask / 5 phần: `EVENT.AGENDA`, `EVENT.LOGISTICS`, `EVENT.PROMOTION`, `EVENT.RUNSHEET`, `EVENT.REPORT`).
5. **`PRESS_RECOMMENDATION`** — Thông cáo báo chí & PR (4 vai trò subtask / 4 phần: `PRESS.MEDIA_LIST`, `PRESS.RELEASE`, `PRESS.CONTACT_LOG`, `PRESS.COVERAGE`).
6. **`KOL_BOOKING`** — Quản lý KOL / Influencer (5 vai trò subtask / 5 phần: `KOL.SHORTLIST`, `KOL.DEAL`, `KOL.BRIEF`, `KOL.DRAFT`, `KOL.REPORT`).
7. **`WORKSHOP`** — Tổ chức Hội thảo / Workshop (5 vai trò subtask / 5 phần: `WORKSHOP.PROGRAM`, `WORKSHOP.SPEAKERS`, `WORKSHOP.LOGISTICS`, `WORKSHOP.REGISTRATION`, `WORKSHOP.REPORT`).
8. **`EMAIL_NEWSLETTER`** — Bản tin Email gửi thật (4 vai trò subtask / 4 phần: `EMAIL.CONTENT`, `EMAIL.DESIGN`, `EMAIL.AUDIENCE`, `EMAIL.REPORT`).

---

## 5. Các Ràng buộc & Tính năng Đã Loại bỏ Khỏi Phạm vi (Strict Exclusions — `AGENTS.md`)

Để đảm bảo tính nhất quán tuyệt đối trên toàn dự án, các mục dưới đây **đã bị loại bỏ khỏi phạm vi (De-scoped)** và tuyệt đối không được đưa lại vào code hay tài liệu:
1. **Không có Livestream**: Không có loại công việc `LIVESTREAM`, không có kịch bản Livestream AI hay phiên phát trực tiếp.
2. **Không có Hạ cấp Gói cước (`Downgrade Plan`)**: Chỉ hỗ trợ nâng cấp/gia hạn gói (`3.9.1 Upgrade Plan`).
3. **Không có Kiểm tra Đạo văn / Bản quyền (`Copyright / Plagiarism Check`)**: Chỉ giữ kiểm tra tuân thủ tiêu chuẩn cộng đồng/ngôn từ (`3.6.33 Check Compliance Content`) và hàng đợi kiểm duyệt của Admin (`3.10.4 Content Moderation Queue`).
4. **Chỉ hỗ trợ đúng 4 nền tảng Mạng xã hội**: **Facebook, Instagram, TikTok, và Threads** (không hỗ trợ Zalo OA).
5. **Chỉ sử dụng cổng thanh toán SePay / PayOS (VietQR)**: Không sử dụng VNPay hay Stripe.
6. **Quy tắc "Zero Manage"**: Không bao giờ đặt tên FR hoặc Use Case bằng động từ mơ hồ `"Manage ..."` hay `"... Management"`.
