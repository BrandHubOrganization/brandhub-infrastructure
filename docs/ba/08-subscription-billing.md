# 08 — Gói Cước, Thanh Toán SePay (VietQR) & Quản Trị Ví AI Credit (Subscription, Billing & AI Credit)

> [<< 07 - Publishing & Social](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/07-publishing-social-collaborator.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md) | [Tiếp: 09 - Admin Management >>](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/09-admin-management.md)
>
> **Phạm vi FR chuẩn**: **Mục `3.9 Subscription & Billing` — 6 FR (`3.9.1` – `3.9.6`)** | `UC-122` – `UC-127`.
> Tuân thủ tuyệt đối `AGENTS.md` (**Không có Downgrade Plan**, **Chỉ dùng cổng thanh toán SePay / PayOS VietQR**) và kiến trúc hợp nhất **Ví AI Credit cấp Agency + Trần Ngân sách cấp Workspace (`workspace-credit-unification`)**.

---

## 1. Bảng Tổng hợp 6 Yêu cầu Chức năng Chuẩn (`3.9.1` – `3.9.6`)

| Mã FR | Mã UC | Tên Chức năng Chuẩn (Atomic CRUD FR) | Actors / Roles Chuẩn | Mô tả Nghiệp vụ Cốt lõi |
| :-: | :-: | :--- | :--- | :--- |
| **`3.9.1`** | `UC-122` | **Upgrade Plan** | `Owner`, `Manager`, `Creator`, `Client` | Xem bảng so sánh các gói dịch vụ (`Basic`, `Plus` / `Pro`, `Enterprise`) và khởi tạo đơn nâng cấp hoặc gia hạn gói cước cho `Agency` / `Personal Hub`. |
| **`3.9.2`** | `UC-123` | **Make Payment (SePay)** | `Owner` | Thực hiện thanh toán đơn hàng nâng cấp gói cước hoặc mua gói thông qua mã **VietQR động (SePay / PayOS)**; hệ thống đối soát tự động qua Webhook và kích hoạt quyền lợi tức thì. |
| **`3.9.3`** | `UC-124` | **View Invoice History** | `Owner`, `Admin` | Xem danh sách lịch sử hóa đơn và giao dịch thanh toán (`PENDING`, `PAID`, `EXPIRED`, `CANCELLED`), xem chi tiết và xuất chứng từ hóa đơn. |
| **`3.9.4`** | `UC-125` | **View AI Credit Tracking** | `Owner`, `Manager`, `Creator` | Theo dõi số dư ví AI Credit của `Agency`, mức tiêu thụ và phần đang tạm giữ (`workspaceUsed` + `workspaceHeld`) của từng `Workspace`, cùng lịch sử giao dịch chi tiết theo từng tác vụ AI. |
| **`3.9.5`** | `UC-126` | **Buy Credit** | `Owner` | Mua bổ sung gói AI Credit (credit mua thêm không bị hết hạn cuối chu kỳ) thông qua luồng thanh toán SePay / PayOS. |
| **`3.9.6`** | `UC-127` | **Set Credit** | `Owner` | Thiết lập, điều chỉnh hoặc gỡ bỏ **trần ngân sách AI Credit cho từng Workspace (`workspaceLimit`)** thuộc `Agency` (`PUT /api/v1/agencies/{agencyId}/credit/workspaces/{workspaceId}/limit`). |

---

## 2. Cơ cấu Gói Cước (`Subscription Plans`) & Quyền lợi Định mức

Hệ thống cung cấp 3 hạng gói cước chuẩn áp dụng chung cho cả `Agency` B2B và `Personal Hub` cá nhân:

