# UC — Generate Livestream Script

| | |
|---|---|
| FR Code | 3.7.11 |
| Feature | Generate Livestream Script |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạo mẫu kịch bản cho livestream, hỗ trợ trực tiếp FR 3.6.23 Write Livestream Script.

## 2. User Story

Là một Creator,
tôi muốn AI tạo bản kịch bản mẫu cho livestream,
để có điểm khởi đầu trước khi tự viết/chỉnh sửa hoàn chỉnh.

## 3. Acceptance Criteria

- Input: idea/goal của buổi livestream (từ FR 3.6.22) → AI trả về script mẫu theo timeline segment.
- Creator có thể chỉnh sửa tiếp trên bản AI gợi ý (không tự động áp dụng thẳng vào FR 3.6.23, cần Creator review).

## 4. UI / UX

- Nút 'AI Generate Script' trong tab Script của Task Detail (loại Livestream).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/generate-livestream-script
{ "idea", "goal" }
→ 200 { "success": true, "data": { "segments": [{ "timeMark", "content" }] } }
```

## 6. Error Handling

- Hết credit → 402 `INSUFFICIENT_AI_CREDIT`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Generate script mẫu thành công, đúng format timeline segment để Creator chỉnh sửa tiếp.

## Out of Scope

- Không có.

## Tham chiếu BA

[06_AI_Features.md](../../../BA/06_AI_Features.md)
