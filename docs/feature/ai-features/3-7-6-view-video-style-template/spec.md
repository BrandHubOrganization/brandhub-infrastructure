# 3.7.6 View Video Style Template

| | |
|---|---|
| FR Code | 3.7.6 |
| Feature | View Video Style Template |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 — 2026-09-27 — aligned with PO decisions and Google Veo 3.1 capability matrix |
| Document status | Target Spec |
| Implementation status | Research-pending |

## Function Trigger

Begins when a Creator opens the Video Generation Studio (`/workspaces/:workspaceId/ai/video-studio`) or selects the Video tab in Task Detail (`/workspaces/:workspaceId/tasks/:taskId`), and clicks the "Browse Style Templates" button to explore, filter, and preview available video style presets before generating video content.

## Function Description

- **Actors / Roles:** CREATOR (Workspace member with content creation permissions).
- **Purpose:** Provide a curated library of 30 video style presets (structured across 10 visual archetypes and 3 camera motion styles) with pre-rendered 3-second preview clips, camera motion tags, and prompt injection guidelines. Enables Creators to select an artistic/cinematic direction compatible with Google Veo 3.1 without manual prompt engineering.
- **Interface:**
  - Template Catalog Modal / Drawer: Filter bar (Archetype, Motion Style, Target Aspect Ratio), Search box, Grid of Template Cards.
  - Template Card: 3-second looped MP4 preview player (hover-to-play or click-to-preview), Archetype tag, Camera Motion badge, Recommended aspect ratio (`16:9` / `9:16`).
  - Template Detail Preview: Expanded modal displaying full 3s HD clip, Prompt modifier preview, parameter slots (`{subject}`, `{action}`, `{environment}`), and "Apply to Studio" button.
- **Data Processing:** `VideoTemplateController.listTemplates` → `VideoTemplateService.getTemplates` retrieves template definitions from PostgreSQL and Redis catalog cache (`ai:video:templates:catalog`). Static preview video files are served directly from CloudFront/S3 CDN. No AI credit deduction or generative GPU compute is incurred.

## Routes and DTOs

### Public / Client Endpoints (API Gateway → Business Service)

- `GET /api/v1/workspaces/{workspaceId}/ai/video-style-templates`
  - Query params: `archetype` (optional, string), `motionStyle` (optional, string), `aspectRatio` (optional, enum: `16:9`, `9:16`), `page` (default: 1), `limit` (default: 20).
  - Response `200 OK`: `ApiResponse<PageResult<VideoStyleTemplateDto>>`
- `GET /api/v1/workspaces/{workspaceId}/ai/video-style-templates/{templateId}`
  - Response `200 OK`: `ApiResponse<VideoStyleTemplateDetailDto>`

### DTO Schemas

```json
// VideoStyleTemplateDto
{
  "id": "tpl-vid-cinematic-orbit-01",
  "name": "Cinematic Drone Orbit",
  "archetype": "CINEMATIC",
  "motionStyle": "ORBIT_360",
  "previewClipUrl": "https://cdn.brandhub.io/ai/video-templates/previews/cinematic-orbit.mp4",
  "supportedAspectRatios": ["16:9", "9:16"],
  "tags": ["dramatic", "orbit", "cinematic-lighting", "slow-pace"]
}

// VideoStyleTemplateDetailDto
{
  "id": "tpl-vid-cinematic-orbit-01",
  "name": "Cinematic Drone Orbit",
  "archetype": "CINEMATIC",
  "motionStyle": "ORBIT_360",
  "previewClipUrl": "https://cdn.brandhub.io/ai/video-templates/previews/cinematic-orbit.mp4",
  "previewDurationSeconds": 3.0,
  "supportedAspectRatios": ["16:9", "9:16"],
  "defaultDurationSeconds": 5,
  "promptModifierTemplate": "cinematic 35mm film grain, 360 degree smooth drone orbit around {subject}, dramatic volumetric golden hour lighting, 8k resolution, 24fps",
  "parameterSlots": ["subject", "action", "environment"],
  "tags": ["dramatic", "orbit", "cinematic-lighting", "slow-pace"],
  "isRecommendedForReferenceImage": true
}
```

