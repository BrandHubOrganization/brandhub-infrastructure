# Đặc tả nghiệp vụ — FR 3.6.15: Apply Watermark to Material

| Thông tin | Chi tiết |
|---|---|
| **Mã chức năng (FR Code)** | **3.6.15** |
| **Mã Task kế hoạch** | **DA-E51-06e** |
| **Tên tính năng** | Apply Watermark to Material (Đóng dấu bản quyền thương hiệu lên ấn phẩm) |
| **Phân hệ (Domain)** | Content & Task Workflow (FR 3.6 / Epic E51) |
| **Vai trò người dùng (Roles)** | `CREATOR` (Thực thi chính), `MANAGER` (Kiểm duyệt & thực thi), `CLIENT` (Xem ấn phẩm có watermark) |
| **Phiên bản tài liệu** | 3.0 — 2026-10-07 (Đầy đủ khảo sát đối thủ & đặc tả kỹ thuật chi tiết) |
| **Trạng thái tài liệu** | **Approved Specification** |

---

## 1. Khảo sát thị trường & Phân tích đối thủ cạnh tranh (Competitor Research)

### 1.1 Khảo sát các nền tảng có tính năng tương tự
Trong quy trình sản xuất nội dung số và quản lý tài sản truyền thông, việc đóng dấu watermark là bước chuẩn hóa không thể thiếu. Khảo sát 4 nền tảng phổ biến hiện nay:

1. **Img2Go / ILoveIMG (Web Utility Tools)**:
   - *Cách làm*: Người dùng upload ảnh nền và upload ảnh watermark (hoặc gõ text). Chọn vị trí theo lưới 9 ô, chỉnh độ mờ (opacity) và padding từ viền.
   - *Nhược điểm*: Rời rạc, độc lập, không có ngữ cảnh thương hiệu. Người dùng phải tải ảnh từ hệ thống nội bộ về máy -> mở web tool -> tự tìm file logo upload lên -> xử lý -> tải về -> upload lại hệ thống. Tốn thời gian, dễ nhầm lẫn version logo cũ/mới và tiềm ẩn rủi ro lộ tài nguyên chưa công bố.
2. **Canva (Graphic Design Platform)**:
   - *Cách làm*: Cho phép chèn Logo từ *Brand Kit* vào artboard thiết kế, kéo thả kích thước, chỉnh độ trong suốt (Transparency slider từ 0–100%).
   - *Ưu điểm*: Logo được chuẩn hóa trong Brand Kit của công ty.
   - *Nhược điểm*: Phụ thuộc vào thao tác thủ công của người thiết kế trong trình biên tập đồ họa; không có cơ chế đóng dấu hàng loạt (batch watermark) hay tự động giữ phiên bản phái sinh (derived version) gắn liền với vòng đời nhiệm vụ duyệt (Approval Task).
3. **Watermarkly / Visual Watermark (Dedicated Watermarking Tools)**:
   - *Cách làm*: Hỗ trợ chế độ đóng dấu đơn lẻ (Single watermark) và đóng dấu lặp dạng lưới chéo (Tiled watermark - lặp lại full màn hình với góc xoay 45°).
   - *Ưu điểm*: Chế độ Tiled Watermark bảo vệ tối đa bản quyền khi gửi bản thảo (Draft) cho khách hàng xem trước mà không sợ bị tải về sử dụng lậu.
   - *Nhược điểm*: Chỉ là công cụ offline hoặc web app đơn lẻ, không tích hợp vào quy trình làm việc giữa Agency và Client.
4. **Cloudinary / Adobe Experience Manager (Enterprise DAM)**:
   - *Cách làm*: Đóng dấu watermark bằng dynamic URL transformations (layer overlay `l_brand:logo`, `o_30`, `g_south_east`).
   - *Ưu điểm*: Xử lý mạnh mẽ, phi hủy diệt, tự động scale theo kích thước ảnh gốc.
   - *Nhược điểm*: Chi phí hạ tầng cao, cấu hình phức tạp, đòi hỏi thiết lập kỹ thuật thay vì giao diện trực quan cho Creator.

