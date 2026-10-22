# Định nghĩa file `task.md`

## Mục đích

`task.md` trả lời câu hỏi **"Cần làm những bước cụ thể gì, xong bước nào chưa"** — chẻ `plan.md` thành checklist thực thi để dev tự theo dõi tiến độ và để người khác (Trung/reviewer) biết đang làm tới đâu mà không cần hỏi trực tiếp.

## Ai viết, khi nào viết

Dev tự viết ngay trước khi bắt đầu code, dựa trên `plan.md` đã có. Cập nhật (tick checkbox) liên tục trong lúc code — không viết 1 lần rồi bỏ quên, file này phải phản ánh đúng tiến độ thật tại mọi thời điểm.

## Nội dung cần có

- Checklist dạng `- [ ] việc cần làm` — mỗi dòng là một bước triển khai nhỏ, đủ cụ thể để biết "làm xong" nghĩa là gì (không viết mơ hồ kiểu "làm backend", phải là "viết `AgencyController.list()` + `AgencyService.findByOwnerId()`").
- Thứ tự các bước theo đúng trình tự triển khai thật (thường: entity/schema → service logic → API endpoint → validate/error handling → frontend nếu có → viết test).
- Đánh dấu rõ bước nào đang làm, bước nào chặn bởi task/FR khác (link tới FR đó).
- Khi phát sinh việc ngoài dự kiến lúc code (bug, thiếu case) → thêm dòng mới vào đây, không giấu trong commit message.

## Ranh giới với các file khác

- Không lặp lại thiết kế kỹ thuật đã có trong `plan.md` — chỉ trỏ tới, mỗi dòng task chỉ là hành động ngắn.
- Không phải nơi ghi log nghiệp vụ hay quyết định thiết kế — quyết định thiết kế mới phát sinh thì sửa `plan.md`, chỉ tick/thêm dòng hành động ở đây.
- Khi tất cả checkbox đã tick và code đã qua `test.md` → FR coi như Done, không cần giữ file task ở trạng thái "đang làm" nữa.
