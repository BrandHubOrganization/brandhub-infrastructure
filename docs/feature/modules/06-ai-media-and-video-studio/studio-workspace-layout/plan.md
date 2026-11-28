# Studio workspace implementation plan

Goal: expand the editor and correct draft-to-library saving.

Revision: extract StudioModelCreator for inline generation/save beneath each model input; normalize legacy session selection to ad-composer. Replace the workflow step cards with compact text-only buttons.

1. Add a focused Studio library-save helper using material browse/create-folder/get/move/promote APIs. Move before promotion and re-fetch the version after moving. Test draft, saved, failure and retry paths.
2. Carry draft state on StudioAssetItem from generation responses. Use explicit saved state in basic and canvas output controls.
3. Update StudioSimpleMode layout and remove ratio, quality, prompt-chip controls and duplicate canvas navigation. Keep generation defaults internal. Expand input slots and output preview responsively.
4. Update paired vi/en aiStudio locale keys and localize canvas status/role badges.
5. Run focused tests, type-check, lint and production build; inspect the live page if an authenticated session is available.

Files: StudioSimpleMode.tsx, StudioSimpleSlotCard.tsx, StudioNodes.tsx, studioAiRunner.ts, studioLibrarySave.ts, types/studio.ts, locales/{vi,en}/aiStudio.json, tests/unit/studioLibrarySave.test.ts.
