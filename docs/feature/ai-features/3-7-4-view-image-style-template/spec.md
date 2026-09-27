# 3.7.4 View Image Style Template

| | |
|---|---|
| FR Code | 3.7.4 |
| Feature | View Image Style Template (FLUX.2 Capability Parameters & Prompt Modifiers) |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR (thuộc Workspace / Agency) |
| Routes | `GET /api/v1/ai/image-style-templates`<br>`GET /api/v1/ai/image-style-templates/{templateId}`<br>`GET /internal/ai/image/templates` (ai-service) |
| Related FRs | 3.7.3 Generate Ambassador, 3.7.5 Generate Image, 3.7.6 View Video Style Template |
| Document status | Target Spec |
| Implementation status | In Progress (FLUX.2 Capability Modifiers & System Catalog Migration) |

## Function Trigger
Begins when a Creator opens the Image Generation Studio (`/workspaces/:workspaceId/ai/generate-image`) or Ambassador Studio (`/workspaces/:workspaceId/ai/ambassador`), and opens the Style Template Gallery to browse, filter, inspect, or select an image style preset.

## Function Description
- **Actors / Roles:** CREATOR (holding active Workspace access).
- **Purpose:** Provide a curated, high-aesthetic catalog of visual style templates optimized specifically for the FLUX.2 image foundation model. Each template encapsulates positive and negative prompt modifiers, lighting, texture, and capability tuning parameters, eliminating the requirement for manual prompt engineering or legacy SDXL LoRA adapters.
- **Interface:** Interactive Style Gallery Drawer / Modal (`StyleTemplateGalleryModal.tsx` embedded in `/workspaces/:workspaceId/ai/generate-image`):
  - Category filter pills (`All`, `Commercial Product`, `Studio Portrait`, `Cinematic`, `Minimalist & Editorial`, `Anime & Illustration`, `3D & CGI`, `Vintage & Film`).
  - Search bar supporting full-text keyword lookup.
  - Responsive thumbnail card grid with hover zoom, active selection checkmark, and template preview details.
  - Template Detail Inspector drawer showcasing before-and-after sample generations, parameter recommendations, and prompt injection snippets.
- **Data Processing:** The Business Service queries cached template metadata from Redis (with database fallback), filters by category and search keyword, verifies active template status, and returns a paginated list of style templates with CDN-accelerated preview URLs. When a user selects a template, the client injects the template ID and capability modifiers into the generation payload for FR 3.7.5.

## Screen Layout
Figure — Style Template Gallery Drawer (`StyleTemplateGalleryModal.tsx`):
- **Header:** Title "Thư viện Phong cách Ảnh AI", Search input (`TemplateSearchInput`, placeholder `Tìm kiếm phong cách: studio, cinematic, anime...`), Close button (`X`), and active selection indicator ("Đang chọn: 1 phong cách" or "Chưa chọn phong cách").
- **Category Filter Bar:** Horizontal scrollable chip list:
  - `ALL` (Tất cả)
  - `COMMERCIAL_PRODUCT` (Sản phẩm thương mại & Quảng cáo)
  - `STUDIO_PORTRAIT` (Chân dung studio cao cấp)
  - `CINEMATIC` (Điện ảnh & Ánh sáng kịch tính)
  - `MINIMALIST_EDITORIAL` (Tối giản & Bìa tạp chí)
  - `ANIME_MANGA` (Minh họa & Anime Nhật Bản)
  - `3D_CGI` (Đồ họa 3D & Isometric Octane Render)
  - `VINTAGE_FILM` (Phim nhựa Retro & Hoài cổ)
- **Template Card Grid:** 3-column to 4-column responsive grid:
  - **Template Card Component:**
    - High-quality 1:1 preview thumbnail with lazy loading and rounded corners.
    - Category pill in the top-left corner.
    - Checkmark badge in the top-right corner when selected.
    - Title (`name`) and one-line aesthetic summary (`description`).
    - Quick Action Buttons: "Xem chi tiết" (Opens Detail Inspector) and "Áp dụng" (Selects template and updates form).
