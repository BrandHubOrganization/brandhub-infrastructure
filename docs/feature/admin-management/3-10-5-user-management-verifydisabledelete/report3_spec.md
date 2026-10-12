**3.10.5 User Management (Quản lý Trạng thái và Strike)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) chọn thao tác "Quản lý Trạng thái & Vi phạm" từ danh sách người dùng (/admin/users).

**Function Description**

- **Actors / Roles**: ADMIN quản lý tuân thủ. Người dùng tự xác thực email qua luồng kích hoạt.
- **Purpose**: Quản lý strike YELLOW/ORANGE/RED và cờ tài khoản. PENDING_VERIFICATION nghĩa là chưa xác thực email; chức năng này không khôi phục Authenticator bị mất.
- **Interface**: Hộp thoại Quản lý Trạng thái & Thẻ phạt Vi phạm (SCR-ADM-05), hiển thị dưới dạng modal gồm thông tin tài khoản, bộ đếm thẻ phạt 3 cấp độ và các nút hành động.
- **Data Processing**: Kiểm tra ADMIN và đối tượng, lưu sự kiện strike và audit, mỗi nhóm vàng chỉ quy đổi một lần, cập nhật hạn thời gian sạch và hạn chế đăng bài, tạo một yêu cầu xử phạt chờ cho RED/ba ORANGE còn hiệu lực. Gỡ theo strikeId cụ thể, không gỡ dây chuyền.

**Screen Layout**

Figure — Hộp thoại Quản lý Trạng thái & Thẻ phạt Vi phạm Người dùng (SCR-ADM-05):

- Left/Header: Tiêu đề "Quản lý Trạng thái & Thẻ phạt Vi phạm", biểu tượng bảo vệ, và nhãn trạng thái hiện tại (ACTIVE xanh lá, FLAGGED vàng cam, PENDING_VERIFICATION vàng chanh).
- Center: Hồ sơ, trạng thái và tình trạng xác thực email; YELLOW chưa quy đổi x/3, ORANGE còn hiệu lực x/3, chỉ báo RED, lịch sử đã quy đổi/hết hạn/gỡ và hạn thời gian sạch. Thao tác: ghi strike, gỡ đúng thẻ, bỏ cờ sau khi xử lý thẻ còn hiệu lực. Link yêu cầu xử phạt chờ duyệt; không có Verify 2FA.
- Buttons: Hủy, Xác nhận ghi strike / Gỡ thẻ / Bỏ cờ, Mở yêu cầu xử phạt.
- Footer: Ghi chú kiểm toán: "Mọi thao tác ghi nhận hoặc gỡ bỏ vi phạm đều được lưu vĩnh viễn trong Audit Log kèm mã Admin và lý do bắt buộc. Hệ thống tuyệt đối không xóa tài khoản người dùng".

**Function Details**

- **Data Specifications**
    - **Input required**: userId, action (add_strike, remove_strike, unflag), reason; add_strike cần violationLevel (YELLOW/ORANGE/RED) và violationCategory; remove_strike cần strikeId.
    - **Input optional**: postId, contentVersionId, tham chiếu chứng cứ.
    - **System data**: adminId, status, emailVerifiedAt, requirePasswordReset, lastViolationAt, cleanPeriodEndsAt, trạng thái thẻ và liên kết quy đổi, bộ đếm còn hiệu lực, pendingSanctionRequestId.
    - **Output**: Kết quả cập nhật hồ sơ người dùng kèm mã HTTP 200 OK.

