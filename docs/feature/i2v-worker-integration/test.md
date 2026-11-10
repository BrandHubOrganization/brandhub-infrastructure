# Verification

- Image-only requests choose I2V without requiring Google Veo key; pose requests retain Animate selection.
- Adapter sends the uploaded image and prompt to `/api/v1/generate_video`, forwards `X-API-Key`, exact 5/10/15/20 duration and allowed dimensions.
- Local completed MP4 is downloaded using authenticated `/api/v1/media` and stored through the existing uploader. A returned S3 video URL can be reused.
- Key rejection, unsupported duration and failed/unknown worker status fail rather than falling back to Veo.
- Existing Veo/config tests remain green.
- Frontend mode switches preserve legacy reference-video behavior; prompt mode sends no pose video and includes prompt/duration/aspect. All new vi/en keys match, controls use existing theme tokens, labels support keyboard use.
- Live check: public `/docs` and `/openapi.json` identify the correct service; authenticated `/health` returns status ok. Do not submit `/generate_video` as part of verification.
- Full browser-to-GPU render is a separate paid runtime check; do not claim it was executed.
- Compilation prerequisite: only one PostDashboardPage delegates to PostDashboardView; Network imported once; canonical RawPostDetailDto/PostStatusData remain. npm run ci must clear the duplicate-declaration failures observed before cleanup.

2026-11-09 sync: text brief without complete motion inputs uses remote text route; image+prompt mode with selected image uses aiVideoService with no pose and selected duration/aspect; reference mode retains motion metadata and optional brief. Missing prompt/image/video fails before provider request. JSON locales parse and contain both branches' keys; remote admin-navbar permissions remain. No live GPU call.
