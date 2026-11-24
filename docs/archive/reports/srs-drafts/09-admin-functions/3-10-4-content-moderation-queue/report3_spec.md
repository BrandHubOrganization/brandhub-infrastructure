**3.10.4 Content Moderation Queue (Hàng Đợi Kiểm Duyệt Nội Dung)**

**Function Trigger**

Admin mở /admin/content-moderation để xét nội dung bài viết bị đánh dấu hoặc bài của user FLAGGED.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên kiểm duyệt nội dung có thẩm quyền phê duyệt cho phép xuất bản hoặc cấm bài viết vi phạm.
- **Purpose**: Duyệt nội dung bài viết theo phiên bản cụ thể. User FLAGGED phải được ADMIN duyệt; chặn một phiên bản vẫn cho sửa và gửi phiên bản mới.
- **Interface**: Màn hình Hàng Đợi Kiểm Duyệt (SCR-ADM-04), gồm bảng danh sách bài viết chờ duyệt, ngăn kéo đối soát vi phạm (so sánh song song bản gốc và phần nghi vấn), các nút phán quyết và ô nhập lý do.
- **Data Processing**: Điểm tích hợp content/publishing gửi postId, contentVersionId, tác giả và snapshot/lý do vào PENDING_MODERATION. Giữ các bài đã lên lịch khi tác giả bị FLAGGED. Trước gửi thật, kiểm tra lại trạng thái tài khoản, phiên bản và quyết định ADMIN. APPROVE cho tiếp tục luồng/lịch xuất bản; BLOCK chặn phiên bản đó và ghi strike đã chọn qua FR 3.10.5. RED/ba ORANGE tạo yêu cầu xem xét, không tự khóa.

**Screen Layout**

Figure — Màn hình Hàng Đợi Kiểm Duyệt Nội Dung (SCR-ADM-04):

- Left/Header: Sidebar điều hướng Admin; Top Header hiển thị tiêu đề "Hàng Đợi Kiểm Duyệt Nội Dung", số lượng bài chờ duyệt và bộ lọc loại vi phạm (Chính sách, Bản quyền).
- Center: Hàng đợi: ID bài, phiên bản, tác giả, bộ đếm YELLOW/ORANGE/RED còn hiệu lực, nguồn cờ, lý do và thời điểm. Drawer đối chiếu snapshot nội dung với chứng cứ; chọn mức strike khi xác nhận vi phạm và nhập lý do.
- Buttons: Nút "Xác nhận vi phạm & Ghi nhận Thẻ phạt" (màu đỏ), Nút "Bỏ qua cảnh báo & Cho phép xuất bản" (màu xanh), Ô nhập lý do (bắt buộc khi bỏ qua cảnh báo), Nút "Đóng".
- Footer: Thanh phân trang danh sách (10, 20, 50 dòng/trang) và tổng số bài đã xử lý trong ngày.

**Function Details**

- **Data Specifications**
    - **Input required**: moderationId, postId, contentVersionId, decision (approve/block); note ít nhất 10 ký tự khi approve; strikeLevel và lý do khi block.
    - **Input optional**: violationCategory, tham chiếu chứng cứ.
    - **System data**: creatorId, reviewerId, snapshot nội dung, trạng thái tài khoản hiện tại, activeStrikeCounts, trạng thái và revision duyệt, reviewedAt.
    - **Output**: Kết quả phán quyết kiểm duyệt kèm mã HTTP 200 OK.

