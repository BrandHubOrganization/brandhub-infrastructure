# Agency Subscription — Checklist thực thi

Đọc [spec](spec.md), [plan](plan.md), [test](test.md) trước code. Các task tổng thể vẫn mở; execution slice hiện tại chỉ thực hiện Basic→Plus agency với SePay và entrypoint owner.

## Execution slice: Agency Basic→Plus qua SePay

- [x] Backend: owner tạo order idempotent, QR lấy từ cấu hình; đường subscribe legacy không thể kích hoạt paid plan.
- [x] SePay webhook: API-key auth, đối chiếu order code/transfer type/amount, unique transaction ID; fulfillment subscription và credit trong một transaction.
- [x] Gateway: route webhook cụ thể đứng trước route JWT/rate-limit; provider key được xác thực ở Business.
- [x] Web: diamond bên phải notification, chỉ owner agency thấy; plans/checkout gọi API, hiển thị QR và chờ backend fulfillment.
- [x] Thiếu giá Plus/bank account/webhook key thì fail closed. Chưa áp migration vào DB dùng chung, chưa thanh toán live.
- [ ] Evidence DB ACID: đã thêm test rollback/replay trên PostgreSQL cô lập; chưa chạy được do PostgreSQL tại `127.0.0.1:55439` không hoạt động và Docker daemon không truy cập được.
- [x] Evidence còn lại: backend unit tests, gateway route test, web type-check/build và 3 Playwright UI tests đã PASS.

Thứ tự: 1,2,3,4,5,6,9,7,8,10,11,12. Chi tiết file/interface/red-green nằm tại plan, không tạo bản mô tả thứ hai.

- [ ] Task 1 — Agency Basic và schema nền. Depends: Không. Evidence: command/result/commit SHA theo repo.
- [ ] Task 2 — Ví credit và grant bất biến. Depends: 1. Evidence: command/result/commit SHA theo repo.
- [ ] Task 3 — Quote/order idempotent và SePay adapter. Depends: 1. Evidence: command/result/commit SHA theo repo.
- [ ] Task 4 — Webhook atomic fulfillment và outbox. Depends: 2,3. Evidence: command/result/commit SHA theo repo.
- [ ] Task 5 — Renewal, nâng Plus→Enterprise và hết hạn. Depends: 4. Evidence: command/result/commit SHA theo repo.
- [ ] Task 6 — Reservation và workspace hard cap. Depends: 2,5. Evidence: command/result/commit SHA theo repo.
- [ ] Task 7 — AI orchestration bắt buộc reserve trước provider. Depends: 6,9. Evidence: command/result/commit SHA theo repo.
- [ ] Task 8 — Top-up, tracking và receipt/history. Depends: 4,6. Evidence: command/result/commit SHA theo repo.
- [ ] Task 9 — Quota tài nguyên và recovery sau lapse. Depends: 1,5. Evidence: command/result/commit SHA theo repo.
- [ ] Task 10 — Web billing cho sáu FR. Depends: 5,8,9. Evidence: command/result/commit SHA theo repo.
- [ ] Task 11 — Legacy migration và admin readers. Depends: 1–10. Evidence: command/result/commit SHA theo repo.
- [ ] Task 12 — Reconciliation, retention capability và phát hành. Depends: 1–11. Evidence: command/result/commit SHA theo repo.

- [ ] UI: cập nhật VI/EN subscription.json song song, test key parity.
- [ ] UI: kiểm tra light/dark, keyboard và mobile layout.
- [ ] Scope: không xây downgrade/cancel, vô hiệu legacy cancel mutation.
- [ ] Release: đủ giá/rate/policy được duyệt và mandatory tests không skipped; chưa bật production checkout trước gate.

