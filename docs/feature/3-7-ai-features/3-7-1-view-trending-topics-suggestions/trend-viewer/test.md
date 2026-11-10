# Verification

- Non-admin rejected before AI reads. Valid historical date forwarded exactly;
  period 6h/24h/7d and limit 1..100 only; malformed/future dates rejected.
- AI failure is not replaced with empty/mock results. Invalid upstream shapes fail.
- List/summary requested independently; summary error does not hide list.
- Day filter defaults to current Vietnam date, live ignores/disables date; URL
  survives reload/back. Replay day link opens correct historical day.
- Search/topic filter only returned candidates; clear no-match filters easily.
- Expand real candidate: score components, momentum, sample/source posts shown
  only when present. No percentage claims or synthetic time series.
- Source links http(s) only; markup renders as text. Missing fields stay absent.
- Empty publication shows recovery to replay, not zero-filled fake KPIs.
- API-mocked browser: loading/success/empty/failure/retry/partial-summary failure,
  responsive 375/768/1440, vi/en and both themes. Keyboard inputs/expansion/link.
- New QA files stay ignored in keep-local-only; no src tests. No shared DB/S3/model
  writes in QA. No automatic replay, clean, commit or push.

## Executed 2026-10-25

- Java Maven compile passed. Local-only Mockito check passed historical date/live
  forwarding, four invalid query cases, unexpected upstream shape, error propagation
  and both Admin guards (denial makes no AI call). No shared DB access in this check.
- Frontend production build and targeted ESLint passed. Existing bundle-size and
  mixed dynamic/static import warnings remain outside this feature.
- Playwright with mocked API passed search/topic/live/7d filters, historical query,
  keyboard expansion, escaped post text, rejection of javascript source links,
  empty/error/retry and independent summary failure. No JS exceptions or horizontal
  page overflow in light/dark at 375/768/1440; vi/en labels verified. Screenshots and
  QA code stay ignored under output/playwright and keep-local-only.
- Real read-only local AI GET for 2026-10-08 returned 200 with 0 candidates;
  summary returned online with latest_run=null. No model/replay/write was invoked.
  New authenticated Business routes were checked in isolation, not against a
  restarted live Business process.

## Manual acceptance after deployment

1. Restart Business Service to register the new Admin controller. Web reload/HMR
   loads the new panel. Sign in as Admin.
2. Open `/admin?view=trends&period=24h&date=2026-10-08` or use Admin > View trends.
3. While replay is blocked, expect an honest empty publication state. After fixing
   Neo4j, resume the existing replay job manually and refresh this viewer.
4. Verify the date's candidates and source posts, then live and trailing seven days.
   The summary is system-wide latest publication, not the selected day's DB health.
5. No DB migration/seed/cleanup or AI restart is required by the viewer itself.
   Scoring, existing general trending-topics API and AI Studio mock page unchanged.

## Commit preflight (2026-10-26)

The current viewer includes updated cards, charts and the crawl-control/history
drawer, which reuses existing guarded crawler endpoints. These dependencies are
included in the viewer commit. The exact staged Web tree built successfully and
passed changed-file ESLint in an isolated checkout; Business staged sources also
compiled. S3 replay routes/panels remain a separate uncommitted change. Historical
browser results above are not a claim that the later UI additions were retested
end-to-end against live services.
