# UC — Generate Ambassador

| | |
|---|---|
| FR Code | 3.7.3 |
| Feature | Generate Ambassador |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Dùng LLM generate Model (người ảo) khi brand không có model thật — Model được dùng làm input cho Generate Image và Generate Video.

## 2. User Story

Là một Creator,
tôi muốn tạo 1 Ambassador ảo bằng AI,
để dùng làm người mẫu đại diện khi brand chưa có người thật.

## 3. Acceptance Criteria

- Input: mô tả ngoại hình/phong cách mong muốn.
- AI trả về Ambassador (hình ảnh đại diện) — lưu lại để tái sử dụng làm input cho Generate Image (FR 3.7.5) và Generate Video (FR 3.7.7).

## 4. UI / UX

- Trang `/workspaces/:id/ai/ambassador`, kết quả lưu vào Material Repository dạng riêng (loại 'ambassador').

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/generate-ambassador
{ "description": "string", "style"? }
→ 200 { "success": true, "data": { "ambassadorId", "previewUrl", "creditsUsed" } }
```

## 6. Error Handling

- Hết credit → 402 `INSUFFICIENT_AI_CREDIT`.

## 7. Edge Cases

- Ambassador tạo ra dùng cho nhiều Task khác nhau (tái sử dụng) → không trừ credit thêm lần sau khi chỉ tái sử dụng (không generate mới).

## 8. Definition of Done

- Generate Ambassador thành công, dùng lại được cho Image/Video generation.

## Out of Scope

- Không có.

## Tham chiếu BA

[06_AI_Features.md](../../../BA/06_AI_Features.md)
