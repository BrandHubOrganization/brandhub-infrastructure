# Product Video Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax. Existing user direction authorizes the selected workflow and three recipes. Do not commit/push; the existing no-commit preference overrides example commit steps.

**Goal:** One approved product brief becomes two or three Veo clips, a rendered 15/20-second MP4, and a safely editable Video Space project, charged only in BrandHub credits.

**Architecture:** Business owns immutable plans/quotes, owner authorization, durable PostgreSQL scene attempts and existing per-scene DA-974 accounting. AI owns deterministic recipes, a durable Mongo execution journal, Google Cloud Veo GA and an allowlisted frame-based FFmpeg renderer adapted from DemoVideo. The authenticated web bridge materializes a native editable project on first open using existing private media/snapshot APIs; it never overwrites existing manual edits.

**Tech Stack:** Existing Spring Boot/PostgreSQL, Python/FastAPI/Mongo/FFmpeg, React/Vite/OpenCut. Reuse existing dependencies and renderer/license inputs. No new generic workflow engine, queue framework, LLM provider or browser-rendering runtime for the three basic recipes.

**Spec:** [spec.md](spec.md).

## Global constraints

- Three recipes only: `review`, `unboxing`, `product_showcase`; `auto` chooses one of those by purpose/requirements and valid inputs.
- Review/edit storyboard and BrandHub-credit quote before Generate. Google fees are server-side only. No paid calls during development/verification, no live DB/cloud migration, no commit/push.
- Existing local edits survive. Baseline tracked/index patches and repo state are in workspace `.tmp/product-video-pipeline-20261030`.
- Product image/logo use existing private Video Project uploads and scoped immutable READY asset IDs. No caller-provided URLs or storage keys; image metadata/content checks precede planning/dispatch.
- Current Gemini Veo preview endpoints are retired. New pipeline uses configurable Cloud Veo GA, default `veo-3.1-generate-001`, `us-central1`, 720p, 8 seconds, one result, reference asset images, OAuth ADC. No fallback paid provider/model. Config is frozen with each approved plan; readiness must fail before credit reservation when missing.
- 15-second output: two 8-second sources, durations 180 and 192 frames, 12-frame overlap at frame 168, total 360 frames at 24 FPS. 20-second output: three source durations 168 frames, starts 0/156/312, total 480. No hidden four-second outro, looping source, arbitrary slowdown or unapproved TTS.
- Independent DemoVideo FFmpeg timing/cut/mix/QC techniques only. No SeeCut-VN noncommercial runtime, shell=True, runtime npx installs, remote HTML or arbitrary model-generated code/filters. Carry the chosen font/CC0 audio notices.
- Public UI uses shared components/tokens, parallel vi/en `productVideo` keys, light/dark and 375/768/1440 widths. Long review is a page, not a modal.
- API/provider fixtures prove control flow. Operational Cloud credentials/quota, storage configuration and applied migrations remain explicitly unverified unless separately run.

## Review focus

1. Paid submission acknowledgment lost: query stable attempt receipt; unknown Google submission retains hold and forbids a new paid POST. Known operation resumes polling/download/upload only.
2. Partial sources/render failure: preserve successful clips, charge their existing reservations once; retry only a definitively failed scene after an additional approved quote. Render retry never calls Veo.
3. Concurrent tabs/stale quotes: immutable revision/hash/config; matching idempotent replay precedes expiry/current-price checks; changed quote/request conflicts and atomic batch holds roll back fully.
4. Foreign assets/projects and stale manual edits: validate owner/workspace for each asset/read; native import reopens existing local/remote project and uses CAS for first save.
5. Duration/overlay/audio drift: frame-exact final decode, matching source timings, linear incoming video fade, explicit text pixel units, local Vietnamese font and no extra audio/outro.

## Frozen public contract

Base: `/api/v1/workspaces/{workspaceId}/ai/video-productions`; all JSON uses `ApiResponse`.

`POST /plan` body:

