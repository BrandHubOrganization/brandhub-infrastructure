# Tasks — video auto-edit agent

- [x] T1 ai-service: `tools.py` — list_sources, view_frames (contact sheet), detect_scenes, submit_plan (validate_plan → is_error feedback)
- [x] T2 ai-service: `agent.py` — manual loop on `claude-sonnet-5-5`, adaptive thinking, effort medium, fallbacks default, caching, limits (turns/frames/tokens/deadline), refusal/max_tokens handling, usage receipt
- [x] T3 ai-service: wire agent as worker planner, stage turn progress, config defaults, unit tests with fake client
- [ ] T4 Live smoke: matcha fixture, one paid Sonnet 5.5 run (user approval), record tokens/turns/frames and plan quality
- [ ] T5 business-service: `render_mp4` admission flag, stop-after-plan path, receipt `summary/plan/agent/render_mp4`, tests
- [ ] T6 web: `import-render-plan.ts` RenderPlan → new scene (one undo), MP4-only feature list
- [ ] T7 web: panel — Xuất MP4 checkbox, turn progress, Mở trên timeline; vi/en messages; e2e with mocked receipts
- [ ] T8 End-to-end on localhost with matcha clips (timeline only, then timeline + MP4); RESULT.md

## Cost notes (2026-11-10, measured prompt size, usage estimated)
- `count_tokens` on claude-sonnet-5-5: system prompt + tools = 9,337 tokens; one 6-frame contact sheet = 472 tokens.
- Typical job estimate (8 turns, ~20 frames, ~12k output incl. thinking, caching on): ≈ $0.2–0.3. Without cache ≈ $0.45.
- Ceiling from limits (16 turns, 60 frames, 64k output): ≈ $1–1.2. MP4 render is local ffmpeg, no API cost.
- Real numbers come from T4 (job receipt field `agent`).

## Quality round (2026-11-10, user: "làm toàn bộ")
- [x] A self-review: `render_preview` tool (real compositor, half size); submit requires the exact previewed plan.
- [x] B renderer: 5 more OFL fonts, text colour/panel (box/band/none)/bold/uppercase, animations fade/rise/pop/slam/words, clip punch/flash, slide transition, CC0 library music with fade-out.
- [x] Quality gates on submit: detect_scenes for every used video, cuts on the beat grid of library music, no overlapping text.
- [x] D high-quality mode via env: claude-opus-5-5, effort high, 30 turns, 120 frames, 5 previews, 1500 s deadline.
- [x] Memory: per-user preferences (`video_edit_memory`, only from exact quoted request words, max 20) and shared lessons (`video_edit_lessons` from validator rejections + render failures, plus curated `server-lessons.md`).
- [x] C HyperFrames: Graphic kind `motion` with 4 first-party GSAP templates (kinetic-slam, mask-reveal, highlight-sweep, cta-pill) rendered by pinned hyperframes 0.8.170 to RGBA PNG frames, cached per inputs, composited by the renderer; model only fills typed variables. Worker image installs node + Chrome libs + `browser ensure`.
- [x] T5 `render_mp4` + summary/plan/agent receipt; T6 `import-render-plan.ts` (new undoable scene); T7 panel (Xuất MP4, agent progress, Mở trên timeline); memory view/forget UI (worker GET/PUT, BE `auto-edit-memory`, delete-only).
- Run 3 (Opus 5.5 high): 6 turns, 46 frames, 2 previews, 15.5k output, ≈ $0.49, ~5.5 min total.

## Continuation — on-demand original guides

User selected approach1 in Claude thread84196747-2e11-4de6-80a8-44555d54e163 after the cost discussion. Implementation/evidence is tracked in `../video-edit-guide-library/`. No earlier agent/render/model changes were rolled back. Full documents are read through bounded list/read tools, with licensed image resources and a separate private bundle.
