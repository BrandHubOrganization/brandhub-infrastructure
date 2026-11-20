# Post-migration crawl attempt and RAM observation — 2026-11-03

Before session import, the authenticated management API accepted a Facebook test preview (one source, at most two posts), but rejected the start request with HTTP 503 and `TREND_PIPELINE_NOT_READY`. No crawler run was started in that initial attempt. The health API reported Facebook and Threads `SESSION_MISSING`, TikTok `TIKTOK_NOT_CONFIGURED`, and no active run. No checks were bypassed and no scheduling/source configuration was changed.

Both EC2 instances were sampled 12 times at five-second intervals over about 55 seconds. These are **idle baseline measurements**, not crawl-load measurements.

| Measurement | Result |
| --- | --- |
| Gateway host minimum MemAvailable | 5850.6 MiB (~5.71 GiB) |
| Service host minimum MemAvailable | 5712.5 MiB (~5.58 GiB) |
| AI highest sampled cgroup memory.current | 650.9 MiB / 5 GiB limit |
| AI cgroup lifetime memory.peak | 824.2 MiB; includes earlier browser smoke, not a new crawl peak |
| AI OOM / OOM kills / restart count | 0 / 0 / 0 |

No container restart count changed during sampling. PostgreSQL's existing restart count of 1 predates this observation. Container cgroup usage can include file cache; it is not identical to Docker's displayed working-set figure.

Next required step: restore at least the Facebook session through the authenticated crawler management UI. Then repeat the bounded test with RAM sampling active before start and until completion/cleanup. Full pipeline processing needs a separate run because test mode does not publish live results. Successful idle measurements cannot establish that the original full-crawl OOM is fixed.

Raw per-sample metrics are retained locally at `D:/capstone/brandhub/.audit/crawl-ram-baseline.json`; no credentials or cookie values were recorded.

## Follow-up after user-supplied session import

Facebook and Threads sessions were imported through the management API and retained in API process RAM. Transfer used a one-use RSA/AES-GCM envelope; the private transfer key lived in container tmpfs and was deleted, as were local encrypted transfer artifacts. No cookie values were written to source, this report, RAM samples, or SSM command plaintext. Metadata reported `FORMAT_VALID_UNVERIFIED`: this confirms import/format, not provider acceptance of the login session.

Two real test jobs were accepted with HTTP 202 and observed around 16:53 Asia/Saigon:

| Platform | Native run ID | Result |
| --- | --- | --- |
| Facebook | `b000a725a66f4a40a1c43de28958b5be` | FAILED / `CRAWLER_EXIT_1`, 0 posts |
| Threads | `a02cbb9bea3b49938e48de969279a18b` | FAILED / `CRAWLER_EXIT_1`, 0 posts |

Both failed before browser collection during proxy preparation. Native run logs showed `PROXY_PROVIDER_HTTP_400`, with orchestration elapsed times of 0.8 and 0.6 seconds. A targeted provider check confirmed HTTP 400, provider code `40001031`, error `KEY_EXPIRED`, and the message that the proxy key has expired and needs renewal. The previously configured proxy endpoint also failed its TCP connectivity check. No direct/no-proxy fallback was introduced, and no production source/schedule configuration was changed.

Simultaneous target/source observation results:

| Measurement | Result |
| --- | --- |
| AI highest sampled cgroup memory.current | 657.9 MiB / 5 GiB |
| AI lifetime cgroup memory.peak | 824.2 MiB, unchanged from before the tests |
| Gateway minimum MemAvailable | 5835.3 MiB (~5.70 GiB) |
| Service minimum MemAvailable | 5707.9 MiB (~5.57 GiB) |
| AI OOM / OOM kill / restarts | 0 / 0 / 0 |
| Public HTTPS after tests | Health 200/UP; Business validation 400; protected unauthenticated API 401 |

The controller sampled RAM every five seconds with limits of 4500 MiB AI usage, 1024 MiB host MemAvailable, and a four-minute per-run observation budget before requesting a graceful stop. Neither memory guard was reached. Full per-sample data is retained at `D:/capstone/brandhub/.audit/crawl-observation-results.json` with no credentials.

**Initial blocker (subsequently resolved by renewal):** the configured KiotProxy key had expired. These failed-start measurements do not establish peak RAM during browser crawling or downstream NLP/worker processing. The renewed-key observations below supersede this initial blocker for Facebook.

## After proxy renewal: Facebook browser crawl succeeded

The user supplied the renewed proxy key. A private hash comparison confirmed it was already the configured runtime key, so neither key replacement nor an AI restart was needed. Existing RAM-only sessions were preserved. The provider first reported no assigned proxy, then the native flow successfully obtained one. No credentials are included in this report.

| Platform / attempt | Run ID | Result | Observed duration | Posts |
| --- | --- | --- | --- | --- |
| Facebook | `c4055dafdd5b4effa176a53fd87b770f` | COMPLETED / SUCCESS | 55.5 s | 3 |
| Facebook repeat | `ce6893ab83f24728946aa9d005fa33e3` | COMPLETED / SUCCESS | 50.5 s | 3 |
| Threads | `8525fa44123d45ef87154a30f790d82b` | FAILED / CRAWLER_EXIT_1 | 5.1 s | 0 |
| Threads repeat | `cd1fe133481848eebbfdeaa235fec8e5` | FAILED / CRAWLER_EXIT_1 | 5.1 s | 0 |

Both Facebook runs opened the actual crawler browser and produced a cold-backup output file. They used native test mode with live delivery and RabbitMQ publication disabled. Although the test preview requested two posts per source, the actual manifest reported three posts in each run; the table records observed results rather than treating the requested limit as an exact count.

| RAM / health measurement across renewed-key observations | Result |
| --- | --- |
| AI cgroup high-water mark | 1642.2 MiB (~1.60 GiB) / 5 GiB limit |
| Highest sampled AI memory.current | 1634.6 MiB |
| AI after cleanup | ~660–665 MiB |
| Gateway minimum MemAvailable | 4956.2 MiB (~4.84 GiB) |
| Service minimum MemAvailable | 5677.2 MiB (~5.54 GiB) |
| AI OOM / OOM kills / restart count | 0 / 0 / 0 throughout |
| Public health during/after tests | HTTPS 200/UP, Business validation 400, protected unauthenticated endpoint 401 |

The first renewed-key observation covered the entire Facebook/Threads pair on both machines. The repeat target observation covered the whole pair; its source observer had to be restarted after a stale stop flag, so the repeat's source coverage starts later. The first complete window's source minimum was 5691.1 MiB. No memory stop guard was reached.

Threads still fails before its browser stage: native logs show `Threads proxy preparation failed: PROXY_PROVIDER_HTTP_400` on both renewed-key attempts. A separate idle provider diagnostic could obtain a proxy successfully (HTTP 200). The exact cause of the Threads-specific repeated proxy-preparation rejection remains unverified; do not label the renewed key expired or attribute these failures to RAM.

Raw first renewed-key samples: `.audit/crawl-observation-results-renewed.json`. Repeat samples: `.audit/crawl-observation-results.json`. No cookie/key values were saved in these metrics. Sessions remain in API RAM; no production schedule/source settings were changed.

**Conclusion:** the new two-EC2 placement completed these small Facebook browser crawls with ample host RAM and no OOM. This does not establish memory safety for large crawls, simultaneous browsers, or the downstream NLP/worker pipeline, because test mode disabled broker publication.