```json
{
  "productionId": null,
  "projectId": "uuid",
  "expectedRevision": 0,
  "brief": {
    "recipeId": "auto",
    "productName": "User product",
    "productFacts": "Only facts supplied by user",
    "requirements": "User direction",
    "durationSeconds": 15,
    "aspectRatio": "9:16",
    "productImageAssetId": "uuid",
    "packagingImageAssetId": null,
    "logoAssetId": null,
    "allowGenericPackaging": false,
    "cta": "",
    "musicId": null,
    "preserveSourceAudio": true,
    "language": "vi"
  },
  "sceneEdits": [{"sceneId": "uuid", "prompt": "Edited prompt"}]
}
```

First plan has no sceneEdits. Existing production replan is DRAFT-only with expectedRevision; user text prompt edits are bounded and create a new immutable revision/quote. New plan returns `productionId`, `projectId`, `state`, `revision`, `brief`, `recipeId`, `selectionReason`, `scenes`, `renderPlan`, `missingInputs`, `providerReady`, `quote`. Missing input means no actionable quote. Scene public shape: `{sceneId,ordinal,role,prompt,sourceDurationSeconds:8}`. Quote: `{quoteId,units,unitCredits,totalCredits,expiresAt}`; never USD or Google project/credentials. Public plan also contains source-config display `{model,sourceDurationSeconds,resolution}` without infrastructure identities.

`POST /{id}/generate` requires `Idempotency-Key`, body `{revision,quoteId}`. Return 202 persisted production state. Never trust client price, model override, payload hash or source count.

`GET /{id}` returns `{productionId,projectId,state,revision,brief,recipeId,scenes,quote,creditsHeld,creditsCharged,canRetryRender,hasResult,errorCode}`. Each scene has planning fields plus `{status,attempt,canRetry,errorCode}`. Result view uses authenticated final/content Blob; do not expose keys/expired signed URLs.

`POST /{id}/scenes/{sceneId}/retry`: `{revision}` returns a persisted one-unit additional quote; `{revision,quoteId}` plus a NEW Idempotency-Key consumes it once and starts only that failed scene. UNKNOWN scenes cannot be retried for a new charge until reconciled.

`POST /{id}/render-retry`: `{revision}`, Idempotency-Key; only RENDER_FAILED with valid source selections, no generation/credit operations.

`GET /{id}/content` authenticated final MP4; `GET /{id}/scenes/{sceneId}/content` selected successful source; read-only owner lookup, no reconcile/generate/credit side effects.

`GET /{id}/editing-bundle` returns semantic data:

```json
{
  "productionId": "uuid", "projectId": "uuid", "name": "User product",
  "fps": 24, "width": 720, "height": 1280, "totalFrames": 360,
  "preserveSourceAudio": true,
  "segments": [{"sceneId":"uuid","assetId":"attempt-uuid","startFrame":0,"sourceStartFrame":0,"durationFrames":180,"fadeInFrames":0}],
  "texts": [{"id":"uuid","text":"User CTA","startFrame":300,"endFrame":360,"centerX":360,"centerY":1050,"fontFamily":"Be Vietnam Pro","fontSizePx":48,"color":"#ffffff"}],
  "logo": null,
  "music": null
}
```

Logo, when present: `{assetId,startFrame,endFrame,centerX,centerY,widthPx}` and reads original through existing private project media endpoint. Music, when present: `{assetId,catalogId,startFrame,endFrame,gain}` referencing a bundled licensed resource; no untrusted remote URL. Scene assetId is immutable attempt UUID. All positions/font sizes are canvas pixels; all time values integer frames.

States: `NEEDS_INPUT`, `PLAN_READY`, `GENERATING`, `RECONCILIATION_REQUIRED`, `SCENE_FAILED`, `EDITING`, `VALIDATING`, `RENDER_FAILED`, `COMPLETED`. Keep codes server-safe and translate UI messages. Errors include stale plan/quote/price, unsupported/config unavailable, insufficient credits, invalid/private asset and source/render failure. Use existing codes where they already fit.

## Internal AI contract

All routes use the existing machine authentication, unavailable publicly through user proxy calls.

### Wire convention and integration rulings (30 October)

