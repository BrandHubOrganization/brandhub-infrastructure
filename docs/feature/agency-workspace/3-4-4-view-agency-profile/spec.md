# UC — View Agency Profile

| | |
|---|---|
| FR Code | 3.4.4 |
| Feature | View Agency Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị Profile công khai của Agency — thông tin để Client hiểu về Agency trước khi hợp tác.

## 2. User Story

Là một Owner (hoặc Client được chia sẻ),
tôi muốn xem Profile công khai của Agency,
để hiểu rõ thông tin công ty đại diện.

## 3. Acceptance Criteria

- Hiển thị: `name`, `logo`, `description`, số năm hoạt động, các case study/portfolio (nếu có mở rộng sau).
- Trang này khác Agency Dashboard (FR 3.4.2) — Dashboard là nội bộ (số liệu quản lý), Profile là công khai/giới thiệu.

## 4. UI / UX

- Trang `/agencies/:id/profile` — có thể public (không cần login) nếu dùng làm trang giới thiệu cho Client tương lai xem trước khi ký hợp đồng.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/agencies/{id}/profile
→ 200 { "success": true, "data": { "id", "name", "logoUrl", "description" } }
```

## 6. Error Handling

- Agency không tồn tại → 404 `AGENCY_NOT_FOUND`.

## 7. Edge Cases

- Nếu cho phép public view (không login) → cần đảm bảo không lộ thông tin nội bộ (danh sách Workspace, Member) qua endpoint này.

## 8. Definition of Done

- Profile hiển thị đúng thông tin công khai, không lộ thông tin nội bộ.

## Out of Scope

- Portfolio/case study đầy đủ (mở rộng sau, CSV chỉ yêu cầu thông tin cơ bản).

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
