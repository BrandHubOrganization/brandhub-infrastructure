# Plan — Workspace Detail Fields → Enum Toggle

## Backend (brandhub-business-service)

### 1. Enum mới
`model/enums/WorkspaceIndustry.java`:
```java
public enum WorkspaceIndustry {
    FNB, FASHION, BEAUTY, TECHNOLOGY, REAL_ESTATE,
    EDUCATION, HEALTHCARE, SERVICES, RETAIL, OTHER
}
```
`model/enums/ReportFrequency.java`:
```java
public enum ReportFrequency { WEEKLY, MONTHLY }
```
Đặt cùng package `model.enums` như `MemberRole` hiện có — không tạo package
mới.

### 2. WorkspaceSettings (response DTO, jsonb shape)
Thêm field `industry`:
```java
public record WorkspaceSettings(
        WorkspaceIndustry industry,
        String timezone,
        List<String> defaultPlatforms,
        ReportFrequency reportFrequency
) {}
```
Đổi `reportFrequency` từ `String` sang `ReportFrequency`. Jackson tự
serialize/deserialize enum ↔ string name qua `ObjectMapper` sẵn có trong
`WorkspaceServiceImpl.parseSettings`/`writeSettings` — không cần code thêm,
nhưng PHẢI xử lý an toàn khi JSON cũ có giá trị không khớp enum (xem mục 5).

### 3. CreateWorkspaceRequest
```java
public record CreateWorkspaceRequest(
        @NotBlank String name,
        WorkspaceIndustry industry
) {}
```
Đổi `String` → `WorkspaceIndustry`. Jackson tự validate enum hợp lệ khi
deserialize request body — giá trị sai tự động 400 qua
`HttpMessageNotReadableException` (đã có handler chung trong
`GlobalExceptionHandler`, kiểm tra có bắt đúng loại lỗi này chưa, nếu chưa
thêm handler trả 400 rõ ràng thay vì lọt vào generic 500).

### 4. UpdateWorkspaceSettingsRequest
```java
public record UpdateWorkspaceSettingsRequest(
        String name,
        String timezone,
        List<String> defaultPlatforms,
        ReportFrequency reportFrequency
) {}
```

### 5. WorkspaceServiceImpl — FIX BUG + cập nhật logic
**`createWorkspace`**: hiện tại hoàn toàn không dùng `request.industry()`.
Sửa để lưu vào settings ngay lúc tạo:
```java
Workspace workspace = Workspace.builder()
        .name(request.name())
        .slug(slug)
        .ownerId(currentUser.getId())
        .settings(writeSettings(new WorkspaceSettings(
                request.industry(), null, null, null)))
        .build();
```

**`updateSettings`**: đổi `request.reportFrequency()` kiểu `String`→
`ReportFrequency`, giữ nguyên logic merge (field null giữ giá trị cũ).

**`parseSettings`**: hiện bắt `JsonProcessingException` → trả object rỗng.
Cần kiểm tra: nếu jsonb cũ có `industry`/`reportFrequency` là string không
khớp enum (case dữ liệu cũ theo spec mục Error Handling), Jackson sẽ throw
`InvalidFormatException` (subclass của `JsonProcessingException`) — catch đã
đủ rộng, tự động fallback về `WorkspaceSettings(null,null,null,null)` — xác
nhận lại hành vi này qua unit test, KHÔNG cần code thêm nếu catch hiện tại
đã bọc đúng phạm vi.

### 6. Test
- `WorkspaceServiceImplTest`: `createWorkspace_withIndustry_savesIndustryInSettings`
  (test fix bug), `updateSettings_invalidReportFrequency_rejectedByDeserialize`
  (test ở tầng controller/MockMvc vì enum invalid fail tại Jackson
  deserialize, trước khi vào service).

## Frontend (brandhub-web-dashboard)

