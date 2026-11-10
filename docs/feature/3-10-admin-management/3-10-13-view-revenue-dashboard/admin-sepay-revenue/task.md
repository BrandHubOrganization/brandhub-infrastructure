- [x] Kiểm tra nguồn, định nghĩa SePay verified receipts và MRR riêng.
- [x] Thêm fixture/test PostgreSQL; cập nhật expectations legacy.
- [x] Đổi service/DTO/PDF sang billing mới; UI chart, doanh thu theo gói và vi/en.
- [x] Frontend type-check/lint/build và Java source/test compile, diff-check.
- [ ] Chạy assertions PostgreSQL khi Docker khả dụng; rerun test ADMIN_TEST_DB_URL trên schema hiện tại.
- [ ] Restart Business qua Runner, kiểm tra UI light/dark/mobile với API mới sau khi test DB pass.

- [ ] Sửa alias daily và compile lại; test PostgreSQL hiện có phải xác nhận daily Jan 1/VN và UTC.

- [x] Sửa alias receipt_date và compile PASS; còn xác minh SQL/API runtime sau restart.