| Quyền lợi / Định mức | **`Basic` (Gói Mặc định / Miễn phí)** | **`Plus` / `Pro` (Gói Chuyên nghiệp)** | **`Enterprise` (Gói Doanh nghiệp / Quy mô lớn)** |
| :--- | :---: | :---: | :---: |
| **Cách kích hoạt** | Tự động cấp ngay khi tạo `Agency` hoặc `Personal Studio` | Nâng cấp/Gia hạn qua SePay (`3.9.1`, `3.9.2`) | Nâng cấp/Gia hạn qua SePay (`3.9.1`, `3.9.2`) |
| **Định mức AI Credit cấp theo chu kỳ (`Plan Credit`)** | Theo cấu hình gói của `Admin` (`3.10.7`) | Theo cấu hình gói của `Admin` + ưu đãi giao diện `Plus` (`agency-plus-style`) | Định mức cao nhất theo cấu hình của `Admin` |
| **Định mức Gửi Email Newsletter (`newsletter.quota.*`)** | **1.000 email / tháng / agency** | **10.000 email / tháng / agency** | **50.000 email / tháng / agency** |
| **Hỗ trợ Nâng cấp & Gia hạn (`Renewal`)** | Có thể nâng cấp lên `Plus` hoặc `Enterprise` bất kỳ lúc nào | Hỗ trợ gia hạn sớm (`agency-plus-renewal`) hoặc nâng cấp lên `Enterprise` | Hỗ trợ gia hạn theo chu kỳ tháng/năm |

> **Quy tắc bất biến theo `AGENTS.md`**: Hệ thống **không có chức năng Hạ cấp gói (`Downgrade Plan`)**.

---

## 3. Luồng Thanh Toán Tự Động Qua SePay / PayOS (VietQR — `3.9.1`..`3.9.3`)

```
[Owner chọn Nâng cấp gói (3.9.1) hoặc Mua thêm Credit (3.9.5)]
       │
       ▼
[Backend tạo Order + Invoice (status = PENDING) kèm mã tham chiếu thanh toán duy nhất]
       │
       ▼
[Frontend hiển thị mã VietQR động (Số tài khoản, Ngân hàng, Số tiền chính xác, Nội dung chuyển khoản)]
       │
       ├──(Người dùng quét QR trên App Ngân hàng)──▶ [Cổng SePay / PayOS nhận biến động số dư]
       │                                                       │
       │                                                       ▼
       │                                    [Webhook gọi về Backend (xác thực chữ ký & chống trùng lặp Idempotent)]
       │                                                       │
       ▼                                                       ▼
[Trạng thái Invoice chuyển sang PAID] ──▶ [Cấp gói Subscription mới + Ghi nhận Plan Credit / Purchased Credit vào Ví Agency]
```

- **Chống ghi nhận trùng (`Idempotency`)**: Một giao dịch thanh toán hoặc callback Webhook từ SePay bị gửi lặp nhiều lần tuyệt đối không bao giờ cộng tiền hay kích hoạt gói 2 lần.
- **Lịch sử Hóa đơn (`3.9.3 View Invoice History`)**:
  - `Owner` xem toàn bộ hóa đơn của `Agency` / `Personal Hub` mình sở hữu tại `/agency/billing`.
  - `Admin` xem và đối soát toàn bộ hóa đơn trên toàn hệ thống kèm thống kê doanh thu tại `/admin/revenue`.

---

## 4. Kiến trúc Hợp nhất Ví AI Credit & Trần Ngân sách Workspace (`3.9.4` – `3.9.6`)

Theo đặc tả chuẩn đã chốt tại `docs/feature/workspace-credit-unification/spec.md`:

### 4.1. Một Ví Tổng cấp Agency (`Single Agency Wallet`) & Hai Nguồn Credit
- Mỗi `Agency` (bao gồm cả `Personal Hub`) có **duy nhất 1 ví `agency_credit_wallets`** là nguồn tiền thực tế cho mọi Workspace trực thuộc.
- Trong ví chia làm 2 lớp số dư (`Credit Grants`):
  1. **`Plan Credit` (Credit định kỳ theo gói)**: Được cấp khi kích hoạt/gia hạn gói cước và làm mới theo chu kỳ gói.
  2. **`Purchased Credit` (Credit mua thêm — Non-expiring)**: Không bị hết hạn khi kết thúc chu kỳ gói; ngay cả khi gói trả phí đã hết hạn, người dùng vẫn được phép tiêu số `Purchased Credit` còn lại.
