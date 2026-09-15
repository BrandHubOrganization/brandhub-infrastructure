# UC — Export Report File PDF

| | |
|---|---|
| FR Code | 3.10.12 |
| Feature | Export Report File PDF |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xuất báo cáo cho các trang quản lý User, Revenue... dạng PDF.

## 2. User Story

Là một Admin,
tôi muốn export báo cáo dạng PDF,
để lưu trữ hoặc trình bày cho các bên liên quan.

## 3. Acceptance Criteria

- Chọn loại báo cáo (User list, Revenue...) + khoảng thời gian → generate PDF, download trực tiếp.

## 4. UI / UX

- Nút 'Export PDF' trong các trang Admin liên quan (Users, Revenue).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/admin/reports/export?type=user|revenue&from=...&to=...&format=pdf
→ 200 (binary PDF stream)
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.
- Không có dữ liệu trong khoảng thời gian chọn → vẫn generate PDF (trang trống có ghi chú 'không có dữ liệu'), không lỗi.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Export PDF thành công, đúng dữ liệu theo filter.

## Out of Scope

- Export định dạng khác (Excel, CSV) — CSV chỉ yêu cầu PDF.

## Tham chiếu BA

[09-admin-management.md](../../../BA/09-admin-management.md)
