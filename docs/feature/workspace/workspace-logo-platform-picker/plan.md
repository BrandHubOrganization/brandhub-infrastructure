# Plan — Workspace Logo Upload + Platform Icon Picker

## Backend (brandhub-business-service)

### 1. ErrorCode.java
Thêm 2 code trong domain group Workspace:
```java
WORKSPACE_LOGO_INVALID_TYPE (HttpStatus.BAD_REQUEST, "Logo must be JPEG, PNG, or WebP"),
WORKSPACE_LOGO_TOO_LARGE    (HttpStatus.BAD_REQUEST, "Logo must not exceed 5MB"),
```

### 2. FileStorageService (interface) + S3FileStorageServiceImpl
Thêm method mới, KHÔNG sửa `uploadAvatar`/`deleteAvatar` hiện có (tránh phá
avatar user đang chạy):
```java
String uploadWorkspaceLogo(UUID workspaceId, byte[] content, String contentType);
void deleteFile(String fileUrl); // generalize từ deleteAvatar, dùng chung cho cả avatar lẫn logo
```
`uploadWorkspaceLogo` copy logic `uploadAvatar` (convert WebP, key pattern
`image/workspace-logos/{workspaceId}/{epochMilli}.{ext}`), khác key prefix.
`deleteFile` = rename `deleteAvatar` hiện tại (logic parse URL → xóa S3 object
không phụ thuộc "avatar", đổi tên gọi từ cả 2 chỗ).

### 3. WorkspaceService + WorkspaceServiceImpl
Thêm:
```java
WorkspaceResponse updateLogo(UUID workspaceId, MultipartFile file);
```
Logic: validate content-type (jpeg/png/webp) + size (≤5MB) → ném
`BusinessException(WORKSPACE_LOGO_INVALID_TYPE / TOO_LARGE)` → gọi
`fileStorageService.deleteFile(workspace.getLogoUrl())` nếu có logo cũ →
`fileStorageService.uploadWorkspaceLogo(...)` → set `workspace.setLogoUrl(url)`
→ save → map `WorkspaceResponse`.

### 4. WorkspaceController
```java
@PostMapping("/{workspaceId}/logo")
@RequireRole({MemberRole.OWNER, MemberRole.ACCOUNT})
public ApiResponse<WorkspaceResponse> uploadLogo(
        @PathVariable UUID workspaceId,
        @RequestParam("file") MultipartFile file,
        WebRequest webRequest) {
    return ApiResponse.ok(workspaceService.updateLogo(workspaceId, file), webRequest.getHeader("X-Request-Id"));
}
```
Trả `WorkspaceResponse` đầy đủ (không cần DTO riêng `WorkspaceLogoResponse` —
frontend đã có `Workspace.logoUrl`, dùng chung response type như
`updateSettings` — đơn giản hơn, tránh DTO thừa).

## Frontend (brandhub-web-dashboard)

### 5. workspaceService.ts
```ts
uploadLogo: (workspaceId: string, file: File) => {
  const formData = new FormData();
  formData.append("file", file);
  return api.post<ApiResponse<Workspace>>(
    `/api/v1/workspaces/${workspaceId}/logo`,
    formData,
    { headers: { "Content-Type": "multipart/form-data" } },
  );
},
```
Tham khảo `userService.uploadAvatar` cho pattern multipart hiện có.

### 6. WorkspaceSettingsPage.tsx
- Thêm state: `logoUrl`, `uploadingLogo`, `fileInputRef` — copy pattern từ
  `SettingsPage.tsx` avatar tab.
- Thêm avatar block trên đầu form (giống `SettingsPage.tsx` tab avatar):
  ảnh tròn + placeholder chữ cái đầu `name`, input file ẩn, nút upload.
- Xóa `Input` text `defaultPlatforms` (dòng 89-93 hiện tại), thay bằng grid 4
  icon toggle từ `lucide-react`: `Facebook`, `Instagram`, dùng icon TikTok
  tương đương có sẵn trong lucide-react (kiểm tra tên chính xác lúc code —
  `Music2` là fallback nếu không có icon TikTok riêng), `Linkedin`.
- State `defaultPlatforms` đổi từ `string` (join bằng dấu phẩy) sang
  `string[]` — set lúc load từ `data.data.settings.defaultPlatforms ?? []`
  thẳng, không `.join(", ")`.
- Toggle logic: click icon → nếu đã có trong mảng thì filter ra, chưa có thì
  thêm vào.
- Role check: cần biết role hiện tại của user trong workspace này để ẩn nút
  upload — kiểm tra `Layout.tsx`/route context có sẵn cung cấp `role` cho
  trang con không (Sidebar.tsx nhận prop `role: MemberRole | null` từ layout);
  nếu không có sẵn ở `WorkspaceSettingsPage`, gọi `workspaceService.listMembers`
  lọc theo `userId` hiện tại (từ `useAuthStore`) để lấy role.

### 7. i18n
Thêm 5 key mới vào `vi.json` + `en.json` namespace `workspace.settings.*`
theo spec.md, đặt cạnh các key `workspace.settings.*` hiện có.

## File Touch List
- `brandhub-business-service/src/main/java/com/brandhub/business/exception/ErrorCode.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/service/FileStorageService.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/service/impl/S3FileStorageServiceImpl.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/service/WorkspaceService.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/service/impl/WorkspaceServiceImpl.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/controller/WorkspaceController.java`
- `brandhub-web-dashboard/src/services/workspaceService.ts`
- `brandhub-web-dashboard/src/pages/workspaces/WorkspaceSettingsPage.tsx`
- `brandhub-web-dashboard/src/i18n/locales/vi.json`
- `brandhub-web-dashboard/src/i18n/locales/en.json`

## Rủi ro
- `deleteAvatar` → `deleteFile` rename: phải update cả chỗ gọi trong
  `UserServiceImpl` (avatar flow hiện tại) để không phá tính năng cũ. Kiểm
  tra bằng grep trước khi rename.
- S3 credentials thiếu ở local (đã biết từ điều tra CORS trước đó) — upload
  sẽ 500 khi test thật. Không thuộc scope sửa; test unit-level (mock
  `FileStorageService`) vẫn cần pass.
- Chưa rõ nguồn `role` hiện tại của user trong workspace ở
  `WorkspaceSettingsPage.tsx` — cần đọc `Layout.tsx`/`Sidebar.tsx` truyền prop
  trước khi code task 6, không đoán.
