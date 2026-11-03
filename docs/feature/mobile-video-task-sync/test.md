# Mobile video → Task sync — Test

## Tự động
| # | Kiểm tra | Mong đợi |
|---|---|---|
| A1 | Validator: `isom`, `mp42`, `qt` khai `video/mp4` hoặc `video/quicktime` | Qua |
| A2 | Policy: JPEG vào TASK | Qua; PDF vào TASK bị từ chối |
| A3 | `GET materials?taskId=` | Chỉ trả tệp của task; Client không thấy INTERNAL |
| A4 | Client đọc bài có media INTERNAL đã ghim | Có URL |
| A5 | Pipeline: session hết hạn | Upload lại, thành công |
| A6 | Pipeline: `TASK_NOT_ASSIGNED` | `FAILED`, không thử lại |
| A7 | Khởi động với mục `UPLOADING` | Về `QUEUED` |
| A8 | Chỉ Wi-Fi trên 4G | Không chạy; có Wi-Fi thì chạy |
| A9 | Web: danh sách, rỗng, đưa vào bài | Đúng trạng thái và payload |

## API thật (Docker riêng: Postgres, Mongo replica set, MinIO)
| # | Bước | Mong đợi |
|---|---|---|
| B1 | Creator tạo session, PUT file `.mov`, confirm | Material `READY`, có `taskId` |
| B2 | Như B1 với MP4 `isom` và JPEG | `READY` |
| B3 | `GET materials?taskId=` bằng Manager | Thấy tệp; Client không thấy |
| B4 | Lưu bài với `materialId`, gửi duyệt | Bài có media; task `IN_REVIEW` |
| B5 | Web mở task | Thấy tệp, xem trước, chuyển ngôn ngữ và theme không vỡ |

## Thiết bị (người dùng xác nhận, dev build)
| # | Bước | Mong đợi |
|---|---|---|
| C1 | iPhone quay clip | Tự upload, web thấy trong khoảng 15s |
| C2 | Android quay clip | Như C1 |
| C3 | Bật máy bay giữa upload, tắt lại | Tự tiếp tục |
| C4 | Tắt app giữa upload, mở lại | Tự tiếp tục |
| C5 | Đổi FPS 24/30/60 | Metadata file đúng FPS |
| C6 | Ảnh HEIC trên iPhone | Lên task dạng JPEG |
| C7 | Quay quá mục tiêu thời lượng | Không tự dừng |
| C8 | Quay 3 take liên tiếp | Ở lại camera, giữ cài đặt, số take tăng 01, 02, 03 |
| C9 | Đang quay thì vuốt back (iPhone) và bấm back (Android) | Không thoát, clip vẫn lưu khi dừng |
| C10 | So khung trên màn với file đã quay | Video không bị cắt thêm, khung canh đúng vị trí |
| C11 | Từ chối quyền camera, mở lại màn quay | Có nút Mở Cài đặt, bật quyền xong quay được |
| C12 | Chạm một take trong chi tiết Task | Mở được video bằng trình phát của máy |
| C13 | Bật dark mode, đi hết luồng | Không còn nền sáng lẫn vào, chữ đọc rõ |

## Kết quả chạy emulator (2026-11-02)
Pixel_9a, Android 17 (API 37), camera ảo, debug build, stack e2e riêng. Chưa thay thế xác nhận trên máy thật.

| # | Kết quả | Ghi chú |
|---|---|---|
| C2 | Đạt một phần | Quay, tự tải lên, material `READY`, đúng dung lượng. Chưa kiểm tra phía web |
| C4 | Đạt một phần | Đưa app ra nền rồi mở lại: hàng đợi chạy tiếp và thử lại được. Chưa tắt app giữa lúc upload |
| C8 | Đạt | Ở lại camera, số take tăng 01 → 04. Chưa kiểm tra giữ cài đặt |
| C9 | Đạt phần Android | Nút back bị chặn, có cảnh báo. Chưa thử iPhone |
| C10 | Có vấn đề | File 720x1280 (9:16) nhưng preview 4:3; chọn 1080p ra 720p. Cần xác nhận trên máy thật |
| C1, C3, C5, C6, C7, C11, C12, C13 | Chưa chạy | Xem lượt chạy lại bên dưới |

