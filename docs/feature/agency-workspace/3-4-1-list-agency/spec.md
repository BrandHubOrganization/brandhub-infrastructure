# UC — List Agency

| | |
|---|---|
| FR Code | 3.4.1 |
| Feature | List Agency |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.1 — Cập nhật 2026-09-23 — đồng bộ theo code thật |
| Trạng thái tài liệu | Confirmed — đã code (`AgencyController.listMyAgencies`, `AgencyServiceImpl.listMyAgencies`) |

## 1. Objective

Hiển thị danh sách Agency mà User hiện tại đang sở hữu (là Owner).

## 2. User Story

Là một User,
tôi muốn xem danh sách các Agency tôi đang sở hữu,
để chọn vào 1 Agency cụ thể để quản lý.

## 3. Acceptance Criteria

- List tất cả `Agency` mà current user là Owner (`ownerId = current user`) **hoặc** là Member (có `AgencyMember` record) — code thật gộp cả 2 nguồn (`findByOwnerIdAndStatusNot` + `agencyMemberRepository.findByUserId`), loại trừ `SOFT_DELETED`.
- Mỗi item trả về đầy đủ field của Agency (xem API Contract) — không có `workspaceCount` tính sẵn trong response hiện tại.
- Bấm vào 1 Agency → vào Agency Dashboard (FR 3.4.2 — hiện chưa có endpoint riêng, dùng GET chi tiết FR 3.4.4).
- Có nút 'Tạo Agency mới' → FR 3.4.3.

## 4. UI / UX

- Trang `/agencies` (landing sau login nếu User có ≥1 Agency; nếu chưa có Agency nào → hiển thị empty state mời tạo mới).

## 5. API Contract (khớp code thật)

```
GET /api/v1/agencies
→ 200 { "success": true, "data": [ AgencyResponse, ... ] }
```

`AgencyResponse` (dùng chung cho List/Create/Get/Update):

| Field | Kiểu/Ghi chú |
|---|---|
| id | UUID |
| name | string |
| ownerId | UUID |
| logoUrl | string |
| description | string |
| category | enum AgencyCategory: MARKETING, FNB, FASHION, BEAUTY, TECHNOLOGY, REAL_ESTATE, EDUCATION, HEALTHCARE, RETAIL, FINANCE, ENTERTAINMENT, OTHER |
| companySize | enum CompanySize: SIZE_1_10, SIZE_11_50, SIZE_51_200, SIZE_201_500, SIZE_500_PLUS |
| website | string |
| phone | string |
| location | string |
| brandColor | string (hex) |
| logoIcon | string |
| tagline | string |
| foundedYear | integer |
| facebookUrl | string |
| linkedinUrl | string |
| instagramUrl | string |
| status | enum EntityStatus (ACTIVE / SOFT_DELETED / ...) |
| createdAt | OffsetDateTime |
| updatedAt | OffsetDateTime |

## 6. Error Handling

- Không có lỗi đặc biệt — luôn trả list (rỗng nếu chưa có Agency).

## 7. Edge Cases

- User mới đăng ký, chưa từng tạo Agency → empty state, không lỗi.

## 8. Definition of Done

- List đúng chỉ các Agency user là Owner (không lẫn Agency họ chỉ là Member).

## Out of Scope

- List Agency mà user chỉ là Member (không phải Owner) — không thuộc FR này (Owner-only theo tên FR).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
