# Test — Create Agency with Personal and Business Mode (FR 3.4.3.B)

> Danh mục Test Case kiểm thử chức năng Tạo Agency hỗ trợ chế độ Cá nhân (Personal Mode) và Doanh nghiệp (Business Mode), suy từ Acceptance Criteria trong [report3_spec.md](report3_spec.md).

| Test Case ID | Mô tả kịch bản (Input / Điều kiện) | AC liên quan | Kết quả mong đợi | Loại kiểm thử | Trạng thái |
|:---|:---|:---|:---|:---|:---|
| **TC-PERS-01** | Tạo Agency với `type = 'PERSONAL'` đầy đủ thông tin hợp lệ | AC-02, AC-03 | • HTTP `201 Created`.<br/>• Bản ghi `agencies` có `type = 'PERSONAL'`.<br/>• Bản ghi `workspaces` cá nhân được auto-create với cùng tên/branding.<br/>• `workspace_members` tạo cho currentUser với role `MANAGER`.<br/>• Response trả về `defaultWorkspaceId` khác null. | Happy Path (Backend) | Đã sẵn sàng test |
| **TC-PERS-02** | Tạo Agency với `type = 'PERSONAL'` tối giản (chỉ có `name` và `type`) | AC-02 | • HTTP `201 Created`.<br/>• Agency và Workspace đều được tạo thành công với các trường tùy chọn mang giá trị null.<br/>• `defaultWorkspaceId` trả về hợp lệ. | Happy Path (Backend) | Đã sẵn sàng test |
| **TC-PERS-03** | Tạo Agency với `type = 'BUSINESS'` | AC-01 | • HTTP `201 Created`.<br/>• Bản ghi `agencies` có `type = 'BUSINESS'`.<br/>• **Không** tự động tạo Workspace (`defaultWorkspaceId == null`).<br/>• Chuyển hướng người dùng về trang chi tiết Agency `/agency/{id}`. | Happy Path (Backend) | Đã sẵn sàng test |
| **TC-PERS-04** | Tạo Agency nhưng không truyền `type` (Tương thích ngược) | AC-06 | • Server tự động gán giá trị mặc định `type = 'BUSINESS'`.<br/>• Hoạt động chuẩn như phiên bản cũ. | Regression / Backward Compat | Đã sẵn sàng test |
| **TC-PERS-05** | Nhập `name` rỗng hoặc chỉ có khoảng trắng | BR-AGENCY-01 | • HTTP `400 VALIDATION_ERROR` (do `@NotBlank`).<br/>• Không có Agency hay Workspace nào được lưu vào DB. | Validation Error | Đã sẵn sàng test |
| **TC-PERS-06** | Mã màu `brandColor` quá 9 ký tự hoặc `tagline` quá 140 ký tự | BR-AGENCY-02 | • HTTP `400 VALIDATION_ERROR`.<br/>• Báo lỗi trường tương ứng. | Validation Error | Đã sẵn sàng test |
| **TC-PERS-07** | Không kèm JWT Token hoặc Token hết hạn | BR-AUTH | • HTTP `401 UNAUTHORIZED`.<br/>• Request bị chặn tại Gateway/Security Filter. | Security Error | Đã sẵn sàng test |
| **TC-PERS-08** | Lỗi xảy ra khi lưu Workspace (Kiểm tra Rollback Transaction) | AC-05 | • Nếu lưu Workspace gặp sự cố, giao dịch `@Transactional` rollback toàn bộ.<br/>• Bản ghi Agency **không** tồn tại trong database (không sinh orphan record). | Reliability / Atomicity | Đã sẵn sàng test |
| **TC-PERS-09** | Frontend: Trải nghiệm người dùng khi tạo Personal Agency | AC-03 | • Ngay sau khi API trả về thành công, Client tự động cập nhật `activeWorkspace`.<br/>• Trình duyệt điều hướng thẳng tới `/workspaces/{defaultWorkspaceId}/dashboard`. | E2E Frontend | Đã sẵn sàng test |
| **TC-PERS-10** | Frontend: Kiểm tra Sidebar khi đang chọn Personal Agency | AC-04 | • Sidebar **ẩn** hoàn toàn các mục: Khách hàng, Hồ sơ khách hàng, Lời mời khách hàng, Cổng khách hàng, Phân quyền vai trò.<br/>• Chỉ hiển thị các công cụ sáng tạo (Viết bài, Calendar, Thư viện, Đăng bài) và Báo cáo. | UI / Access Control | Đã sẵn sàng test |
| **TC-PERS-11** | Nâng cấp Agency từ `PERSONAL` lên `BUSINESS` | BR-PERSONAL-06 | • Gọi `PATCH /api/v1/agencies/{id}/upgrade-type` với `type = 'BUSINESS'`.<br/>• Agency chuyển sang `BUSINESS`, Sidebar tự động mở lại các mục Client và Member roles. | Feature Toggle / Upgrade | Đã sẵn sàng test |

---

## Tiêu Chí Hoàn Thành (Definition of Done - DoD)
1. 100% các Test Case trên pass cả Unit Test (`AgencyServiceImplTest`) và Manual Test trên Web UI.
2. Không phát sinh hồi quy (regression) đối với các Agency Doanh nghiệp hiện có.
3. Không có lỗi rò rỉ quyền (Access Leak) hoặc hiển thị nhầm menu B2B trong chế độ Cá nhân.
