# Verification
Inbox empty stays empty; real results contain no mock entries; malformed/error response rejects. Mark-read/read-all use server and failures reject. Navbar shows load error/retry; failed mark-read retains unread. Social empty is valid; API failure rejects; no timestamp/handle invention. Editor error does not assert disconnected or connected. Verify vi/light and en/dark plus existing hashtag flows. Full type-check known unrelated errors recorded separately.

## Results
- Before fix: all 7 targeted service checks failed (sample inbox merge, swallowed failures, fabricated social metadata).
- After fix: 7/7 Vitest checks passed.
- Playwright: 6/6 targeted checks passed; inbox tests cover vi/light and en/dark, keyboard retry, failed read preserving unread state; social error/retry and existing hashtag flows passed.
- ESLint passed on changed runtime files; Vite startup confirmed by Playwright webServer.
- Full type-check still reports pre-existing errors in useTaskContentSync, MediaDropzone, workspace/dashboard and AppRoutes; no errors in changed runtime files.
- No live database changes. API results in browser tests are contract fixtures.

## Scope evidence
- UserNotificationController and UserNotificationService implement inbox/read/read-all.
- SocialAccountController implements social account listing; existing page already has error/retry UI.
- BillingServiceImpl methods and SubscriptionServiceImpl.listPlans still throw UnsupportedOperationException.
- Global analytics/activity, workspace posts/dashboard and posts/{id}/detail contracts are absent from current Business controllers; these demo features were not migrated.
- Legacy AI trends/knowledge UI contracts are not exposed by current Business/Gateway routes. Content templates are distinct from implemented workspace/mail templates.
