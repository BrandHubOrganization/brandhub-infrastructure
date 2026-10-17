> Checkpoint 2026-10-17: restored specification and historical verification for retained Media Package/Campaign UI. Task UI changes described as rolled back remain out of this UX scope. API/classification changes after this checkpoint are governed by the Media Package package-simplification spec; historical fixture test results are not a new verification run.

# Media workspace UX

## Objective
Give Media Package and Media Campaign users the full available page width for long content and forms. Follow the existing BrandHub design. Task screens and logic are explicitly outside this change.

## Acceptance criteria
- Replace package detail, custom package creation, terms negotiation and campaign completion review modals with in-page work areas. No overlay, focus trap or viewport-height cap for these workflows.
- Keep current APIs, request payloads, versions, role checks, validation, error feedback and save semantics. Preserve unsaved-change confirmation and tab-close warnings.
- Catalog details occupy the catalog width; returning retains query, availability filter and visible item count. Give visible return/cancel controls and focus the newly opened work area. Restore trigger focus on return when possible.
- Retain only short discard confirmations as dialogs in these modules. Campaign cancellation's existing inline confirmation remains unchanged.
- Reuse existing Button/Input/theme tokens, typography and spacing. Light/dark themes and 375/768/1440px layouts work without page overflow.
- Add `mediaPackage.ui.backToPackages` to both vi/en mediaPackage.json. Reuse existing translated titles and actions elsewhere.

## UI states / errors
Keep forms mounted during save/reload; failed submissions retain drafts. Successful saves return to the overview. Version conflict keeps the entered proposal. Long deliverables and closure lists use normal page scrolling.

## Scope and done
UI only, no Task source changes, backend/schema/dependency changes or design replacement. Validate changed-source lint, production bundle, existing relevant E2E selectors, and browser fixtures covering save/cancel/discard/failure and responsive/theme behavior. Record existing build blockers separately.
