# Kế hoạch Triển khai Kỹ thuật — FR 3.6.15: Apply Watermark to Material

| Thông tin | Chi tiết |
|---|---|
| **Mã chức năng** | **FR 3.6.15 (DA-E51-06e)** |
| **Phân hệ phụ trách** | `brandhub-business-service` (BE), `brandhub-web-dashboard` (FE) |
| **Tài liệu tham chiếu** | [spec.md](./spec.md) |
| **Tác giả** | Lê Trí Trung (Tech Lead) |
| **Trạng thái** | Ready for Implementation |

---

## 1. Kiến trúc Tổng quan (Architectural Overview)

Tính năng Apply Watermark được thiết kế theo nguyên lý **Hybrid Processing (Xử lý kết hợp)**:
1. **Client-Side (Frontend HTML5 Canvas)**: Chịu trách nhiệm render xem trước (Live Preview) tương tác thời gian thực với độ trễ < 16ms (60 FPS). Sử dụng bản ảnh preview kích thước tối ưu để đảm bảo thanh trượt Opacity, Scale và nút chọn vị trí 3x3 phản hồi mượt mà mà không cần gọi API render nặng nề về server.
2. **Server-Side (Backend Java Graphics2D Engine)**: Chịu trách nhiệm thực hiện phép ghép ảnh (compositing) trên file gốc phân giải cao nguyên bản (Full High-Resolution) với chất lượng Bicubic Antialiasing cao nhất, lưu trữ kết quả lên MinIO/S3 và cập nhật cơ sở dữ liệu `materials`.

```
[Creator UI (FE)]
       │
       ├── (1) Load Base Image & Brand Logos ──────────► [File Storage / S3]
       ├── (2) Real-time HTML5 Canvas Preview (Local)
       │
       └── (3) POST /api/v1/.../materials/{id}/watermark
                     │
                     ▼
       [MaterialController (Spring Boot)]
                     │
                     ▼
       [MaterialServiceImpl]
              ├── Fetch Base Material & Brand Logo Asset
              ├── [ImageWatermarkProcessor (Java AWT Graphics2D)]
              │         └── AlphaComposite.SRC_OVER + High-res Bicubic
              ├── Upload Watermarked Image Stream ─────► [File Storage / S3]
              └── Save new Material (type=WATERMARKED) ─► [Database / MongoDB]
```

---

## 2. Chi tiết Thiết kế Backend (`brandhub-business-service`)

### 2.1 Cấu trúc Dữ liệu & Entity Model

#### `Material.java` (Entity Document / Table)
Bổ sung các trường phục vụ lưu trữ tài nguyên phái sinh:
```java
public class Material {
    private String id;
    private String workspaceId;
    private String name;
    private String originalName;
    private MaterialType type; // RAW, RETOUCHED, WATERMARKED
    private String mimeType;
    private Long fileSize;
    private String url;
    
    // Liên kết nguồn gốc phi hủy diệt (Non-destructive lineage)
    private String parentMaterialId; // ID của ảnh gốc trước khi watermark
    private WatermarkMetadata watermarkMeta; // Thông số đã đóng dấu
    
    private String createdBy;
    private Instant createdAt;
    private Instant updatedAt;
}
```

#### `WatermarkMetadata.java` (Embedded Object)
```java
public class WatermarkMetadata {
    private String logoAssetId;
    private WatermarkMode mode; // SINGLE, TILED
    private WatermarkPosition position; // TOP_LEFT, BOTTOM_RIGHT, etc.
    private Double opacity; // 0.1 to 1.0
    private Double scale; // 0.05 to 0.40
    private Double paddingPercent; // 0.03
    private Integer rotationAngle; // Cho chế độ TILED (-45 deg)
}
```

### 2.2 Động cơ xử lý ảnh `ImageWatermarkProcessor.java`

Sử dụng thư viện chuẩn của Java `java.awt.Graphics2D` với cấu hình chất lượng cao:
- **Rendering Hints**:
  - `RenderingHints.KEY_INTERPOLATION` = `VALUE_INTERPOLATION_BICUBIC`
  - `RenderingHints.KEY_RENDERING` = `VALUE_RENDER_QUALITY`
  - `RenderingHints.KEY_ANTIALIASING` = `VALUE_ANTIALIAS_ON`
  - `RenderingHints.KEY_ALPHA_INTERPOLATION` = `VALUE_ALPHA_INTERPOLATION_QUALITY`
