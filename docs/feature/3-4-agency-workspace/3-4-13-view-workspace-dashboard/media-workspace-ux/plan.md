> Checkpoint 2026-10-17: restored specification and historical verification for retained Media Package/Campaign UI. Task UI changes described as rolled back remain out of this UX scope. API/classification changes after this checkpoint are governed by the Media Package package-simplification spec; historical fixture test results are not a new verification run.

# Plan

1. Add shared InlineWorkArea using existing tokens and Button with a focused heading and visible return action. Document in AGENTS.md that long media workflows should use page content.
2. Rename CreateCustomPackageDialog to CreateCustomPackageForm and NegotiateTermsModal to NegotiateTermsForm; change presentation wrappers and retain form/request logic. Render creation as the main page content while open. Negotiation replaces the selected package overview while open.
3. Move selected catalog detail state from cards to MediaPackageCatalog. MediaPackageDetail fills the catalog width and keeps existing selection/template/duplicate actions available. Restore opener focus when returning.
4. Rename CampaignClosureDialog to CampaignClosureSection, render inside the delivery section as a full-width work area, and remove nested list height limits.
5. Update src/i18n/locales/vi/mediaPackage.json and en/mediaPackage.json in parallel. Update existing media-package E2E locators from dialog to region to match the new UI.
6. Verify no Task file changes in this turn, then lint, build and run browser scenarios using fixture APIs.

Risks: parent reloads must not unmount drafts while saving; the negotiation base version must remain frozen. Keep discard confirmation guards and existing role gates.