### 7. types/workspace.ts
```ts
export type WorkspaceIndustry =
  | "FNB" | "FASHION" | "BEAUTY" | "TECHNOLOGY" | "REAL_ESTATE"
  | "EDUCATION" | "HEALTHCARE" | "SERVICES" | "RETAIL" | "OTHER";

export type ReportFrequency = "WEEKLY" | "MONTHLY";

export interface WorkspaceSettings {
  industry: WorkspaceIndustry | null;
  timezone: string | null;
  defaultPlatforms: string[] | null;
  reportFrequency: ReportFrequency | null;
}
```

### 8. workspaceService.ts
```ts
export interface CreateWorkspaceRequest {
  name: string;
  industry?: WorkspaceIndustry;
}
export interface UpdateWorkspaceSettingsRequest {
  name?: string;
  timezone?: string;
  defaultPlatforms?: string[];
  reportFrequency?: ReportFrequency;
}
```

### 9. CreateWorkspacePage.tsx
- Bỏ `Input` industry, state `industry: string` → `industry: WorkspaceIndustry | null`.
- Toggle 10 nút (giống pattern platform picker
  `workspace-logo-platform-picker/plan.md`), single-select: click lại giá trị
  đang active → set `null`.
- Label hiển thị qua `t(\`workspace.industry.${value}\`)`.
- `handleSubmit` gửi `industry: industry ?? undefined`.

### 10. WorkspaceSettingsPage.tsx
- Bỏ `Input` reportFrequency, state `reportFrequency: string` →
  `reportFrequency: ReportFrequency | null`.
- Toggle 2 nút (WEEKLY/MONTHLY), single-select cùng cơ chế click-lại-để-bỏ.
- `handleSubmit` gửi `reportFrequency: reportFrequency ?? undefined`.

### 11. i18n
`vi.json` + `en.json`: thêm namespace `workspace.industry.*` (10 key) +
`workspace.reportFrequency.*` (2 key), đặt cạnh `workspace.settings.*` hiện
có.

## File Touch List
- `brandhub-business-service/src/main/java/com/brandhub/business/model/enums/WorkspaceIndustry.java` (mới)
- `brandhub-business-service/src/main/java/com/brandhub/business/model/enums/ReportFrequency.java` (mới)
- `brandhub-business-service/src/main/java/com/brandhub/business/dto/response/WorkspaceSettings.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/CreateWorkspaceRequest.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/dto/request/UpdateWorkspaceSettingsRequest.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/service/impl/WorkspaceServiceImpl.java`
- `brandhub-business-service/src/main/java/com/brandhub/business/exception/GlobalExceptionHandler.java` (kiểm tra, sửa nếu thiếu handler enum-deserialize-fail)
- `brandhub-web-dashboard/src/types/workspace.ts`
- `brandhub-web-dashboard/src/services/workspaceService.ts`
- `brandhub-web-dashboard/src/pages/workspaces/CreateWorkspacePage.tsx`
- `brandhub-web-dashboard/src/pages/workspaces/WorkspaceSettingsPage.tsx`
- `brandhub-web-dashboard/src/i18n/locales/vi.json`
- `brandhub-web-dashboard/src/i18n/locales/en.json`

## Rủi ro
- `Client.industry` (model/Client.java, dùng cho client trong workspace,
  KHÔNG phải workspace) là `String` riêng biệt, KHÔNG đổi — xác nhận đây là
  domain khác (client profile), ngoài scope, chỉ đổi `Workspace.settings`.
- Đổi type record field (String→enum) là breaking change cho request cũ nếu
  có client khác đang gọi API với industry text tự do — chấp nhận được vì
  dự án đang ở giai đoạn dev, không có consumer khác ngoài web-dashboard này.
- Kiểm tra kỹ `GlobalExceptionHandler` đã bắt
  `HttpMessageNotReadableException` chưa trước khi giả định 400 tự động xảy
  ra — nếu chưa có, phải thêm handler, không được bỏ qua.
