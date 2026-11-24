**3.10.9 Deactive User (Xử lý Vi phạm & Tạm khóa Tài khoản)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) nhấn nút "Xử lý Vi phạm / Tạm khóa" từ hồ sơ chi tiết người dùng (/admin/users/:id).

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên áp dụng biện pháp chế tài đối với tài khoản vi phạm.
- **Purpose**: Gắn cờ đăng bài hoặc xác nhận khóa toàn tài khoản 30 ngày. Đủ 30 ngày tự mở tài khoản và gửi email.
- **Interface**: Hộp thoại Xử lý Vi phạm & Chế tài Tài khoản (SCR-ADM-09), gồm tóm tắt thông tin tài khoản, bộ đếm thẻ phạt 30 ngày, 2 lựa chọn hình thức chế tài và ô nhập lý do bắt buộc.
- **Data Processing**: RED/ba ORANGE còn hiệu lực tạo yêu cầu xem xét. Admin đọc chứng cứ, xác nhận DEACTIVATE kèm lý do; đặt deactivatedAt/reactivateAt=deactivatedAt+30 ngày, thu hồi mọi session/token và chặn tài khoản. Job nền chạy an toàn khi lặp tự chuyển ACTIVE khi đủ hạn và gửi email; không cần Admin duyệt mở lại.

**Screen Layout**

Figure — Hộp thoại Xử lý Vi phạm & Tạm khóa Người dùng (SCR-ADM-09):

- Left/Header: Tiêu đề "Xử lý Vi phạm & Chế tài Tài khoản", biểu tượng tam giác cảnh báo màu cam (nếu Gắn cờ) hoặc ổ khóa màu đỏ (nếu Tạm khóa), hiển thị User ID mục tiêu.
- Center: Thông tin user, bộ đếm YELLOW/ORANGE/RED còn hiệu lực, yêu cầu/chứng cứ, chọn FLAG hoặc DEACTIVATE, lý do và checkbox xác nhận. Trước khóa Owner duy nhất, nêu thành viên vẫn làm việc trong quyền hiện có, thao tác riêng Owner tạm dừng. Hiện lúc bắt đầu khóa, lúc tự mở và trạng thái xem xét.
- Buttons: Nút "Hủy bỏ", Nút hành động chính (Màu cam "Xác nhận Gắn cờ" hoặc Màu đỏ "Xác nhận Tạm khóa").
- Footer: Quy tắc bắt buộc: "Quản trị viên không thể tự xử lý chính mình và không thể xử lý Admin khác. Toàn bộ bài viết và dữ liệu thanh toán PayOS được bảo toàn nguyên vẹn trong CSDL".

**Function Details**

- **Data Specifications**
    - **Input required**: userId, sanctionType (FLAG/DEACTIVATE), reason; DEACTIVATE cần Admin xác nhận rõ và chứng cứ xem xét.
    - **Input optional**: sanctionRequestId, linkedStrikeIds, tham chiếu chứng cứ.
    - **System data**: adminId, systemRole/status đối tượng, thẻ hiệu lực, trạng thái xem xét, deactivatedAt, reactivateAt, restoredAt, tình trạng gửi email.
    - **Output**: Kết quả chế tài { userId, status: "FLAGGED" | "DEACTIVATED", activeStrikes } kèm mã HTTP 200 OK.