## Kết quả chạy lại trên emulator (2026-11-02, sau khi sửa UI)
Pixel_9a, debug build + Metro, stack e2e riêng. Vẫn chưa thay thế xác nhận trên máy thật.

| # | Kết quả | Ghi chú |
|---|---|---|
| C3 | Đạt | Cắt mạng lúc `UPLOADING`: take thành `FAILED`, có mạng lại tự tải tiếp đến `SYNCED` sau 9 giây |
| C4 | Đạt | Tắt app lúc `UPLOADING`, mở lại thì tự tải tiếp đến `SYNCED`. Tắt app ngay sau khi dừng quay, trước khi clip vào hàng đợi, thì mất clip đó |
| C7 | Đạt | Mục tiêu 15 giây, quay quá 30 giây, timer đổi màu, không tự dừng |
| C10 | Đạt phần khung trên emulator | Preview đã cắt theo tỉ lệ file, khung canh nằm trong hình, nhãn hiện đúng 720p. Cần so với file trên máy thật |
| C11 | Đạt phần emulator | Từ chối quyền thì có Mở Cài đặt. Cấp lại bằng `pm grant` thì quay được, chưa đi qua màn Cài đặt |
| C12 | Đạt trên Android | Mở bằng trình xem video của máy (Google Photos trên emulator). iOS chưa kiểm tra |
| C13 | Đạt phần đã xem | Home, Chi tiết Task, Tải tệp, màn quay ở theme tối của app. Công tắc theme xoay vòng sáng, tối, theo hệ thống |
| Histogram | Đạt | Góc phải trên của khung, không bị ngăn kéo và thẻ kịch bản che |
| Zebra | Đạt phần vị trí | Đã sửa lỗi lệch 180°. Kiểm tra bằng ngưỡng tạm 150 vì cảnh ảo không chạm 235 |
| EV +2 | Không kiểm chứng được | Giá trị đổi, nhưng hình và histogram của camera ảo gần như không đổi |
| Kim dB | Không kiểm chứng được | Luôn -60 dB dù bật `-allow-host-audio` và phát tiếng ra loa. Track âm thanh của file cũng gần như im lặng (khoảng 102 byte mỗi frame AAC), nên nghi mic ảo không nhận tiếng. Cần thử có tiếng thật trên máy thật |
| Motion | Đạt trên Expo Web, chưa kiểm tra lại trên Android | Khung 412x915: skeleton, nội dung hiện dần, tab drawer trồi nhẹ, thanh tab trượt, Reduce Motion bỏ dịch chuyển. Đổi 10 lần tab drawer với CPU chậm 6 lần không có màn trống. Emulator từng có 1 lần màn trống sau khi mở app, chưa tái hiện được (13 lần mở lại đều đạt); đã bỏ native driver ở 2 animation có thể che cả màn, cần xác nhận trên Android |
| C1, C5, C6 | Chưa chạy | Cần iPhone, kiểm tra metadata file hoặc ảnh HEIC |

## Kết quả trên Expo Web (dark mode và ngôn ngữ)
Khung 412x915, stack e2e riêng, vai trò Creator và Admin. Bộ dò tự động đo vùng nền sáng lớn, độ tương phản chữ/nền và chữ tiếng Việt còn sót trên phần đang hiển thị của mỗi màn. Chưa kiểm tra trên Android.

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Dark mode, các tab và menu More của Creator | Đạt | 19 màn không còn vùng nền sáng lớn. Lỗi tương phản ở nút Lịch sử màn Tạo video AI đã sửa ở Button dùng chung |
| Dark mode, 8 màn chính của Admin | Đạt | Màn con, form và hộp thoại chỉ được chuyển bằng script, chưa mở hết để xem |
| Tiếng Anh, 19 màn của Creator | Đạt | Chỉ còn tên ngôn ngữ "Tiếng Việt" ở ô chọn, là đúng. Nội dung do backend trả về vẫn giữ nguyên ngôn ngữ gốc |
| Đổi ngôn ngữ trong phiên | Đạt | Cập nhật ngay, app quay về màn đầu của luồng |
| Đăng nhập Google | Đạt một phần | Google nhận client_id và redirect_uri, tới trang đăng nhập. Chưa đăng nhập hết luồng nên client secret chưa được kiểm chứng |