- **Tọa độ Single Placement (9 vị trí)**:
  - Tính toán `targetLogoWidth = baseWidth * scale`.
  - Tính toán `targetLogoHeight = targetLogoWidth * (logoOriginalHeight / logoOriginalWidth)`.
  - Padding: `padX = baseWidth * paddingPercent`, `padY = baseHeight * paddingPercent`.
  - Tọa độ `X, Y`:
    - `TOP_LEFT`: `(padX, padY)`
    - `TOP_CENTER`: `((baseWidth - targetLogoWidth) / 2, padY)`
    - `TOP_RIGHT`: `(baseWidth - targetLogoWidth - padX, padY)`
    - `MIDDLE_LEFT`: `(padX, (baseHeight - targetLogoHeight) / 2)`
    - `CENTER`: `((baseWidth - targetLogoWidth) / 2, (baseHeight - targetLogoHeight) / 2)`
    - `MIDDLE_RIGHT`: `(baseWidth - targetLogoWidth - padX, (baseHeight - targetLogoHeight) / 2)`
    - `BOTTOM_LEFT`: `(padX, baseHeight - targetLogoHeight - padY)`
    - `BOTTOM_CENTER`: `((baseWidth - targetLogoWidth) / 2, baseHeight - targetLogoHeight - padY)`
    - `BOTTOM_RIGHT`: `(baseWidth - targetLogoWidth - padX, baseHeight - targetLogoHeight - padY)`
- **Độ trong suốt (Transparency)**:
  - `g2d.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, opacity.floatValue()));`
- **Chế độ Lưới (Tiled Mode)**:
  - Tính toán bước lặp `stepX = targetLogoWidth * 2.5`, `stepY = targetLogoHeight * 2.5`.
  - Áp dụng phép xoay `g2d.rotate(Math.toRadians(-45), cx, cy)`.

### 2.3 Quản lý Bộ nhớ & Tối ưu Hiệu năng (Memory & Performance)
- Để tránh tràn bộ nhớ JVM Heap (OOM) khi xử lý đồng thời nhiều ảnh lớn:
  1. Giới hạn dung lượng tối đa file ảnh đầu vào là 25MB.
  2. Sử dụng `ImageIO.createImageInputStream` và giải phóng đối tượng `BufferedImage.flush()` ngay sau khi upload xong stream ra MinIO/S3.
  3. Xử lý ảnh trong khối `try-finally` đảm bảo gọi `g2d.dispose()`.

---

## 3. Chi tiết Thiết kế Frontend (`brandhub-web-dashboard`)

### 3.1 Cấu trúc Thư mục & Components
Tạo mới trong `src/pages/workspace/materials/components/watermark/`:
```
src/pages/workspace/materials/components/watermark/
├── WatermarkStudioModal.tsx        # Modal chính chứa bố cục 2 cột
├── WatermarkPreviewCanvas.tsx      # Canvas vẽ live preview
├── WatermarkPositionGrid.tsx       # Bộ nút chọn 3x3 vị trí chuẩn
├── BrandLogoSelector.tsx           # Danh sách lựa chọn logo từ Brand Collection
└── useWatermarkCanvas.ts           # Custom hook tính toán tọa độ và vẽ canvas
```

### 3.2 State Management
```typescript
interface WatermarkState {
  selectedLogoId: string | null;
  mode: 'SINGLE' | 'TILED';
  position: 'TOP_LEFT' | 'TOP_CENTER' | 'TOP_RIGHT' | 
            'MIDDLE_LEFT' | 'CENTER' | 'MIDDLE_RIGHT' | 
            'BOTTOM_LEFT' | 'BOTTOM_CENTER' | 'BOTTOM_RIGHT';
  opacity: number; // 0.1 to 1.0 (default 0.8)
  scale: number; // 0.05 to 0.40 (default 0.15)
  isProcessing: boolean;
}
```

### 3.3 Danh sách các File i18n chịu ảnh hưởng
Bổ sung các key định nghĩa tại `spec.md` vào:
- `src/i18n/locales/vi/materials.json`
- `src/i18n/locales/en/materials.json`

---

## 4. Kế hoạch Triển khai theo từng giai đoạn (Phased Implementation)

### Giai đoạn 1: Backend Foundation & Image Processing Engine
- Tạo DTO request/response cho Watermark.
- Xây dựng component `ImageWatermarkProcessor` với đầy đủ unit test xử lý alpha channel và 9 vị trí tọa độ.
- Tạo API Controller `POST /api/v1/workspaces/{id}/materials/{materialId}/watermark`.
- Tích hợp lưu file phái sinh vào `FileStorageService` và lưu bản ghi `Material`.

### Giai đoạn 2: Frontend Watermark Studio Modal
- Xây dựng modal với Live Preview Canvas HTML5.
- Kết nối API lấy danh sách logo từ `Brand Collection`.
- Ráp nối gọi API thực thi và cập nhật danh sách Material trên UI.
- Hoàn tất bảng dịch song ngữ `vi.json` và `en.json`.
- Kiểm thử hiển thị Dark/Light theme.

### Giai đoạn 3: Tích hợp vào Task Detail & Kiểm thử E2E
- Gắn nút kích hoạt Watermark Studio từ màn hình chi tiết Task (loại Post).
- Kiểm thử tải ảnh lớn, định dạng trong suốt PNG/WebP và các trường hợp biên.