## Screen Layout

Figure — Video Style Template Gallery (`brandhub-web/src/pages/ai/video/components/VideoStyleTemplateModal.tsx`):
- Top Filter Bar:
  - Search input ("Search styles, tags, camera movements...").
  - Archetype filter chips: `All`, `Cinematic`, `Product Showcase`, `Minimalist`, `Dynamic Social`, `Corporate/Explainer`, `Retro/Vintage`, `Futuristic`, `Luxury`, `Vlog/Casual`, `Stop-Motion`.
  - Motion tags dropdown: `All Motions`, `Dynamic Pan`, `Zoom In/Out`, `Orbit 360`, `Drone FPV`, `Tracking Shot`, `Static Locked`.
  - Aspect Ratio toggle: `Any`, `16:9 (Landscape)`, `9:16 (Vertical Reel/TikTok)`.
- Template Grid:
  - Responsive cards with border highlight on hover.
  - Video preview container: Looping `<video>` element with mute and autoplay on mouse hover, duration badge "0:03".
  - Metadata row: Archetype pill tag, Motion badge, Aspect ratio icon.
  - Action button: "Select Style" (primary orange button).
- Drawer / Detail Inspector (when clicking "Inspect"):
  - Side-by-side view: Large video player on left, template details and prompt injection preview on right.
  - Prompt structure breakdown: Shows base style tokens that will be appended to the Creator's custom prompt.
  - Button "Apply to Generator": Closes modal and injects template ID into FR 3.7.7 Generate Video form.

## Function Details

### Data Specifications

- **Input query parameters:**
  - `workspaceId` (path, UUID): Valid workspace identifier.
  - `archetype` (query, optional, enum): One of 10 supported archetypes.
  - `motionStyle` (query, optional, enum): One of camera motion tags.
  - `aspectRatio` (query, optional, enum): `16:9` or `9:16`.
- **System data:**
  - Static catalog definitions stored in system database and cached in Redis (`ai:catalog:video-templates`, TTL = 24h).
  - Static MP4 clip files stored on S3 at `/public/assets/video-templates/previews/*.mp4` and served via CDN.
- **Output:**
  - Paginated list of `VideoStyleTemplateDto` records containing metadata, tags, and signed/public CDN preview URLs.

### Business Rules

- **BR-AI-601 (Catalog Structure):** The system maintains 30 standard template presets composed of 10 visual archetypes paired with 3 motion variations:
  1. `CINEMATIC` (Orbit, Dolly Zoom, Low-angle Pan)
  2. `PRODUCT_SHOWCASE` (Pedestal Rise, 360 Spin, Macro Slide)
  3. `MINIMALIST_CLEAN` (Slow Subtle Push, Static Studio, Lateral Tracking)
  4. `DYNAMIC_SOCIAL_REEL` (Whip Pan, Fast Zoom, FPV Rush)
  5. `CORPORATE_EXPLAINER` (Smooth Slider, Neutral Tripod, Floating Gimbal)
  6. `RETRO_VINTAGE` (Handheld Shaky, 70s Zoom, Film Reel Pan)
  7. `FUTURISTIC_SCIFI` (Cyber Drone, Warp Speed, Neon Tracking)
  8. `LUXURY_ELEGANCE` (Fluid Slow-motion Crane, Gliding Tilt, S-curve Orbit)
  9. `VLOG_CASUAL` (Selfie Handheld, Point-of-View Walk, Natural Whip)
  10. `STOP_MOTION_CLAY` (Frame-by-frame Jitter, Tabletop Step, Pop-in Angle)
