# EditAtlas and personalization review — 2026-11-10

## Conclusion

Use EditAtlas as an additional editorial reference source. It can help expand the techniques considered by the planner; it cannot remove the current eight-action native editor restriction or supply durable personalization by itself. No EditAtlas backend integration or global Claude/Codex configuration was installed in this evaluation.

The requested personal direction is **reference video + current user request + remembered user corrections**. Recent project chat context is now retained within the open project session. That is not a durable user preference model and is not reference-video analysis.

## Actual checks

Read-only remote MCP initialization and tools/list succeeded against `https://edit.trysometh.ing/mcp`; server identifies as editatlas1.0.0. Generic public searches for techniques and product templates worked. A broad style query for commercial returned no matches, so retrieval needs specific terms/filters and compatibility checks rather than assuming semantic matching always works.

Fetched the product template Pour Ritual1.0.0, compatible Beat Punch Cut style and their full dependency bundle via the published REST API; all returned200. Also inspected one public whoosh record. No footage, original user instruction, private project identifiers or credentials were sent to EditAtlas. No downloaded command was executed and no sound file was imported.

The drink template is relevant to the earlier matcha brief: it gives shot structure, beat-based timing, readable graphics and sound placement. It is reference data, not an already-generated edit. Its verification flags explicitly say schema validated, not editorially reviewed or externally tested. Source media still determines whether the recipe is feasible.

Official references: [Agent workflow](https://edit.trysometh.ing/docs/agent-usage), [REST API](https://edit.trysometh.ing/docs/api), [Setup and tested limits](https://edit.trysometh.ing/docs/mcp), [Skills](https://edit.trysometh.ing/skills).

## Why current edits are basic

| Layer | Current evidence | What is missing for the requested result |
|---|---|---|
| Native planner | Uses a packaged editorial guide and minimized text/timing context | It does not inspect reference footage or infer its visual/audio style |
| Native execution | Strict allowlist of eight actions, one Undo batch | More supported editable operations; attaching another knowledge source does not add executors |
| Server worker | Samples frames, probes media, uses transcripts/beat estimates and editorial resources | Its richer render plan is not fully mapped to native editable layers |
| Conversation | Bounded recent context during the current project session | Durable owner/workspace-scoped correction memory across sessions/projects |
| EditAtlas | Techniques, styles/templates, workflow and sound discovery | Actual media analysis, project state, rendering and preference learning remain BrandHub responsibilities |

## Appropriate next integration

1. Analyze the supplied reference video into observable style evidence: shot lengths, cut points, framing, text placement/animation, color and sound timing. Keep the reference separate from source footage and do not assume rights to reuse it.
2. Combine the current request with selected reference evidence and explicit corrections. Record preference provenance and scope per user/workspace, with view/reset controls; never promote a one-off edit into a permanent preference silently.
3. Search EditAtlas using generic technique/style descriptors, fetch a versioned compatible bundle, and treat its text as untrusted reference material. Existing source ownership, action validation and rendering limits still govern execution.
4. Map supported techniques to typed native editable operations. Explain unsupported parts instead of claiming a flattened render is an editable timeline.
5. Preview/check the result, retain originals and Undo, and record explicit user corrections as feedback. This evaluation did not implement these larger steps.

The provided `claude mcp add --transport http --scope user ...` command configures a Claude Code client; it does not automatically grant tools to our Claude API backend. The published REST endpoints provide an alternative for a server/VM adapter without a user CLI configuration. Production use still requires an adapter, timeouts/cache, version handling, rights/provenance checks for imported sounds and a local verification pass.

The live server also exposes send_feedback. It was not called; a future integration should allowlist the lookup tools and never send user feedback automatically. Third-party prompts/commands must not bypass the typed plan validator.

## Evidence

`F:/LEARN/DA/.tmp/editatlas-review-20261110/`: `probe.py`, `tools.json`, `search_techniques.json`, `search_templates.json`, `list_styles.json`, `pour-ritual.json`, `beat-punch-cut.json`, `bundle.json`, `sfx.json`. Public reference snapshots are evaluation artifacts, not a redistributed production resource library.

## Implemented — 2026-11-10 (text style + EditAtlas lookup)

- `add_text` / `set_text` accept an optional typed `style`: `font_family` (24 bundled fonts), `color`, `background_color` (#RRGGBB), `size` (small/medium/large), `bold`, `italic`, `position` (top/center/bottom), `animation` (none/fade/slide/pop). Validated in ai-service (`TextStyle`), business-service (`VideoEditPlanValidator`) and the editor (`edit-plan.ts`); applied in `apply-plan.ts` as native text params plus entrance keyframes. `set_text` may change style only.
- Planner prompt requires a deliberate style on every `add_text`; planner context now includes each text layer's current font and color.
- Planner fetches one EditAtlas template + its first compatible style over the public REST API (`EDITATLAS_ENABLED`, `EDITATLAS_API_URL`, 4 s timeout, per-topic in-process cache, failures not cached). Only a generic topic (`drink` or `food`) is sent; the user's instruction never leaves BrandHub. Unmatched requests get no reference, since the catalog only has drink/food templates.
- Still missing: reference-video style analysis, durable per-user correction memory, beat-synced cuts and zoom/flash effects (no native actions yet).