- **Business Rules**
    - **BR-64**: Duyệt nội dung bài viết theo phiên bản bất biến; chứng cứ asset đính kèm không phải phê duyệt riêng toàn bộ asset.
    - **BR-35**: Chỉ ADMIN được duyệt hàng đợi này. Manager/Client duyệt luồng nghiệp vụ không thay thế ADMIN.
    - **BR-64**: FLAGGED giữ cả bài đã lên lịch và bài gửi mới để ADMIN duyệt. Job chờ gửi phải kiểm tra lại trạng thái và đúng phiên bản đã duyệt trước dispatch.
    - **BR-64**: BLOCK áp dụng phiên bản đang duyệt; tác giả được sửa và gửi phiên bản mới. APPROVE không tự đăng ngay, không bỏ qua lịch và điều kiện luồng khác.
    - **BR-94**: YELLOW là cảnh cáo. Có ORANGE còn hiệu lực thì tài khoản bị FLAGGED, đăng bài phải được ADMIN duyệt nhưng vẫn được đăng nhập. RED hoặc đủ ba ORANGE còn hiệu lực tạo yêu cầu xem xét xử phạt tại FR 3.10.9; chỉ khóa sau khi Admin xác nhận.
    - **BR-95**: Ba YELLOW còn hiệu lực, chưa quy đổi, thuộc bất kỳ loại lỗi nào tạo một ORANGE độc lập. Đánh dấu cả ba thẻ nguồn đã quy đổi và giữ liên kết. YELLOW thứ tư bắt đầu nhóm tiếp theo; sáu YELLOW hợp lệ tạo hai ORANGE. Có thể ghi nhận ORANGE trực tiếp. Gỡ YELLOW nguồn không tự gỡ ORANGE phát sinh.
    - **BR-96**: Mỗi vi phạm mới bắt đầu lại thời gian 30 ngày liên tiếp không vi phạm cho tài khoản. Các thẻ còn hiệu lực hết hạn sau thời gian sạch này, không tính riêng 30 ngày từ lúc tạo từng thẻ. Không hồi sinh thẻ đã hết hạn/đã gỡ; quy đổi không phải một lần tái phạm mới. Giữ lịch sử bất biến khi hết hạn hoặc gỡ. Hết ORANGE chỉ khôi phục quyền đăng bài nếu không còn khóa tài khoản hoặc hạn chế kích hoạt.
    - **BR-16**: Audit người duyệt, bài/phiên bản, chứng cứ, quyết định, liên kết strike và lý do; xử lý lặp/đồng thời không tạo strike trùng.

- **Validation**
    - Thiếu quyền ADMIN → MSG39 (403).
    - Bài/phiên bản hoặc mục kiểm duyệt không tồn tại → MSG38 (404).
    - Mục đã xử lý hoặc phiên bản gửi đã đổi → xung đột (409); tải lại trạng thái hiện tại.
    - APPROVE thiếu ghi chú hoặc dưới 10 ký tự → MSG80; BLOCK thiếu mức/lý do → lỗi kiểm tra.
    - Lưu duyệt thành công → MSG42; chặn phiên bản được xét → MSG43.

**Functionalities**

- **Normal Flow**
    1. Điểm tích hợp tạo hoặc dùng lại bản ghi chờ duyệt của phiên bản bài.
    2. Admin xem snapshot, lý do, trạng thái tác giả và chứng cứ.
    3. Admin duyệt với ghi chú ít nhất 10 ký tự hoặc chặn kèm mức vi phạm và lý do.
    4. Hệ thống kiểm tra revision còn chờ một cách nguyên tử, lưu quyết định, ghi strike nếu chặn và audit.
    5. Gửi email kết quả cho tác giả. Phiên bản được duyệt tiếp tục luồng bình thường; phiên bản bị chặn phải sửa và gửi duyệt mới.
    6. Publisher kiểm tra lại đúng phiên bản và hạn chế tài khoản/kiểm duyệt trước dispatch.

- **Abnormal Cases**
    - 1.a1: Không tìm thấy bài/phiên bản → not found; sự kiện lặp → dùng lại bản ghi chờ.
    - 3.a1: Thiếu quyền ADMIN hoặc ghi chú duyệt quá ngắn → MSG39/MSG80.
    - 4.a1: Admin khác đã xử lý hoặc phiên bản gửi thay đổi → xung đột; tải lại, không áp quyết định cũ vào bản mới.
    - 6.a1: Tài khoản thành FLAGGED/DEACTIVATED hoặc phiên bản không khớp bản được duyệt → giữ xuất bản và kiểm tra lại điều kiện.

**Post-Conditions**

- Quyết định gắn đúng phiên bản được duyệt, có audit bất biến và liên kết strike.
- Bài của user FLAGGED, kể cả đã lên lịch, phải được ADMIN duyệt.
- Phiên bản BLOCKED_CONFIRMED không được đăng; bản sửa được vào PENDING_MODERATION mới.
- Không tự khóa vì RED hoặc ngưỡng ORANGE nếu chưa có xác nhận Admin tại FR 3.10.9.