### 1.2 Điểm hay vượt trội của BrandHub so với đối thủ
| Tiêu chí | Công cụ truyền thống (Img2Go, Watermarkly) | Canva | **BrandHub (FR 3.6.15)** |
|---|---|---|---|
| **Nguồn tài nguyên Logo** | Tự upload thủ công từng lần | Lấy từ Brand Kit cá nhân | **Trực tiếp từ `Brand Collection` của Client trong Workspace**: Chỉ dùng đúng Logo chính thức do Client cung cấp/duyệt |
| **Quy trình làm việc (Workflow)** | Rời rạc, phải chuyển file qua lại giữa các app | Làm trong artboard thiết kế | **Nhúng trực tiếp (In-Workflow)**: Đóng dấu trực tiếp tại Task Detail / Material Library với 1 click |
| **Bảo toàn dữ liệu (Non-destructive)** | Phải lưu thành file mới ngoài máy | Lưu bản export | **Tự động sinh bản ghi `WATERMARKED` độc lập**, giữ nguyên tuyệt đối bản gốc (`RAW` / `RETOUCHED`) |
| **Chế độ bảo vệ bản quyền** | Thường chỉ có 1 vị trí | Thủ công căn chỉnh | **2 chế độ linh hoạt**: Single Grid (9 vị trí chuẩn) & Tiled Grid (Lưới lặp chéo bảo vệ bản nháp gửi Client duyệt) |
| **Truy vết & Tái sử dụng** | Không lưu thông số | Lưu trên canvas | **Lưu trọn bộ metadata**: `logoAssetId`, `position`, `opacity`, `scale`, `parentMaterialId` để tái tạo khi cần |

---

## 2. Mục tiêu tính năng (Objectives) & User Story

### 2.1 Mục tiêu
1. Cung cấp công cụ đóng dấu watermark chuyên nghiệp, trực quan ngay trên giao diện web của BrandHub.
2. Đảm bảo tính nhất quán nhận diện thương hiệu bằng cách ràng buộc nguồn Logo từ chính **Brand Collection** do Client quản lý trong Workspace.
3. Bảo toàn nguyên vẹn tài sản gốc (Non-destructive editing): Mọi thao tác watermark đều sinh ra file và bản ghi tài liệu mới, liên kết chặt chẽ với bản gốc.

### 2.2 User Stories
- **US-01 (Creator)**: *Là một Creator/Designer*, tôi muốn đóng dấu logo thương hiệu của Client lên ảnh đã chỉnh sửa (retouched) với vị trí, tỷ lệ và độ mờ mong muốn, để bảo vệ quyền sở hữu và chuẩn hóa ấn phẩm trước khi gửi duyệt.
- **US-02 (Creator - Bảo vệ bản thảo)**: *Là một Creator*, tôi muốn bật chế độ đóng dấu lặp dạng lưới (Tiled Draft Protection) khi gửi bản demo xem trước cho Client, để ngăn chặn việc sử dụng ấn phẩm trái phép khi chưa hoàn tất thanh toán hoặc chưa duyệt nghiệm thu.
- **US-03 (Manager)**: *Là một Workspace Manager*, tôi muốn kiểm tra và có thể tự đóng dấu bổ sung/thay thế logo thương hiệu trên ấn phẩm của thành viên trước khi nộp lên Client, để đảm bảo tiêu chuẩn hình ảnh của Agency.
- **US-04 (Client)**: *Là một Client*, tôi muốn thấy ấn phẩm mang đúng logo chuẩn của thương hiệu mình đã cung cấp trong Brand Collection, với chất lượng hiển thị sắc nét và chuyên nghiệp.

---

## 3. Tiêu chí chấp nhận chi tiết (Acceptance Criteria - AC)

- **AC-01 (Nguồn Material đầu vào)**:
  - Chỉ cho phép áp dụng watermark lên các Material có định dạng ảnh (`image/png`, `image/jpeg`, `image/webp`).
  - Không cho phép watermark lên file không phải ảnh (video, pdf) ở phạm vi FR này (hiển thị thông báo hướng dẫn phù hợp).
- **AC-02 (Nguồn Logo đầu vào từ Brand Collection)**:
  - Hệ thống tự động truy vấn danh sách Brand Assets từ `brand_collections` thuộc Workspace hiện tại (loại `LOGO`).
  - Nếu Workspace chưa có Logo nào trong Brand Collection, hệ thống vô hiệu hóa nút Apply, đồng thời hiển thị banner cảnh báo: *"Chưa có logo trong Brand Collection của Client. Vui lòng liên hệ Client hoặc tải lên logo thương hiệu trước."*
- **AC-03 (Căn chỉnh vị trí linh hoạt - 9 Grid Points)**:
  - Hỗ trợ 9 vị trí căn chỉnh chuẩn:
    - Hàng trên: `TOP_LEFT`, `TOP_CENTER`, `TOP_RIGHT`
    - Hàng giữa: `MIDDLE_LEFT`, `CENTER`, `MIDDLE_RIGHT`
    - Hàng dưới: `BOTTOM_LEFT`, `BOTTOM_CENTER`, `BOTTOM_RIGHT` (Mặc định: `BOTTOM_RIGHT`).
  - Tự động áp dụng lề an toàn (Margin padding: 3% - 5% theo kích thước ảnh gốc) để logo không bị sát mép ảnh.
