# Kịch bản Kiểm thử (Test Cases) — FR 3.6.15: Apply Watermark to Material

| Thông tin | Chi tiết |
|---|---|
| **Mã chức năng** | **FR 3.6.15 (DA-E51-06e)** |
| **Tài liệu tham chiếu** | [spec.md](./spec.md) \| [plan.md](./plan.md) |
| **Phân hệ** | `brandhub-business-service`, `brandhub-web-dashboard` |

---

## 1. Kiểm thử Tiêu chí Chấp nhận (Acceptance Criteria Test Cases)

### TC-AC-01: Kiểm tra tính năng đóng dấu cơ bản với 9 vị trí lưới (Single Mode)
- **Tiền điều kiện**: Đã có 1 Material ảnh dạng `RETOUCHED` và Brand Collection của Workspace có ít nhất 1 Logo hợp lệ (PNG trong suốt).
- **Các bước thực hiện**:
  1. Creator mở màn hình Material hoặc Task Detail, bấm icon "Đóng dấu bản quyền" (Apply Watermark).
  2. Chọn Logo từ Brand Collection.
  3. Lần lượt bấm thử 9 vị trí trên lưới: `TOP_LEFT`, `CENTER`, `BOTTOM_RIGHT`...
  4. Quan sát khung Live Preview Canvas.
  5. Chọn vị trí `BOTTOM_RIGHT`, chỉnh Opacity = 80%, Scale = 15%, bấm **"Áp dụng & Tạo bản mới"**.
- **Kết quả mong đợi**:
  - Live Preview cập nhật tức thì vị trí logo tương ứng mỗi khi click chọn.
  - API trả về `201 Created` kèm thông tin Material mới có `type = WATERMARKED`.
  - Ảnh xuất ra có logo nằm chuẩn tại góc dưới bên phải, cách lề an toàn ~3%, độ trong suốt 80%.
  - Ảnh gốc không hề bị thay đổi hay ghi đè.

### TC-AC-02: Kiểm tra chế độ Lưới bảo vệ bản quyền (Tiled Draft Protection Mode)
- **Tiền điều kiện**: Đang mở modal Watermark Studio.
- **Các bước thực hiện**:
  1. Chọn Logo thương hiệu.
  2. Bật chế độ "Lưới bảo vệ bản quyền (Tiled)".
  3. Chỉnh Opacity = 20%, bấm "Áp dụng & Tạo bản mới".
- **Kết quả mong đợi**:
  - Live Preview và file kết quả hiển thị logo lặp lại đều đặn dạng lưới nghiêng -45° phủ toàn bộ diện tích ảnh với độ mờ nhẹ (20%), thích hợp gửi demo cho khách hàng duyệt bản nháp.

### TC-AC-03: Kiểm tra tính bảo toàn kênh Alpha (Alpha Transparency)
- **Tiền điều kiện**: Logo là file PNG có nền trong suốt.
- **Các bước thực hiện**: Đóng dấu logo lên một bức ảnh có nhiều mảng màu tối và sáng.
- **Kết quả mong đợi**:
  - Logo hiển thị mượt mà không có viền đen, răng cưa hay nền trắng bao quanh. Kênh Alpha của logo kết hợp hoàn hảo với các điểm ảnh nền.

---

## 2. Kiểm thử Trường hợp Biên & Ngoại lệ (Edge Cases & Negative Tests)

### TC-NEG-01: Workspace chưa có Logo trong Brand Collection
- **Tiền điều kiện**: Tạo một Workspace mới hoàn toàn mà Client chưa upload bất kỳ Logo nào vào Brand Collection.
- **Các bước thực hiện**:
  1. Mở một Material trong Workspace này và click "Đóng dấu bản quyền".
- **Kết quả mong đợi**:
  - Modal hiển thị thông báo cảnh báo rõ ràng: *"Chưa có logo trong Brand Collection của Client..."*.
  - Nút "Áp dụng" bị vô hiệu hóa (disabled).
  - Nếu cố tình gửi API `POST .../watermark` với `logoAssetId` rỗng -> Backend trả về `400 LOGO_NOT_FOUND`.

### TC-NEG-02: Cố tình đóng dấu lên Material không phải là ảnh (Video / PDF)
- **Tiền điều kiện**: Material có mimeType là `video/mp4` hoặc `application/pdf`.
- **Các bước thực hiện**:
  1. Gửi request `POST /api/v1/workspaces/{id}/materials/{videoMaterialId}/watermark`.
- **Kết quả mong đợi**:
  - Backend chặn ngay lập tức, trả về `400 INVALID_MATERIAL_TYPE`.

### TC-NEG-03: Ảnh gốc độ phân giải cao (4K / 8K, > 10MB)
- **Tiền điều kiện**: Material gốc là ảnh 4K (3840x2160, dung lượng ~12MB).
- **Các bước thực hiện**:
  1. Mở modal Watermark Studio trên Frontend.
  2. Kéo thanh trượt Opacity và Scale liên tục.
  3. Bấm Apply Watermark.
- **Kết quả mong đợi**:
  - Live Preview trên Canvas không bị đơ, giật lag hay treo trình duyệt (nhờ sử dụng preview scale).
  - Backend xử lý thành công không bị tràn bộ nhớ Java Heap (OutOfMemoryError), ảnh kết quả giữ nguyên độ phân giải 3840x2160 sắc nét.

### TC-NEG-04: Quyền truy cập không hợp lệ
- **Tiền điều kiện**: User không thuộc Workspace hoặc tài khoản đã bị vô hiệu hóa.
- **Các bước thực hiện**: Gửi request watermark.
- **Kết quả mong đợi**: Trả về `403 FORBIDDEN_WORKSPACE_ACCESS`.

---

## 3. Kiểm thử Giao diện: Đa ngôn ngữ & Sáng/Tối (i18n & Theme Tests)

### TC-UI-01: Kiểm tra Đa ngôn ngữ (Vietnamese & English)
- **Các bước thực hiện**:
  1. Đổi ngôn ngữ hệ thống sang Tiếng Việt -> Mở Watermark Studio Modal.
  2. Đổi ngôn ngữ hệ thống sang Tiếng Anh -> Mở lại Watermark Studio Modal.
- **Kết quả mong đợi**:
  - 100% tiêu đề, nhãn thanh trượt, tooltip, nút bấm, thông báo toast chuyển đổi đúng theo từ điển i18n (`vi.json` và `en.json`).
  - Tuyệt đối không có chuỗi nào hiển thị dạng mã raw (như `materials.watermark.title`) hoặc bị hardcode tiếng Việt trong giao diện tiếng Anh.

### TC-UI-02: Kiểm tra Giao diện Sáng / Tối (Light & Dark Mode)
- **Các bước thực hiện**:
  1. Bật Dark Mode trong cài đặt hệ thống.
  2. Mở Watermark Studio Modal và thao tác toàn bộ quy trình.
- **Kết quả mong đợi**:
  - Nền modal chuyển sang tông màu tối dịu mắt (`bg-neutral-900`).
  - Vùng canvas preview hiển thị nền caro tối (checkerboard-dark) tương phản tốt với ảnh.
  - Các chữ, nhãn, thanh trượt hiển thị rõ ràng, không bị chìm màu hay mất nét viền.
