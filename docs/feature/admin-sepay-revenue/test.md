Test PostgreSQL: 4 catalog, nhiều phiên bản Plus không nhân receipts; VERIFIED FULFILLED trong kỳ mới tính; REVIEW/ngoài kỳ không tính; renewal FUTURE không nhân MRR; MRR bằng giá đơn kỳ hiện tại; plan filter đồng nhất totals/daily/plans; ngày theo timezone. UI: barMaxSize 40, brand orange thuê bao/AI khác màu, tooltip dark/light, gói doanh thu 0 không chia 0, mobile wrap; dùng i18n vi/en. Không test dưới src frontend. Chạy backend test và frontend type-check/lint/build, không commit/migration DB.

## Kết quả và rollout (21/10/2026)

- Frontend type-check PASS, eslint các file sửa PASS, production build PASS (cảnh báo bundle/import có sẵn), diff-check PASS.
- Maven đã compile production và toàn bộ test Java thành công trước khi Testcontainers khởi tạo.
- AdminSePayRevenuePostgresTest chưa chạy được assertions: Docker endpoint npipe không khả dụng trong phiên công cụ, suite lỗi beforeAll. Không ghi nhận là test PASS. Fixture kiểm tra VERIFIED/FULFILLED, version catalog không nhân bản, giá order thay giá catalog, filter gói và timezone.
- Cập nhật test legacy tài chính để chứng minh giao dịch PayOS cũ không đi vào nguồn SePay, và PDF không in khoản legacy. Test môi trường ADMIN_TEST_DB_URL cần schema billing mới, không chỉ schema legacy.
- Chưa restart Business do tiến trình do Runner đang quản lý. Sau khi chạy lại kiểm thử PostgreSQL thành công, bấm Restart Business trong run-repo; web Vite tự reload. Không cần migration mới, không chỉnh dữ liệu DB. API và UI phải triển khai cùng nhau; UI từ chối contract cũ thay vì hiện NaN hoặc số liệu PayOS nhầm là SePay.
- UI dùng đúng catalog/version từ backend; Personal chưa có luồng mua cá nhân thì thu 0; Basic miễn phí thu 0. Không tạo dữ liệu doanh thu mẫu.
- MRR/ARR chỉ tính agency có kỳ CURRENT ACTIVE READY và khoản trả phí verified, chưa bao gồm Personal chưa triển khai. Refund = 0 có chú thích nghiệp vụ chưa triển khai, không suy đoán từ legacy updated_at.
- Bộ lọc invoice vẫn độc lập với filter thống kê doanh thu như trước. Không commit/push.

Regression lỗi 500: log session_232443_400 dòng 471 báo syntax error day. AdminSePayRevenuePostgresTest gọi overview và assert daily, phải chạy qua truy vấn daily sau sửa AS receipt_date.

Sửa alias 23:27 ngày 21/10/2026: SELECT AS receipt_date/GROUP BY/JDBC đã đồng nhất; mvn -o -DskipTests compile PASS, diff-check PASS. Chưa xác nhận API 200 sau restart; PostgreSQL regression vẫn cần Docker khả dụng, không coi compile là kiểm thử SQL.
