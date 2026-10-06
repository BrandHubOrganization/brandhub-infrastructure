# 05. Kế Hoạch Triển Khai & Danh Mục Công Việc (Implementation Plan & Tasks)

## 1. Lộ Trình Triển Khai (Roadmap Overview)

Kế hoạch chuyển đổi được chia thành **4 giai đoạn tuần tự** nhằm đảm bảo tính ổn định, không làm gián đoạn hệ thống hiện tại và dễ dàng kiểm thử nghiệm thu từng phần:

```text
┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐
│        PHASE 1         │      │        PHASE 2         │      │        PHASE 3         │      │        PHASE 4         │
│   Database Migration   │ ───► │     API & Store        │ ───► │  Màn Hình Tạo Agency   │ ───► │   Sidebar Tinh Gọn     │
│   & Backend Service    │      │    Frontend Contract   │      │   & Auto-transition    │      │  & Luồng Đăng Trực Tiếp│
└────────────────────────┘      └────────────────────────┘      └────────────────────────┘      └────────────────────────┘
```

---

## 2. Danh Mục Công Việc Chi Tiết (Task Breakdown)

### Giai đoạn 1: Database Migration & Backend Business Service
* [ ] **Task 1.1: Tạo file Migration SQL**:
  * Tạo file `docs/database/migrations/2026-10-06-add-agency-type-and-personal-mode.sql` (tạo enum `agency_type`, thêm cột `type` vào bảng `agencies`).
  * Thực thi migration lên môi trường PostgreSQL local/dev.
* [ ] **Task 1.2: Cập nhật Java Model & Enums**:
  * Thêm enum `com.brandhub.business.model.enums.AgencyType.java` (`PERSONAL`, `BUSINESS`).
  * Bổ sung trường `type` vào `Agency.java` với annotation `@Enumerated` và `@JdbcTypeCode`.
* [ ] **Task 1.3: Mở rộng DTO Request & Response**:
  * Cập nhật `AgencyRequest.java`: Thêm thuộc tính `AgencyType type`.
  * Cập nhật `AgencyResponse.java`: Thêm `AgencyType type` và `UUID defaultWorkspaceId`.
* [ ] **Task 1.4: Triển khai Nghiệp vụ Auto-provisioning Workspace trong `AgencyServiceImpl.java`**:
  * Kiểm tra nếu `request.type() == AgencyType.PERSONAL`: Tự động khởi tạo 1 `Workspace` cá nhân và gán `WorkspaceMember` với vai trò `MANAGER`.
  * Đảm bảo giao dịch `@Transactional` rollback toàn phần nếu có lỗi.
* [ ] **Task 1.5: Viết Unit Test & Integration Test**:
  * Viết test case `createAgency_whenPersonal_autoCreatesWorkspaceAndMember()` trong `AgencyServiceImplTest.java`.
  * Chạy `mvn test` đảm bảo 100% test case pass.

---

### Giai đoạn 2: API Gateway & Store Frontend
* [ ] **Task 2.1: Cập nhật TypeScript Types (`src/types/agency.ts`)**:
  * Thêm type `AgencyType = "PERSONAL" | "BUSINESS"`.
  * Bổ sung `type: AgencyType` và `defaultWorkspaceId?: string` vào interface `Agency` và `AgencyRequest`.
* [ ] **Task 2.2: Cập nhật Agency Store & Workspace Store**:
  * Lưu trữ thông tin loại hình Agency hiện tại để các thành phần UI khác dễ dàng truy vấn.
* [ ] **Task 2.3: Bổ sung i18n đa ngôn ngữ (`locales/vi/agency.json` & `locales/en/agency.json`)**:
  * Thêm các bản dịch: "Sử dụng cho Cá nhân", "Sử dụng cho Doanh nghiệp", "Tên thương hiệu / Kênh của bạn", "Bắt đầu sáng tạo ngay ✨".

---

### Giai đoạn 3: Màn Hình Tạo Agency & Luồng Chuyển Đổi Tức Thì
* [ ] **Task 3.1: Thiết kế Card Chọn Mục Đích Sử Dụng trên `CreateAgencyPage.tsx`**:
  * Tạo component chọn loại hình trực quan (Personal vs Business) với icon và chú thích.
* [ ] **Task 3.2: Xử lý Ẩn/Hiện Trường Động**:
  * Khi chọn "Cá nhân": Ẩn chọn quy mô công ty `companySize`, đổi nhãn tên thương hiệu.
* [ ] **Task 3.3: Triển khai Luồng Submit & Chuyển Hướng**:
  * Khi tạo thành công với loại `PERSONAL`:
    1. Đọc `defaultWorkspaceId` từ API response.
    2. Cập nhật `activeWorkspace` trong `workspaceStore`.
    3. Điều hướng ngay sang `/workspaces/{defaultWorkspaceId}/dashboard`.

---

### Giai đoạn 4: Tinh Gọn Sidebar & Luồng Xuất Bản Trực Tiếp
* [ ] **Task 4.1: Cập nhật Cấu hình Navigation (`sidebarNavConfig.ts`)**:
  * Bổ sung thuộc tính `hideInPersonalAgency?: boolean` vào interface `NavItem`.
  * Đánh dấu các route Client, Client Profile, Portal, Roles là ẩn đối với Agency Cá nhân.
* [ ] **Task 4.2: Tinh chỉnh Component `Sidebar.tsx`**:
  * Lọc bỏ các mục menu bị ẩn dựa trên loại hình của Agency đang active.
* [ ] **Task 4.3: Tinh chỉnh Giao diện Soạn Thảo (`/content-writing`)**:
  * Nếu thuộc Workspace Cá nhân: Ẩn nút "Gửi duyệt cho khách hàng", chỉ hiển thị "Đăng ngay" và "Lên lịch đăng".

---

## 3. Tiêu Chí Kiểm Thử & Nghiệm Thu (Acceptance Criteria)

| Mã AC | Tiêu chí kiểm thử | Kết quả mong đợi |
|:---|:---|:---|
| **AC-01** | Tạo Agency Doanh nghiệp (`BUSINESS`) | Tạo thành công, không tự tạo Workspace, chuyển về trang xem hồ sơ Agency như cũ. Đầy đủ menu Client. |
| **AC-02** | Tạo Agency Cá nhân (`PERSONAL`) | Tạo thành công cả Agency và Workspace đi kèm trong cùng 1 request. |
| **AC-03** | Trải nghiệm tức thì | Ngay sau khi tạo Agency Cá nhân, người dùng được đưa thẳng vào Dashboard Workspace để làm việc, không qua trang Agency rỗng. |
| **AC-04** | Hiển thị Sidebar Cá nhân | Sidebar hoàn toàn không xuất hiện các menu: Khách hàng, Hồ sơ khách hàng, Lời mời, Portal, Phân quyền Roles. |
| **AC-05** | Tính toàn vẹn dữ liệu | Nếu tạo Workspace bị lỗi, toàn bộ thao tác tạo Agency phải được rollback, không sinh ra Agency mồ côi. |
| **AC-06** | Tương thích ngược | Các Agency cũ đã có trong hệ thống vẫn hoạt động bình thường với loại mặc định `BUSINESS`. |
