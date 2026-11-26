> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.3.2: Update User Profile

> Implements [spec.md](./spec.md) — Personal profile field updates (`PUT /api/v1/users/me`) and independent validated image uploads (`POST /api/v1/users/me/avatar`, `POST /api/v1/users/me/banner`) enforcing `BR-11`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **Controller** | `brandhub-business-service` | `controller/user/UserController.java` (`PUT /api/v1/users/me`, `POST /api/v1/users/me/avatar`, `POST /api/v1/users/me/banner`) |
| **Service** | `brandhub-business-service` | `service/impl/user/UserServiceImpl.java` (`updateUserProfile`, `uploadAvatar`, `uploadBanner`), `service/impl/storage/S3FileStorageServiceImpl.java`, `util/ImageValidator.java` |
| **DTOs & Errors** | `brandhub-business-service` | `UpdateProfileRequest`, `UserProfileResponse`, `AvatarResponse`, `BannerResponse`, `ErrorCode` (`VALIDATION_ERROR`, `NO_FILE_PROVIDED`, `INVALID_FILE_TYPE`, `FILE_TOO_LARGE`, `UPLOAD_FAILED`) |
| **Persistence** | `brandhub-business-service` | `UserRepository.java` (PostgreSQL `users`), AWS S3 bucket (`avatars/`, `banners/`) |
| **Web Frontend** | `brandhub-web` | `src/pages/profile/index.tsx`, `src/pages/profile/components/{ProfileEditForm,AvatarUploadModal,JobTitleSelect,SkillsChipSelect,LanguageChipSelect,LocationAutocomplete}.tsx`, `src/components/shared/BannerUploader.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/settings/AccountSettingsScreen.tsx`, `src/services/userService.ts` |

## 2. API Contract & Partial-Merge Semantics

```http
PUT /api/v1/users/me
Authorization: Bearer <accessToken>
Body: { fullName, phone?, professionalTitle?, bio?, portfolioUrls?, skills?, location?, socialLinks?, workingLanguage?, timezone?, notificationPreferences? }
-> 200 ApiResponse<UserProfileResponse>

POST /api/v1/users/me/avatar   (multipart/form-data: file)
-> 200 ApiResponse<AvatarResponse>

POST /api/v1/users/me/banner   (multipart/form-data: file)
-> 200 ApiResponse<BannerResponse>
```

- **Immutable Email Structural Guard (`BR-11`):** `UpdateProfileRequest` contains no `email` field, structurally preventing email tampering.
- **Safe JSONB Preferences Merge:** `timezone` and `notificationPreferences` merge into existing `users.preferences` JSONB so updating `timezone` never wipes `notificationPreferences` (and vice versa).
- **Decoupled Media Lifecycle:** Avatar and banner uploads run independently via `S3FileStorageServiceImpl` after MIME + size (`<= 5 MB`) validation (`ImageValidator`), deleting replaced S3 objects cleanly without rolling back saved text fields.

## 3. End-to-End Execution Flow

1. **Profile Field Save (`PUT /api/v1/users/me`):**
   - Validates `fullName` (`@NotBlank` -> `400 VALIDATION_ERROR` `MSG02`).
   - Loads `User` by `@AuthenticationPrincipal` (`404 USER_NOT_FOUND` if missing), updates submitted columns (`fullName`, `phone`, `professionalTitle`, `bio`, `portfolioUrls`, `workingLanguage`, etc.), merges non-null `timezone` / `notificationPreferences` into `preferences` JSONB, saves `User`, and returns `UserProfileResponse`.
   - Frontend updates `authStore.setUser(...)` and invalidates profile/completeness queries immediately without page reload.
2. **Avatar / Banner Upload (`POST /api/v1/users/me/avatar`):**
   - Validates file non-empty (`NO_FILE_PROVIDED`), `image/*` MIME & magic bytes (`INVALID_FILE_TYPE`), and size `<= 5 MB` (`FILE_TOO_LARGE`).
   - Uploads new object to S3, deletes prior S3 object if present, saves `user.avatarUrl`, and returns `AvatarResponse`.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.3.2` — Update User Profile |
| **HTTP / WS Endpoints** | `PUT /api/v1/users/me · POST /api/v1/users/me/avatar · POST /api/v1/users/me/banner` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `UserController` -> `UserServiceImpl, S3FileStorageServiceImpl, ImageValidator` |
| **Persistence / Cache Targets** | PostgreSQL `users` (`preferences` JSONB); AWS S3 (`avatars/`, `banners/`) |
| **Business Rule Invariants** | `BR-11` |
| **Error Code Contract** | `400 VALIDATION_ERROR` / `NO_FILE_PROVIDED` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE`, `401 UNAUTHORIZED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/profile/index.tsx`, `src/pages/profile/components/{ProfileEditForm,AvatarUploadModal,JobTitleSelect,SkillsChipSelect,LanguageChipSelect,LocationAutocomplete}.tsx`, `src/services/userService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/settings/AccountSettingsScreen.tsx`, `src/services/userService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `profile.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
