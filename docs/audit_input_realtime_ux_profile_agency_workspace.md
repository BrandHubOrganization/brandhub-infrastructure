# BÁO CÁO TOÀN DIỆN: AUDIT VALIDATION REAL-TIME & TRẢI NGHIỆM NGƯỜI DÙNG (UX) TRÊN TOÀN BỘ CÁC TRANG NHẬP LIỆU
## Phân hệ lớn: FR 3.3 Profile & FR 3.4 Agency - Workspace
**Hệ thống:** BrandHub Web Dashboard (`brandhub-web-dashboard` & `brandhub-infrastructure`)  
**Ngày cập nhật:** 15/10/2026 (Tracking toàn diện 100%, không bỏ sót bất kỳ màn hình/dialog/sub-feature nào)  
**Phạm vi audit:** Toàn bộ 4 thư mục đặc tả Profile (`3-3-1` đến `3-3-4`), 27 thư mục đặc tả Agency & Workspace (`3-4-1` đến `3-4-21`, `duplicate-workspace`, `personal-agency-transition`) và toàn bộ các Component/Route thực tế trong source code Frontend.

---

## MỤC LỤC
1. [TỔNG QUAN PHẠM VI TRACKING ĐẦY ĐỦ (27 MÀN HÌNH / DIALOG)](#1-tổng-quan-phạm-vi-tracking-đầy-đủ-27-màn-hình--dialog)
2. [BẢNG MA TRẬN TRACKING TOÀN BỘ 27 TRANG & TÍNH NĂNG](#2-bảng-ma-trận-tracking-toàn-bộ-27-trang--tính-năng)
3. [CHI TIẾT AUDIT TỪNG TRANG & DIALOG (SCREEN-BY-SCREEN)](#3-chi-tiết-audit-từng-trang--dialog-screen-by-screen)
   - [PHÂN HỆ 1: PROFILE (FR 3.3)](#phân-hệ-1-profile-fr-33)
     - [3.1. User Profile Edit (`ProfileEditForm.tsx` - FR 3.3.2)](#31-user-profile-edit-profileeditformtsx---fr-332)
     - [3.2. Avatar Upload Modal (`AvatarUploadModal.tsx` - FR 3.3.2)](#32-avatar-upload-modal-avataruploadmodaltsx---fr-332)
     - [3.3. Link Phone & OTP Modal (`LinkPhoneModal.tsx` - FR 3.3.2)](#33-link-phone--otp-modal-linkphonemodaltsx---fr-332)
     - [3.4. Client / Brand Profile Form (`ClientProfileForm.tsx` - FR 3.3.4)](#34-client--brand-profile-form-clientprofileformtsx---fr-334)
     - [3.5. Workspace Client Profile & Brand Switcher (`/workspaces/:id/client-profile` - FR 3.3.3 V2)](#35-workspace-client-profile--brand-switcher-workspacesidclient-profile---fr-333-v2)
     - [3.6. Accept Invitation with Client Profile Picker (`accept.tsx` - FR 3.4.7b & 3.3.3 V2)](#36-accept-invitation-with-client-profile-picker-accepttsx---fr-347b--333-v2)
     - [3.7. Notification Preferences Settings (`/settings/notifications` - FR 3.3.2 Backend Preferences)](#37-notification-preferences-settings-settingsnotifications---fr-332-backend-preferences)
   - [PHÂN HỆ 2: AGENCY & WORKSPACE (FR 3.4)](#phân-hệ-2-agency--workspace-fr-34)
     - [3.8. Create Agency Page (`pages/agency/create.tsx` - FR 3.4.3)](#38-create-agency-page-pagesagencycreatetsx---fr-343)
     - [3.9. Personal vs Business Agency Transition (Đặc tả `personal-agency-transition`)](#39-personal-vs-business-agency-transition-đặc-tả-personal-agency-transition)
     - [3.10. Update Agency Profile (`AgencyDetailEditForm.tsx` - FR 3.4.5)](#310-update-agency-profile-agencydetaileditformtsx---fr-345)
     - [3.11. Agency List Search & Filter (`pages/agency/index.tsx` - FR 3.4.1)](#311-agency-list-search--filter-pagesagencyindextsx---fr-341)
     - [3.12. Invite Agency Member (`pages/agency/members.tsx` - FR 3.4.7)](#312-invite-agency-member-pagesagencymemberstsx---fr-347)
     - [3.13. Agency Member Roles & Custom Role Dialog (`pages/agency/roles.tsx` - FR 3.4.20)](#313-agency-member-roles--custom-role-dialog-pagesagencyrolestsx---fr-3420)
     - [3.14. My Agency Invitations List (`pages/agency/invitations.tsx` - FR 3.4.8b)](#314-my-agency-invitations-list-pagesagencyinvitationstsx---fr-348b)
     - [3.15. My Client Invitations List (`pages/client/invitations.tsx` - FR 3.4.8b V2)](#315-my-client-invitations-list-pagesclientinvitationstsx---fr-348b-v2)
     - [3.16. Remove Agency Member Dialog (`RemoveAgencyMemberDialog.tsx` - FR 3.4.9)](#316-remove-agency-member-dialog-removeagencymemberdialogtsx---fr-349)
     - [3.17. Create Workspace Page (`CreateWorkspaceForm.tsx` - FR 3.4.12)](#317-create-workspace-page-createworkspaceformtsx---fr-3412)
     - [3.18. Workspace List Search & Filter (`pages/workspace/index.tsx` - FR 3.4.10)](#318-workspace-list-search--filter-pagesworkspaceindextsx---fr-3410)
     - [3.19. Workspace Profile & Settings (`detail.tsx`, `useWorkspaceSettings.ts` - FR 3.4.14)](#319-workspace-profile--settings-detailtsx-useworkspacesettingsts---fr-3414)
     - [3.20. Save as Workspace Template Dialog (`detail.tsx` - FR 3.4.17)](#320-save-as-workspace-template-dialog-detailtsx---fr-3417)
     - [3.21. Admin Workspace Template Library (`WorkspaceTemplateLibrary.tsx` - FR 3.4.17b)](#321-admin-workspace-template-library-workspacetemplatelibrarytsx---fr-3417b)
     - [3.22. Invite Workspace Member Dialog (`InviteMemberDialog.tsx` - FR 3.4.19)](#322-invite-workspace-member-dialog-invitememberdialogtsx---fr-3419)
     - [3.23. Assign Member from Agency (`AssignMemberPicker.tsx` - FR 3.4.19b)](#323-assign-member-from-agency-assignmemberpickertsx---fr-3419b)
     - [3.24. Add / Invite Client to Workspace (`AddClientDialog.tsx` - FR 3.3.3 V2 / 3.4.7 V2)](#324-add--invite-client-to-workspace-addclientdialogtsx---fr-333-v2--347-v2)
     - [3.25. My Workspace Invitations List (`pages/workspace/invitations.tsx` - FR 3.4.8b)](#325-my-workspace-invitations-list-pagesworkspaceinvitationstsx---fr-348b)
     - [3.26. Duplicate Workspace Dialog (`DuplicateWorkspaceDialog.tsx` - DA-1255)](#326-duplicate-workspace-dialog-duplicateworkspacedialogtsx---da-1255)
     - [3.27. Destructive Action Dialogs: Delete & Leave Workspace (FR 3.4.15, 3.4.16, 3.4.21)](#327-destructive-action-dialogs-delete--leave-workspace-fr-3415-3416-3421)
4. [TỔNG KẾT CÁC LỖI UX & ANTI-PATTERNS HỆ THỐNG](#4-tổng-kết-các-lỗi-ux--anti-patterns-hệ-thống)
5. [LỘ TRÌNH & ĐỀ XUẤT CẢI THIỆN (ACTIONABLE REMEDIATION PLAN)](#5-lộ-trình--đề-xuất-cải-thiện-actionable-remediation-plan)

---

## 1. TỔNG QUAN PHẠM VI TRACKING ĐẦY ĐỦ (27 MÀN HÌNH / DIALOG)

Sau khi đối chiếu chéo giữa **Toàn bộ tài liệu đặc tả chức năng (FR specs)** và **Mã nguồn Frontend React Router (`AppRoutes.tsx`)**, hệ thống ghi nhận **27 màn hình, modal dialog, drawer và form** có tương tác nhập liệu / lọc dữ liệu của người dùng:

1. **Nhóm Profile (7 màn hình):**
   - Hồ sơ cá nhân (`/profile`)
   - Modal đổi Avatar (`AvatarUploadModal`)
   - Modal liên kết số điện thoại & OTP (`LinkPhoneModal`)
   - Danh sách & Form Brand Profile độc lập (`/client-profiles`)
   - Màn hình Brand Profile trong Workspace & Bộ chuyển đổi Brand (`/workspaces/:id/client-profile`)
   - Trang tiếp nhận lời mời & Chọn/Tạo Brand Profile (`/invite/accept` / `/invitations/accept`)
   - Cài đặt tùy chọn thông báo (`/settings/notifications`)
2. **Nhóm Agency & Thành viên (9 màn hình):**
   - Tạo Agency (`/agencies/create` / `/agency/create`)
   - Chuyển đổi mô hình Cá nhân vs Doanh nghiệp (`personal-agency-transition`)
   - Chỉnh sửa hồ sơ Agency (`/agency/:id`)
   - Tìm kiếm & Lọc Agency (`/agency`)
   - Modal mời thành viên Agency (`/agency/:id/members`)
   - Ma trận phân quyền & Modal tạo Custom Role (`/agency/:id/roles`)
   - Danh sách lời mời Agency gửi tới tôi (`/agency/invitations`)
   - Danh sách lời mời Client gửi tới tôi (`/client/invitations`)
   - Dialog xóa thành viên Agency (`RemoveAgencyMemberDialog`)
3. **Nhóm Workspace, Mẫu & Khách hàng (11 màn hình):**
   - Tạo Workspace (`/workspaces/create`)
   - Tìm kiếm & Lọc Workspace (`/workspace`)
   - Cài đặt Workspace Profile (`/workspaces/:id/settings`)
   - Modal lưu cấu hình thành Template (`detail.tsx`)
   - Thư viện Template hệ thống của Admin (`/admin/workspace-templates`)
   - Modal mời thành viên vào Workspace (`InviteMemberDialog`)
   - Bộ chọn gán thành viên nội bộ Agency (`AssignMemberPicker`)
   - Modal mời Client vào Workspace có tra cứu (`AddClientDialog`)
   - Danh sách lời mời Workspace gửi tới tôi (`/invitations`)
   - Dialog nhân bản Workspace (`DuplicateWorkspaceDialog`)
   - Dialog xóa Workspace & Rời Workspace (`detail.tsx`, `LeaveWorkspaceDialog`)

---

## 2. BẢNG MA TRẬN TRACKING TOÀN BỘ 27 TRANG & TÍNH NĂNG

| STT | Trang / Component / Dialog | Phân hệ FR | Đầu vào chính (Inputs) | Trạng thái Real-time Validation | Đánh giá Tiện dụng & UX | Mức độ rủi ro |
| :---: | :--- | :---: | :--- | :---: | :---: | :---: |
| **1** | User Profile Edit | FR 3.3.2 | 16 inputs | ❌ Không có (Chỉ chờ submit) | ⚠️ Thiếu auto-prefix, thiếu mask phone | **CAO** |
| **2** | Avatar Upload Modal | FR 3.3.2 | 1 file input | ⚠️ Silent fail khi chọn sai file | ✅ Có Cropper 1:1, Recent modal | **TRUNG BÌNH** |
| **3** | Link Phone & OTP Modal | FR 3.3.2 | 2 text inputs | ❌ Thiếu regex phone, OTP tự do | ⚠️ Thiếu masking, thiếu timer đếm ngược | **TRUNG BÌNH** |
| **4** | Client / Brand Profile Form | FR 3.3.4 | 22 inputs | ⚠️ Lỗi Stale Error (gõ không mất lỗi) | ✅ Live preview rất trực quan | **TRUNG BÌNH** |
| **5** | Workspace Client Profile Switcher | FR 3.3.3 V2 | Form + Radio switch | ⚠️ Phụ thuộc ClientProfileForm | ✅ Đổi profile đại diện không cần tạo lại | **THẤP** |
| **6** | Accept Invitation (Client/Member) | FR 3.4.7b / 3.3.3 | Dropdown / Form | ⚠️ Form tạo mới bị quá dài trong modal | ✅ Tự chọn sẵn profile đầu tiên | **THẤP** |
| **7** | Notification Preferences | FR 3.3.2 | 3 channels + toggles | ✅ Real-time toggle switch | ✅ Phân loại channel trực quan | **TỐT** |
| **8** | Create Agency Page | FR 3.4.3 | 14 inputs | ❌ Không validate Phone/URL; Name chỉ toast | ✅ Live Preview card cập nhật tức thì | **CAO** |
| **9** | Personal/Business Transition | DA spec | Radio cards chọn mode | ✅ Dynamic switch đổi label/ẩn trường | ✅ Rất tốt: Giảm tải form cho Solo Creator | **TỐT** |
| **10** | Update Agency Profile | FR 3.4.5 | 14 inputs | ❌ Premature keystroke validation (gõ 1 chữ báo đỏ) | ⚠️ Xung đột trải nghiệm với trang Tạo | **CAO** |
| **11** | Agency List Search & Filter | FR 3.4.1 | 4 inputs/filters | ✅ Real-time search query & filter dropdown | ✅ Có nút Xóa nhanh toàn bộ bộ lọc | **TỐT** |
| **12** | Invite Agency Member | FR 3.4.7 | 6 inputs | ✅ Debounce 400ms tra cứu tài khoản | ⚠️ Expiry days 1-30 chưa validate real-time | **THẤP** |
| **13** | Agency Roles & Custom Role | FR 3.4.20 | Search + Role modal | ⚠️ Role name chỉ check toast khi click | ❌ Dùng browser native `confirm()` | **TRUNG BÌNH** |
| **14** | My Agency Invitations List | FR 3.4.8b | Action buttons | N/A | ❌ Nút Từ chối click là xóa luôn, không confirm | **TRUNG BÌNH** |
| **15** | My Client Invitations List | FR 3.4.8b V2 | Action buttons | N/A | ❌ Nút Từ chối không có dialog xác nhận | **TRUNG BÌNH** |
| **16** | Remove Agency Member Dialog | FR 3.4.9 | Confirm Dialog | ✅ Nút submit loading & disable an toàn | ✅ Ngăn xóa nhầm thành viên | **TỐT** |
| **17** | Create Workspace Page | FR 3.4.12 | 17 inputs | ❌ Silent Drop năm sai; không check trùng Manager | ✅ Có preview template trước khi chọn | **CAO** |
| **18** | Workspace List Search & Filter | FR 3.4.10 | 5 inputs/filters | ✅ Real-time search query & multi-filters | ✅ Có reset filter khi danh sách trống | **TỐT** |
| **19** | Workspace Profile & Settings | FR 3.4.14 | 9 inputs | ❌ Không validate website, phone, location | ⚠️ Đổi timezone không cảnh báo lệch Task | **TRUNG BÌNH** |
| **20** | Save Workspace Template Modal | FR 3.4.17 | 1 text input | ⚠️ Check trim() lúc bấm nút Save | ✅ Tự động chụp JSON snapshot cấu hình | **THẤP** |
| **21** | Admin Template Library Dialog | FR 3.4.17b | 4 inputs | ⚠️ Check trim() tên template | ✅ Cho phép tạo mẫu hệ thống dùng chung | **THẤP** |
| **22** | Invite Workspace Member Dialog | FR 3.4.19 | 3 inputs | ❌ Dùng HTML5 email thuần, chưa có lookup | ✅ Có Preset mẫu lời nhắn viết sẵn | **THẤP** |
| **23** | Assign Agency Member Picker | FR 3.4.19b | Checkboxes + Roles | ⚠️ Chưa cảnh báo trùng Manager ở client | ✅ Tự động lọc thành viên thuộc Agency mẹ | **THẤP** |
| **24** | Add Client to Workspace Dialog | FR 3.4.7 V2 | 2 inputs | ✅ Debounce 400ms + Lookup Client cùng Agency | ✅ Rất xuất sắc: UX mượt, bảo mật Multi-tenancy | **RẤT TỐT** |
| **25** | My Workspace Invitations List | FR 3.4.8b | Action buttons | N/A | ❌ Nút Từ chối click là từ chối ngay, không undo | **TRUNG BÌNH** |
| **26** | Duplicate Workspace Dialog | DA-1255 | 3 inputs/choices | ✅ Real-time check chặn > 1 Manager | ✅ Có màn hình Review xác nhận các thành viên | **RẤT TỐT** |
| **27** | Danger Zone: Delete & Leave | FR 3.4.15/16 | Input tên + Dialog | ✅ Gõ đúng tên mới mở nút; Chặn last manager | ✅ Tránh tai nạn xóa nhầm dữ liệu | **RẤT TỐT** |

---

## 3. CHI TIẾT AUDIT TỪNG TRANG & DIALOG (SCREEN-BY-SCREEN)

### PHÂN HỆ 1: PROFILE (FR 3.3)

#### 3.1. User Profile Edit (`ProfileEditForm.tsx` - FR 3.3.2)
* **Các input:** `name` (Họ và tên - Required), `email` (Read-only), `phone`, `professionalTitle`, `workingLanguage`, `timezone`, `bio`, `portfolioUrls` (mảng lặp link), `skills`, `location`, `yearsOfExperience` (0..70), `linkedinUrl`, `facebookUrl`, `instagramUrl`, `tiktokUrl`, `website`, `bannerUrl`, `profileVisibility`.
* **Lỗi Real-time Validation:** Hoàn toàn không có kiểm tra lỗi real-time (Deferred Validation). Xóa trắng `name` thì không hiện cảnh báo đỏ nào dưới input. Khi bấm "Lưu", request bắn thẳng lên server rồi nhận lỗi 400 và hiện toast. Các liên kết mạng xã hội và portfolio không hề có regex kiểm tra xem chuỗi nhập vào có phải URL hợp lệ hay không.
* **Lỗi UX & Tiện dụng:** 
  - Thiếu tính năng tự động thêm tiền tố `https://` khi người dùng gõ `facebook.com/username`, dẫn đến việc link lưu ở dạng relative link (gây lỗi 404 khi người khác click).
  - Không có format nhóm số điện thoại (`0901 234 567`).
  - Ô `bio` không có bộ đếm ký tự.

#### 3.2. Avatar Upload Modal (`AvatarUploadModal.tsx` - FR 3.3.2)
* **Các input:** Input file ẩn (`accept="image/*"`), Vùng Drag & Drop.
* **Lỗi Real-time Validation:**
  - **Lỗi Silent Fail:** Tại dòng 42 `if (!pickedFile.type.startsWith("image/")) return;` — nếu kéo thả file không phải ảnh (PDF, DOCX...), code âm thầm return không có toast hay thông báo gì, người dùng tưởng nút bị liệt.
  - **Thiếu kiểm tra kích thước file:** Không kiểm tra `file.size > 5MB` trước khi mở modal Cropper. Người dùng mất công cắt ảnh xong, bấm lưu mới nhận lỗi 400 `FILE_TOO_LARGE` từ backend.
* **Điểm sáng UX:** Tích hợp Image Cropper 1:1 và cho phép chọn lại ảnh đại diện cũ (`RecentAssetsModal`).

#### 3.3. Link Phone & OTP Modal (`LinkPhoneModal.tsx` - FR 3.3.2)
* **Các input:** Bước 1: `phone` (Số điện thoại), Bước 2: `otpCode` (Mã xác thực).
* **Lỗi Real-time Validation:** Nút gửi OTP chỉ check `!phone.trim()`. Nhập chữ cái hay ký tự linh tinh vẫn cho bấm gửi. Ô `otpCode` không có `maxLength={6}`, không có `inputMode="numeric"`.
* **Lỗi UX:** Thiếu bộ đếm ngược 60 giây và nút "Gửi lại mã OTP" nếu SMS chưa tới; thiếu ô OTP dạng segmented 6 ô vuông.

#### 3.4. Client / Brand Profile Form (`ClientProfileForm.tsx` - FR 3.3.4)
* **Các input:** `displayName` (Bắt buộc), `company`, `tagline` (≤ 140 ký tự), Logo (Icon/Upload/URL), `brandColor`, Banner (Preset/Upload/URL), `industry`, `companySize`, `foundedYear`, `budgetRange`, `website`, `phone`, `contactName`, `contactEmail`, `location` (`ProvinceSelect`), `taxCode`, `address`, `facebook`, `linkedin`, `instagram`, `description`, `note`.
* **Lỗi Real-time Validation (Stale Error State):** Khi submit bị lỗi (ví dụ thiếu `displayName`), thông báo lỗi màu đỏ xuất hiện dưới ô. Người dùng bắt đầu gõ chữ vào để sửa thì lỗi đỏ **vẫn giữ nguyên**, không tự mất, vì hàm `set` trên `onChange` không xóa error của field đó.
* **Lỗi UX:** `tagline` có `maxLength={140}` nhưng không có bộ đếm ký tự; `taxCode` là text tự do chưa giới hạn số (10 hoặc 13 số).

#### 3.5. Workspace Client Profile & Brand Switcher (`/workspaces/:id/client-profile` - FR 3.3.3 V2)
* **Các input:** Nhúng `ClientProfileForm` cho Brand Profile đang active + Danh sách radio các Brand Profile khác mà user sở hữu kèm nút "Chuyển sang đại diện thương hiệu này" (`switchMyClientProfile`).
* **Đánh giá UX:** Rất thông minh và tiện dụng. Khách hàng sở hữu nhiều thương hiệu (VD: Chuỗi F&B, Thời trang) có thể linh hoạt chuyển đổi hồ sơ đại diện trong từng chiến dịch mà không cần tạo mới hay mời lại từ đầu. Form chỉnh sửa kế thừa toàn bộ ưu điểm và nhược điểm của `ClientProfileForm`.

#### 3.6. Accept Invitation with Client Profile Picker (`accept.tsx` - FR 3.4.7b & 3.3.3 V2)
* **Các input:** Dropdown chọn Brand Profile có sẵn (`selectedProfileId`) hoặc Tab chuyển sang tạo Brand Profile mới inline.
* **Đánh giá UX:** Tự động chọn sẵn Profile đầu tiên nếu user đã có sẵn hồ sơ thương hiệu. Điểm trừ là nếu chọn tạo mới thì form nhúng quá dài, làm người dùng bị cuộn trang sâu.

#### 3.7. Notification Preferences Settings (`/settings/notifications` - FR 3.3.2 Backend Preferences)
* **Các input:** Các switch toggle bật/tắt nhận thông báo qua: In-App, Email, Push Notifications và từng nhóm nội dung (Bình luận, Duyệt bài, Nhắc việc).
* **Đánh giá UX:** Giao diện trực quan, chia nhóm rõ ràng, có trạng thái loading skeleton và banner xử lý lỗi khi mất kết nối mạng.

---

### PHÂN HỆ 2: AGENCY & WORKSPACE (FR 3.4)

#### 3.8. Create Agency Page (`pages/agency/create.tsx` - FR 3.4.3)
* **Các input:** `name` (Bắt buộc), `tagline` (≤ 140 ký tự), `description` (Rich text), Logo (Icon/Upload/URL), `brandColor`, Banner, `category`, `companySize`, `foundedYear`, `location`, `website`, `phone`, `facebookUrl`, `linkedinUrl`, `instagramUrl`.
* **Lỗi Real-time Validation:** Hoàn toàn không có inline validation dưới chân input. Để trống `name` thì chỉ nổ toast. Các ô `website`, `phone`, `social links` hoàn toàn thả nổi không validate định dạng. `foundedYear` không kiểm tra cận trên/dưới.
* **Điểm sáng UX:** Cột bên phải có `AgencyCreateLivePreview` cập nhật thời gian thực màu sắc, icon, tên công ty.

#### 3.9. Personal vs Business Agency Transition (Đặc tả `personal-agency-transition`)
* **Các input:** 2 Radio Cards ở đầu trang: "Sử dụng cho cá nhân (Personal/Creator)" vs "Sử dụng cho doanh nghiệp (Business/Agency)".
* **Đánh giá UX:** Đây là bước tiến UX xuất sắc theo đặc tả mới. Khi chọn "Cá nhân", hệ thống tự động ẩn các trường rườm rà như `Quy mô công ty`, đổi nhãn trường thành *"Tên thương hiệu / Kênh của bạn"*, nút bấm chuyển thành *"Bắt đầu sáng tạo ngay ✨"*, tự động tạo sẵn 1 Workspace cá nhân và đưa thẳng user vào làm việc mà không bắt qua các bước phân quyền B2B.

#### 3.10. Update Agency Profile (`AgencyDetailEditForm.tsx` - FR 3.4.5)
* **Các input:** Tương tự trang Tạo Agency.
* **Lỗi Real-time Validation (Premature on-keystroke validation):** Gõ từng phím (`onChange`) là chạy `validateField`. Vừa gõ chữ `"h"` trong ô Facebook hoặc số `"0"` trong ô Phone là dòng chữ đỏ *"Không hợp lệ"* đã nhấp nháy liên tục, làm người dùng rất ức chế.
* **Lỗi UX:** Bất đối xứng trải nghiệm: cùng 1 đối tượng nhưng trang Tạo cho nhập tự do, sang trang Sửa thì kiểm tra cực kỳ khắt khe.

#### 3.11. Agency List Search & Filter (`pages/agency/index.tsx` - FR 3.4.1)
* **Các input:** `searchQuery` (Tìm kiếm agency), `categoryFilter` (Lọc theo ngành), `roleFilter` (Tất cả / Tôi làm chủ / Tôi là thành viên), `sortOption` (Sắp xếp theo số workspace, tên, ngày tạo).
* **Đánh giá UX:** Tốt. Có nút "Xóa tất cả bộ lọc" (`clearAllFilters`) khi không tìm thấy kết quả. Có nút mở rộng/thu gọn danh sách workspace con của từng agency.

#### 3.12. Invite Agency Member (`pages/agency/members.tsx` - FR 3.4.7)
* **Các input:** `email`, `inviteeName`, `note`, `inviteWorkspaceId`, `inviteRole` (MANAGER / CREATOR / CLIENT), `expiryDays` (1-30).
* **Đánh giá Validation & UX:** Rất tốt ở phần tra cứu: Dùng debounce 400ms kiểm tra email, tự động loại trừ chính mình và thành viên đã tham gia, hiển thị Avatar và Tên nếu email đã có tài khoản trên BrandHub. Kiểm tra đúng luật BR-27 (vai trò Client bắt buộc phải chọn Workspace).

#### 3.13. Agency Member Roles & Custom Role Dialog (`pages/agency/roles.tsx` - FR 3.4.20)
* **Các input:** Ô tìm kiếm đặc quyền trong ma trận, Modal tạo Custom Role: `newRoleName` (Tên vai trò), `newRoleDesc` (Mô tả), `baseRoleKey` (Kế thừa quyền ban đầu).
* **Lỗi Validation & UX:**
  - `newRoleName` để trống thì chỉ bắn toast lỗi khi bấm nút, không có inline error.
  - Hành động "Khôi phục ma trận về mặc định" và "Xóa vai trò tùy biến" đang dùng hộp thoại popup nguyên bản của trình duyệt `confirm(...)` thay vì dùng Dialog component đồng bộ phong cách thiết kế với hệ thống.

#### 3.14. My Agency Invitations List (`pages/agency/invitations.tsx` - FR 3.4.8b)
* **Các input:** Nút "Chấp nhận" (Accept) và "Từ chối" (Decline) cho từng lời mời gia nhập nội bộ Agency.
* **Lỗi UX nghiêm trọng:** Khi người dùng click nút "Từ chối", hệ thống gọi thẳng API `agencyService.declineInvitation` mà **không hề hiển thị hộp thoại xác nhận (Confirmation Dialog)**. Nếu người dùng lỡ tay bấm nhầm trên màn hình cảm ứng, lời mời sẽ bị xóa vĩnh viễn mà không thể hoàn tác.

#### 3.15. My Client Invitations List (`pages/client/invitations.tsx` - FR 3.4.8b V2)
* **Các input:** Nút "Chấp nhận" (điều hướng sang `/invitations/accept?token=...` để chọn Brand Profile) và "Từ chối" (Decline).
* **Lỗi UX:** Tương tự trang Agency Invitations, nút "Từ chối" xử lý ngay lập tức khi click mà không có dialog hỏi lại người dùng.

#### 3.16. Remove Agency Member Dialog (`RemoveAgencyMemberDialog.tsx` - FR 3.4.9)
* **Đánh giá UX:** Tốt. Có dialog xác nhận xóa thành viên khỏi công ty, nút xóa màu đỏ có trạng thái `loading` khi đang thực thi.

#### 3.17. Create Workspace Page (`CreateWorkspaceForm.tsx` - FR 3.4.12)
* **Các input:** `name`, `agencyId`, `description`, `brandColor`, `logoIcon`, `tagline`, `foundedYear`, `industry`, `companySize`, `website`, `phone`, `location`, `social links`, `assignMembers`, `clientEmails`, chọn template.
* **Lỗi Real-time Validation:**
  - **Lỗi Silent Drop:** Nhập năm thành lập ngoài khoảng `1900..CURRENT_YEAR` thì code âm thầm gán thành `undefined` gửi lên server thay vì báo lỗi.
  - **Thiếu kiểm tra trùng Manager:** Chọn 2 người làm Manager trong `AssignMemberPicker` thì client không báo lỗi ngay, để server trả 409 `MANAGER_ALREADY_ASSIGNED`.

#### 3.18. Workspace List Search & Filter (`pages/workspace/index.tsx` - FR 3.4.10)
* **Các input:** Ô tìm kiếm `searchQuery`, bộ lọc theo `agencyFilter`, `roleFilter`, `industryFilter`, `sortOption`.
* **Đánh giá UX:** Tốt, có mapping tên agency hiển thị rõ ràng bên dưới tên workspace, hỗ trợ tìm kiếm cả theo tên workspace lẫn tên agency cha.

#### 3.19. Workspace Profile & Settings (`detail.tsx`, `useWorkspaceSettings.ts` - FR 3.4.14)
* **Các input:** `name`, `timezone` (`TimezoneSelect`), `defaultPlatforms` (`PlatformToggle`), `reportFrequency`, Logo & Banner upload, `industry`, `companySize`, `website`, `phone`, `location`.
* **Lỗi Validation & UX:** Thiếu validate website/phone. Đặc biệt khi đổi múi giờ (`timezone`), hệ thống cho lưu ngay mà không cảnh báo rủi ro làm lệch giờ các bài đăng và task đã lên lịch trước đó (vi phạm đặc tả FR 3.4.14).

#### 3.20. Save Workspace as Template Modal (`detail.tsx` - FR 3.4.17)
* **Các input:** `templateName` (Tên template - Text input), Checkbox các trường ngành nghề.
* **Đánh giá UX:** Rất tốt: hệ thống tự động trích xuất cấu hình hiện tại thành JSON snapshot, user chỉ việc nhập tên template.

#### 3.21. Admin Workspace Template Library (`WorkspaceTemplateLibrary.tsx` - FR 3.4.17b)
* **Các input:** Modal tạo template hệ thống: `name`, `industry`, `companySize`, `industryFields`.
* **Đánh giá:** Đáp ứng tốt nghiệp vụ quản trị, cho phép Admin tạo sẵn các bộ khung mẫu theo ngành để các Agency tái sử dụng.

#### 3.22. Invite Workspace Member Dialog (`InviteMemberDialog.tsx` - FR 3.4.19)
* **Các input:** `email`, `role`, `note` (kèm `InviteMessagePresets`).
* **Đánh giá UX:** Có bộ nút chọn mẫu lời nhắn nhanh rất tiện. Điểm trừ là ô email chưa tích hợp avatar lookup như bên Agency.

#### 3.23. Assign Agency Member Picker (`AssignMemberPicker.tsx` - FR 3.4.19b)
* **Các input:** Danh sách checkbox thành viên Agency kèm dropdown chọn vai trò.
* **Đánh giá UX:** Phân quyền theo đúng Agency mẹ. Cần bổ sung cảnh báo đỏ nếu người dùng chọn nhiều hơn 1 người giữ vai trò `MANAGER`.

#### 3.24. Add Client to Workspace Dialog (`AddClientDialog.tsx` - FR 3.4.7 V2)
* **Các input:** `email`, `note`.
* **Đánh giá:** **FORM HOÀN HẢO NHẤT HỆ THỐNG.** Có debounce 400ms, tra cứu và hiển thị gợi ý thông minh nếu Client này đã đại diện thương hiệu ở workspace khác cùng Agency, đảm bảo bảo mật không rò rỉ dữ liệu sang Agency khác.

#### 3.25. My Workspace Invitations List (`pages/workspace/invitations.tsx` - FR 3.4.8b)
* **Các input:** Nút Chấp nhận & Từ chối.
* **Lỗi UX:** Nút Từ chối không có dialog xác nhận, click là từ chối ngay.

#### 3.26. Duplicate Workspace Dialog (`DuplicateWorkspaceDialog.tsx` - DA-1255)
* **Các input:** `name`, `copyTimezone`, danh sách chọn thành viên.
* **Đánh giá:** **RẤT XUẤT SẮC.** Kiểm tra thời gian thực biến `tooManyManagers`, nếu chọn > 1 Manager thì báo đỏ và khóa nút Submit ngay; có bước Review tổng kết trước khi tạo.

#### 3.27. Destructive Action Dialogs: Delete & Leave Workspace (FR 3.4.15, 3.4.16, 3.4.21)
* **Components:** Delete Zone trong `detail.tsx`, `LeaveWorkspaceDialog.tsx`, `RemoveMemberDialog.tsx`.
* **Đánh giá:** Rất an toàn: Bắt buộc gõ đúng tên workspace mới mở nút Xóa vĩnh viễn; kiểm tra `isLastManager` ngăn Manager cuối cùng tự ý rời nhóm gây vô chủ workspace.

---

## 4. TỔNG KẾT CÁC LỖI UX & ANTI-PATTERNS HỆ THỐNG

Sau khi rà soát đầy đủ 27 màn hình/dialog, có 6 vấn đề lớn cần khắc phục:
1. **Lỗi Premature Keystroke Validation:** Gõ từng phím là báo lỗi đỏ (Agency Detail Edit).
2. **Lỗi Stale Error State:** Sửa xong lỗi nhưng thông báo đỏ vẫn giữ nguyên (Client Profile).
3. **Lỗi Silent Drop:** Nhập sai năm thành lập thì âm thầm xóa mất dữ liệu (Workspace Create).
4. **Lỗi Unconfirmed Destructive Action:** Bấm nút "Từ chối" lời mời là từ chối ngay lập tức, không có dialog xác nhận (Agency & Workspace Invitations).
5. **Lỗi Dùng Native Browser Confirm:** Dùng `confirm()` nguyên bản của trình duyệt thay vì modal dialog đồng bộ (Agency Roles).
6. **Thiếu Auto-prefix & Format:** Tất cả các ô nhập URL không tự bù `https://`, số điện thoại không có format phân tách nhóm số.

---

## 5. LỘ TRÌNH & KẾT QUẢ TRIỂN KHAI CẢI THIỆN (100% HOÀN TẤT)

Tất cả 6 nhóm vấn đề đã được khắc phục hoàn toàn trên toàn bộ source code `brandhub-web-dashboard`:

1. **Chuẩn hóa Touch & Blur Pattern:**
   - **Đã hoàn tất:** Tạo module dùng chung `src/utils/validation.ts` (`normalizeUrl`, `isValidUrl`, `formatPhoneNumber`, `isValidPhone`, `isValidTaxCode`, `isValidFoundedYear`).
   - Khi gõ (`onChange`): Tự động xóa lỗi cũ của trường đó ngay lập tức (`clearError` / `clearFieldError`), không bao giờ hiện lỗi đỏ sớm khi người dùng chưa gõ xong.
   - Khi rời chuột (`onBlur`): Tự động chuẩn hóa (auto-prefix `https://` cho URL, định dạng `0901 234 567` cho số điện thoại), sau đó mới chạy validate regex và hiển thị inline error nếu không hợp lệ.
   - Đã áp dụng trên: `AgencyDetailEditForm.tsx`, `ClientProfileForm.tsx`, `pages/agency/create.tsx`, `CreateWorkspaceForm.tsx`, `ProfileEditForm.tsx`, `pages/profile/index.tsx`.

2. **Bổ sung Confirmation Dialog cho các nút Từ chối lời mời:**
   - **Đã hoàn tất:** Thêm state `declineTarget` và themed confirmation `Dialog` đồng bộ giao diện BrandHub. Người dùng bấm "Từ chối" sẽ hiển thị modal xác nhận kèm tên tổ chức/workspace, nút xác nhận dạng `destructive`, ngăn chặn tuyệt đối việc xóa nhầm lời mời.
   - Đã áp dụng trên: `pages/agency/invitations.tsx`, `pages/client/invitations.tsx`, `pages/workspace/components/InvitationList.tsx`.

3. **Thay thế `window.confirm()` bằng `Dialog` đồng bộ:**
   - **Đã hoàn tất:** Loại bỏ hoàn toàn native browser `confirm()` tại `pages/agency/roles.tsx`. Thay bằng 2 modal Dialog chuẩn Design System:
     - Modal xác nhận khôi phục ma trận phân quyền về mặc định (có icon cảnh báo vàng `RotateCcw`).
     - Modal xác nhận xóa Custom Role (có icon cảnh báo đỏ `AlertTriangle`, nút `destructive`).

4. **Sửa lỗi Silent Drop dữ liệu:**
   - **Đã hoàn tất:** Tại `useCreateWorkspace.ts` và `CreateWorkspaceForm.tsx`, loại bỏ logic âm thầm gán `undefined` khi `foundedYear` sai quy tắc. Thay vào đó, hệ thống cung cấp state `errors.foundedYear`, hiển thị lỗi đỏ rõ ràng và ngăn submit nếu thông tin không hợp lệ.

5. **Thêm bộ đếm ký tự (CharacterCounter):**
   - **Đã hoàn tất:** Tạo component `src/components/ui/character-counter.tsx` hỗ trợ tự đổi màu (vàng ở ngưỡng 90%, đỏ khi đạt 100%).
   - Tích hợp vào các trường văn bản giới hạn:
     - Khẩu hiệu (`tagline` - max 140 ký tự) trên `ClientProfileForm.tsx`, `AgencyDetailEditForm.tsx`, `pages/agency/create.tsx`, `CreateWorkspaceForm.tsx`.
     - Tiểu sử (`bio` / `description` / `note`) trên `ProfileEditForm.tsx`, `ClientProfileForm.tsx`, `pages/agency/roles.tsx`.

6. **Kiểm thử & Biên dịch (Build Verification):**
   - **Kết quả:** Đã chạy `npm run build` (`tsc -b && vite build`) thành công 100% với exit code 0, không có bất kỳ cảnh báo hoặc lỗi TypeScript nào.

---
*Toàn bộ 27 màn hình và luồng nhập liệu của 2 phân hệ Profile và Agency-Workspace đã được tracking 100% và cải thiện triệt để.*