- Internal product-video JSON uses **camelCase**, identical semantic brief/scene/render fields to the public contract. Python models use explicit aliases or an alias generator. Legacy video request/status fields remain snake_case. `POST /ai/video/generate` accepts an additive `product_execution` envelope; its fields use camelCase. Business and AI share this boundary and do not independently rename fields.
- Plan request: `{productionId,brief,assets,sceneEdits}`. `assets` maps `productImage`, `packagingImage`, `logo` to verified `{assetId,sha256,mimeType,width,height}` or null. Plan response: `{recipeId,selectionReason,missingInputs,providerReady,sourceConfig,scenes,renderPlan}`. `sourceConfig` freezes provider/model/location/project configuration server-side; only its display subset is public. Scene IDs are deterministic UUIDs from production ID + ordinal. Reference asset IDs are recorded per scene.
- Generation envelope: `{executionId,productionId,sceneId,workspaceId,requestHash,sourceConfig,references:[{assetId,sha256,mimeType,dataBase64}]}`. The surrounding legacy prompt and aspect_ratio carry the approved values. Product recipes bypass legacy style transformation. Response stays `{job_id}`; common status preserves legacy keys with additive `s3_key`, `sha256`, `file_size`, and `SUBMISSION_UNKNOWN`.
- Render request: `{renderId,productionId,workspaceId,planHash,renderPlan,sources:[{sceneId,assetId,s3Key,sha256}],logo}`. `renderPlan` shares the editing-bundle timing fields, including segments/texts/logo/music. Resolved logo data uses the same verified image descriptor plus `dataBase64`. Status returns `{renderId,status,s3Key,sha256,fileSize,videoUrl,errorCode,qc}`. Scene source keys must be bound to completed journal receipts matching workspace/production/attempt; a safe-looking key alone is insufficient.
- Audio overlap uses a **hard switch at the incoming segment start**: preceding scene source audio ends at the next startFrame; incoming audio starts there. Video still fades in linearly for12frames. This avoids doubled audio and gives deterministic native/FFmpeg parity without pretending opacity controls audio. Optional music overlays the selected source audio with explicit gain; no implicit generated soundtrack.
- Music catalog is the five existing original CC0 music resources from Video Space, with stable IDs and license notices. No external URL field. Missing configured provider credentials makes `providerReady=false`, no actionable quote or hold; the user can still inspect the storyboard.
- Recovery ruling: persist bounded reference images separately from the parent execution document in the private majority Mongo journal (one document/image, below16MB); parent payload keeps only immutable descriptors. Restore PENDING scene references and render logos on restart. A Business timeout followed by an authoritative AI404 can replay the same approved attempt and existing reservation; a known SUBMISSION_UNKNOWN must only poll, never resubmit to Google.
- Execution uses independent repository lanes per subagent-driven-development; the root owns the web form and shared feature documents. Existing feature workspaces and baseline patches preserve local work; no fresh pull/reset, no commit/push.

- `POST /api/v1/ai/product-video/plan`: canonical brief + verified image presence and product/logo dimensions + source config; returns recipe selection, missing inputs, scene specs, validated renderPlan. Deterministic matching, no generation/LLM/credit call.
- Per-scene generation reuses the video API with an additive product execution envelope: stable `execution_id` (attempt UUID), production/scene IDs, request/config fingerprint and frozen GA configuration plus backend-resolved base64 reference assets. Product recipe IDs are NOT fed to old eight-style `template_key` validation. Public single-clip legacy behavior stays compatible.
- Common video status recognizes the durable product execution receipt and returns job_id, PENDING/PROCESSING/COMPLETED/FAILED or SUBMISSION_UNKNOWN plus sanitized error, persisted S3 key/SHA/file size. Completion is after successful source persistence.
- `POST /api/v1/ai/product-video/render`: stable render UUID, immutable production/revision hash, workspace ID, selected scene source S3 keys/checksums and typed render plan, resolved logo data. No caller URLs, arbitrary filter expressions or code. `GET /api/v1/ai/product-video/render/{id}` returns state/QC/persisted output key, with fresh signed URL where existing accounting adapters need it.
- AI stores durable request hash, submission intent, operation name, timestamps, lease token and output checkpoint in a dedicated Mongo journal with majority writes. Only the unique claimed scene attempt can submit. Mongo unavailable fails before submission. An expired SUBMITTING lease with no operation becomes SUBMISSION_UNKNOWN, not another submit. Known operations safely resume. Rendering can retry from saved sources without generation.

## Task 1 — AI planner, durable provider and deterministic render

