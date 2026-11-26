# Plan
1. Map UI services/hooks -> Business proxies -> AI Redis/Neo4j/S3 and inspect error/empty branches.
2. Remove Business list catch/fallback and validate array payload; extend existing controller test for failures/malformed payload and empty/real mapping.
3. Keep only observed series in TrendSparkline and show existing noGrowth text for fewer than two points. Preserve existing query/error rendering and legitimate calculations from observed counts.
4. Disable two legacy synthetic strategies with NotImplementedError, propagate through crawl_multi_source and map legacy /crawl to explicit 503. Remove missing-file generation from explicit internal adapter. Keep independent crawler HTTP controls unchanged.
5. Extend existing AI tests for no synthetic source/file output and API failure; run relevant regressions. Run frontend ci and focused Business tests. Where possible read local API without triggering crawl and report exact scope/limits; do not access AWS.

Board guard: reject MockS3Client in trend_boards.latest before any listing/read; use existing API exception mapping to TREND_BOARD_UNAVAILABLE (503). Add assertion to existing test_trend_boards.py; no change to global S3 factory.
