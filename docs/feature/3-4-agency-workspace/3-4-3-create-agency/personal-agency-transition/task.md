# Task — Create Agency with Personal & Business Mode (FR 3.4.3.B)

> Checklist triển khai chi tiết theo [plan.md](05_IMPLEMENTATION_PLAN_AND_TASKS.md). Thực hiện theo đúng thứ tự ưu tiên dưới đây.

---

## 1. Database — `brandhub-infrastructure`

- [ ] **DB-01**: Tạo migration script `docs/database/migrations/2026-10-06-add-agency-type-and-personal-mode.sql`.
- [ ] **DB-02**: Chạy migration trên môi trường PostgreSQL local (`psql`).
- [ ] **DB-03**: Verify bảng `agencies` có cột `type` với giá trị mặc định là `'BUSINESS'` và index `idx_agencies_type`.

---

## 2. Backend — `brandhub-business-service`

- [ ] **BE-01**: Tạo enum `AgencyType.java` (`PERSONAL`, `BUSINESS`) tại `com.brandhub.business.model.enums`.
- [ ] **BE-02**: Cập nhật `Agency.java` — thêm field `type` với `@Enumerated(EnumType.STRING)` và `@JdbcTypeCode(SqlTypes.NAMED_ENUM)`.
- [ ] **BE-03**: Cập nhật `AgencyRequest.java` — thêm field `AgencyType type`.
- [ ] **BE-04**: Cập nhật `AgencyResponse.java` — thêm `AgencyType type` và `UUID defaultWorkspaceId`.
- [ ] **BE-05**: Cập nhật `AgencyServiceImpl.createAgency` — kiểm tra nếu `type == AgencyType.PERSONAL`:
  - Khởi tạo `Workspace` cá nhân đồng bộ tên, branding.
  - Gán `WorkspaceMember` cho `currentUser` với vai trò `MANAGER`.
  - Gắn `defaultWorkspaceId` vào `AgencyResponse`.
- [ ] **BE-06**: Bổ sung API `PATCH /api/v1/agencies/{id}/upgrade-type` cho phép nâng cấp từ `PERSONAL` lên `BUSINESS`.
- [ ] **BE-07**: Viết Unit Test trong `AgencyServiceImplTest.java`:
  - `createAgency_whenPersonal_autoCreatesWorkspaceAndManagerMember()`.
  - `createAgency_whenBusiness_doesNotCreateWorkspace()`.
  - `createAgency_nullType_defaultsToBusiness()`.
- [ ] **BE-08**: Chạy `mvn test` đảm bảo 100% tests pass.

---

## 3. Frontend — `brandhub-web-dashboard`

- [ ] **FE-01**: Cập nhật `src/types/agency.ts`:
  - Khai báo type `AgencyType = "PERSONAL" | "BUSINESS"`.
  - Thêm `type` và `defaultWorkspaceId` vào `Agency` và `AgencyRequest`.
- [ ] **FE-02**: Cập nhật i18n (`src/i18n/locales/vi/agency.json` và `en/agency.json`):
  - Thêm từ khóa mô tả cho chế độ Cá nhân và Doanh nghiệp.
- [ ] **FE-03**: Nâng cấp màn hình `CreateAgencyPage.tsx`:
  - Thêm khối chọn Loại hình (Personal Card vs Business Card).
  - Tự động ẩn `companySize` khi chọn Cá nhân.
  - Đổi nhãn nút Submit thành "Bắt đầu sáng tạo ngay ✨".
- [ ] **FE-04**: Xử lý Submit & Điều hướng trong `CreateAgencyPage.tsx`:
  - Đọc `defaultWorkspaceId` từ response.
  - Gán `currentWorkspace` trong `workspaceStore`.
  - Điều hướng tới `/workspaces/{defaultWorkspaceId}/dashboard`.
- [ ] **FE-05**: Cập nhật `src/components/layout/sidebar/sidebarNavConfig.ts`:
  - Thêm thuộc tính `hideInPersonalAgency?: boolean`.
  - Đánh dấu ẩn các route: `/clients`, `/client-profiles`, `/client/invitations`, `/portal`, `/agency/:id/roles`.
- [ ] **FE-06**: Cập nhật `Sidebar.tsx`:
  - Lọc bỏ các mục `hideInPersonalAgency` nếu Agency hiện tại có `type === "PERSONAL"`.
- [ ] **FE-07**: Chạy `npm run lint`, `npm run type-check`, `npm run build` đảm bảo không có lỗi TypeScript hay build error.

---

## 4. Kiểm Thử Nghiệm Thu (Verification)

- [ ] **QA-01**: Chạy các test case theo [test.md](test.md) (TC-PERS-01 đến TC-PERS-11).
- [ ] **QA-02**: Kiểm tra tính toàn vẹn dữ liệu khi tạo thất bại (Rollback verify).
- [ ] **QA-03**: Xác nhận các tài khoản cũ (Business) không bị ảnh hưởng.