**Files:** create `brandhub-ai-service/app/models/product_video_models.py`, `app/services/product_video/{recipes,store,provider,service,renderer}.py`, `app/api/v1/endpoints/product_video.py`; extend `video_models.py`, `veo_client.py`/video routes only at additive dispatch/status boundary, router/lifespan/config, Docker/font/audio resources where needed. Tests under existing `tests/unit/services/` plus real local FFmpeg test.

**Interfaces:** planner consumes verified brief/config; generation consumes stable approved scene attempt; renderer consumes typed frame plan and validated scoped source objects. Returns the internal shapes above. Root/Business supplies reference bytes after access checks.

- [ ] RED tests: three recipe matches and missing-box consent; exact 360/480 frame plans; no invented facts; duplicate/conflicting attempt; unknown submission; known-operation resume; invalid source keys/plan and insufficient source frames; replayed render ID.
- [ ] Implement deterministic recipe matching/templates, prompt-edits validation and canonical configuration hash; no LLM dependency.
- [ ] Implement Cloud GA submit/poll with ADC and persisted operation checkpoint; decode bounded base64 output or configured GCS only if deliberately supported. Omit output storage URI for the baseline inline-result path; persist to existing S3. Never auto-resubmit an ambiguous paid request.
- [ ] Port allowlisted frame-based segment/transition/audio/QC techniques from DemoVideo into renderer; local Be Vietnam Pro TTF/OFL and approved music IDs. Run FFmpeg using argument arrays, timeout, bounded scratch/concurrency and decode/frame-count gate. No automatic TTS/noise/end card/loop.
- [ ] GREEN tests plus real synthetic two/three-source renders at both aspect ratios; inspect boundary/overlay pixels, audio duration and final frame count. Retain ordinary one-clip/style regressions.

## Task 2 — Business plan/quote/production coordinator

**Files:** create `controller/ProductVideoController.java`, DTO request/response records, `service/productvideo/{ProductVideoService,ProductVideoWorker,ProductVideoAiClient,ProductVideoAssets}.java`, `repository/ProductVideoStore.java`; narrowly extract shared preparation/reserved execution in `AiCreditGenerationService.java`; add schema readiness/error codes. Prepare additive SQL migration under infrastructure docs/database/migrations; update fresh init without running it. Tests in Business src/test.

**Persistence:** additive PostgreSQL production, immutable plan and per-scene-attempt tables, unique reservation/request/retry consumption constraints. JSONB for bounded immutable semantic plans/brief; store image IDs/SHA rather than blobs. Domain records are durable outbox/work states; bounded worker sweeps, not a new queue framework.

- [ ] RED tests for private asset refs, stale quote/model/revision, disabled price, duplicate generate/retry, full batch rollback and unknown submission hold.
- [ ] Resolve private product/box/logo originals using VideoProjectAccess/MediaService and bounded provider reads. Freeze their hashes, scene config and current `CreditAccountingStore.price(VIDEO_GENERATE)` into the quote. Reject inconsistent image formats/sizes before any hold.
- [ ] In explicit PostgreSQL transaction lock parent + current price, validate immutable approved quote, prepare all canonical requests using the same generation hash routine, reserve one DA-974 unit per scene, compare every frozen price, insert attempts and COMMIT before dispatch. Matching idempotent replay precedes expiry checks. No manual credit-ledger writes.
- [ ] Add server-only prepared/existing-reservation dispatch and stable AI execution ID. Recover lost acknowledgments by status lookup; keep unknown holds. Reuse authoritative existing child settlement, preserving successful clip charges when another scene/render fails.
- [ ] Worker submits/polls generation/render with persisted IDs and guarded CAS state; successful scene attempts never regenerate automatically. Explicit retry produces an additional one-unit quote/attempt. Render-only retry consumes no generation credit.
- [ ] Serve owner-only state/content/semantic editing bundle. No server OpenCut snapshot builder or direct READY media insertion; native first-open will use existing private upload/snapshot flow. No keys/USD/credentials in public JSON.
- [ ] GREEN focused accounting/storage/controller/worker tests, then appropriate complete suite. Do not apply migration to current DB; optional integration tests only against an explicitly disposable loopback test DB.