## Rà bản dịch và nội dung backend (chỉ test tự động, chưa mở trên trình duyệt)
| Mục | Kết quả | Ghi chú |
|---|---|---|
| Rà bản dịch tiếng Anh | Agent đã đọc hết, chưa có người đọc lại | Đã sửa các chuỗi sai nghĩa theo ngữ cảnh và thống nhất thuật ngữ. Placeholder khớp ở mọi khoá |
| Câu hệ thống từ backend | Đạt test tự động | Thông báo, lỗi đăng bài và lý do kiểm duyệt có bản tiếng Anh. Nội dung người dùng và AI, email, PDF, mẫu seed giữ nguyên |
| Thông báo lỗi API | Đạt test tự động | Mobile đọc `error.message`; tiếng Việt chỉ hiện với mã đã dịch, mã khác và lỗi 5xx giữ câu của màn hình |
| Creator vào `/requests` trên web | Đạt test tự động | Route đã chặn Creator, ẩn link Yêu cầu nội dung trong chi tiết Task |
| Owner xem Yêu cầu nội dung (web, mobile) | Đạt trên Expo Web | Mở danh sách và chi tiết. Backend trả mọi quyền thao tác là false nên Owner chỉ xem; form tạo vẫn đóng với Owner |

## Quét toàn bộ trên Expo Web (2026-11-03)
Khung 412x915, stack e2e riêng dựng lại từ schema và seed của dự án. Chưa kiểm tra trên Android hay iOS.

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Owner, Manager, Client, Creator, Admin: tối + tiếng Anh | Đạt | Mở cả màn con và form chính. Chữ tiếng Việt còn lại là dữ liệu seed hoặc tên thương hiệu |
| Owner: sáng + tiếng Việt | Đạt | Sửa chữ "Đã kết nối" tương phản thấp bằng token `successText`. Vai trò khác chưa quét ở chế độ này |
| Lỗi đăng nhập sai | Đạt | Hiện đúng thông báo của backend thay cho câu chung |
| Thông báo do backend tạo | Đạt | Thông báo giao Task thật hiện tiếng Anh |
| Đăng xuất Admin | Đạt | Trước đây Admin không có đường đăng xuất |
| PDF Admin `en`, `vi`, không truyền | Đạt | Một ngôn ngữ khi có `language`, hai ngôn ngữ khi không truyền |
| Chân email hàng loạt theo `working_language` | Đạt | `en`, `vi` đúng ngôn ngữ, rỗng nhận cả hai. Đọc từ `admin_email_outbox`, chưa gửi email thật |
| Mất clip khi tắt app sau khi dừng quay | Đạt test tự động | Chưa thử trên máy thật: ghi vào `filePath` riêng và tắt app thật |

## Lượt quét thêm (2026-11-03)
| Mục | Kết quả | Ghi chú |
|---|---|---|
| Manager, Creator, Client, Admin: sáng + tiếng Việt | Đạt | Quét các màn trong menu và tối đa 2 màn con mỗi màn. 503 ở Tạo Video AI là do stack test không chạy dịch vụ AI |
| Bộ lọc loại Task | Đạt | Bỏ `VIDEO` backend không nhận (400), thêm `EVENT_PLAN`, `PRESS_RECOMMENDATION` |
| Admin có Cài đặt | Đạt | Đổi giao diện, Cài đặt tài khoản, Bảo mật mở được. Ngôn ngữ chưa đổi thử trong lượt này |
| Owner xem Task | Đạt | Trước đây lỗi 403 làm Owner không mở được chi tiết Task. Giờ chỉ xem, ẩn bình luận và lịch sử duyệt |
| Owner với trình soạn thảo và mời Workspace | Đạt trên mobile và web | Ẩn vì API từ chối. Web đã kiểm tra trên trình duyệt bằng Owner thật, xem mục bên dưới |
| Email OTP, đặt lại mật khẩu, mời Agency, mời Workspace, kích hoạt | Đạt qua Mailpit | Có `working_language` thì một ngôn ngữ, không có thì hai ngôn ngữ. Mã và link có đủ ở cả hai phần. SMTP cục bộ, chưa gửi email thật |