- **BR-AI-602 (Free Catalog Access):** Browsing, filtering, and previewing style templates consumes 0 AI credits. No billing ledger reservation or quota reduction is triggered.
- **BR-AI-603 (Veo 3.1 Compatibility):** Every template definition MUST conform to Google Veo 3.1 parameters:
  - Supported aspect ratios are strictly `16:9` and `9:16` (24 FPS native).
  - Templates must specify whether they are compatible with Reference-to-Video mode (Image input) or Text-to-Video only.
- **BR-AI-604 (Preview Independence vs. Zero Thumbnail Rule):** Previews served in FR 3.7.6 are pre-generated static 3-second system demo clips. This is independent of FR 3.7.7's "Zero Thumbnail" policy for newly generated user videos (which avoids runtime thumbnail extraction costs).
- **BR-AI-605 (Prompt Composition Slotting):** Applying a template inserts predefined prompt wrappers and camera tokens into the FR 3.7.7 prompt builder while preserving user placeholders (`{subject}`, `{action}`).

### Validation

- `workspaceId` invalid or user lacks membership in workspace → 403 `FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, Display: MSG-AI-01.
- `templateId` does not exist or has been deprecated → 404 `TEMPLATE_NOT_FOUND`, Display: MSG-AI-601 ("Requested video style template does not exist.").
- Invalid query filter values (e.g., unsupported aspect ratio `1:1`) → 400 `INVALID_FILTER_PARAMETER`, Display: MSG-AI-602 ("Aspect ratio must be 16:9 or 9:16.").

## Functionalities

### Normal Flow

1. Creator opens the Video Generation Studio (`/workspaces/:workspaceId/ai/video-studio`) and clicks "Choose Style Preset".
2. Client sends `GET /api/v1/workspaces/{workspaceId}/ai/video-style-templates` with default pagination to Gateway.
3. Gateway validates user authentication and passes request to Business Service.
4. Business Service verifies user workspace membership and fetches template catalog from Redis cache (or database if cache miss).
5. Endpoint returns `200 OK` with the list of 30 templates.
6. Frontend displays the template gallery modal.
7. Creator hovers over a template card; client plays the 3-second looped MP4 preview clip smoothly via CDN URL.
8. Creator clicks on "Cinematic Drone Orbit" card, reviews details, and clicks "Apply Template".
9. Modal closes. The template ID, recommended aspect ratio (`16:9`), and prompt modifier tokens are loaded into the FR 3.7.7 generation form.

### Abnormal Cases

- 2.a1: Redis cache down or DB connection timeout → Business Service falls back to static in-memory catalog fallback; returns `200 OK`. If total failure → 500 `INTERNAL_SERVER_ERROR`, toast MSG-AI-99. 2.a2: Creator clicks "Retry".
- 4.a1: User is not a member of the workspace or workspace is suspended → 403 `FORBIDDEN`, toast MSG-AI-01. Navigation redirected to workspace switch.
- 7.a1: Network failure while streaming preview clip from CDN → Player displays thumbnail fallback with a retry icon; UI remains functional without crashing.
- 8.a1: Selected template is marked `deprecated: true` → System displays inline warning MSG-AI-603 ("This style preset is outdated; please select a current Veo 3.1 template.") and prevents applying.

## Post-Conditions

- No database mutation occurs (read-only query).
- Selected template metadata (`templateId`, `promptModifierTemplate`, `motionStyle`, `supportedAspectRatios`) is stored in frontend form state for subsequent use by FR 3.7.7 Generate Video.

## Out of Scope

- Editing or uploading custom user video templates (templates are curated system-level assets managed by Admin).
- Real-time AI generation of preview clips (all preview clips are static pre-rendered MP4 assets).
- Audio and music track templates (Veo 3.1 audio generation/sync is out of scope).

## References

- [06-ai-features.md](../../../ba/06-ai-features.md)
- [ai-features-spec-alignment-plan.md](../../../plan/ai-features-spec-alignment-plan.md) (Decision D08, Section 2.6: Video & Export)
- [Google Veo 3.1 Capabilities Documentation](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)
