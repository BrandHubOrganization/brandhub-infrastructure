# UC — View Agency Profile

| | |
|---|---|
| FR Code | 3.4.4 |
| Feature | View Agency Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER, MEMBER (AgencyMember bất kỳ role) |
| Version | 2.2 — Cập nhật 2026-09-23 — thêm kiểm tra quyền owner/member |
| Trạng thái tài liệu | Confirmed — đã code, dùng chung endpoint GET Agency (`AgencyController.getAgency`), **không có route `/profile` riêng**. Endpoint **yêu cầu đăng nhập** và **chỉ OWNER hoặc MEMBER của Agency** mới xem được. |

## 1. Objective

Hiển thị Profile của Agency — thông tin branding/giới thiệu công ty cho thành viên trong Agency. Chỉ OWNER hoặc MEMBER của Agency xem được.

## 2. User Story

Là một Owner hoặc Member của Agency,
tôi muốn xem Profile của Agency,
để nắm thông tin công ty đại diện.

## 3. Acceptance Criteria

- Hiển thị toàn bộ field của `AgencyResponse` — `name`, `logoUrl`, `description`, `category`, `companySize`, `website`, `phone`, `location`, `brandColor`, `logoIcon`, `tagline`, `foundedYear`, `facebookUrl`, `linkedinUrl`, `instagramUrl` (xem bảng field đầy đủ tại FR 3.4.1). `foundedYear` dùng để hiển thị số năm hoạt động (tính từ năm hiện tại).
- Trang này khác Agency Dashboard (FR 3.4.2) — Dashboard là số liệu quản lý, Profile là phần giới thiệu/branding của Agency. Cả hai đều yêu cầu user thuộc Agency.
- **Quyền xem:** chỉ OWNER hoặc MEMBER của Agency xem được. User ngoài Agency (kể cả đã đăng nhập) → `400 NOT_AGENCY_MEMBER`.
- **Không có endpoint `/profile` riêng trong code** — FE gọi chung `GET /api/v1/agencies/{agencyId}` (`getAgency`) dùng cho cả FR 3.4.4 lẫn phần "xem chi tiết" sau khi List (FR 3.4.1). Endpoint này **yêu cầu Bearer token** (`@AuthenticationPrincipal AuthenticatedUser currentUser` trong controller) và **kiểm tra quyền ở service**: chỉ user là OWNER (`agency.ownerId == currentUser.id`) hoặc có bản ghi `AgencyMember` của agency đó mới xem được; nếu không → `400 NOT_AGENCY_MEMBER`.

## 4. UI / UX

- Trang `/agencies/:agencyId/profile` (FE route riêng) nhưng gọi chung API GET Agency.
- **Không còn là trang public** — user phải đăng nhập và là owner/member của Agency. Client bên ngoài chưa xem trước được profile Agency (nếu BA cần trang giới thiệu public cho Client tiềm năng thì phải mở thêm route công khai riêng, hiện chưa có).

## 5. API Contract (khớp code thật)

```
GET /api/v1/agencies/{agencyId}
Authorization: Bearer <access-token>
→ 200 { "success": true, "data": AgencyResponse }
```

Không có `GET /{agencyId}/profile` riêng. `AgencyResponse` — xem bảng field đầy đủ tại spec FR 3.4.1.

## 6. Error Handling

- Thiếu/sai token → 401 `UNAUTHORIZED` (chặn ở `JwtAuthenticationFilter`, không vào tới service).
- Agency không tồn tại → 404 `AGENCY_NOT_FOUND`.
- User không phải OWNER và cũng không phải MEMBER của Agency → 400 `NOT_AGENCY_MEMBER`.

## 7. Edge Cases

- Response không trả field nội bộ nào ngoài branding/thông tin công ty (không có danh sách Workspace/Member).
- Owner luôn xem được kể cả khi không có bản ghi `AgencyMember` (check `agency.ownerId` độc lập với check member).
- MEMBER (role MEMBER/MANAGER/CREATOR trong `AgencyMember`) xem được profile — không phân biệt role.
- Agency đã soft-delete: `findAgencyOrThrow` hiện vẫn trả về bản ghi (chỉ `findById`, không lọc status) → owner/member vẫn xem được profile; xem thêm FR 3.4.6.

## 8. Definition of Done

- Profile hiển thị đúng thông tin công khai, không lộ thông tin nội bộ.
- Chỉ OWNER/MEMBER của Agency truy cập được; user ngoài Agency nhận `400 NOT_AGENCY_MEMBER`.

## Out of Scope

- Portfolio/case study đầy đủ (mở rộng sau, CSV chỉ yêu cầu thông tin cơ bản).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