- **Business Rules**
    - **BR-63**: Chỉ ADMIN ghi/gỡ strike và quản lý cờ, bắt buộc lý do và audit bất biến.
    - **BR-92**: Admin không xóa cứng user; giữ dữ liệu liên quan và lịch sử thẻ. Người dùng tự xóa tài khoản là luồng riêng.
    - **BR-15**: PENDING_VERIFICATION là chưa xác thực email. User tự xác thực; Admin không bỏ qua hoặc reset TOTP tại đây. Xác thực email không bắt buộc thiết lập lại 2FA.
    - **BR-94**: YELLOW là cảnh cáo. Có ORANGE còn hiệu lực thì tài khoản bị FLAGGED, đăng bài phải được ADMIN duyệt nhưng vẫn được đăng nhập. RED hoặc đủ ba ORANGE còn hiệu lực tạo yêu cầu xem xét xử phạt tại FR 3.10.9; chỉ khóa sau khi Admin xác nhận.
    - **BR-95**: Ba YELLOW còn hiệu lực, chưa quy đổi, thuộc bất kỳ loại lỗi nào tạo một ORANGE độc lập. Đánh dấu cả ba thẻ nguồn đã quy đổi và giữ liên kết. YELLOW thứ tư bắt đầu nhóm tiếp theo; sáu YELLOW hợp lệ tạo hai ORANGE. Có thể ghi nhận ORANGE trực tiếp. Gỡ YELLOW nguồn không tự gỡ ORANGE phát sinh.
    - **BR-96**: Mỗi vi phạm mới bắt đầu lại thời gian 30 ngày liên tiếp không vi phạm cho tài khoản. Các thẻ còn hiệu lực hết hạn sau thời gian sạch này, không tính riêng 30 ngày từ lúc tạo từng thẻ. Không hồi sinh thẻ đã hết hạn/đã gỡ; quy đổi không phải một lần tái phạm mới. Giữ lịch sử bất biến khi hết hạn hoặc gỡ. Hết ORANGE chỉ khôi phục quyền đăng bài nếu không còn khóa tài khoản hoặc hạn chế kích hoạt.
    - **BR-23**: Owner duy nhất của Agency/Workspace vẫn được sửa hồ sơ, ghi strike, gắn cờ và khóa tài khoản 30 ngày sau xác nhận. Thành viên khác tiếp tục quyền hiện có; thao tác chỉ Owner được làm tạm dừng đến khi mở khóa. Không khóa cả Agency, không tự chuyển quyền sở hữu. Quyền Owner độc lập với system role.
    - **BR-15**: Unflag yêu cầu gỡ/đợi hết hạn các thẻ vi phạm còn hiệu lực trước, đặc biệt toàn bộ ORANGE. Không dùng unflag mở DEACTIVATED; FR 3.10.9 quản lý thời hạn khóa riêng 30 ngày.
    - **BR-35**: Admin không tự xử phạt hoặc xử phạt ADMIN ngang hàng.

- **Validation**
    - Thiếu quyền ADMIN hoặc tự phạt/phạt Admin ngang hàng → MSG39.
    - Không có user/thẻ → MSG38; thiếu lý do → MSG02.
    - Unflag khi còn thẻ vi phạm hiệu lực hoặc đối tượng DEACTIVATED → từ chối chuyển trạng thái.
    - Yêu cầu/quy đổi lặp → trả kết quả đã có, không tạo thẻ hoặc xử phạt trùng.
    - Thao tác hợp lệ với Owner duy nhất được phép; hiển thị ảnh hưởng Agency trước khóa.
    - Cập nhật thẻ/trạng thái thành công → MSG26.

**Functionalities**

- **Normal Flow**
    1. Admin mở hộp thoại trạng thái/strike và xem thẻ còn hiệu lực cùng lịch sử.
    2. Chọn thêm, gỡ theo strikeId hoặc unflag và nhập lý do.
    3. Kiểm tra nguyên tử quyền, trạng thái đối tượng và điều kiện chuyển.
    4. Ghi vi phạm; bắt đầu lại thời gian sạch cho thẻ còn hiệu lực. Quy đổi nhóm vàng hợp lệ đúng một lần hoặc chỉ gỡ thẻ đã chọn.
    5. Tính lại FLAGGED và bộ đếm; RED/ba ORANGE mở yêu cầu xem xét mà chưa khóa.
    6. Lưu audit, cập nhật UI. Job nền hết hạn thẻ sau 30 ngày sạch; không bỏ qua thời hạn khóa tài khoản.

- **Abnormal Cases**
    - 2.a1: Thiếu lý do → MSG02.
    - 3.a1: Tự phạt/phạt Admin ngang hàng hoặc thiếu quyền ADMIN → MSG39.
    - 3.a2: Chưa xác thực email phải dùng luồng kích hoạt của user; không có Admin verify-2FA để bỏ qua.
    - 3.a3: Revision cũ/gỡ hoặc quy đổi đồng thời → tải trạng thái nhất quán; mỗi thao tác chỉ một kết quả audit.

**Post-Conditions**

- Lưu vòng đời thẻ và liên kết quy đổi nguồn; giữ lịch sử.
- User FLAGGED vẫn đăng nhập nhưng bài phải được ADMIN duyệt, kể cả bài đã lên lịch.
- RED/ba ORANGE để lại yêu cầu chờ Admin xác nhận.
- Kích hoạt email và thời hạn khóa DEACTIVATED độc lập với unflag/dọn thẻ.
