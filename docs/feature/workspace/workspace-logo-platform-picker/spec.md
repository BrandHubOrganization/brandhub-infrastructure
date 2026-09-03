# Spec — Workspace Logo Upload + Platform Icon Picker

## Objective
Trang Workspace Settings hiện chỉ có text input thô. Cần: (1) cho phép upload
ảnh đại diện (logo) cho workspace, giống flow avatar user đã có; (2) thay input
text tự gõ tên platform (`facebook, instagram, tiktok`) bằng bộ chọn icon
multi-select (Facebook/Instagram/TikTok/LinkedIn).

## User Story
Là OWNER/ACCOUNT của workspace, tôi muốn tải logo cho workspace và chọn nền
tảng mặc định bằng cách bấm icon thay vì gõ tay, để tránh gõ sai tên platform
và workspace có nhận diện trực quan hơn.

## Acceptance Criteria
- Trang `/workspace/:id/settings` hiển thị avatar/logo hiện tại (hoặc chữ cái
  đầu tên workspace nếu chưa có logo), nút upload ảnh (jpeg/png/webp, ≤5MB).
- Upload thành công → cập nhật `logoUrl` ngay trên UI, toast success.
- Sai định dạng/quá size → toast lỗi, không gọi API.
- Chỉ OWNER/ACCOUNT thấy nút upload (role khác: ẩn nút, chỉ xem logo).
- Phần "Nền tảng mặc định": 4 icon toggle (Facebook, Instagram, TikTok,
  LinkedIn), click để bật/tắt, trạng thái active có viền/nền brand-orange.
  Không còn input text tự gõ.
- Lưu form vẫn qua nút "Lưu thay đổi" hiện có, gửi `defaultPlatforms` là mảng
  các platform đang bật (giữ nguyên contract `UpdateWorkspaceSettingsRequest`).

## API Contract (mới)
`POST /api/v1/workspaces/{workspaceId}/logo`
- `multipart/form-data`, field `file`.
- Role required: `OWNER`, `ACCOUNT` (dùng `@RequireRole` có sẵn).
- Response: `ApiResponse<WorkspaceLogoResponse { logoUrl: string }>`.
- Lỗi: sai content-type / quá 5MB → `BusinessException` (thêm
  `WORKSPACE_LOGO_INVALID_TYPE`, `WORKSPACE_LOGO_TOO_LARGE` vào `ErrorCode`).

## Error Handling
- File rỗng/null → 400.
- Content-type ngoài jpeg/png/webp → 400.
- >5MB → 400.
- Không phải OWNER/ACCOUNT → 403 (có sẵn qua `@RequireRole`).
- S3 upload fail → 500 generic (đã có `GlobalExceptionHandler`, không xử lý
  riêng — biết trước local dev thiếu AWS credentials sẽ lỗi 500, đây là vấn đề
  môi trường, không phải logic, ghi chú trong task.md).

## Edge Cases
- Workspace chưa có `logoUrl` (null) → hiển thị placeholder chữ cái đầu tên,
  giống pattern avatar user hiện tại.
- Đổi logo mới → xóa logo cũ trên S3 (tái dùng logic xóa-theo-URL đã có trong
  `S3FileStorageServiceImpl.deleteAvatar`, generalize thành method dùng chung
  hoặc thêm `deleteWorkspaceLogo` gọi cùng helper).
- `defaultPlatforms` rỗng (không bật platform nào) → cho phép lưu mảng rỗng,
  không bắt buộc chọn ít nhất 1.

## UI States
- Loading: giữ `if (loading) return null;` hiện tại.
- Uploading logo: nút hiện spinner (dùng `Button loading` prop có sẵn).
- Icon platform: default (chưa chọn) = viền xám/muted; active = viền + nền
  `brand-orange` nhạt, icon màu `brand-orange`.

## i18n
Namespace `workspace.settings.*`. Key mới cần thêm (đồng thời `vi.json` +
`en.json`):
- `workspace.settings.logoLabel` — "Logo workspace" / "Workspace logo"
- `workspace.settings.logoUploadButton` — "Tải logo" / "Upload logo"
- `workspace.settings.logoInvalidType` — thông báo sai định dạng
- `workspace.settings.logoTooLarge` — thông báo quá dung lượng
- `workspace.settings.logoUploadSuccess` — toast thành công
- `workspace.settings.defaultPlatformsLabel` giữ nguyên (label khối icon
  picker, không đổi text).
- Tên platform hiển thị (Facebook/Instagram/TikTok/LinkedIn) là tên riêng,
  không dịch — giống cách `SettingsPage.tsx` xử lý "Google"/"GitHub".

## Light/Dark mode
Icon toggle dùng token theme sẵn có: `border-border`, `bg-card`,
`text-muted-foreground`, active state dùng `var(--brand-orange, #f05a28)`
giống pattern `NavLink` active trong `Sidebar.tsx`. Không hardcode màu rời
theme.

## Test Cases (sơ bộ)
1. Upload logo hợp lệ (png <5MB) → `logoUrl` cập nhật, hiển thị ảnh mới.
2. Upload file .txt → toast lỗi, không gọi API.
3. Upload file 6MB → toast lỗi client-side trước khi gọi API.
4. Click icon Facebook → active; click lại → tắt.
5. Lưu form với 2 platform bật → `defaultPlatforms: ["facebook","tiktok"]`
   gửi đúng backend.
6. Role ACCOUNT/CREATOR/CLIENT vào trang → không thấy nút upload logo (chỉ OWNER/MANAGER).
7. Chuyển theme dark/light → icon picker vẫn đọc được, không vỡ contrast.
8. Đổi ngôn ngữ vi/en → label logo/nút upload đổi đúng.

## Definition of Done
- Backend: endpoint `/workspaces/{id}/logo` hoạt động, role-gated, unit test
  service pass.
- Frontend: `WorkspaceSettingsPage.tsx` có avatar block + icon picker, không
  còn text input platform. `tsc`/`eslint` sạch.
- i18n key-parallel `vi.json`/`en.json`.
- Verify thủ công qua Chrome DevTools (nếu S3 local có credentials; nếu không,
  ghi rõ giới hạn môi trường trong báo cáo cuối).

## Out of Scope
- Crop/resize ảnh phía client.
- Thêm platform ngoài 4 cái (Facebook/Instagram/TikTok/LinkedIn) — theo đúng
  4 kênh đã nêu trong CLAUDE.md dự án.
- Sửa lỗi thiếu AWS credentials ở môi trường local (vấn đề infra, không phải
  code).
