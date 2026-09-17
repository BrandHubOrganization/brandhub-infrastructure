# Định nghĩa file `plan.md`

## Mục đích

`plan.md` trả lời câu hỏi **"Kỹ thuật triển khai như thế nào"** — dịch nghiệp vụ trong `spec.md` thành thiết kế cụ thể: động chạm file/module nào, schema nào, API contract final, thứ tự implement ra sao. Đây là bước dev tự thiết kế trước khi viết code thật, để review được trước khi tốn công code sai hướng.

## Ai viết, khi nào viết

Dev được giao task viết, **sau khi `spec.md` đã ở trạng thái confirmed** (không viết plan cho spec còn Draft/chưa rõ). Viết trước khi code, không viết song song hoặc sau khi code xong (mất tác dụng review trước).

## Nội dung cần có

| Mục | Nội dung |
|---|---|
| Liên kết | Link tới `spec.md` cùng FR, tóm tắt 1 câu lại mục tiêu |
| Phạm vi kỹ thuật | Repo/service nào bị động (business-service, ai-service, web-dashboard...), file/module chính sẽ tạo hoặc sửa |
| API Contract (final) | Method, path, request/response schema thật — chốt lại từ đề xuất ở `spec.md`, khác gì thì ghi rõ vì sao |
| Data Model | Bảng/collection nào đọc/viết, field nào mới cần thêm, migration cần không |
| Luồng xử lý | Bước xử lý chính ở backend/frontend (business logic, validation, side-effect) — không cần pseudo-code chi tiết, chỉ cần đủ để review đúng-sai logic |
| Dependencies | Feature/API/service nào phải xong trước; feature nào bị chặn bởi cái này |
| Rủi ro kỹ thuật | Chỗ dễ sai, cần cẩn thận (concurrency, third-party rate limit, migration dữ liệu cũ...) |

## Ranh giới với các file khác

- Không lặp lại nghiệp vụ đã có trong `spec.md` — chỉ link tới, không copy AC.
- Không chẻ nhỏ ra từng bước code cụ thể (đó là việc của `task.md`) — `plan.md` là thiết kế, `task.md` là checklist thực thi.
- Nếu lúc code phát hiện thiết kế trong `plan.md` sai/thiếu → sửa `plan.md` trước khi tiếp tục code, giữ file luôn phản ánh đúng cái đang code.