- **Detail Inspector Drawer (`TemplateDetailDrawer.tsx`):**
  - High-resolution carousel displaying 2–4 sample images generated with this template on FLUX.2.
  - Recommended aspect ratios (e.g., `1:1`, `4:5`, `16:9`).
  - Prompt modifier preview snippet (e.g., `prefix: "cinematic film still, 35mm photograph...", suffix: "...kodachrome 64, volumetric fog, rim lighting"`).
  - Recommended guidance scale & step count indicator.
  - Action Button: "Chọn phong cách này" (Sets as active style and closes drawer) or "Bỏ chọn phong cách" (If currently active).
- **Footer Bar:** "Bỏ chọn tất cả", "Đóng", and "Xác nhận áp dụng".

## Function Details
### Data Specifications
- **Input query parameters:**
  - `category` (optional enum: `ALL`, `COMMERCIAL_PRODUCT`, `STUDIO_PORTRAIT`, `CINEMATIC`, `MINIMALIST_EDITORIAL`, `ANIME_MANGA`, `3D_CGI`, `VINTAGE_FILM`, default: `ALL`).
  - `search` (optional string, max 100 chars, trims whitespace).
  - `page` (optional integer, min 1, default: 1).
  - `limit` (optional integer, range: 1–50, default: 24).
- **System data:**
  - `templateId` (UUID, primary key).
  - `code` (string, unique slug, e.g., `flux2-cinematic-kodak-gold`).
  - `isActive` (boolean, indicates whether template is enabled in production).
  - `sortOrder` (integer, ranking priority in list).
- **Output:**
  - Paginated list of style templates containing: `id`, `code`, `name`, `category`, `description`, `previewThumbnailUrl`, `sampleImages`, `recommendedAspectRatio`, `fluxModifiers` (`promptPrefix`, `promptSuffix`, `negativePromptSnippet`), `recommendedSteps`, `recommendedGuidanceScale`, `isActive`.

### Business Rules
- **BR-AI-11: Zero SDXL LoRA Dependency (Pure FLUX.2 Capability Architecture):** All style templates use FLUX.2 foundation prompt framing and capability modifier tokens. No legacy SDXL LoRA weights, external `.safetensors` files, or Topic LoRA dependencies are loaded. This guarantees high generation speed, zero cold-start model swap latency, and multi-tenant safety.
- **BR-AI-12: Non-Destructive Prompt Augmentation:** Selecting a Style Template NEVER overwrites or erases the Creator's custom prompt text in the input box. The template's `promptPrefix` and `promptSuffix` are merged at generation time by the Business Service / AI Service orchestrator, preserving the user's creative text intact.
- **BR-AI-13: De-selection & Neutral Default:** Applying a Style Template is strictly optional. The Creator can deselect the active template at any time, returning the generation mode to `RAW_USER_PROMPT` (pure prompt without automatic stylistic modifiers).
- **BR-AI-14: Template Availability & Version Snapshotting:**
  - Only templates with `isActive == true` are returned by the catalog API and allowed for new generation requests.
  - Inactive or deprecated templates cannot be selected for new jobs.
  - When an image generation job is created, the system stores a snapshot of the applied template parameters in the job metadata. Historical regenerations or audits continue to trace the exact prompt modifiers even if the catalog template is updated later.
- **BR-AI-15: Zero Credit Consumption:** Browsing, searching, inspecting, and selecting style templates is completely free and incurs zero AI credits. AI credits are only consumed when an actual generation job is dispatched in FR 3.7.5 or FR 3.7.3.

### Validation & Error Messages
- `category` contains an unrecognized enum value → HTTP 400, Display: **MSG-AI-11** ("Danh mục phong cách không hợp lệ.")
- `search` keyword exceeds 100 characters → HTTP 400, Display: **MSG-AI-12** ("Từ khóa tìm kiếm không được vượt quá 100 ký tự.")
- `templateId` does not exist → HTTP 404, Display: **MSG-AI-13** ("Phong cách hình ảnh không tồn tại.")
- Selected `templateId` is inactive or deprecated → HTTP 410, Display: **MSG-AI-14** ("Phong cách hình ảnh này đã ngừng hỗ trợ. Vui lòng chọn phong cách khác.")
- Internal cache or database retrieval failure → HTTP 500, Display: **MSG-AI-15** ("Không thể tải danh sách phong cách ảnh. Vui lòng thử lại sau.")

