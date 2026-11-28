# External GPU Workers Architecture (`gpu-workers/`)

On-demand GPU worker bundles provisioned on external cloud GPU instances (**Vast.ai** `L40S` / `A6000` / `RTX 6000 Ada` >= 48 GB VRAM, or `A100` / `H100` 80 GB VRAM) and orchestrated remotely by `brandhub-ai-service`.

- Back to [Infrastructure Hub](../README.md)
- Wan 2.2 Fun VACE + S2V + Qwen Image 2.1 Worker Manual: [`wan-vace/README.md`](wan-vace/README.md)
- 12-Genre Product Video Flow Library: [`wan-vace/flows/README.md`](wan-vace/flows/README.md)
- Director Prompt & Storyboard Rules: [`wan-vace/wan-vace-bundle/director/prompt-rules-wan.md`](wan-vace/wan-vace-bundle/director/prompt-rules-wan.md)
- AI Service & Video Research Docs: [`../docs/architecture/ai-service-architecture.md`](../docs/architecture/ai-service-architecture.md) · [`../docs/ai-models/video-generation-research-report.md`](../docs/ai-models/video-generation-research-report.md)
- Vast.ai S3 IAM User (`brandhub-image-worker-prod`): [`../prod/terraform/04-storage/README.md`](../prod/terraform/04-storage/README.md)

---

## 1. Why GPU Workers Live Outside the AWS EC2 Fleet

Running persistent AWS `g5`/`g6e` GPU instances in `ap-southeast-1` 24/7 is cost-prohibitive when multi-segment 14B diffusion video renders occur in burst workloads. BrandHub decouples GPU compute cleanly:
- **Control Plane (`brandhub-business-service` + `brandhub-ai-service` on AWS EC2)**: Handles AI credit reservation (`product_video_*` durable coordinator tables in PostgreSQL), multimodal director script authoring (`Claude` via `app/services/ltx_director.py`), JSON Schema & timing pre-validation, job polling, CC0 audio mixing (`ffmpeg`), and final S3 persistence.
- **Data/Compute Plane (`gpu-workers/wan-vace/` on Vast.ai)**: Self-contained `wan-vace-bundle.zip` unpacked onto `/workspace`, running pinned **ComfyUI** on `127.0.0.1:10101` behind an `X-API-Key`-authenticated **FastAPI** job server (`vace_api.py` on `:10200`).

---

## 2. End-to-End Integration Contract (`ltx_director.py` ↔ `vace_api.py`)

```text
brandhub-business-service (ProductVideoProduction coordinator + AI credit reservation)
  │  POST /api/v1/ai/video/generate (X-Internal-Key)
  ▼
brandhub-ai-service (app/services/ltx_director.py)
  ├─ 1. Decodes reference_image_base64 (product photo) + optional character_image_base64 (person photo)
  ├─ 2. Calls Claude (generate_claude or fallback claude_cli) with DIRECTOR_PROMPT.md + script.schema.json
  ├─ 3. Pre-validates script in check_script() BEFORE touching GPU:
  │      • Draft202012 JSON Schema + 1..8 segments + 1..2 storyboard grids (K0..K3 or K0..K7)
  │      • Every segment frame count satisfies 4n + 1 (default 85 frames @ 16 fps = 5.3s)
  │      • Total video duration (accounting for 8-frame 'prev' overlap) strictly within 15.0s .. 21.0s
  │      • Maps aspect_ratio {'9:16': [576, 1024], '16:9': [1024, 576]} and pops 'music' track name
  ├─ 4. Submits multipart POST {LTX_WORKER_URL}/api/v1/generate_video (Header: X-API-Key: LTX_WORKER_API_KEY)
  │      • Form fields: reference_image, extra_images (optional), script_json
  ▼
Vast.ai GPU Worker (wan-vace-bundle/vace_api.py :10200 -> ComfyUI 127.0.0.1:10101)
  ├─ 5. RequestGuard validates X-API-Key (constant-time hmac.compare_digest) & caps upload <= 81 MiB
  ├─ 6. Uploads images to ComfyUI /upload/image, compiles script via build_vace_flow.py + canvas_api.py,
  │     submits expanded graph to ComfyUI /prompt -> returns {prompt_id, status_path}
  ├─ 7. AI Service polls GET /api/v1/jobs/{prompt_id} every LTX_WORKER_POLL_INTERVAL_SECONDS
  └─ 8. Downloads rendered silent MP4 via GET /api/v1/media, mixes faded CC0 soundtrack in add_music()
        (AAC 192k, +faststart), and uploads final asset to S3 (brandhub-media-134875421878)
```

---

## 3. Shared Timing & Security Invariants

1. **Synchronized Frame Constants**: `FPS = 16`, `OVERLAP = 8`, and `DEFAULT_FRAMES = 85` in `brandhub-ai-service/app/services/ltx_director.py` match `gpu-workers/wan-vace/build_vace_flow.py` identically. Changing any timing constant requires updating both repositories together.
2. **Never Expose ComfyUI (`:10101`)**: ComfyUI has no built-in authentication and listens locally behind `vace_api.py`. Public tunnels (Vast.ai port mappings or `NGROK_AUTHTOKEN`) must target **only** `API_PORT` (`10200`).
3. **Least-Privilege S3 Credentials**: When a worker interacts directly with S3 (e.g., Qwen/Flux image or ambassador pipelines), it uses IAM user `brandhub-image-worker-prod` scoped strictly to `ai/*` and `qwen-ambassador/*` on `brandhub-media-134875421878` ([`../prod/terraform/04-storage/app-buckets.tf`](../prod/terraform/04-storage/app-buckets.tf)).