- **Business Rules**
    - **BR-63**: Chỉ ADMIN xác nhận khóa tài khoản. RED hoặc ba ORANGE còn hiệu lực tạo yêu cầu chờ xem xét, không tự khóa. Kiểm tra lại chứng cứ khi xác nhận; yêu cầu cũ/lặp không tạo xử phạt trùng.
    - **BR-94**: FLAGGED vẫn đăng nhập nhưng cả bài mới và đã lên lịch phải được ADMIN duyệt. DEACTIVATED khóa toàn tài khoản 30 ngày từ lúc xác nhận xử phạt.
    - **BR-06**: Áp dụng DEACTIVATED ở đăng nhập, refresh và thao tác đã xác thực; token phát trước đó không được giữ quyền truy cập.
    - **BR-22**: Thu hồi mọi session và access/refresh token khi khóa. Mở lại phải đăng nhập mới; token đã thu hồi không có hiệu lực trở lại.
    - **BR-23**: Owner duy nhất của Agency/Workspace vẫn được sửa hồ sơ, ghi strike, gắn cờ và khóa tài khoản 30 ngày sau xác nhận. Thành viên khác tiếp tục quyền hiện có; thao tác chỉ Owner được làm tạm dừng đến khi mở khóa. Không khóa cả Agency, không tự chuyển quyền sở hữu. Quyền Owner độc lập với system role.
    - **BR-35**: Admin không tự xử phạt hoặc xử phạt ADMIN ngang hàng.
    - **BR-96**: Đến reactivateAt tự chuyển ACTIVE và gửi email mở lại, không cần Admin duyệt. Dọn thẻ không mở khóa sớm. Giữ lịch sử thẻ; hết phạt không hồi sinh thẻ cũ. Email lỗi được retry mà không hoàn tác mở khóa. Không mở DELETED hoặc SUSPENDED cũ không thuộc xử phạt này.
    - **BR-92**: Giữ toàn bộ dữ liệu user, Agency, bài viết và thanh toán; không xóa cứng.
    - **BR-16**: Audit xem xét, xác nhận, thu hồi session và tự mở với chứng cứ/thời điểm liên kết.

- **Validation**
    - Thiếu ADMIN, tự phạt hoặc phạt Admin ngang hàng → MSG39.
    - Không có user/yêu cầu → MSG38; thiếu lý do/xác nhận → MSG02.
    - Owner duy nhất được khóa sau thông báo ảnh hưởng và Admin xác nhận; không từ chối MSG92 chỉ vì là Owner.
    - Yêu cầu đã xử lý hoặc tài khoản đã khóa → xung đột/kết quả đã có; không vô tình tính lại thời hạn phạt.
    - Khóa thành công → MSG91.

**Functionalities**

- **Normal Flow**
    1. RED/ba ORANGE còn hiệu lực mở yêu cầu xem xét; chưa tự khóa tài khoản.
    2. Admin đọc thẻ/chứng cứ rồi chọn FLAG hoặc xác nhận DEACTIVATE kèm lý do.
    3. Kiểm tra bảo vệ bản thân/ngang hàng và trạng thái hiện tại; hiển thị ảnh hưởng Owner duy nhất nếu có.
    4. Áp dụng xử phạt đúng một lần. DEACTIVATE lưu hạn 30 ngày, thu hồi mọi session/token, gửi email xử phạt và audit.
    5. Đến hạn, job nền kiểm tra đúng xử phạt đã đủ thời gian và tự chuyển ACTIVE.
    6. Ghi sự kiện mở lại, gửi email; user đăng nhập lại bằng session mới.

- **Abnormal Cases**
    - 2.a1: Admin chưa xác nhận → yêu cầu chưa giải quyết; không khóa.
    - 3.a1: Đối tượng bản thân/Admin ngang hàng → MSG39; chỉ riêng quyền Owner không làm từ chối.
    - 4.a1: Gửi yêu cầu lặp → trả kết quả cũ; không tạo thẻ trùng hoặc tính lại hạn phạt.
    - 5.a1: Worker gián đoạn → xử lý bù các hạn đã tới khi phục hồi; không mở trước hạn.
    - 6.a1: Email lỗi → retry thông báo, tài khoản vẫn đã mở. Không ghi đè xử phạt khác hoặc trạng thái DELETED hiện tại.

**Post-Conditions**

- User FLAGGED giữ session nhưng đăng bài qua ADMIN; user DEACTIVATED mất toàn bộ quyền truy cập tài khoản.
- Lưu hạn phạt 30 ngày; đủ hạn tự ACTIVE, có email và audit.
- Thành viên Agency tiếp tục quyền hiện có; không tự chuyển Owner hoặc khóa toàn Agency.
- Giữ toàn bộ dữ liệu và lịch sử xử phạt/strike.