## API Contracts & DTOs
### 1. List Style Templates
`GET /api/v1/ai/image-style-templates?category=COMMERCIAL_PRODUCT&search=studio&page=1&limit=24`
```json
// Response: 200 OK
{
  "success": true,
  "data": [
    {
      "id": "7f8b3c10-1a2b-4c3d-8e4f-5a6b7c8d9e0f",
      "code": "flux2-commercial-studio-clean",
      "name": "Commercial Clean Studio",
      "category": "COMMERCIAL_PRODUCT",
      "description": "Phong cách studio chuyên nghiệp, phông nền đơn sắc tối giản, ánh sáng softbox khuếch tán làm nổi bật chi tiết sản phẩm.",
      "previewThumbnailUrl": "https://cdn.brandhub.io/templates/images/thumbs/commercial-clean-studio.webp",
      "sampleImages": [
        "https://cdn.brandhub.io/templates/images/samples/commercial-clean-studio-1.webp",
        "https://cdn.brandhub.io/templates/images/samples/commercial-clean-studio-2.webp"
      ],
      "recommendedAspectRatio": "1:1",
      "fluxModifiers": {
        "promptPrefix": "Commercial studio product photography, clean minimalist podium background, professional softbox studio lighting, sharp focus,",
        "promptSuffix": "8k uhd, photorealistic, premium commercial advertising quality, ultra detailed texture",
        "negativePromptSnippet": "cluttered background, harsh specular reflection, grain, noisy, blurry, cartoon, low resolution"
      },
      "recommendedSteps": 28,
      "recommendedGuidanceScale": 3.5,
      "isActive": true,
      "sortOrder": 1
    },
    {
      "id": "8e9c4d21-2b3c-5d4e-9f5a-6b7c8d9e0f1a",
      "code": "flux2-cinematic-editorial",
      "name": "Cinematic Editorial Portrait",
      "category": "CINEMATIC",
      "description": "Ánh sáng điện ảnh kịch tính, phong cách bìa tạp chí thời trang quốc tế với chiều sâu trường ảnh sâu và gam màu giàu cảm xúc.",
      "previewThumbnailUrl": "https://cdn.brandhub.io/templates/images/thumbs/cinematic-editorial.webp",
      "sampleImages": [
        "https://cdn.brandhub.io/templates/images/samples/cinematic-editorial-1.webp"
      ],
      "recommendedAspectRatio": "4:5",
      "fluxModifiers": {
        "promptPrefix": "Cinematic editorial fashion photograph, dramatic chiaroscuro lighting, shallow depth of field, 35mm film aesthetic,",
        "promptSuffix": "editorial color grading, vogue magazine cover quality, award winning photography",
        "negativePromptSnippet": "flat lighting, overexposed, amateur, bad anatomy, deformed"
      },
      "recommendedSteps": 30,
      "recommendedGuidanceScale": 4.0,
      "isActive": true,
      "sortOrder": 2
    }
  ],
  "meta": {
    "page": 1,
    "limit": 24,
    "total": 18,
    "totalPages": 1
  }
}
```

