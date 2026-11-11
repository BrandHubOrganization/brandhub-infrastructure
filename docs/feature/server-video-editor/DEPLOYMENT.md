# Server video editor deployment

The worker is packaged in `brandhub-ai-service/Dockerfile.video-edit` and
`compose.video-edit.yml`. It can run on a separate Linux VM; no VM has been
deployed by this change. Business remains the authority for private media,
ownership, quota and credits.

## Configuration

Copy `.env.video-edit.example` to ignored `.env.video-edit` in the AI repository.
Set the existing internal service key, a Mongo URI/database, the Business origin,
the existing Anthropic key/model, and the allowed upload capability origins.
The worker does not need AWS credentials or `REPOSITORY_ENCRYPTION_KEY_V1`.
Those stay in Business, which decrypts authorized sources and encrypts outputs.

For a worker on another VM, `VIDEO_EDIT_BUSINESS_URL` must be a reachable private
Business origin. `VIDEO_EDIT_UPLOAD_ORIGINS` must match the gateway origin used
in server-issued upload links. A localhost URL refers to the worker's own VM,
so do not copy local URLs unchanged to a remote deployment.

Mount an existing faster-whisper model directory using
`VIDEO_EDIT_HOST_MODEL_DIR`. Model files must include `model.bin`, configuration,
tokenizer and vocabulary. Requests do not download models. Stock Edge TTS is
optional and disabled by default; it needs outbound network access when enabled.

Configure the main AI service's `VIDEO_EDIT_RUNTIME_URL` to reach this worker.
Keep port8094 on the private network and restrict ingress to the AI service;
internal API calls still require the existing internal key.

## Start and verify

From the AI repository:

```sh
docker compose -f compose.video-edit.yml up -d --build
docker compose -f compose.video-edit.yml ps
docker compose -f compose.video-edit.yml logs --tail 100 video-edit
```

`GET /health` checks process readiness. The authenticated
`GET /api/v1/ai/video-edit/capabilities` reports configured tools, model readiness
and actual supported editing operations without making a provider call.
Test the public Business submission/status/content flow before exposing it to
users. An internal health response alone is not an end-to-end proof.

## Capacity and recovery

The compose package limits the worker to four CPUs,4GiB RAM,128 PIDs and a
read-only root filesystem. It uses a writable scratch volume, one leased
executor and a bounded durable queue. Benchmark real source material on the
chosen VM before making turnaround promises. The600-second deadline is a limit,
not a throughput guarantee.

Retain Mongo job records and output-session checkpoints during recovery.
Completed outputs are separate private assets. Unknown Claude outcomes remain
`RECONCILIATION_REQUIRED`; do not delete the job and silently retry a paid call.
Output publication retries reuse the cached verified artifact and deterministic
Business session. Archive or remove terminal scratch folders according to an
operator retention policy; never remove an active job or its recovery files.

## Capability boundary

The executable pipeline probes media, samples frames, transcribes provided
speech with a mounted model, plans with Claude, renders typed edits and checks
the resulting MP4. It includes cuts, retiming, freeze/callouts, captions/titles,
supplied alpha portraits, transitions and audio mixing. Unsupported manual
effects fail explicitly. HyperFrames,Manim,CapCut and tracking/background-removal
references are not advertised as executable server features.

Local evidence and limitations are recorded in the feature test report. No new
footage generation, automatic publishing, cloud purchase or VM deployment is
performed by starting this editor worker.
