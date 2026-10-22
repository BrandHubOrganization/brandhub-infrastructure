# Định nghĩa file `test.md`

## Mục đích

`test.md` trả lời câu hỏi **"Làm sao biết feature này đúng"** — liệt kê test case cụ thể suy ra trực tiếp từ Acceptance Criteria trong `spec.md`, để verify code chạy đúng trước khi coi FR là Done. Không phải file dump kết quả test tự động chạy (CI report), mà là bảng test case người viết trước, dùng để tự kiểm hoặc code test tự động theo.

## Ai viết, khi nào viết

Dev viết song song hoặc ngay sau khi code — mỗi Acceptance Criteria ở `spec.md` phải có ít nhất một test case tương ứng ở đây. Không viết test case chung chung không map được về AC nào.

## Nội dung cần có

| Cột | Nội dung |
|---|---|
| Test case ID | Ngắn, ví dụ `TC-01`, `TC-02` |
| Mô tả | Input/điều kiện cụ thể đang test |
| AC liên quan | Trỏ về đúng dòng AC nào trong `spec.md` |
| Kết quả mong đợi | Output/response/behavior đúng phải là gì |
| Loại | Happy path / Edge case / Error case — phải có đủ cả 3 loại, không chỉ test happy path |
| Trạng thái | Pass/Fail/Chưa test — cập nhật thật khi verify |

Bắt buộc bao gồm: mọi Edge Case và Error Handling đã ghi trong `spec.md` (mục 6, 7) phải xuất hiện thành test case ở đây — nếu spec có ghi edge case mà không có test case tương ứng, coi như chưa xong.

## Ranh giới với các file khác

- Không viết lại nghiệp vụ — mỗi test case chỉ cần trỏ về AC, không copy nguyên văn.
- Không phải checklist công việc (đó là `task.md`) — đây là bảng kiểm chứng kết quả, viết theo input/output, không viết theo hành động "làm gì".
- FR chỉ coi là Done khi toàn bộ test case ở đây ở trạng thái Pass — nếu có test Fail mà vẫn đóng FR, phải ghi rõ lý do (known issue, chờ fix sau) ngay tại dòng đó.
