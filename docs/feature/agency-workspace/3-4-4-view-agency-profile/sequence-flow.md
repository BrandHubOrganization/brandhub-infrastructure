# Sequence Flow — View Agency Profile

> Bổ sung cho `spec.md` (FR 3.4.4). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyController.getAgency`, `AgencyServiceImpl.getAgency`).

## Actors

- **Viewer** — Owner hoặc Member của Agency (bắt buộc đăng nhập; endpoint có check quyền).
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agencies`, `agency_members`).

---

## Flow A — Xem Agency Profile

1. Viewer → FE: mở `/agencies/:agencyId/profile`.
2. FE → BE: `GET /api/v1/agencies/{agencyId}` kèm `Authorization: Bearer <access-token>` (route dùng chung với FR 3.4.1 "xem chi tiết" — không có route `/profile` riêng).
3. BE (`JwtAuthenticationFilter`): thiếu/sai token → `401 UNAUTHORIZED`, dừng trước khi vào service.
4. BE (`AgencyServiceImpl.getAgency`):
   a. `findAgencyOrThrow(agencyId)` — không tồn tại → `404 AGENCY_NOT_FOUND`.
   b. `isOwner = agency.getOwnerId().equals(currentUser.getId())`.
   c. `isMember = agencyMemberRepository.findByAgencyIdAndUserId(agencyId, currentUser.getId()).isPresent()`.
   d. `!isOwner && !isMember` → `400 NOT_AGENCY_MEMBER`.
   e. Map `Agency` → `AgencyResponse`.
5. BE → FE: `200 { data: AgencyResponse }`.
6. FE: render Profile — `name`, `logoUrl`, `description`, `category`, `companySize`, `website`, `phone`, `location`, `brandColor`, `logoIcon`, `tagline`, `foundedYear` (tính số năm hoạt động = năm hiện tại − `foundedYear`), `facebookUrl`, `linkedinUrl`, `instagramUrl`.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Filter | Thiếu/sai/expired token | 401 | `UNAUTHORIZED` |
| Get | Agency không tồn tại | 404 | `AGENCY_NOT_FOUND` |
| Get | User không phải OWNER và không phải MEMBER | 400 | `NOT_AGENCY_MEMBER` |

## Ghi chú drift đã fix

- Bản trước ghi endpoint "không check quyền / không yêu cầu login (public)". **Sai so với code hiện tại** — `AgencyController.getAgency` đã có `@AuthenticationPrincipal AuthenticatedUser currentUser`, và `AgencyServiceImpl.getAgency` check OWNER (`agency.ownerId`) hoặc MEMBER (`agencyMemberRepository.findByAgencyIdAndUserId`) → ném `NOT_AGENCY_MEMBER`. Không còn public view.