### 2. Get Style Template Details
`GET /api/v1/ai/image-style-templates/{templateId}`
```json
// Response: 200 OK
{
  "success": true,
  "data": {
    "id": "7f8b3c10-1a2b-4c3d-8e4f-5a6b7c8d9e0f",
    "code": "flux2-commercial-studio-clean",
    "name": "Commercial Clean Studio",
    "category": "COMMERCIAL_PRODUCT",
    "description": "Phong cách studio chuyên nghiệp, phông nền đơn sắc tối giản...",
    "previewThumbnailUrl": "https://cdn.brandhub.io/templates/images/thumbs/commercial-clean-studio.webp",
    "sampleImages": [
      "https://cdn.brandhub.io/templates/images/samples/commercial-clean-studio-1.webp",
      "https://cdn.brandhub.io/templates/images/samples/commercial-clean-studio-2.webp"
    ],
    "recommendedAspectRatio": "1:1",
    "fluxModifiers": {
      "promptPrefix": "Commercial studio product photography, clean minimalist podium background...",
      "promptSuffix": "8k uhd, photorealistic, premium commercial advertising quality...",
      "negativePromptSnippet": "cluttered background, harsh specular reflection..."
    },
    "recommendedSteps": 28,
    "recommendedGuidanceScale": 3.5,
    "isActive": true,
    "createdAt": "2026-09-01T00:00:00Z",
    "updatedAt": "2026-09-20T10:00:00Z"
  }
}
```

## Functionalities
### Normal Flow
1. The Creator navigates to `/workspaces/:workspaceId/ai/generate-image` and clicks on the "Chọn phong cách mẫu" (Choose Style Template) button.
2. The UI opens the `StyleTemplateGalleryModal` and triggers `GET /api/v1/ai/image-style-templates?category=ALL`.
3. The server retrieves cached template objects and delivers the JSON array to the client.
4. The client renders the category filter chips, search input, and responsive template card grid.
5. The Creator clicks the `COMMERCIAL_PRODUCT` tab or enters a keyword in the search bar.
6. The client filters the list instantly or requests updated search results from the API.
7. The Creator clicks on a card to open `TemplateDetailDrawer`, reviewing sample outputs and prompt modifier previews.
8. The Creator clicks "Áp dụng phong cách này" (Apply this style).
9. The modal closes; the selected template's ID and badge are displayed in the Image Generation Studio form under "Phong cách đã chọn".
10. When the Creator subsequently generates an image (FR 3.7.5), the selected `styleTemplateId` is attached to the generation payload.

### Abnormal Cases
- **5.a1:** Search keyword or category yields no matching templates → The UI displays an empty illustration state with the message "Không tìm thấy phong cách phù hợp" and a quick-action button "Xóa bộ lọc". **5.a2:** The Creator clicks "Xóa bộ lọc" to reset the list to `ALL`.
- **7.a1:** A template displayed in the gallery is deactivated by an administrator before the user selects it (BR-AI-14) → Upon selection, server returns HTTP 410 GONE, alert MSG-AI-14. **7.a2:** UI updates the template card to "Đã ngừng hỗ trợ" and prompts the user to select another template.
- **8.a1:** The Creator decides not to use any visual template → The Creator clicks "Bỏ chọn phong cách". **8.a2:** The form clears the `styleTemplateId` and returns to raw prompt generation mode without error.
- **10.a1:** CDN thumbnail fails to load due to client-side network interruption → The UI displays a graceful fallback gradient placeholder with the template title, ensuring the interface remains functional and clickable.

## Post-Conditions
- The active `styleTemplateId` is stored in the frontend state of the Image Generation Studio.
- The template's recommended aspect ratio is suggested to the user (without forcibly overriding manual selections).
- When submitting the generation request in FR 3.7.5, the system merges the template's FLUX.2 modifiers into the orchestration pipeline.

## Out of Scope
- Uploading custom user-trained LoRA models or modifying server-side FLUX.2 capability definitions.
- Creating or editing style templates from the Creator role (Template management is an administrative function).
- Purchasing or unlocking premium templates via individual credit micropayments (Templates are bundled with active workspace subscription tiers).

## References
- Architecture & Alignment: [docs/plan/ai-features-spec-alignment-plan.md](../../plan/ai-features-spec-alignment-plan.md) (PO decisions D01, D11).
- BA Specification: [docs/ba/06-ai-features.md](../../ba/06-ai-features.md) (UC-74 & Image Template Guidelines).
- Related Features: FR 3.7.3 Generate Ambassador, FR 3.7.5 Generate Image, FR 3.7.6 View Video Style Template.
