# Sequence Flow — Remove Member

> Bổ sung cho `spec.md` (FR 3.4.9). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyController.removeMember`, `AgencyServiceImpl.removeMember`).

## Actors

- **Owner**
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agency_members`).

---

## Flow A — Remove Member thành công

1. Owner → FE: mở `/agencies/:agencyId/members`, bấm "Remove" trên 1 Member (không phải Owner) → dialog confirm.
2. FE → BE: `DELETE /api/v1/agencies/{agencyId}/members/{memberId}` (`memberId` là `AgencyMember.id`, không phải `userId`).
3. BE (`AgencyServiceImpl.removeMember`):
   a. `findAgencyOrThrow(agencyId)`.
   b. Check `agency.getOwnerId().equals(currentUser.getId())` — sai → `403 NOT_AGENCY_OWNER`.
   c. Tìm `AgencyMember` theo `memberId`, filter `m.agencyId == agencyId` — không có → `404 NOT_FOUND`.
   d. Check `member.getRole() == AgencyMemberRole.OWNER` — nếu đúng → `409 CANNOT_REMOVE_OWNER` (chặn xóa chính Owner).
   e. `DELETE agency_members WHERE id = memberId`.
4. BE → FE: `200 { data: null }`.
5. FE: xóa dòng khỏi bảng Member, hiện toast. Member mất quyền truy cập mọi Workspace của Agency ngay lập tức (do các check quyền ở API khác đều dựa trên còn tồn tại `AgencyMember` record).
6. Tài nguyên Member từng tạo (Task, Material, Content...) **không bị xóa/không đổi owner** — vẫn thuộc Workspace/Agency.

## Flow B — Thử xóa Owner (bị chặn)

1. Owner → FE: bấm Remove trên chính dòng Owner (nếu FE không ẩn nút này) hoặc gọi trực tiếp API với `memberId` là bản ghi role OWNER.
2. FE → BE: `DELETE /api/v1/agencies/{agencyId}/members/{memberId}`.
3. BE: qua bước 3.a–3.c Flow A bình thường, đến 3.d: `member.getRole() == OWNER` → `throw BusinessException(ErrorCode.CANNOT_REMOVE_OWNER)`.
4. BE → FE: `409 { errorCode: "CANNOT_REMOVE_OWNER" }`.
5. FE: hiện lỗi, không xóa gì.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Remove | Không phải Owner của Agency | 403 | `NOT_AGENCY_OWNER` |
| Remove | `memberId` không tồn tại/không thuộc agency | 404 | `NOT_FOUND` |
| Remove | `memberId` là chính Owner (chặn tự xóa/xóa Owner) | 409 | `CANNOT_REMOVE_OWNER` |

## Ghi chú drift đã fix

- Bản trước ghi "[Sai lệch với bản audit trước] code dùng `ErrorCode.FORBIDDEN` (403), `ErrorCode` hiện không có `CANNOT_REMOVE_OWNER`". **Không còn đúng**: `ErrorCode` nay đã có `CANNOT_REMOVE_OWNER (HttpStatus.CONFLICT, "Cannot remove the owner of the agency")` và `AgencyServiceImpl.removeMember` ném mã này → **409**, không phải 403 `FORBIDDEN`. Drift đã đóng.
