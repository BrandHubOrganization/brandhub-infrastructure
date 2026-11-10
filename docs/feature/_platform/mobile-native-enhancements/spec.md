# Tính năng riêng cho mobile và làm đẹp giao diện

Viết sau khi code, vì yêu cầu đến khi chủ dự án vắng mặt (2026-11-04). Cần được rà lại theo đúng quy trình `spec → plan → task → test`.

## 1. Objective

Dùng những gì chỉ điện thoại có để giúp người dùng: bảo vệ dữ liệu trên máy, nhắc việc không cần backend, báo rõ khi mất mạng, phản hồi xúc giác. Dashboard chỉ vẽ dữ liệu thật.

## 2. User Stories

- Là người dùng, tôi muốn khoá app bằng vân tay, khuôn mặt hoặc mật khẩu máy, để người mượn điện thoại không xem được dữ liệu khách hàng.
- Là Creator, tôi muốn được nhắc trước hạn Task, để không trễ deadline dù không mở app.
- Là người quay video ngoài hiện trường, tôi muốn biết khi mất mạng, và biết video đã quay vẫn được giữ.
- Là Manager, tôi muốn thấy số liệu thật của Workspace trên Dashboard.

## 3. Acceptance Criteria

**Khoá ứng dụng**
- AC-L1: Bật trong Cài đặt ứng dụng. Phải xác minh thành công mới đổi được trạng thái, cả khi bật lẫn khi tắt.
- AC-L2: Máy chưa đặt khoá màn hình thì không bật được, và có thông báo.
- AC-L3: Khi đã bật: khoá lúc mở app và khi quay lại sau từ 60 giây ở nền. Đồng hồ máy bị chỉnh lùi cũng khoá.
- AC-L4: Huỷ hoặc xác minh sai thì vẫn khoá, có nút thử lại.
- AC-L5: Luôn có nút Đăng xuất, để không ai bị kẹt.
- AC-L6: Khi khoá, nút Back không điều khiển màn phía sau, trình đọc màn hình không đọc nội dung phía sau.
- AC-L7: Mở khoá xong vẫn ở đúng màn cũ, bản nháp và upload không mất.

**Nhắc hạn Task**
- AC-R1: Tắt mặc định. Bật thì xin quyền thông báo; bị từ chối thì không bật và có đường mở Cài đặt máy.
- AC-R2: Nhắc trước 1 ngày và 1 giờ với Task đang mở được giao cho người đang đăng nhập, trong Workspace hiện tại.
- AC-R3: Bỏ qua mốc đã qua và Task không có hạn hoặc hạn sai định dạng. Tối đa 40 lịch, ưu tiên gần nhất (iOS giới hạn 64).
- AC-R4: Lịch được thay mới khi mở app. Task đã xong hoặc đổi người thì không còn nhắc.
- AC-R5: Tắt tính năng hoặc đăng xuất thì huỷ mọi lịch nhắc, để tài khoản khác trên máy không nhận.
- AC-R6: Chạm thông báo mở đúng Task, đổi Workspace nếu cần. Mất quyền vào Workspace thì không làm gì.

**Báo mất mạng**
- AC-O1: Không có kết nối thì hiện dòng báo ở trên cùng, không chặn thao tác, tự ẩn khi có mạng lại.

**Phản hồi xúc giác**
- AC-H1: Nhẹ khi bấm nút. Thành công hoặc cảnh báo cho thao tác Task, Kanban, gửi email. Máy không hỗ trợ thì bỏ qua, không lỗi.

**Dashboard**
- AC-D1: Bỏ biểu đồ dữ liệu mẫu. Biểu đồ Task theo trạng thái và Task đến hạn 6 tháng tính từ Task thật, không tính Task đã huỷ.
- AC-D2: Role không được xem danh sách Task của Workspace thì không hiện khu biểu đồ. Không có Task thì hiện câu báo, không vẽ biểu đồ rỗng.
- AC-D3: Thẻ chào hiện số Task đang mở và số sắp đến hạn trong 3 ngày, tính cả quá hạn.

**Đa ngôn ngữ và giao diện**
- AC-I1: Mọi chuỗi mới có trong `src/i18n/locales/en.json`, khoá là câu tiếng Việt qua `tr()`.
- AC-T1: Màu dùng token theo theme. Riêng `brandGradient` giữ nguyên ở 2 theme, chữ trên đó luôn màu trắng.

## 4. API

Không thêm API. Nhắc hạn dùng `GET /api/v1/workspaces/{id}/tasks` sẵn có.

## 5. Out of Scope

Push notification từ server, khoá theo từng Workspace, nhắc cho Workspace không chọn hiện tại.

## 6. Định nghĩa hoàn thành

Toàn bộ AC ở `test.md` đạt trên Android và iOS. Hiện chưa kiểm tra trên iOS và thiết bị thật, xem `test.md`.