## Task 3 — Native editing-bundle import

**Files:** `brandhub-web/shared/video-space-protocol.ts`, host `src/pages/video-space/` context/route, vendor `src/platform/host.ts`, `src/editor-app.tsx`, new `src/brandhub/import-production.ts`; focused importer/shared tests outside src.

- [ ] RED guards for selected production endpoints only; no foreign origin/session/path; malformed/negative/fractional frame or external URL fields reject before importing.
- [ ] Add optional sourceProductionId through keyed session context. Load semantic bundle with owned ID; reuse existing local project if present, or restore a remote accepted project. Only exact remote404 means unaccepted draft; 403/5xx do not become a new empty project.
- [ ] Materialize the bundle's projectId locally, preserve source asset IDs using existing storage primitives, process original metadata and build one native scene. Main=first clip; incoming clip2/3 on overlays with linear opacity fade over12frames; overlays ordered topmost-first, text/logo above videos. Do not fade both outgoing and incoming images. Convert pixel font sizes/positions to actual native units. Audio follows the validated plan.
- [ ] Save local draft, then existing private uploads + first snapshot CAS. Cloud failure retains local draft; an existing/manual project is never overwritten by reopening a production.
- [ ] GREEN 15/20-second importer timing/identity/reopen tests, existing bridge/import tests, native typecheck/verify/build.

## Task 4 — Product form, storyboard consent and results

**Files:** new `brandhub-web/src/pages/product-video/{index,types,services,hooks,components}/`, new vi/en `productVideo.json` + imports; AppRoutes/access/Navbar metadata; entry action in existing ai-studio/video page. Test files under `tests/unit` and `tests/e2e/product-video`.

- [ ] RED API/UI tests: no Generate call before explicit click; quote shown only in credit; stale edits invalidate consent; missing-box recovery, partial scene retry/additional quote and render-only retry.
- [ ] Full-page route `/workspaces/:id/product-video` for OWNER/MANAGER/CREATOR. Product/photo, three recipes/auto, requirements/facts, 15/20seconds, ratio, optional box/logo/CTA/audio. Upload selected raster files through existing private Video Project media service, retaining IDs for replan/reload.
- [ ] Page review shows selected recipe/reason, editable scene prompts, source/final durations, total BrandHub credits and explicit Generate. POST replan refreshes immutable quote; progress survives reload via productionId query. No new long modal or USD display.
- [ ] Progress/results show individual scenes, unknown/retry states, safe error recovery, authenticated MP4 preview/download and Open in Video Space (`productionId` context). Reuse existing query/auth/refresh/theme and visible Back.
- [ ] GREEN typecheck/lint/production builds and real-frame browser fixtures for all3 recipes and failed-scene/render retries. Verify original one-clip Video AI route remains usable.

## Task 5 — Integration and evidence

- [ ] Confirm cross-language contracts and readiness guards against actual implementation; update spec/plan/task/test before correcting any discovered requirement mismatch.
- [ ] E2E fake provider/real local renderer: form→plan→credit consent→2/3 sources→final MP4→native import→manual edit→save/reopen/export; inspect decoded frames/audio. No paid model call.
- [ ] Review access/idempotency/unknown state/partial credit behavior and safe subprocess boundaries. Fix supported findings and rerun affected checks.
- [ ] Record files, commands/counts/screenshots, migration/setup requirements and any unverified live Cloud behavior. No new commit/push or unresolved conflicts.

## Runtime setup and verification handoff

Implementation and local fixture verification completed30October2026. See `test.md` for the actual evidence and limits. No SQL migration or paid Cloud request was executed.

