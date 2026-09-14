# UC — View Comment Detail List

| | |
|---|---|
| FR Code | 3.8.5 |
| Feature | View Comment Detail List |
| Domain | Publishing & Social (FR 3.8) |
| Role | MEMBER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị danh sách chi tiết comment từ bài post.

## 2. User Story

Là một Member,
tôi muốn xem danh sách comment của 1 bài đăng,
để theo dõi phản hồi từ người xem.

## 3. Acceptance Criteria

- List comment: tên người comment, nội dung, thời gian, (nếu API platform hỗ trợ) sentiment cơ bản.

## 4. UI / UX

- Tab 'Comments' trong trang Post Track Detail.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/workspaces/{id}/posts/{postId}/comments
→ 200 { "success": true, "data": [{ "author", "content", "commentedAt" }] }
```

## 6. Error Handling

- Platform API lỗi khi fetch comment → 502 `PLATFORM_API_ERROR`, hiển thị cache cũ nếu có.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Hiển thị đúng list comment.

## Out of Scope

- Reply comment trực tiếp từ hệ thống (không có trong CSV).

## Tham chiếu BA

[07_Publishing_Social_Collaborator.md](../../../BA/07_Publishing_Social_Collaborator.md)
