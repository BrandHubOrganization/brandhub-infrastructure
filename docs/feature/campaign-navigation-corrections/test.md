# Verification

Check package chat destination has no context query. Campaign DRAFT, APPROVED, pending/failed deployment and IN_PROGRESS with no tasks hide task CTA and false task-created guidance. Successful task fetch enables CTA; refresh failure hides it. Optional absent deployment returns successful null; default absent read still throws domain 404; campaign not found and access denied remain errors. Web retains legacy domain-404 handling for rollout, arbitrary 404/401 remain load errors. Verify keyboard, vi/en, light/dark and mobile; run Business compile and Web CI. All executable QA under ignored keep-local-only. No real deploy, DB edits, paid AI or login bypass.

## Results — 2026-10-30

- Package chat navigation now targets /workspaces/{id}/chat without contextual
  parameters. Package context ID remains for negotiation history; no messages deleted.
- Business compile passed. Isolated Mockito smoke passed optional absent = null,
  default absent = domain404, succeeded response, cross-workspace404, forbidden
  before repository access. No DB/network used.
- Actual NextStep/Delivery components tested in a private browser against mock APIs:
  empty IN_PROGRESS hides CTA, confirmed tasks show it, removal hides it again,
  APPROVED without tasks hides it; optional=true sent. No mutation requests.
  Vietnamese/English, light/dark and 375px checked; screenshots inspected.
- User-provided production response confirms SUCCEEDED deployment, completedAt
  2026-10-30T08:59:46.997298Z (15:59 Vietnam). Earlier 404 can be a missing deployment
  record; the exact earlier response was not supplied. Keep arbitrary404 visible.
- 401 remains unconfirmed: current shared Axios client attaches access token and
  supports a single refresh/retry, including concurrent requests. Console401 alone
  cannot distinguish recovered token expiry from failed refresh. No authentication
  bypass or unverified auth changes. Need refresh/final request response if it recurs.
- No database migration, seed, cleanup or production write. New executable QA and
  screenshots are ignored under keep-local-only, not part of source changes.
- Web npm run ci passed: lint (0 errors, existing warnings), TypeScript and
  production build. Deploy Web and Business together to enable optional empty
  deployment reads without console404; old Business retains domain404 fallback.
