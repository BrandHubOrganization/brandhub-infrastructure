# Phân rã Công việc (Task Checklist) — FR 3.6.15: Apply Watermark to Material

| Thông tin | Chi tiết |
|---|---|
| **Mã công việc** | **DA-E51-06e** |
| **Phân hệ** | Content & Workflow (FR 3.6) |
| **Người thực hiện** | Lê Trí Trung (Tech Lead) |
| **Tài liệu tham chiếu** | [spec.md](./spec.md) \| [plan.md](./plan.md) |

---

## 1. Backend (`brandhub-business-service`)

### 1.1 Data Model & DTOs
- [x] **TASK-BE-01**: Cập nhật Model `MaterialDocument.java` bổ sung các trường `parentMaterialId` và `WatermarkMetadata`.
- [x] **TASK-BE-02**: Tạo enum `WatermarkMode` (`SINGLE`, `TILED`) và `WatermarkPosition` (9 vị trí từ `TOP_LEFT` đến `BOTTOM_RIGHT`).
- [x] **TASK-BE-03**: Tạo `ApplyWatermarkRequest.java` và `MaterialResponse.java` kèm validation rules (`@NotNull`, `@Min`, `@Max`).

### 1.2 Image Processing Engine
- [x] **TASK-BE-04**: Xây dựng service component `ImageWatermarkProcessor.java` xử lý composite ảnh bằng Java `Graphics2D`:
  - [x] Hỗ trợ tính toán tọa độ theo 9 điểm lưới chuẩn kèm margin padding.
  - [x] Hỗ trợ cấu hình `AlphaComposite` cho độ mờ đục (Opacity 10%–100%).
  - [x] Hỗ trợ chế độ lưới lặp lại (Tiled Pattern) góc xoay -45°.
  - [x] Bảo toàn kênh Alpha (transparency) của logo PNG/WebP và màu sắc ảnh gốc.
- [x] **TASK-BE-05**: Viết Unit Test độc lập cho `ImageWatermarkProcessorTest` (kiểm tra render 9 vị trí, opacity, không crash với ảnh kích thước khác nhau).

### 1.3 Service Logic & API Controller
- [x] **TASK-BE-06**: Cập nhật `MaterialService` và `MaterialServiceImpl`:
  - [x] Kiểm tra quyền truy cập Workspace của người dùng (`CREATOR`, `MANAGER`, `OWNER`).
  - [x] Kiểm tra loại file của Material gốc (phải là định dạng ảnh).
  - [x] Truy vấn và nạp logo từ Brand Collection của Client trong Workspace (`LOGO_NOT_FOUND` nếu không tồn tại).
  - [x] Thực thi composite qua `ImageWatermarkProcessor`.
  - [x] Upload file kết quả mới lên `FileStorageService` (MinIO/S3), không ghi đè file gốc.
  - [x] Lưu bản ghi Material mới với type `WATERMARKED`.
- [x] **TASK-BE-07**: Tạo API Endpoint trong `MaterialController.java`:
  - `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/watermark`.
- [x] **TASK-BE-08**: Viết Test cho Service và Processor (`MaterialServiceImplTest`, `ImageWatermarkProcessorTest`).

---

## 2. Frontend (`brandhub-web-dashboard`)

### 2.1 API Client & State Management
- [x] **TASK-FE-01**: Cập nhật `src/services/materialService.ts` thêm method `applyWatermark(workspaceId, materialId, payload)`.
- [x] **TASK-FE-02**: Cập nhật `materialService.ts` thêm method `listBrandAssets(workspaceId)` lấy danh sách logo từ Brand Collection / Workspace / Client Profiles.

### 2.2 UI Components
- [x] **TASK-FE-03**: Xây dựng custom hook `useWatermarkCanvas.ts` quản lý tính toán vẽ preview HTML5 Canvas thời gian thực (60 FPS).
- [x] **TASK-FE-04**: Xây dựng component `WatermarkPositionGrid.tsx` (ma trận lưới 3x3 trực quan, có highlight trạng thái active).
- [x] **TASK-FE-05**: Xây dựng component `BrandLogoSelector.tsx` hiển thị danh sách logo kèm tải logo tạm thời.
- [x] **TASK-FE-06**: Xây dựng component `WatermarkPreviewCanvas.tsx` chứa khung preview, hỗ trợ zoom, loading spinner.
- [x] **TASK-FE-07**: Xây dựng modal tổng hợp `WatermarkStudioModal.tsx` bố cục 2 cột, kết nối bộ điều khiển độ mờ, kích thước và nút xác nhận.

### 2.3 Tích hợp Giao diện & Entry Points
- [x] **TASK-FE-08**: Tích hợp nút mở Watermark Studio trên `MediaDetailPanel.tsx` trong thư viện ấn phẩm.
- [x] **TASK-FE-09**: Tích hợp callback `onWatermarked` cập nhật danh sách media tức thì khi sinh ấn phẩm mới.
- [x] **TASK-FE-10**: Hiển thị nhãn nhận diện `FR 3.6.15` và trạng thái đóng dấu.

---

## 3. Đa ngôn ngữ (i18n) & Giao diện (Theme)

- [x] **TASK-UI-01**: Cập nhật toàn bộ các key văn bản mới vào `src/i18n/locales/vi/materials.json`.
- [x] **TASK-UI-02**: Cập nhật tương ứng các key song song vào `src/i18n/locales/en/materials.json`.
- [x] **TASK-UI-03**: Kiểm tra toàn diện hiển thị trên giao diện Sáng (Light mode) và Tối (Dark mode).

---

## 4. Kiểm thử & Tài liệu (Testing & Docs)

- [x] **TASK-DOC-01**: Hoàn thiện 4 file tài liệu chuẩn: `spec.md`, `plan.md`, `task.md`, `test.md`.
- [x] **TASK-QA-01**: Chạy toàn bộ Unit Tests BE (7/7 tests passed: `ImageWatermarkProcessorTest`, `MaterialServiceImplTest`).
- [x] **TASK-QA-02**: Chạy kiểm tra TypeScript (`tsc --noEmit`), ESLint và Build bundle Vite thành công (0 errors).
- [x] **TASK-DOC-02**: Cập nhật trạng thái `DA-984` thành `Done` trong `jira_status.json`.

---

## 4. Phase 1 (Sprint 11) — Advanced Watermark Suite Progress

- [x] **DA-ADV-01**: Xây dựng `LumaDetector.java` (Rec. 601 formula $Y = 0.299R + 0.587G + 0.114B$) & 5/5 Unit Tests passed (Commit `0e85f96`).
- [x] **DA-ADV-02**: Tích hợp Real-time Canvas Luma Analyzer, Smart Contrast suggestion badge và Drop Shadow rendering trên FE (Commit `2b98d59`).
- [x] **DA-ADV-03**: Xây dựng `WatermarkPresetDocument`, Service, Repository & REST API CRUD (`/watermark-presets`) & 4/4 Unit Tests passed (Commit `35d5f27`).
- [x] **DA-ADV-04**: Xây dựng `WatermarkPresetSelector.tsx`, lưu mẫu cấu hình theo Client, tự động nạp cấu hình mặc định, Vite build thành công (Commit `adfde14`).
- [ ] **DA-ADV-05**: Xây dựng Text Watermark Engine (TrueType Fonts & Dynamic Tokens `{clientName}`, `{year}`, `{creatorName}`, `{date}`).
- [ ] **DA-ADV-06**: Xây dựng Text Studio Controls Tab trên FE.

