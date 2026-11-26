# Verification

## Follow-up acceptance cases

- Default and deep-link routes load the complete paginated graph beyond 200 nodes, including disconnected clusters and source posts; no visible hop/node/batch limit controls or old legends/counts/toggle.
- Type dropdown includes real unknown types. Name/ID text and numeric degree conditions support all/any, zero and invalid input handling, add/remove, apply/clear. Local filtering does not trigger a scan. Relationships require both endpoints in the result.
- Filters applied during scan also affect subsequent pages; clearing restores all fetched nodes/edges. Degree evaluated before filtering; loop counts once.
- Clicking and keyboard-selecting a node opens real properties immediately; clicking adjacent node updates properties. Escape closes drawer.
- vi/en, responsive light/dark, popover keyboard access and fixed graph viewport; CI passes. Fixtures local-only.

- Default admin graph has no mode buttons and scans real database with existing controls. Explicit node/trend URLs remain functional.
- At desktop and mobile sizes the canvas bottom and page bottom remain within the available viewport; filters/details/keyboard list cannot increase document height.
- Selecting a node highlights direct relations without hiding other edges. Detail drawer closes with Escape/button; expansion, node dragging, right-button panning, zoom and fit remain available.
- Shape-boundary assertions cover circles, diamonds, rectangles/rounded rectangles, triangles and hexagons, cardinal/diagonal rays and root/hover radii. Self-loops connect at node boundaries. SVG uses actual degree-dependent radii.
- Opaque bases prevent edge bleed in both themes, including dimmed nodes. vi/en labels remain readable with keyboard focus and narrow layout.
- Run `npm run ci`; keep fixture/screenshots under ignored keep-local-only. No live crawl, production writes or new src test files.

## Local results (2026-11-22)

- Browser fixture with the actual AdminPage and graph components (15 checks passed): viewport fits at 390x844, 768x900 and 1440x900; filters/details preserve canvas height; Escape, post filter, vi/en and light/dark pass. Both trend and node deep links verified. No production/data API calls were made.
- Shape ray intersections: 1,512 assertions matched Canvas isPointInPath across 7 types, 3 radii and 72 directions.
- Additional interactions: node selection, collapsed detail behavior, drag/pin, right-button pan, zoom, keyboard movement, retained unrelated edges and opaque bases pass (8 checks).
- Web lint passed: 0 errors, 227 advisory warnings. Full Web CI passed (lint, TypeScript, production build and 105 prerendered pages). Targeted ESLint also passed on the final edits.
- Screenshots and verification scripts are local-only under Web keep-local-only.

## Follow-up local results (2026-11-22)

- Actual AdminPage/graph browser fixture: 18 checks passed including source post visibility, local type/custom filters, no query reload, real node properties on click, no-result feedback, keyboard popover, dark mobile viewport, English and deep-link full graph.
- 219-node fixture with multiple seed pages and disconnected components loaded all nodes, including a dynamically discovered custom type.
- 12 filter utility checks passed: name/ID, all/any, numeric validation, zero and self-loop incident degree. Additional UI checks passed for numeric fields, negative rejection, zero acceptance and multiple conditions with ANY.
- 27 new vi/en filter keys are parallel. Test fixtures/screenshots stay in ignored keep-local-only; no live production/database mutation.
- Full Web CI passed: lint (0 errors, 227 existing advisory warnings), TypeScript, production build and 105 prerendered pages. Final targeted ESLint passed without warnings.

## Compact toolbar acceptance
Above graph: one compact row, no duplicate title or standalone scan status row. Requested buttons absent. Loading pause/resume/refresh still accessible. Direct type multiselect, name/ID and valid degree presets/range combine with custom rules; clearing restores loaded graph without new scan. Keyboard can open root properties without node-list button. Test 390/768/1440, light/dark, vi/en; check toolbar height and expanded canvas. Full Web CI.

## Compact toolbar results (2026-11-22)

- Browser: 18 checks passed. Desktop canvas begins at y=127 below a 56px app header (about 140px more canvas height than the previous multi-row fixture). Duplicate title, relationship-label and node-list buttons are absent.
- Direct multi-type checkbox options, name filtering, degree presets/range validation and clear work without rescanning. Seven utility cases verify quick options combine with custom rules using AND. Existing custom numeric/ANY form passes three additional UI checks.
- Enter opens/reopens selected/root properties. Pause/resume icons work. Viewports 390/768/1440, dark mobile popup and English pass; no page errors. All 33 filter locale keys are parallel.
- Full Web CI passed (0 lint errors, 227 pre-existing advisory warnings, TypeScript and production build). Final source build verification passed, including TypeScript build and 105 prerendered pages; final targeted ESLint passed without warnings. Local-only screenshots/scripts remain ignored.
- Official references: https://neo4j.com/docs/bloom-user-guide/current/bloom-visual-tour/bloom-overview/ and https://neo4j.com/docs/bloom-user-guide/current/bloom-visual-tour/bloom-scene-interactions/ .