## Test backend bản build sạch
Biên dịch `clean` trên bản sao, bật test DB bằng `ADMIN_TEST_DB_URL`: 1454 test, 12 lỗi, 42 skip. Cả 12 lỗi đều có trên code gốc khi chạy cùng DB: `AiCreditDatabaseTest` 6, `AiVideoDatabaseTest` 5, `AdminFinanceDatabaseTest` 1.

Kết quả cũ "1454 test, 0 lỗi, 80 skip" của lượt sửa email và PDF không dùng được: Maven khi đó không biên dịch lại vì `target/classes` đã bị tiện ích Java của IDE ghi đè. Cần chạy `mvn clean` trước khi tin kết quả test.

## Sửa test DB (nhánh `fix/backend-db-tests` của backend)
12 test lỗi đều do test cũ, không có lỗi thật về tiền hay credit. Fixture AI Credit dùng đồng hồ thật của DB trong khi service dùng đồng hồ cố định, nên hỏng từ khi qua ngày 2026-10-31. Test báo cáo doanh thu tạo giao dịch kiểu cũ, trong khi báo cáo chỉ tính biên lai SePay đã xác minh.

Kết quả build sạch: 1439 test, 0 lỗi, 42 skip.

Trong nhóm skip, `MailStorePostgresTest` và `UserOAuthProviderRepositoryTest` đạt khi bật riêng. Các test còn lại chưa chạy được vì ghi cứng môi trường (cổng và tên DB như `55438/partner_test`, `55439/package_test`, replica set `taskWorkflowTest`) hoặc cần migration Mongo riêng. `*AtlasInventoryTest` đọc Atlas thật và `PaymentApiTest` cần cả hệ thống thanh toán nên không bật.

## Kiểm tra trên bản ghép backend và quét sâu
Backend ghép `feat/mobile-video-task-sync` với `fix/backend-db-tests`, build sạch: 1454 test, 0 lỗi, 42 skip.

Owner thật là chủ agency nhưng không là thành viên workspace (`myRole=OWNER`). Tài khoản `user177` trong seed có `myRole=MANAGER` nên không dùng để thử vai trò này được.

| Mục | Kết quả | Ghi chú |
| --- | --- | --- |
| Web, Owner mở Task | Đạt | Không có bình luận, nút Editor, ô phân công. Không còn 403 từ `/post`. Vào `/editor` bị chuyển về `/dashboard` |
| Web, Manager mở Task | Đạt | Vẫn có ô phân công |
| Expo Web, Owner mở Task | Đạt | Không có request 403 |
| Expo Web, Admin đổi ngôn ngữ | Đạt | Đổi ngay, tải lại vẫn giữ, không bị đẩy khỏi Cài đặt |
| Quét màn con, sáng + tiếng Việt, khổ 412px | Đạt | Manager 16 menu, Owner 14, Creator 9, Client 9, Admin 9, tối đa 6 màn con mỗi menu. Script kiểm tra chữ tiếng Anh, độ tương phản, tràn ngang, thông báo lỗi và request lỗi |

Giới hạn của lượt quét: dữ liệu seed không có Task nên chỉ dùng 1 Task tạo tay. Script bỏ qua nút có tác động như xoá, duyệt, gửi. Nhiều menu không có màn con để mở. Các tab Dashboard, Task, Lịch, Chat không nằm trong lượt này.
