# test

Saved profile and edit preview show cover, logo+name/tagline, badges, About and Contact & Socials in the same order. Long names/URLs/HTML content wrap; view description is not clamped; missing contacts do not show dash rows; missing/error logo and cover have fallbacks. Owner Edit/cancel/save remains available, non-owner has no Edit. Check keyboard links, 375/768/1440px, vi/en and light/dark. MIME: selected language only; full profile fields appear once, true uploaded logo/cover remain, seed or unsafe image URL omitted; rich description formatting retained while scripts/event handlers and unsafe URLs removed; category/size/founded labels localized. Existing note/invite/expiry tests stay green. Run npm run ci and targeted Maven mail/service/controller tests; no real invitation sent.

## Verification results
- Backend: 71 targeted tests passed (AgencyControllerTest 2, AgencyServiceImplTest 58, MailServiceImplSendMessageTest 11). Reran the 11 MIME tests after aligning all category/size/founded labels with frontend locales.
- Browser (mock APIs): saved profile fields and sections verified; Edit shows the same card structure in preview; Cancel returns to read mode; English headings verified.
- Saved profile at 375/768/1440 px in light/dark, no horizontal overflow. Final mobile action placed on the cover to preserve title width. Local vi/en email previews at 375/900 px, no overflow. Screenshots reviewed under workspace output/playwright.
- Changed card and preview pass targeted ESLint/Prettier checks. Full frontend npm run ci passed (lint, type-check, production build; existing repository warnings only).
- No real data changed or email sent; running business-service needs rebuild/restart to use the updated email renderer.

Check Facebook blue, LinkedIn cyan and Instagram pink with matching soft backgrounds; icons inherit link colors; keyboard focus and link destinations remain intact. Verify matching email inline colors and light/dark variants.

Social color refinement: shared card passed Prettier/ESLint and browser visual review. Generated email HTML verified all three per-network foreground/background pairs.

HTML references visible network icons by CID; MIME contains matching PNG Content-ID parts. Missing networks create no icon parts. Verify PNG resources and mobile email layout.

Email social-icon refinement: all 11 mail tests pass, including serialized MIME assertions for the three PNG Content-ID attachments and matching brand colors. Local vi/en previews verified all three embedded images load at 375/900px without overflow; social-chip screenshot reviewed.

Missing/seed/failed cover shows default image instead of no-cover text in saved profile and preview. Existing custom cover remains. Missing/unsafe email cover references embedded default JPEG; custom cover email omits default attachment. Assets have matching hashes; default does not enter save/create payload. Check mobile, vi/en and light/dark.

Default-cover refinement: Prettier, changed-file ESLint and frontend type-check passed. All 11 mail tests passed, including embedded JPEG and no attachment when a custom cover exists. Browser verified default image in view/edit preview, custom-cover priority, failed-custom fallback, no default URL in save payload, and vi/en email images at 375/900 px without overflow. Frontend and backend JPEG hashes match (102,055 bytes).

Serialized email root is multipart/related. HTML cid addresses contain @ and match one image part each. Each image is inline and decodes to the expected valid PNG/JPEG bytes; missing-network images absent; IDs differ between two messages. Do not send external mail without authorization.

Gmail repair intermediate verification: actual local .eml exported through MailServiceImpl with an intercepted sender (no SMTP); Python parsed multipart/related and resolved all four Content-ID references to valid decoded PNG/JPEG payloads. Added OTP MIME regression to keep non-image messages unchanged. Browser file-protocol preview was unavailable; this does not verify live Gmail rendering.

Gmail icon repair final results: 13 mail tests passed, including serialized MIME image resolution, PNG/JPEG byte fidelity, per-message Content-ID uniqueness, and unchanged OTP MIME structure. Local .eml fixture contains four valid inline parts in one multipart/related container. Live Gmail rendering remains unverified because no Gmail browser session is connected; no external email was sent. Requires running backend restart/rebuild and a new invitation to confirm inbox behavior.
