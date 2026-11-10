# Plan — List Agency (FR 3.4.1)

> Liên kết: [spec.md](spec.md) — cho User xem danh sách Agency họ có quyền truy cập (Owner hoặc Member).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `AgencyServiceImpl.listMyAgencies()` |
| File đã có | `AgencyController` (`GET /api/v1/agencies`), `AgencyRepository`, `AgencyMemberRepository`, `AgencyResponse` |

## 2. API Contract (final)

```
GET /api/v1/agencies
Authorization: Bearer <access-token>
→ 200 ApiResponse<List<AgencyResponse>>
   data = [{ id, name, ownerId, logoUrl, description, status, createdAt, updatedAt }]
```

Khác so với spec.md (đề xuất `GET /api/v1/agencies` trả `workspaceCount` + `createdAt`):

- **Không có `workspaceCount`** — `AgencyResponse` chưa có field này (Workspace chưa liên kết `agencyId`, thuộc DA-E16-10 chưa làm). Bỏ khỏi response hiện tại, bổ sung khi FK `Workspace.agency_id` xong.
- **Trả về cả Agency user làm Member**, không chỉ Owner. Lý do: dashboard user mới đăng ký cần thấy Agency họ được mời vào (khớp luồng accept invitation). Đã ghi nhận lệch với tên FR "Owner-only" trong spec — xem mục 6.

## 3. Data Model

- Đọc `agencies` qua `findByOwnerIdAndStatusNot(userId, SOFT_DELETED)` + `agency_members` qua `findByUserId(userId)`.
- Gộp 2 tập `agencyId` (dùng `LinkedHashSet` giữ thứ tự ổn định), rồi `findAllById`.
- Filter lần cuối loại `SOFT_DELETED` (bảo vệ Agency bị soft-delete mà member record còn sót).
- **Không migration**.

## 4. Luồng xử lý

1. Lấy các `Agency` do user sở hữu, chưa soft-delete.
2. Lấy các `AgencyMember` của user → thêm `agencyId` vào tập hợp.
3. `findAllById` → filter `status != SOFT_DELETED` → map `toResponse`.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Agency`/`AgencyMember` entity + repository (đã có) |
| Bị chặn | `View Agency Profile` (3.4.4), `Update` (3.4.5) — cùng repo |

## 6. Rủi ro kỹ thuật

- **Lệch spec "Owner-only":** spec ghi Role OWNER và Out-of-Scope "list Agency user chỉ là Member". Code trả cả owned+member vì luồng mời user cần thấy Agency họ được accept. Cần BA confirm lại nếu muốn giữ đúng Owner-only — chưa chặn, để ghi chú mở.
- **Member của Agency bị soft-delete:** `findByUserId` trả member record mà Agency đã `SOFT_DELETED` → filter cuối loại bỏ. Đã xử lý ở bước 3.
