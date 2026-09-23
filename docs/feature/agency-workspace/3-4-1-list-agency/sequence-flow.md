# Sequence Flow — List Agency

> Bổ sung cho `spec.md` (FR 3.4.1). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AgencyController.listMyAgencies`, `AgencyServiceImpl.listMyAgencies`).

## Actors

- **User** — người đang login (có thể là Owner của 0..N Agency, hoặc Member của Agency khác).
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`agencies`, `agency_members`).

---

## Flow A — Xem danh sách Agency

1. User → FE: login xong, vào trang `/agencies` (landing mặc định nếu có ≥1 Agency).
2. FE → BE: `GET /api/v1/agencies`.
3. BE (`AgencyServiceImpl.listMyAgencies`):
   a. Query `agency_repository.findByOwnerIdAndStatusNot(currentUser.id, SOFT_DELETED)` → tập id Agency user là Owner.
   b. Query `agencyMemberRepository.findByUserId(currentUser.id)` → gộp thêm id Agency user là Member (union vào cùng 1 `Set<UUID>`, loại trùng).
   c. `findAllById(ids)`, filter lần nữa loại `status == SOFT_DELETED`, map sang `AgencyResponse`.
4. BE → FE: `200 { data: [ AgencyResponse, ... ] }` (rỗng nếu user chưa thuộc Agency nào).
5. FE: render danh sách. Nếu rỗng → hiện empty state kèm nút "Tạo Agency mới" (dẫn sang FR 3.4.3).
6. User bấm vào 1 Agency → FE `navigate` sang trang chi tiết (dùng chung `GET /{agencyId}` của FR 3.4.4, chưa có Dashboard riêng theo FR 3.4.2).

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| List | Không có — luôn trả 200 kể cả list rỗng | — | — |

Không có nhánh lỗi nghiệp vụ nào cho FR này — chỉ có lỗi hạ tầng chung (401 nếu chưa login, do filter xác thực xử lý trước khi vào controller, không thuộc phạm vi service).

## Ghi chú khác biệt so với spec.md gốc

- Không có khác biệt — spec.md đã mô tả đúng: response gộp cả Owner lẫn Member dù tên FR là "List Agency" theo góc nhìn Owner (mục "Out of Scope" của spec.md đã lưu ý về điểm này, đây không phải drift mà là ghi chú sẵn trong spec).
