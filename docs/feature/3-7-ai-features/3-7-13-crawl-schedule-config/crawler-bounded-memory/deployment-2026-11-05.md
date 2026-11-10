# Production deployment — 2026-11-05

- AI-service release commit: `1e04f5f` on `fix/crawler-bounded-memory` (based on production `develop` commit `31784b8`). Release is not merged into develop; preserve these commits before a later develop deployment.
- CI/CD: https://github.com/BrandHubOrganization/brandhub-ai-service/actions/runs/41996960161 — lint, unit tests, 241 crawler regressions, immutable image build and SSM rollout succeeded.
- Image: `821014378805.dkr.ecr.ap-southeast-1.amazonaws.com/brandhub/ai-service:sha-1e04f5f-40`.
- Previous rollback image: `sha-31784b8-38`.
- Backend instance: `i-0761e3bd96ca5d4de`; manifest `/home/ec2-user/brandhub/ecr/backend.compose.json`; service-only update, existing volumes retained.
- Actual production memory limit confirmed at 5368709120 bytes (5 GiB); unchanged.
- Enabled Docker `init: true` after discovering unreaped Chromium zombies during live verification. This reaps orphan processes as well as terminating browser workers. Mirrored in checked-in backend manifest and crawler overlay. Init-only rollback snapshot retained as `backend.compose.json.bounded-init.bak` on the host.
- Final smoke: 26 synthetic posts, real Chromium, three distinct workers (25 posts / 1 post / final completion), zero remaining browser processes including zombies. Container memory 612 MiB before, 804 MiB peak, 613 MiB after. No Facebook requests or RabbitMQ publishing were performed by this test.
- Health UP; Redis/RabbitMQ/S3 clients connected; container healthy, zero restarts; cgroup OOM and OOM-kill counters both zero. Public API health returned HTTP 200.
- The first smoke used `set_content` and hit a browser load timeout; repeating with explicit data-URL DOM navigation passed. The failed attempt preserved pending work and stopped after bounded retries.
- Facebook crawl above 100 posts remains unmeasured in production. Sessions live in API memory and must be uploaded again after deployment; synthetic results are not proof of Facebook feed completeness or peak memory at scale.
