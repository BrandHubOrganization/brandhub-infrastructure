# Role-based Dashboards — test

Dữ liệu: agency seed SE08 Digital Agency (3 workspace). Tài khoản lấy từ seeder:
- 1 Owner
- 1 Manager (quản lý đúng 1 workspace)
- 1 Creator (có việc ở 2 workspace)
- 1 Client (1 brand)
- 1 người vừa Manager WS-A vừa Creator WS-B
- 1 user thuộc 2 agency (Owner ở agency này, Creator ở agency kia)

| # | AC | Kịch bản | Mong đợi | PASS |
|---|---|---|---|---|
| 1 | AC1 | grep code dashboard tìm số ghi cứng / công thức sinh số (`tasks.length * 0.`, `"T8"`, ô "4" kênh) | Không còn | |
| 2 | AC2 | User 2 agency mở `/dashboard?tab=analytics` | Bảng 2 hàng; cột tiền chỉ có ở agency mình là Owner, hàng còn lại "—" | |
| 3 | AC2 | User chưa vào agency nào mở tab Phân tích | Trạng thái trống + gợi ý tạo agency/xem lời mời | |
| 4 | AC3 | Owner mở tab Phân tích agency | Đủ 9 khối; xếp hạng mặc định theo Điểm giảm dần; bấm hàng → dashboard workspace | |
| 5 | AC3 | So số của Owner với DB (mongosh/psql) cho 1 workspace, 30D | finished, onTime, firstPass, published, reach, spent, contractValue khớp | |
| 6 | AC4 | Manager gọi `/api/v1/analytics/agencies/{id}` | Chỉ workspace mình quản lý; JSON không có `money`, `finance`, `team` | |
| 7 | AC4 | Manager gọi `/api/v1/analytics/workspaces/{workspace không thuộc mình}` | 403 | |
| 8 | AC5 | Creator gọi API agency | Chỉ việc giao cho mình; không có `workload`, `money` | |
| 9 | AC6 | Client mở dashboard agency | Có 2 tab; chỉ brand mình; không có tiền/credit/workload; Top 5 bài mở đúng link | |
| 10 | AC7 | User vừa Manager vừa Creator | `viewer.sections = [MANAGER, CREATOR]`; UI hiện 2 khối đúng thứ tự | |
| 11 | AC8 | Đổi 7D → 90D rồi tải lại trang | Số đổi; URL giữ `?tab=analytics&range=90D`; ↑↓ đúng dấu | |
| 12 | AC8 | Kỳ trước = 0 | Hiện giá trị, không hiện % | |
| 13 | AC9 | Unit `EfficiencyScore`: đủ 4 thành phần / thiếu engagement / mẫu < 3 / tất cả thiếu | Trọng số chia lại đúng; tất cả thiếu → null, UI "Chưa đủ dữ liệu" | |
| 14 | AC10 | Workspace > 100 task, tab Phân tích | Số khớp DB (không bị cắt ở 100) | |
| 15 | AC11 | Mở `/analytics`, `/reports`, `/agency/{id}/stats` | Chuyển đúng tab Phân tích tương ứng | |
| 16 | AC12 | Owner bấm In báo cáo | Xem trước bản in chỉ có nội dung Phân tích, biểu đồ không bị cắt ngang | |
| 17 | AC13 | User ngoài agency gọi API agency; id không tồn tại | 403; 404 | |
| 18 | AC13 | `range=1Y` | 400 `VALIDATION_ERROR` | |
| 19 | — | Giả lập lỗi đọc tài chính | Các khối khác vẫn hiện; khối Tài chính báo lỗi + Thử lại; `partialErrors` có `finance` | |
| 20 | — | Task được duyệt sang FINISHED, sau đó bị mở lại | `finishedAt` được ghi; mở lại → bị xoá | |
| 21 | — | Chạy backfill 2 lần | Lần 2 không đổi gì | |
| 22 | AC14 | Đổi vi/en ở mọi màn hình | Không lộ key, không vỡ bố cục | |
| 23 | AC15 | Light/Dark ở mọi màn hình | Biểu đồ, trục, chú thích đủ tương phản | |
| 24 | AC16 | Màn hình 375px | Không cuộn ngang trang; bảng cuộn trong khung, cột tên cố định | |
| 25 | AC17 | Seed 10 WS × 2.000 task, gọi API agency 90D | ≤ 1,5 s | |
| 26 | AC18 | Gọi `/agencies/{id}/stats`, `/analytics/overview`, `/workspaces/{id}/dashboard` | JSON giống trước thay đổi | |
| 27 | — | Tour `?` ở 3 dashboard | Mọi bước trỏ đúng phần tử, không bước nào treo | |
| 28 | AC19 | Đi hết dashboard bằng phím Tab, bấm Enter từng phần tử trong "Bản đồ tương tác" | Mọi phần tử tới được, có focus ring, đúng kết quả | |
| 29 | AC20 | Owner bấm ô "Quá hạn 5" | Ngăn kéo có đúng 5 việc, nhóm theo workspace; URL có `?drill=overdue`; Back đóng ngăn kéo | |
| 30 | AC20 | Bấm cột "WS-A × Chờ duyệt" trên biểu đồ trạng thái | Ngăn kéo đúng số việc chờ duyệt của WS-A; "Mở trang đầy đủ" → trang Việc WS-A lọc sẵn | |
| 31 | AC20 | Bấm ô "Đã chi" | Ngăn kéo danh sách đơn đã thanh toán, tổng khớp ô | |
| 32 | AC21 | Creator mở ngăn kéo "Chưa giao", bấm Nhận việc | Việc chuyển sang mình, số "Chưa giao" giảm 1, không tải lại trang | |
| 33 | AC21 | Manager đổi người làm và dời hạn trong ngăn kéo | Dòng cập nhật; số Quá hạn đổi nếu hạn mới > hôm nay | |
| 34 | AC21 | Client mở ngăn kéo "Chờ tôi duyệt" | Không có nút duyệt tại chỗ; nút Duyệt mở `task-approvals?task=` | |
| 35 | AC21 | Creator gọi API assign việc ở workspace khác (sửa request bằng tay) | 403, dòng giữ nguyên, toast lỗi | |
| 36 | AC22 | 4 vai trò + người nhiều vai trò mở Tổng quan | Đúng bộ nút theo bảng; nút cần workspace mở popover khi > 1 workspace; số không lặp với ô số | |
| 37 | AC23 | Creator có 1 việc quá hạn, 1 bị trả lại, 1 đến hạn hôm nay, 1 URGENT | Thẻ Làm tiếp hiện đúng 3 dòng theo thứ tự; nút chính Tiếp tục / Sửa theo góp ý / Bắt đầu đúng trạng thái | |
| 38 | AC24 | Mở dashboard ở 2 trình duyệt, tài khoản B gửi duyệt một việc | Trình duyệt A (người duyệt) thấy số "Chờ tôi duyệt" tăng trong ≤ 15 s, "Cập nhật lúc" đổi | |
| 39 | AC25 | Mở `/workspaces/:id/tasks?status=IN_REVIEW&assignee=me&due=overdue` | Bộ lọc đã chọn sẵn, kết quả đúng; đổi bộ lọc thì URL đổi | |
| 40 | AC26 | Rê chuột/Tab vào điểm biểu đồ; bấm chú thích | Tooltip số chính xác; chuỗi ẩn/hiện; không ẩn được chuỗi cuối | |
| 41 | AC27 | Owner bấm Xuất Excel ở 30D; Manager gọi API export | File 3 sheet, số khớp màn hình, tiêu đề theo ngôn ngữ; Manager → 403 | |
| 42 | AC28 | Workspace mới chưa có việc, mở tab Phân tích | Mỗi khối ghi lý do + nút hành động, không khối nào bị ẩn | |
| 43 | AC29 | Chọn agency A, rời agency A, về `/dashboard` | Nút "Tiếp tục ở A" không hiện | |
| 44 | — | Việc chờ duyệt 4 ngày; việc chờ duyệt 2 ngày | Chỉ việc 4 ngày vào "Việc bị nghẽn" | |
| 45 | — | Workspace có 2 việc hoàn thành | `onTimeRate`, `firstPassRate` "Chưa đủ dữ liệu"; điểm tính từ thành phần còn lại | |
