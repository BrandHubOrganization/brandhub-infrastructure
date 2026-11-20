#!/usr/bin/env bash
# Stop this EC2 when its service has been idle. Run by brandhub-idle-sleep.timer every 5 minutes.
# Terraform sets instance_initiated_shutdown_behavior = "stop", so `shutdown` stops (never terminates) the host.
#   IDLE_MODE=edit-video  busy while a job in the edit-video data volume is QUEUED/RUNNING
#   IDLE_MODE=crawl       busy while a crawl run is RUNNING/STARTING
# Activity = newest file change in the service's data. The host also stays up for IDLE_MINUTES after boot,
# so a wake request has time to arrive and create work.
set -euo pipefail
MODE="${IDLE_MODE:?set IDLE_MODE=edit-video or crawl}"
IDLE_MINUTES="${IDLE_MINUTES:-30}"
VOLUMES=/var/lib/docker/volumes

log() { logger -t brandhub-idle-sleep "$*"; echo "$*"; }

uptime_min=$(( $(cut -d. -f1 /proc/uptime) / 60 ))
if [ "$uptime_min" -lt "$IDLE_MINUTES" ]; then
  log "awake: booted ${uptime_min}m ago"; exit 0
fi

case "$MODE" in
  edit-video)
    data="$VOLUMES/brandhub-edit-video-data/_data/jobs"
    busy=$(python3 - "$data" <<'EOF'
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
busy = 0
for f in root.glob("*/job.json") if root.exists() else []:
    try:
        busy += json.loads(f.read_text()).get("status") in ("QUEUED", "RUNNING")
    except (OSError, ValueError):
        busy += 1  # being written: treat as busy
print(busy)
EOF
)
    ;;
  crawl)
    data="$VOLUMES/brandhub-crawl-data/_data/crawler/control"
    busy=$(python3 - "$data" <<'EOF'
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
busy = int((root / "starting.json").exists())
for f in (root / "runs").glob("*.json") if (root / "runs").exists() else []:
    try:
        busy += json.loads(f.read_text()).get("status") in ("RUNNING", "STARTING")
    except (OSError, ValueError):
        busy += 1
print(busy)
EOF
)
    # A browser still running means a crawl the run files may not show yet.
    if docker top brandhub-crawl-service 2>/dev/null | grep -qiE "chrom|camoufox|firefox"; then busy=$((busy + 1)); fi
    ;;
  *) log "unknown IDLE_MODE $MODE"; exit 1 ;;
esac

if [ "$busy" -gt 0 ]; then
  log "awake: $busy active job(s)"; exit 0
fi

if [ -d "$data" ] && [ -n "$(find "$data" -newermt "-${IDLE_MINUTES} minutes" -print -quit 2>/dev/null)" ]; then
  log "awake: activity in the last ${IDLE_MINUTES}m"; exit 0
fi

log "idle for ${IDLE_MINUTES}m with no active work: stopping this instance"
shutdown -h now
