# Graph viewport refinement

## Approved follow-up, 2026-11-22

Use a single whole-database explorer even for trend/node deep links; deep links select the matching loaded node. Automatically continue the existing paginated/hop scan through every disconnected component. No user-visible hop/node/batch limits or alternate limited graph mode. Load all types including source posts by default.

Remove legacy legend/instructions, hop indicator, global graph counts and explicit detail toggle. Clicking a node or edge opens its existing real properties drawer immediately. Keep viewport sizing, opaque nodes, trimmed links, pan/zoom and error/resume controls.

Provide local search, a dynamic node-type dropdown and custom filters (name, ID, number of incident relations; contains/equal for text, >=/<=/= for numbers; all/any match; add/remove/apply/clear). Filter only the loaded real graph and its induced edges; loading must continue independently, and clearing restores all loaded nodes without a network rescan. Degree means incident relationships in the full loaded graph before filtering, self-loop counted once. Empty filter results have feedback. Do not submit arbitrary query text to Neo4j.

New UI keys use parallel vi/en `admin.trendGraph.filtersUi.*`. Reuse shared SelectMenu, Input, Button, Popover, theme tokens; keyboard, light/dark and narrow viewport required. No API/DB changes.

Implement the approved 2026-11-22 sketch. Remove the By trend / All nodes mode buttons; default to the existing progressive whole-database graph. Preserve explicit trend/node deep links and all existing real-data APIs, scanning, expansion, filters and keyboard alternatives.

The graph fits the space below the admin header without document scrolling. Filters and details are bounded drawers with their own overflow; opening them must not push the graph below the viewport. Selection highlights adjacent relations while retaining other relations. Nodes have opaque category-tinted surfaces in light and dark modes. Directed connectors meet the actual shape boundary for root, hovered and selected nodes, including self-loops.

Reuse existing `admin.trendGraph.*` translation keys in vi/en; add parallel `admin.trendGraph.canvasInteractionHint` for the compact pan/zoom/expand hint while preserving the complete accessible instructions. Reuse BrandHub tokens and controls. No database, permissions, ingestion, production or deployment changes.

## Compact toolbar revision
Follow the latest user request: remove duplicate page title/status rows, relationship-label and node-list buttons. One compact search/filter/action row; pan/zoom controls overlay the canvas. Keep loading state accessible via an icon tooltip and pause/resume; retain automatic complete scan. Selected-element inspector remains. Advanced filters show direct option groups like Campaign: multi-type checkboxes, name/ID inputs, degree presets/range and existing custom conditions. Quick options combine with custom rules using AND; custom rules retain ALL/ANY. No database writes.

Relationship labels are automatic for selected relations/neighbors; no always-on label toolbar button. Retain full property inspection and keyboard Enter for selected/root node.
