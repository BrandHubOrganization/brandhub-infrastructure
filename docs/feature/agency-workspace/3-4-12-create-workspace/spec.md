# UC — Create Workspace

| | |
|---|---|
| FR Code | 3.4.12 |
| Feature | Create Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Agency member (bất kỳ) — tạo Workspace thuộc Agency mình |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Cho phép user tạo Workspace mới trong Agency; người tạo mặc định trở thành MANAGER của Workspace, có thể tùy chọn gán thêm thành viên (kể cả chuyển giao vai trò MANAGER) ngay lúc tạo.

## 2. User Story

Là một thành viên Agency,
tôi muốn tạo 1 Workspace mới,
để bắt đầu 1 không gian làm việc cho team và Client.

## 3. Acceptance Criteria

- Form nhập `name` (bắt buộc), `agencyId` (bắt buộc, nằm trong body — KHÔNG phải path param), cùng các field mở rộng: `industry` (enum `WorkspaceIndustry`), `companySize` (enum `CompanySize`), `website`, `phone`, `location`, `description`, `brandColor`, `logoIcon`, `tagline`, `foundedYear`, `facebookUrl`, `linkedinUrl`, `instagramUrl`.
- Người gọi API (`currentUser`) mặc định được gán `WorkspaceMember` với role=MANAGER.
- Có thể truyền kèm `assignMembers` (danh sách `{userId, role}`, role thuộc `MANAGER|CREATOR|CLIENT`) để gán thêm thành viên ngay lúc tạo. Nếu trong `assignMembers` có chọn MỘT người KHÁC làm MANAGER, hệ thống chuyển giao: người tạo tự động xuống role CREATOR, người được chọn giữ MANAGER (đảm bảo đúng 1 MANAGER áp dụng ngay từ lúc tạo).
- Tạo `Workspace` + `WorkspaceMember` (người tạo) trong 1 transaction; các entry trong `assignMembers` được xử lý ngay sau đó.

## 4. UI / UX

- Trang tạo Workspace trong phạm vi 1 Agency. Có thể chọn thêm thành viên Agency để gán vào Workspace ngay lúc tạo (tùy chọn, không bắt buộc).

## 5. API Contract

```
POST /api/v1/workspaces
{
  "name": "string",
  "agencyId": "uuid",
  "industry"?: "FNB|FASHION|BEAUTY|TECHNOLOGY|REAL_ESTATE|EDUCATION|HEALTHCARE|SERVICES|RETAIL|OTHER",
  "companySize"?: "SIZE_1_10|SIZE_11_50|SIZE_51_200|SIZE_201_500|SIZE_500_PLUS",
  "website"?, "phone"?, "location"?, "description"?, "brandColor"?, "logoIcon"?, "tagline"?, "foundedYear"?,
  "facebookUrl"?, "linkedinUrl"?, "instagramUrl"?,
  "assignMembers"?: [{ "userId": "uuid", "role": "MANAGER|CREATOR|CLIENT" }]
}
→ 200 { "success": true, "data": WorkspaceResponse }
```

## 6. Error Handling

- `name` trống → 400 `VALIDATION_ERROR`.
- `agencyId` thiếu → 400 `VALIDATION_ERROR`.
- Trong `assignMembers` có nhiều hơn 1 người role MANAGER (ngoài người tạo) → 409 `MANAGER_ALREADY_ASSIGNED` (mỗi Workspace chỉ có đúng 1 MANAGER active tại một thời điểm).

## 7. Edge Cases

- Không truyền `assignMembers` → chỉ có duy nhất người tạo làm MANAGER.
- Người tạo tự chọn chính mình vào `assignMembers` với role MANAGER → không coi là "người khác", người tạo vẫn giữ MANAGER bình thường.

## 8. Definition of Done

- Tạo Workspace thành công qua `POST /api/v1/workspaces`, MANAGER được gán đúng (mặc định người tạo hoặc người được chỉ định qua `assignMembers`).

## Out of Scope

- Tạo Workspace từ Template có sẵn (xem FR 3.4.17 Save Workspace Template — đây là chiều ngược, tạo mới từ template là mở rộng UX, không bắt buộc trong CSV).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
