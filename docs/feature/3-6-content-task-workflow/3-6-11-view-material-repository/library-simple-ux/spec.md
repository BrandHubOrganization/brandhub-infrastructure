# Simple library UX
Objective: Make finding, uploading and opening media easy for nontechnical communications staff.
Acceptance: Keep existing API contracts and permission checks. Use a minimal header, clear Vietnamese/English navigation, prominent upload action, search and media type shortcuts. Collapse advanced filters and storage tools. Keep download visible; secondary delete actions in an accessible menu. Retain errors, retention notices and upload progress. Never show placeholder counts.
UI states: Loading skeletons, actionable empty results, folder-only results, errors and pagination. Reuse semantic theme tokens for light/dark. New text uses library.simple.* in both vi/en/library.json; simplify existing page labels.
Out of scope: backend, new storage behavior, redesigning hashtag/template forms.

Upload refinement: Default view shows file picker and upload/close only. Optional metadata and size help are collapsed. Required client selection stays visible; cancel storage note appears only during upload. Keep defaults, validations, permissions and progress unchanged.

Upload fix: native accessible file input avoids shared Input wrapper shrinking text. One compact picker/action row on desktop, stacked on mobile. Hide launcher while form is open. Preserve options, required profile, validation and progress.

Density refinement: combine search/sort and type/filter controls into two rows. Hide normal storage usage inside filters, keep quota warnings visible. Place folder actions before empty state and suppress empty file heading. Preserve scroll and responsive controls.

Direct upload: button opens native device picker synchronously. Selecting a valid file starts upload with existing safe defaults. No upload modal or metadata fields. Preserve progress/cancel/retry/duplicates. Client profile inferred only when unambiguous; if multiple, request required profile inline.

Separate Drive import from storage: From Drive secondary action next to Upload, inline import panel on demand. Header storage usage is clickable, upgrade controls on demand. Remove footer storage/import group and duplicate toolbar usage. Retain quota alerts and checkout permissions.

Drive form refinement: only folder link and Import button initially. Use KEEP_BOTH automatically, no explanatory copy or duplicate selector. Keep job status/errors conditional.
