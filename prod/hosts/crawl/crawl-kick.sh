#!/usr/bin/env bash
# Start a scheduled crawl. EventBridge Scheduler starts the crawl EC2, then runs this through SSM a few
# minutes later. Waits for the crawl API, then calls /management/scheduled with the internal key read from
# the running container, so the key never appears in the schedule or the SSM command.
set -euo pipefail
API=http://172.31.20.50:8084
for _ in $(seq 1 60); do
  curl -fsS -o /dev/null "$API/health" && break
  sleep 10
done
KEY=$(docker exec brandhub-crawl-service printenv INTERNAL_SERVICE_KEY)
code=$(curl -sS -o /tmp/crawl-kick.json -w '%{http_code}' -X POST -H "X-Internal-Key: $KEY" \
  "$API/api/v1/ai/trends/pipeline/management/scheduled")
logger -t brandhub-crawl-kick "scheduled crawl -> HTTP $code"
echo "HTTP $code"; cat /tmp/crawl-kick.json; echo
# 202 started, 409 a run is already going: both are fine.
[ "$code" = 202 ] || [ "$code" = 409 ]