- **AC-04 (Tùy chỉnh thông số hiển thị)**:
  - **Độ mờ (Opacity)**: Thanh trượt từ 10% đến 100% (Mặc định: 80%).
  - **Kích thước logo (Scale)**: Tỷ lệ so với chiều rộng/chiều dài ảnh gốc từ 5% đến 40% (Mặc định: 15%), giữ nguyên tỷ lệ khung hình (Aspect Ratio) của Logo.
  - **Chế độ Lưới bảo vệ (Tiled Watermark)**: Checkbox chuyển đổi giữa chế độ Single Logo và chế độ Lưới lặp lại toàn màn hình (gồm nhiều logo mờ lặp nghiêng góc -45°).
- **AC-05 (Xem trước thời gian thực - Live Preview)**:
  - Giao diện modal cung cấp khung Canvas Interactive Live Preview: Khi Creator thay đổi logo, vị trí, thanh trượt độ mờ hoặc kích thước, khung preview cập nhật tức thì (Client-side HTML5 Canvas preview) trước khi ấn xác nhận.
- **AC-06 (Tính năng phi hủy diệt - Non-destructive Output)**:
  - Khi người dùng bấm **"Áp dụng & Xuất bản mới" (Apply & Save)**:
    - Ảnh gốc (`originalMaterial`) giữ nguyên 100%, không bị sửa đổi.
    - Hệ thống tạo ra một file ảnh mới trên File Storage (MinIO / S3).
    - Tạo bản ghi `Material` mới với thuộc tính `type = WATERMARKED`, lưu kèm metadata: `parentMaterialId`, `watermarkMeta: { logoAssetId, position, opacity, scale, mode }`.
- **AC-07 (Tự động liên kết Task)**:
  - Nếu thao tác đóng dấu được mở từ màn hình Task Detail (loại Post), ảnh mới xuất ra tự động xuất hiện trong danh sách attachments/assets của Task đó, sẵn sàng để gửi duyệt.
- **AC-08 (Hỗ trợ định dạng trong suốt)**:
  - Giữ nguyên kênh Alpha (transparency) của file PNG/WebP logo, không xuất hiện viền đen hoặc nền trắng xung quanh logo khi áp lên ảnh gốc.

---

## 4. Đặc tả Giao diện & Trải nghiệm Người dùng (UI/UX)

### 4.1 Điểm kích hoạt (Entry Points)
1. **Tại Kho lưu trữ Material (`/workspaces/:id/materials`)**:
   - Trên mỗi thẻ Material (card) hoặc menu hành động 3 chấm `...` -> Chọn mục **"Đóng dấu bản quyền" (Apply Watermark)**.
2. **Tại Chi tiết Công việc (`/workspaces/:id/tasks/:taskId`)**:
   - Trong tab "Ấn phẩm & Media", cạnh mỗi ảnh đính kèm đã retouch -> Nút icon Watermark (Đóng dấu).

### 4.2 Thiết kế Modal "Đóng dấu Watermark thương hiệu" (Watermark Studio Modal)
- **Kích thước**: Modal cỡ lớn (`max-w-5xl`), thiết kế 2 cột:
  - **Cột trái (Chiếm 60% - Canvas Preview)**:
    - Khung preview ảnh gốc hiển thị với tỉ lệ chính xác.
    - Logo watermark hiển thị đè lên ảnh theo thời gian thực (real-time canvas rendering).
    - Nút Zoom in, Zoom out, Reset view.
  - **Cột phải (Chiếm 40% - Bộ điều khiển Controller)**:
    1. *Chọn Logo thương hiệu*: Danh sách thumbnail các logo có sẵn trong Brand Collection (có nhãn: Logo chính, Logo âm bản, Icon). Có nút "Tải logo mới vào Brand Collection" nếu có quyền.
    2. *Chế độ đóng dấu*: Radio Button (Đơn vị trí `Single` vs Lưới bản quyền `Tiled Pattern`).
    3. *Chọn vị trí*: Ma trận lưới 3x3 trực quan (9 nút radio biểu tượng).
    4. *Độ mờ (Opacity)*: Thanh trượt `Slider` từ 10% đến 100%, kèm ô nhập số.
    5. *Kích thước logo (Size/Scale)*: Thanh trượt `Slider` từ 5% đến 40% kích thước ảnh.
    6. *Nút hành động (Footer)*:
       - Nút phụ: **"Hủy bỏ" (Cancel)**.
       - Nút chính: **"Tạo bản đóng dấu" (Generate Watermarked Image)** kèm hiệu ứng loading khi BE đang xử lý ảnh gốc phân giải cao.

