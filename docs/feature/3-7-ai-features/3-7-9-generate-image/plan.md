# Plan — Generate Image (FR 3.7.5)

> Liên kết: [spec.md](spec.md) — Sử dụng LLM và promt để tạo ra Image cho bài post.
Việc sinh Image sẽ dựa vào input từ form + model + others materials chuyển thành prompt.
Có LoRA lại model LLM gen Image..

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service`, `brandhub-web-dashboard` |
| File implement | `AiServiceClient.processRequest()` |
| File đã có | `AiGenerationController` (`POST /api/v2/ai/image/commercial/generate`), `imageUrl, creditsUsed=1, remainingCredits` |

## 2. API Contract (final)

```
POST /api/v2/ai/image/commercial/generate
Authorization: Bearer <access-token>
→ 200 ApiResponse<imageUrl, creditsUsed=1, remainingCredits>
```

- Endpoint phục vụ nghiệp vụ `Generate Image` cho Actor `Creator`.
- Chuẩn hóa DTO phản hồi đảm bảo đúng định dạng `imageUrl, creditsUsed=1, remainingCredits` với đầy đủ metadata và timestamp.

## 3. Data Model

- Bảng dữ liệu chính: `aimicroservices` qua `AiCreditLedgerRepository`.
- Kiểm tra toàn vẹn dữ liệu, các ràng buộc khóa ngoại và logic trạng thái nghiệp vụ.
- **Không migration bổ sung** (tận dụng schema hiện hành).

## 4. Luồng xử lý

1. Xác thực danh tính caller qua JWT Token và phân quyền truy cập.
2. Kiểm tra tính hợp lệ của tham số đầu vào và trạng thái nghiệp vụ đối tượng.
3. `AiServiceClient` thực thi logic nghiệp vụ trọng tâm `processRequest()`.
4. Tương tác với `AiCreditLedgerRepository` để truy vấn/cập nhật cơ sở dữ liệu.
5. Map kết quả sang `imageUrl, creditsUsed=1, remainingCredits` và phản hồi 200 OK về Client.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | Các cấu hình bảo mật, Token Authentication và schema cơ sở dữ liệu liên quan |
| Bị chặn | Các nghiệp vụ phụ thuộc vào trạng thái hoàn tất của Generate Image |
