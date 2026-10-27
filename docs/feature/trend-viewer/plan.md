# Plan

1. Guarded thin AdminTrendController delegates to AdminTrendService; inject existing
   AdminAccountService/AiServiceClient, forward only validated query values, preserve
   arrays and validate upstream response shapes. No change to AI or DB schemas.
2. Feature-specific admin types/service/query hook. URL owns filter values;
   TanStack Query caches independently keyed list/summary; no polling/paid actions.
3. AdminTrendPanel orchestrates labeled controls and compact snapshot status/list.
   AdminTrendList and AdminTrendDetail present candidate metrics/history/post
   evidence; React text rendering and safe external URL checks, no raw HTML.
4. Add Admin view/sidebar navigation and graph navigation. Replay navigation is
   supplied by the separate replay feature. Include CrawlRunsDrawer and
   crawlConfigService for the viewer's current crawl-control/history UI.
   Update both src/i18n/locales/vi/admin.json and en/admin.json.
5. Local-only Java/API and UI fixtures: requireAdmin first, valid historical query,
   invalid inputs, unavailable upstream, empty response, filters/detail/retry,
   URL state and language/themes/responsive. Existing test source stays unchanged.
