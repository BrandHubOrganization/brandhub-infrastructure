# UC — Disconnect Account

| | |
|---|---|
| FR Code | 3.8.2 |
| Feature | Disconnect Account |
| Domain | Publishing & Social (FR 3.8) |
| Role | CLIENT |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Ngắt kết nối tài khoản social, log out khỏi mạng xã hội.

## 2. User Story

Là một Client,
tôi muốn ngắt kết nối tài khoản social,
khi tôi không muốn Agency đăng bài thay tôi nữa.

## 3. Acceptance Criteria

- Revoke token phía platform (nếu API hỗ trợ) + xóa/deactivate record `SocialAccount` phía hệ thống.

## 4. UI / UX

- Nút 'Ngắt kết nối' trong `/workspaces/:id/social-accounts`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/social/accounts/{accountId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không phải Client sở hữu account này → 403 `FORBIDDEN`.

## 7. Edge Cases

- Disconnect khi đang có Post `PENDING` chờ publish qua tài khoản này → Post đó chuyển `FAIL` với lý do rõ ràng (account disconnected), không publish ngầm.

## 8. Definition of Done

- Disconnect thành công, các Post pending qua account này được xử lý đúng (fail rõ lý do).

## Out of Scope

- Không có.

## Tham chiếu BA

[07_Publishing_Social_Collaborator.md](../../../BA/07_Publishing_Social_Collaborator.md)
