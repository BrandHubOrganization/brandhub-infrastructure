# UC — List Agency

| | |
|---|---|
| FR Code | 3.4.1 |
| Feature | List Agency |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị danh sách Agency mà User hiện tại đang sở hữu (là Owner).

## 2. User Story

Là một User,
tôi muốn xem danh sách các Agency tôi đang sở hữu,
để chọn vào 1 Agency cụ thể để quản lý.

## 3. Acceptance Criteria

- List tất cả `Agency` có `ownerId = current user`.
- Mỗi item hiển thị: tên, logo, số Workspace, ngày tạo.
- Bấm vào 1 Agency → vào Agency Dashboard (FR 3.4.2).
- Có nút 'Tạo Agency mới' → FR 3.4.3.

## 4. UI / UX

- Trang `/agencies` (landing sau login nếu User có ≥1 Agency; nếu chưa có Agency nào → hiển thị empty state mời tạo mới).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/agencies
→ 200 { "success": true, "data": [{ "id", "name", "logoUrl", "workspaceCount", "createdAt" }] }
```

## 6. Error Handling

- Không có lỗi đặc biệt — luôn trả list (rỗng nếu chưa có Agency).

## 7. Edge Cases

- User mới đăng ký, chưa từng tạo Agency → empty state, không lỗi.

## 8. Definition of Done

- List đúng chỉ các Agency user là Owner (không lẫn Agency họ chỉ là Member).

## Out of Scope

- List Agency mà user chỉ là Member (không phải Owner) — không thuộc FR này (Owner-only theo tên FR).

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)