---

## 5. Hợp đồng API (API Contract Specification)

### 5.1 Endpoint áp dụng Watermark
- **Phương thức & URL**: `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/watermark`
- **Xác thực**: Bearer JWT (`Authorization: Bearer <token>`)
- **Phân quyền tối thiểu**: `CREATOR`, `MANAGER`, `OWNER` trong Workspace.

#### Request Body
```json
{
  "logoAssetId": "brand_asset_65f1234abcd",
  "mode": "SINGLE",
  "position": "BOTTOM_RIGHT",
  "opacity": 0.85,
  "scale": 0.15,
  "paddingPercent": 0.03
}
```

*Trong trường hợp `mode = "TILED"`:*
```json
{
  "logoAssetId": "brand_asset_65f1234abcd",
  "mode": "TILED",
  "opacity": 0.20,
  "scale": 0.10,
  "rotationAngle": -45
}
```

#### Response Thành công (`201 Created`)
```json
{
  "success": true,
  "data": {
    "id": "mat_9876543210fedc",
    "workspaceId": "ws_123456",
    "name": "banner_summer_campaign_watermarked.png",
    "originalName": "banner_summer_campaign.png",
    "type": "WATERMARKED",
    "mimeType": "image/png",
    "fileSize": 2451098,
    "url": "https://storage.brandhub.io/workspaces/ws_123456/materials/banner_summer_campaign_watermarked.png",
    "parentMaterialId": "mat_original_12345",
    "watermarkMeta": {
      "logoAssetId": "brand_asset_65f1234abcd",
      "mode": "SINGLE",
      "position": "BOTTOM_RIGHT",
      "opacity": 0.85,
      "scale": 0.15
    },
    "createdBy": "usr_789012",
    "createdAt": "2026-10-07T12:30:00Z"
  },
  "message": "Watermark applied successfully"
}
```

#### Mã lỗi (Error Responses)
| HTTP Status | Error Code | Mô tả |
|---|---|---|
| `400 Bad Request` | `INVALID_MATERIAL_TYPE` | File gốc không phải là hình ảnh được hỗ trợ. |
| `400 Bad Request` | `LOGO_NOT_FOUND` | `logoAssetId` không tồn tại trong Brand Collection của Workspace. |
| `400 Bad Request` | `INVALID_WATERMARK_PARAMS` | Độ mờ nằm ngoài khoảng (0.1–1.0) hoặc vị trí không hợp lệ. |
| `403 Forbidden` | `FORBIDDEN_WORKSPACE_ACCESS` | Người dùng không phải là thành viên hoạt động của Workspace. |
| `404 Not Found` | `MATERIAL_NOT_FOUND` | `materialId` gốc không tìm thấy hoặc đã bị xóa. |
| `500 Internal Error` | `IMAGE_PROCESSING_FAILED` | Lỗi trong quá trình render/composite ảnh tại server. |

---

## 6. Yêu cầu Giao diện: Đa ngôn ngữ (i18n) & Giao diện Sáng/Tối (Dark/Light)

### 6.1 Bảng từ điển Đa ngôn ngữ (i18n Key Parallel)
Toàn bộ chuỗi văn bản được đặt dưới namespace `materials.watermark.*`:

| i18n Key | Tiếng Việt (`vi.json`) | Tiếng Anh (`en.json`) |
|---|---|---|
| `materials.watermark.title` | Đóng dấu Watermark thương hiệu | Apply Brand Watermark |
| `materials.watermark.subtitle` | Gắn logo từ Brand Collection để bảo vệ bản quyền ấn phẩm | Stamp Client logo from Brand Collection to protect asset copyright |
| `materials.watermark.selectLogo` | Chọn Logo thương hiệu | Select Brand Logo |
| `materials.watermark.noLogoWarning` | Chưa có logo trong Brand Collection. Vui lòng thêm logo trước. | No logo found in Brand Collection. Please upload a logo first. |
| `materials.watermark.uploadLogoPrompt` | Tải logo lên Brand Collection | Upload logo to Brand Collection |
| `materials.watermark.modeSingle` | Vị trí đơn | Single Placement |
| `materials.watermark.modeTiled` | Lưới bảo vệ bản quyền (Tiled) | Draft Copyright Grid (Tiled) |
| `materials.watermark.position` | Vị trí đóng dấu | Placement Position |
| `materials.watermark.opacity` | Độ mờ đục | Opacity |
| `materials.watermark.scale` | Kích thước logo (%) | Logo Scale (%) |
| `materials.watermark.preview` | Xem trước thời gian thực | Real-time Preview |
| `materials.watermark.applyBtn` | Áp dụng & Tạo bản mới | Apply & Save As New |
| `materials.watermark.cancelBtn` | Hủy bỏ | Cancel |
| `materials.watermark.successToast` | Đã đóng dấu watermark thành công | Watermark applied successfully |
| `materials.watermark.failedToast` | Không thể đóng dấu ảnh. Vui lòng thử lại. | Failed to apply watermark. Please try again. |
| `materials.watermark.badgeWatermarked` | Đã đóng dấu | Watermarked |