1. Apply `docs/database/migrations/2026-10-30-product-video-pipeline.sql` through the normal deployment process after the existing DA-974 credit schema. It adds production/plan/quote/attempt/request tables; it does not rewrite balances. Fresh installs include the same block in `docs/database/init-postgres-v2.sql`.
2. AI runtime: set `PRODUCT_VIDEO_ENABLED=true`, `PRODUCT_VIDEO_CLOUD_PROJECT`, the selected supported GA model/location, and private `PRODUCT_VIDEO_MONGO_URI`. The runtime must have ADC permission/quota/billing for Veo and the existing S3 output configuration. An existing Gemini API key does not supply Cloud ADC. See AI `.env.example`; no credentials belong in the frontend.
3. FFmpeg/FFprobe, the bundled Be Vietnam Pro font and five CC0 music files must be present. Set scratch to a writable runtime directory with capacity. Readiness checks the executables, font/music, Mongo availability, storage configuration and ADC discovery before providing an actionable quote. Discovery does not prove live Cloud quota/billing; an authoritative pre-submit auth failure is refundable, while an ambiguous paid submission keeps its hold.
4. Open Video AI → Create product video. Product assets use existing private Video Project uploads. The first native import publishes a complete snapshot into the same staged project; revision0 stays hidden from ordinary project detail until that first save. Returning from the editor goes back to the production URL after flushing the draft.

Final review corrections: order render sources by storyboard segments rather than UUID database order; resume PENDING scenes on polling as well as startup; restore bounded journaled images/logo after restart; classify token-refresh failures before any paid POST as definitely unsubmitted; reject public injection of the internal execution envelope. All received regression coverage.

## Revision: action-based unboxing/review and approved native speech

Live Flow render compatibility: validate each render source against that segment's required source frames, rather than a blanket192. Keep standalone admission's default192 and the15s second segment's192-frame requirement. First add real FFmpeg regression coverage for190-frame inputs accepted by the20s/168-frame cuts and rejected by a192-frame cut; retain the existing short-source rejection and full-decode gates. No padding, freeze or provider retry.

The user's correction supersedes the weak static showcase presentation. This revision changes recipe prompts and storyboard clarity, not accounting/renderer timing or automatic paid submission.

- Backward-compatible brief field `reviewScript?: string|null`, max900characters. Empty/null means no narration; populated means exactly2/3 nonempty lines, at most18whitespace-separated words per line, matching source scene count. Invalid count/length returns missing inputs `reviewScriptLineCount`/`reviewScriptTooLong`; narration with muted sources returns `reviewScriptNeedsAudio`. No actionable quote when missing inputs exist.
- Extend Scene with optional localized `title`, `action`, `narration` for review UI. Narration is copied exactly from the supplied line, never invented from facts. Prompt overrides remain user-controlled; clear derived action/narration metadata for an overridden prompt so the UI does not claim the old wording is still enforced.
- Stronger deterministic recipes: visible hands opening packaging and lifting the referenced product; experiential review/demonstration and supplied feature facts; deliberate product placement/CTA close. Perfume is recognized only from supplied text and gets a blotter/experience scene without inventing unseen atomizer hardware.15s unboxing/review retains the middle experience beat rather than selecting only first+last static shots.
- Prompt structure follows `fk-camera-guide`: explicit action; camera in a separate sentence; continuity/input facts; audio labels and exact short speech in brief.language, completed by5.5s for existing cut handles; natural SFX and no model music. Keep existing4000character source limit and fail before reservations if exceeded. Same descriptive reviewer voice across clips is a request, not a guarantee of identical synthesis.
- AI lane owns models/recipes/tests; root owns web optional field/card/locales, Business request record, docs and Flow interaction. Read the four updated docs first. No commit/push. User sign-in and final storyboard/credit approval precede any real Flow submission.
- Produce a real planner JSON and3copyable Flow prompts for the authorized fictional AMBER Demo. Record them under workspace `.tmp/.../flow-review/` and label them pending generation. Do not generate another image-pan video to present as unboxing.

Revision implementation and offline verification are recorded in `task.md` and `test.md`. The original planner example lives at `F:/LEARN/DA/.tmp/product-video-pipeline-20261030/flow-review/AMBER_UNBOXING_STORYBOARD.md`. After the automation browser's login rejection, user signed in to normal Edge and explicitly allowed remote debugging; that legitimate session was used without cookie export or a login bypass. User approved at most60 Flow credits; three Veo3.1Fast/Ingredients/9:16/720p clips were generated once each at20 credits. Balance250→190 was observed. `AMBER_DEMO_UNBOXING_20S_REAL.mp4` was assembled and passed480-frame/20s/full-decode QC. Native speech was checked locally; independent-scene wardrobe/voice continuity remains a sample limitation. This manual consumer-Flow run does not configure or validate the separate Cloud API runtime.
