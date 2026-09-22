# Plan — Remove Member (FR 3.4.9)

> Liên kết: [spec.md](spec.md) — cho Owner xóa Member khỏi Agency, giữ nguyên tài nguyên họ tạo.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.removeMember()` |
| File đã có | `AgencyController` (`DELETE /{agencyId}/members/{memberId}`) |

## 2. API Contract (final)

```
DELETE /api/v1/agencies/{agencyId}/members/{memberId}
Authorization: Bearer <access-token>
→ 200 ApiResponse<Void> (data = null)
```

Khác so với spec.md: không lệch đáng kể. Spec ghi `409 CANNOT_REMOVE_OWNER` — code dùng `FORBIDDEN` (403) khi cố xóa OWNER (xem mục 6).

## 3. Data Model

- Xóa record `agency_members` (hard delete `delete(member)`).
- **Không** đụng tới tài nguyên member tạo (Task/Material/Content) — đúng AC: tài sản chung của Agency.
- Không migration.

## 4. Luồng xử lý

1. `findAgencyOrThrow(agencyId)` → 404; owner-check → 403 `NOT_AGENCY_OWNER`.
2. Tìm member theo `memberId` + `agencyId` → nếu không `NOT_FOUND`.
3. Nếu `member.role == OWNER` → 403 `FORBIDDEN` (không xóa Owner qua FR này).
4. `agencyMemberRepository.delete(member)`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `AgencyMember` entity + repository (đã có) |
| Bị chặn | không |

## 6. Rủi ro kỹ thuật

- **`CANNOT_REMOVE_OWNER` vs `FORBIDDEN`:** spec ghi 409 `CANNOT_REMOVE_OWNER`, code dùng 403 `FORBIDDEN` (error code chung). Nếu cần phân biệt rõ, bổ sung error code riêng. Ghi chú để BA quyết.
- **Task `IN_PROGRESS` của member bị xóa (spec mục 7):** không auto unassign — đúng spec, Manager reassign thủ công. Không cần xử lý.