### 6.2 Chuẩn hóa Giao diện Sáng / Tối (Dark / Light Theme Tokens)
| Thành phần UI | Light Mode | Dark Mode |
|---|---|---|
| Nền Modal | `bg-white border-neutral-200` | `bg-neutral-900 border-neutral-800` |
| Vùng Canvas Preview | `bg-neutral-100 checkerboard-light` | `bg-neutral-950 checkerboard-dark` |
| Khung chọn Logo Item | `border-neutral-200 hover:border-orange-500 bg-neutral-50` | `border-neutral-800 hover:border-orange-500 bg-neutral-800/60` |
| Nút vị trí 3x3 Grid (Inactive) | `bg-neutral-100 text-neutral-600 hover:bg-neutral-200` | `bg-neutral-800 text-neutral-400 hover:bg-neutral-700` |
| Nút vị trí 3x3 Grid (Active) | `bg-orange-500 text-white font-semibold ring-2 ring-orange-200` | `bg-orange-600 text-white font-semibold ring-2 ring-orange-950` |
| Badge trạng thái Watermarked | `bg-sky-50 text-sky-700 border-sky-200` | `bg-sky-950/60 text-sky-400 border-sky-800` |

---

## 7. Xử lý Trường hợp Biên (Edge Cases) & An toàn Dữ liệu

1. **Ảnh gốc có độ phân giải siêu cao (4K / 8K, > 15MB)**:
   - Trên trình duyệt, Client-side Canvas chỉ render bản thu nhỏ (max width 1200px) để đảm bảo tốc độ phản hồi 60fps mượt mà khi kéo thanh trượt Opacity/Scale.
   - Thao tác xuất ảnh thực tế được đẩy lên Backend xử lý trên luồng nền (Java `Graphics2D` với Bicubic Interpolation và AlphaComposite), đảm bảo ảnh thành phẩm giữ trọn vẹn 100% độ sắc nét gốc.
2. **Logo thương hiệu là file vector SVG**:
   - Nếu Logo trong Brand Collection là SVG, backend chuyển đổi SVG sang raster PNG phân giải cao tương ứng với kích thước tính toán trước khi thực hiện composite.
3. **Logo có tỉ lệ dài bất thường (Horizontal wordmark) hoặc biểu tượng vuông (Square icon)**:
   - Thuật toán scale tính toán dựa trên cạnh lớn nhất (Bounding Box fit), đảm bảo logo không bao giờ bị méo dạng (luôn giữ tỷ lệ khung hình chuẩn).
4. **Trùng tên file**:
   - File xuất mới được tự động thêm hậu tố `_watermarked_{timestamp}.png` để không bao giờ ghi đè hoặc xung đột tên file gốc.

---

## 8. Tiêu chuẩn Hoàn thành (Definition of Done - DoD)

1. [x] Tài liệu `spec.md`, `plan.md`, `task.md`, `test.md` được viết đầy đủ, tuân thủ đúng `feature-workflow.md`.
2. [ ] Backend API `POST /api/v1/workspaces/{id}/materials/{materialId}/watermark` hoàn thành, xử lý composite ảnh sắc nét, giữ nguyên file gốc.
3. [ ] Frontend modal tích hợp Live Preview canvas mượt mà, đầy đủ 9 vị trí và thanh trượt opacity/scale.
4. [ ] Khóa liên kết dữ liệu với `brand_collections` hoạt động chính xác.
5. [ ] 100% chuỗi hiển thị được i18n hóa đầy đủ trong cả `vi.json` và `en.json`.
6. [ ] Giao diện hỗ trợ chuẩn chỉnh cả 2 chế độ Light và Dark mode.
7. [ ] Đạt 100% test case trong `test.md`.
