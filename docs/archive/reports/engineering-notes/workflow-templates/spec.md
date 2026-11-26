# Định nghĩa file `spec.md`

## Mục đích

`spec.md` trả lời câu hỏi **"Feature này làm gì, cho ai, đúng ra sao"** — chốt nghiệp vụ trước khi bất kỳ ai viết code. Đây là hợp đồng giữa BA và Dev: dev không tự suy diễn nghiệp vụ, mọi câu hỏi "case này xử lý sao" phải có câu trả lời trong file này (hoặc phải bổ sung vào file này trước khi code).

## Ai viết, khi nào viết

BA/Trung viết trước khi giao task cho dev. Trạng thái `Draft` cho tới khi BA confirm xong nghiệp vụ, dev **không code khi spec còn Draft có phần chưa rõ**.

## Cấu trúc bắt buộc (theo mẫu đang dùng trong repo)

| Mục | Nội dung |
|---|---|
| Header table | FR Code, Feature name, Domain, Role được phép dùng, Version, Trạng thái tài liệu |
| 1. Objective | Một câu mô tả feature giải quyết vấn đề gì |
| 2. User Story | Format "Là một [role], tôi muốn..., để..." |
| 3. Acceptance Criteria | Danh sách điều kiện nghiệp vụ phải đúng — đây là nguồn cho `test.md` sau này, viết đủ chi tiết để tự sinh test case được |
| 4. UI/UX | Route/trang liên quan, hành vi hiển thị chính (không phải wireframe chi tiết, chỉ đủ để dev hiểu luồng) |
| 5. API Contract (đề xuất) | Method + path + response shape đề xuất — **chưa final**, `plan.md` sẽ chốt lại khi thiết kế kỹ thuật |
| 6. Error Handling | Các lỗi nghiệp vụ cần xử lý và cách xử lý |
| 7. Edge Cases | Case biên (user mới, dữ liệu rỗng, quyền hạn chế...) |
| 8. Definition of Done | Điều kiện để coi feature "xong" ở mức nghiệp vụ |
| Out of Scope | Ghi rõ cái gì KHÔNG thuộc FR này — tránh dev tự mở rộng phạm vi |
| Tham chiếu BA | Link tới tài liệu BA gốc (`docs/BA/*.md`) làm nguồn nghiệp vụ |

## Ranh giới với các file khác

- `spec.md` nói **CÁI GÌ** (what) — không nói **LÀM SAO** (how) ở mức code/database/thư viện. Chi tiết kỹ thuật thuộc về `plan.md`.
- Nếu trong lúc code phát sinh câu hỏi nghiệp vụ mới → sửa `spec.md` trước (và note lại), không tự quyết trong code hoặc chỉ ghi trong `plan.md`/comment.