- **Thứ tự ưu tiên khấu trừ**: Hệ thống luôn trừ **`Plan Credit` trước**, khi hết `Plan Credit` mới trừ sang **`Purchased Credit`**.

### 4.2. Trần Ngân sách cấp Workspace (`Workspace Credit Cap` — `3.9.6 Set Credit`)
- Hệ thống **đã bãi bỏ hoàn toàn hạn mức cá nhân theo từng thành viên** (các lệnh ghi hạn mức cá nhân cũ trả mã `410 Gone — CREDIT_PERSONAL_LIMIT_RETIRED`).
- Thay vào đó, `Owner` kiểm soát ngân sách theo từng **`Workspace`** (`PUT /api/v1/agencies/{agencyId}/credit/workspaces/{workspaceId}/limit` với `{ cap: number | null, expectedRevision: number }`):
  - **`cap = null` (Không giới hạn riêng — Unlimited)**: Workspace được phép sử dụng tự do miễn là ví tổng của Agency còn số dư khả dụng.
  - **`cap = N` (`N > 0`)**: Tổng lượng credit đã dùng (`workspaceUsed`) cộng lượng đang tạm giữ (`workspaceHeld`) của mọi thành viên (`Owner`, `Manager`, `Creator`) trong Workspace đó trong chu kỳ hiện tại không được vượt quá `N`.
  - **`cap = 0`**: Khóa hoàn toàn các tác vụ AI tính phí trong Workspace đó (các tác vụ AI miễn phí vẫn hoạt động bình thường).
- **Phân quyền hiển thị**:
  - `Owner` xem và chỉnh sửa được hạn mức của tất cả các Workspace trong Agency.
  - `Manager` và `Creator` chỉ xem được hạn mức và mức sử dụng (`workspaceLimit`, `workspaceUsed`, `workspaceHeld`) của chính các Workspace mà họ đang tham gia, không lộ số dư riêng tư của các Workspace khác.

### 4.3. Quy trình Tạm giữ & Quyết toán Nguyên tử (`Reserve → Settle / Release`)
1. **Kiểm tra bảng giá cố định của Admin**:
   - Chỉ đúng **4 nhóm tác vụ** sử dụng bảng giá của Admin (`3.10.10`–`3.10.12`):
     1. `CONTENT_GENERATE` (Sinh bài viết / caption mới — `3.7.6`)
     2. `AMBASSADOR_GENERATE` (Sinh đại sứ thương hiệu — `3.7.7`)
     3. `COMMERCIAL_IMAGE` (Sinh ảnh thương mại — `3.7.9`)
     4. `VIDEO_GENERATE` (Sinh video AI — `3.7.11`)
   - Các tác vụ `CAPTION_VARIANTS` (tinh chỉnh biến thể), `HASHTAG_GENERATE` (`3.7.14`), `CHARACTER_SHEET` luôn miễn phí (`unit_credits = 0`, `rate_version = FREE_V1`).
2. **Tạm giữ (`Reserve / HOLD`)**: Trước khi gọi sang nhà cung cấp AI (không bao giờ gọi HTTP bên ngoài bên trong transaction tài chính), hệ thống khóa ví Agency và kiểm tra đồng thời số dư khả dụng của Agency và trần của Workspace, sau đó tạo bản ghi tạm giữ.
3. **Quyết toán (`Settle / Release`)**: Khi AI trả kết quả thành công, hệ thống chốt trừ credit (`SETTLE`); nếu AI thất bại, hệ thống giải phóng khoản tạm giữ (`RELEASE`) để người dùng không bao giờ bị mất oan credit.
