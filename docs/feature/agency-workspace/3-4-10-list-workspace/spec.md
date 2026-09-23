# UC — List Workspace

| | |
|---|---|
| FR Code | 3.4.10 |
| Feature | List Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER/MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị danh sách Workspace — Member chỉ coi workspace mình có mặt, Owner coi toàn bộ Workspace của Agency.

## 2. User Story

Là một Owner hoặc Member,
tôi muốn xem danh sách Workspace,
để chọn vào 1 Workspace cụ thể để làm việc.

## 3. Acceptance Criteria

- Nếu current user là **Owner** của Agency → trả TOÀN BỘ Workspace thuộc Agency đó, bất kể họ có là WorkspaceMember hay không.
- Nếu current user chỉ là **Member** (không phải Owner Agency) → chỉ trả các Workspace mà họ có `WorkspaceMember` record (đang tham gia).

## 4. UI / UX

- Trang `/agencies/:id/workspaces`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/agencies/{id}/workspaces
→ 200 { "success": true, "data": [{ "id", "name", "myRole": "OWNER|MANAGER|MEMBER|null", "memberCount", "clientCount" }] }
```

## 6. Error Handling

- Không có quyền truy cập Agency này (không phải Owner, không phải Member của Agency) → 403 `FORBIDDEN`.

## 7. Edge Cases

- Owner chưa từng tự add mình vào bất kỳ Workspace nào → vẫn thấy toàn bộ list (Owner luôn xem được hết, `myRole` trả `null` nếu chưa có WorkspaceMember record).

## 8. Definition of Done

- Owner thấy toàn bộ, Member chỉ thấy Workspace mình tham gia (verify bằng 2 test case riêng).

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
