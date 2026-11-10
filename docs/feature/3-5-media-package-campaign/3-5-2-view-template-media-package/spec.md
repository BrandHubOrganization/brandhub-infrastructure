# FR 3.5.2 — Guest xem gói quảng bá và Client xem gói workspace

Cập nhật BA 2026-11-05, chờ triển khai. Theo [spec hành trình mới](../3-5-6-view-media-campaign/guest-sharing-manager-led/spec.md).

## Mục tiêu

Khách xem gói Agency qua link được chia sẻ trước khi có tài khoản/workspace. Client đã được mời xem gói thực hiện đã thống nhất trong workspace.

Cập nhật 2026-11-06: Manager phụ trách/Owner có quyền quản lý cũng chia sẻ được Custom Package workspace qua link guest và xuất ảnh/PDF để trao đổi với Client bên ngoài. Cơ chế bảo mật nâng cao để team bàn sau, chưa yêu cầu OTP/mật khẩu/xác minh email.

## Tiêu chí nghiệm thu

- Guest mở link gói quảng bá mà không cần đăng nhập, lời mời hoặc membership.
- Nội dung gồm Agency, tên gói, phạm vi, dịch vụ/hạng mục, sản lượng, đơn vị, mô tả, tiêu chí và ngân sách/thời lượng nếu được cung cấp.
- Link luôn đọc bản mới nhất đã lưu của đúng gói Agency hoặc workspace được chia sẻ. Link workspace không lấy lại nội dung mẫu Agency. Tải lại sau khi người quản lý sửa phải thấy bản mới.
- Ảnh/PDF đã xuất thể hiện bản tại thời điểm xuất và có thông tin ngày xuất. Xuất đủ nội dung, hiển thị đúng tiếng Việt và hạng mục dài.
- Guest chỉ xem nội dung gói được chia sẻ, gồm điều khoản của chính gói đó. Link không cấp quyền xem workspace, Client Profile, Campaign/task, comment, approval hoặc dữ liệu nội bộ khác.
- Client đã tham gia đúng workspace xem gói thực hiện và nội dung liên quan theo quyền hiện hành.
- Client không có bước chọn, request-change hoặc approve Package trong hành trình mới.
- Trạng thái chưa có gói hướng dẫn Manager thiết lập và cho Client biết đang chuẩn bị. Không yêu cầu Client duyệt để tiếp tục.
- Link sai/không còn khả dụng, mất kết nối, tải và xuất file lỗi có trạng thái phù hợp. Dữ liệu lỗi không được thay bằng gói giả.
- Hỗ trợ vi/en, light/dark, bàn phím và mobile theo theme hiện hành.

## Hợp đồng dữ liệu

Phải tách dữ liệu public khỏi dữ liệu workspace ở phía server. Guest không dùng endpoint nội bộ có quyền rộng chỉ vì cùng hiển thị một gói. Tên route, cấu hình chia sẻ và cơ chế export chốt trong plan.
