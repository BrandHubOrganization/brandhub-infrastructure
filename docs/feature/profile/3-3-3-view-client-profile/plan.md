# Plan — View Client Profile (FR 3.3.3)

> Liên kết: [spec.md](spec.md) — hiển thị danh sách Client Profile của User đang đăng nhập, và danh sách Client đang cộng tác trong 1 workspace.
>
> V2 (2026-10-02): **[SỬA]** ClientProfile không còn ràng buộc `agency_id` — thuộc sở hữu User, độc lập Agency, dùng được ở nhiều workspace/agency. Xem [§6](#6-lịch-sử-thay-đổi) cho lý do.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `ClientProfileServiceImpl.listMine()` |
| File liên quan | `ClientProfileController` (`GET /api/v1/client-profile/mine`), `ClientProfileResponse`, `WorkspaceController` (`GET /api/v1/workspaces/{id}/members` — dùng chung cho Workspace Client list, filter role CLIENT ở FE) |

## 2. API Contract (final)

```
GET /api/v1/client-profile/mine
Authorization: Bearer <access-token>
→ 200 ApiResponse<ClientProfileResponse[]>
   data = [{ id, userId, displayName, company, phone, note, logoUrl, website, industry,
             location, description, socialLinks, contactName, contactEmail, companySize,
             instagramUrl, taxCode, address, tagline, foundedYear, budgetRange,
             createdAt, updatedAt }, ...]

GET /api/v1/workspaces/{workspaceId}/members
→ 200 ApiResponse<WorkspaceMemberResponse[]>
   (FE lọc role === "CLIENT" cho trang /workspaces/:id/clients)
```

Không còn `email` trên `ClientProfileResponse` — email lấy từ `User` (authStore) của chính người sở hữu profile.

## 3. Data Model

`client_profiles` — **[SỬA 2026-10-02]** bỏ hẳn `agency_id` (migration `2026-10-02-drop-client-profile-agency-id.sql`). ClientProfile chỉ còn gắn với `user_id`, không ràng buộc Agency:

| Field | Type | Note |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK `users` — chủ sở hữu duy nhất |
| display_name | varchar | not null |
| company | varchar | null |
| phone | varchar | null |
| note | text | null |
| logo_url | varchar | null — logo công ty |
| website | varchar | null — website công ty |
| industry | varchar | null — ngành nghề |
| location | varchar | null — địa điểm |
| description | text | null — mô tả công ty |
| social_links | jsonb | null — `{ "linkedin", "facebook" }` |
| contact_name / contact_email / company_size / instagram_url / tax_code / address / tagline / founded_year / budget_range | — | field thương hiệu bổ sung (2026-09-27) |
| created_at / updated_at | timestamptz | |

Quan hệ với workspace: `workspace_members.client_profile_id` (FK, nullable) — 1 ClientProfile có thể là target của nhiều `workspace_members` row ở nhiều workspace/agency khác nhau cùng lúc. `ClientProfileRepository.findByUserId(userId)` trả toàn bộ profile của 1 user, không filter theo agency.

## 4. Luồng xử lý

**My Brand Profiles:**
1. `findByUserId(currentUser.getId())` → trả list (rỗng nếu chưa tạo profile nào).
2. Map từng record → `ClientProfileResponse`.

**Workspace Client list:**
1. `WorkspaceService.listMembers(workspaceId)` → trả toàn bộ `WorkspaceMember` active.
2. FE lọc `role === "CLIENT"`, hiển thị `fullName` (resolve từ ClientProfile liên kết qua `clientProfileId`).

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `ClientProfile` entity, `ClientProfileRepository` |
| Bị chặn | `Update Client Profile` (3.3.4), `Invite Agency Member` (3.4.7) khi role CLIENT |

## 6. Lịch sử thay đổi

- **2026-09-21** (đã revert): từng thêm `agency_id` vào `client_profiles`, model 1-profile/agency. Sai nghiệp vụ thật — Nike/Adidas không có tài khoản riêng, chỉ có người đại diện (1 User) sở hữu nhiều ClientProfile (mỗi brand 1 cái), dùng xuyên suốt nhiều Agency.
- **2026-10-02:** xoá `agency_id`, chuyển hẳn sang mô hình User-owned, N-per-user. Đồng thời tách trang Thành viên (`/workspaces/:id/members`, chỉ nội bộ) và trang Client (`/workspaces/:id/clients`, CLIENT collaborator) thành 2 route độc lập — trước đó gộp chung 1 trang với tab switcher.
