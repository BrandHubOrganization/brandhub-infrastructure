# Wan 2.2 VACE & S2V Product Video Worker (`gpu-workers/wan-vace/`)

Complete build, packaging, GPU provisioning, FastAPI job server, ComfyUI template, and unit-test guide for BrandHub's **Wan 2.2 Fun VACE 14B + Wan 2.2 S2V 14B + Qwen Image 2.1** product video worker.

- Back to [GPU Workers Overview](../README.md) · [Infrastructure Hub](../../README.md)
- 12-Genre Flow Catalog & Sample Scripts: [`flows/README.md`](flows/README.md)
- Director Prompt, Turnaround, Storyboard & Anti-"Plastic" Rules: [`wan-vace-bundle/director/prompt-rules-wan.md`](wan-vace-bundle/director/prompt-rules-wan.md)

---

## 1. Directory Structure

```text
gpu-workers/wan-vace/
├── README.md                                   # Complete worker & bundle manual (this file)
├── build_vace_flow.py                          # Compiles multi-segment Wan 2.2 Fun VACE 14B + Qwen scripts -> *_GUI.json
├── build_ugc_flow.py                           # Compiles lip-synced Wan 2.2 S2V 14B talking-review scripts -> *_GUI.json
├── package_vace.py                             # Rebuilds all 13 *_GUI.json flows and creates wan-vace-bundle.zip
├── test_web_flow.py                            # Live end-to-end smoke test (brandhub-ai-service -> Claude -> Vast.ai GPU)
├── flows/
│   ├── README.md                               # Detailed catalog of all 12 product-video genres
│   └── {unbox,hero,tvc,lifestyle,asmr,before-after,ugc,food,tech,compare,fashion,home}/
├── wan-vace-bundle/
│   ├── setup.sh                                # Vast.ai provisioning: pinned ComfyUI + aria2c SHA-256 models + API startup
│   ├── start_api.py                            # Dry-compiles all VACE flows against /object_info, then launches uvicorn
│   ├── vace_api.py                             # X-API-Key FastAPI worker (:10200) wrapping ComfyUI (:10101)
│   ├── canvas_api.py                           # Expands ComfyUI UI canvas JSON + subgraphs into /prompt API format
│   ├── requirements-api.txt                    # FastAPI, Uvicorn, httpx, python-multipart
│   ├── director/
│   │   └── prompt-rules-wan.md                 # Storyboard, turnaround, S2V, anti-plastic & Google ABCD TVC rules
│   └── resources/
│       ├── qwen_template.json                  # Reusable Qwen Image 2.1 subgraph (4-view turnaround, 2x2 storyboard, presenter)
│       └── s2v_template.json                   # Official ComfyUI video_wan2_2_14B_s2v base (trimmed above CUT_Y = 1600)
└── tests/
    ├── test_vace_flow.py                       # Offline graph & link topology assertions across VACE, TVC, UGC & turnaround
    └── test_vace_api.py                        # FastAPI auth, validation, subgraph expansion & media endpoint tests
```

---

## 2. ComfyUI Graph Compilation Architecture

### A. Visual Product Video Flows (`build_vace_flow.py` — 11 Genres)

Covers `unbox`, `hero`, `tvc`, `lifestyle`, `asmr`, `before-after`, `food`, `tech`, `compare`, `fashion`, and `home`:
1. **4-Angle Turnaround Sheet (`Qwen Image 2.1`)**: Uses [`wan-vace-bundle/resources/qwen_template.json`](wan-vace-bundle/resources/qwen_template.json) to synthesize a 4-view reference sheet (`output/video/turnaround*.png`) from the uploaded product photo and `views` descriptions, feeding it as **Image 2** into every storyboard node so rear/side/bottom/open-cap angles remain faithful instead of hallucinated.
2. **Optional Person / Model Reference (`extra_images`)**: Bound as **Image 3** after the turnaround sheet (e.g., `fashion` lookbooks or ambassador clips).
3. **Pinned Storyboard Grids (`K0..K3` or `K0..K7`)**: Generates 1 or 2 `2×2` Qwen grids at the exact output aspect ratio (`576×1024` or `1024×576`) and slices panels `K0..K7`.
4. **Segment Synthesis (`WanVaceToVideo`, `85` frames @ `16 fps` = `5.3 s` per segment)**:
   - Always receives the white-padded original product photo as `reference_image`.
   - Starts on **`"prev"`** (the last `8` frames of the previous segment for seamless motion chaining) or an integer panel index (`0..7` for hard scene cuts in `tvc`, `food`, `tech`, `compare`), and optionally pins `end_panel` (`0..7` or `null`).
   - Uses dual high/low-noise 14B FP8 experts with 4-step `lightx2v` LoRAs (`euler` / `simple`), trims reference latents, drops shared `8`-frame overlaps, and concatenates into `output/video/WanVACE_<name>_<sec>s.mp4`.

### B. Lip-Synced Talking-Review Flow (`build_ugc_flow.py` — `ugc` Genre)

Built from [`wan-vace-bundle/resources/s2v_template.json`](wan-vace-bundle/resources/s2v_template.json) (retaining only the fast 4-step lightning branch above `CUT_Y = 1600`):
1. Synthesizes a realistic creator holding the uploaded product via `qwen_template.json` (`presenter_prompt`), scales to `W×H` (`lanczos`), and fans that presenter frame into the base `WanSoundImageToVideo` node plus up to 3 `Video S2V Extend` subgraphs.
2. Synchronizes lip movement to an uploaded voice track (`mp3`/`wav` >= `20 s`) via `wav2vec2_large_english_fp16`: `3` chunks × `77` frames = `14.4 s`, or `4` chunks = `19.3 s` at `16 fps`.

### C. High-Quality Anti-"Plastic" Mode (Manual ComfyUI Tuning, ~5× Slower)

When inspecting a flow interactively in ComfyUI and wanting maximum skin/material micro-texture: bypass both `"lightx2v 4-step LoRA"` nodes, set both high/low-noise `KSamplerAdvanced` nodes in each segment to `steps = 20`, `cfg = 3.5`, split `0–10` / `10–20`, and keep `shift = 8`.

---

## 3. Building the Bundle & Running Offline Tests (No GPU Needed)

[`package_vace.py`](package_vace.py) regenerates every `*_GUI.json` workflow under `flows/*/` and writes `wan-vace-bundle.zip` using a strict file allowlist (never bundling `.safetensors` weights or `.api_key` secrets):

```powershell
cd gpu-workers/wan-vace

# Run all 8 offline unit tests (graph chaining, hard cuts, UGC fan-out, turnaround, API auth & subgraphs)
python -m unittest discover -s tests -p "test_*.py" -v

# Compile all 12 genres (13 workflows) and package wan-vace-bundle.zip
python package_vace.py
```

| Test Module | Assertions Verified Without a GPU |
| :--- | :--- |
| [`tests/test_vace_flow.py`](tests/test_vace_flow.py) | 4-segment `8`-frame overlap chaining (`unbox`), `1024×576` hard cuts (`tvc`), 5-link presenter fan-out (`ugc`), turnaround → `image_2` storyboard wiring across all VACE genres, and `extra_images` → `image_3` binding (`fashion`) |
| [`tests/test_vace_api.py`](tests/test_vace_api.py) | `401` on missing/wrong `X-API-Key`, `422` on empty segments or bad MIME, `400` on `../` path traversal, `canvas_to_api` subgraph flattening, uploaded filename substitution, and completed video listing |

---

## 4. Provisioning on Vast.ai (`wan-vace-bundle/setup.sh`)

### Hardware Requirements

- **GPU**: >= **48 GB VRAM** (`L40S`, `RTX A6000`, `RTX 6000 Ada`); **80 GB VRAM** (`A100` / `H100`) significantly reduces per-segment latency.
- **System RAM**: >= **96 GB** · **Container Disk (`/workspace`)**: >= **160 GB** (~92 GB total model weights, or ~75 GB when setting `NO_S2V=1` to skip UGC S2V weights).

### One-Command Bootstrap

Upload `wan-vace-bundle.zip` to `/workspace` on the rented GPU VM and run:

```bash
cd /workspace
unzip -o wan-vace-bundle.zip

# Standard startup (downloads & SHA-256 verifies all Wan 2.2 VACE, S2V & Qwen Image 2.1 weights)
bash wan-vace-bundle/setup.sh

# Optional flags: skip S2V weights and expose API_PORT=10200 via ngrok
NO_S2V=1 NGROK_AUTHTOKEN="<token>" bash wan-vace-bundle/setup.sh
```

What [`wan-vace-bundle/setup.sh`](wan-vace-bundle/setup.sh) & [`wan-vace-bundle/start_api.py`](wan-vace-bundle/start_api.py) do:
1. Clones `Comfy-Org/ComfyUI` pinned at commit `6b904b5fafd062effc1acbc46b1d3196922f7055`, preserving the VM's prebuilt CUDA PyTorch wheels.
2. Downloads all FP8/INT8/BF16 `.safetensors` weights via `aria2c -x 16` and verifies exact **SHA-256** checksums.
3. Copies compiled `*_GUI.json` workflows into `/workspace/ComfyUI/user/default/workflows/<genre>/` and sample inputs into `/workspace/ComfyUI/input/`.
4. Starts ComfyUI on `127.0.0.1:10101` (`--cache-none`), dry-compiles every VACE script against live `/object_info` via `start_api.py` (submitting zero GPU jobs), and launches `uvicorn vace_api:app` on `API_PORT` (default `10200`).
5. Generates a `0600` 32-byte token in `wan-vace-bundle/.api_key` unless `API_KEY` is supplied via environment variable. Configure `LTX_WORKER_URL` and `LTX_WORKER_API_KEY` in `brandhub-ai-service` to point to this tunnel.

---

## 5. Authenticated Worker HTTP API (`wan-vace-bundle/vace_api.py`)

Every route requires header `X-API-Key: <key>` (enforced before multipart spooling by `RequestGuard`, capping request bodies at `~81 MiB` / `20 MiB` per image, max `3` extra images, `1..8` segments, `1..2` storyboard grids, `256..1280` px sides):

| Method & Path | Request / Query Parameters | Response Summary |
| :--- | :--- | :--- |
| `GET /health` | — | `{"status": "ok", "comfy_url": "...", "fps": 16, "max_segments": 8}` (`503` if ComfyUI is down) |
| `POST /api/v1/generate_video` | Multipart: `reference_image` (`png`/`jpeg`/`webp`), `script_json` (`<= 120 KB`), optional `extra_images` (`<= 3`) | Uploads images to ComfyUI, expands subgraphs via `canvas_api.py`, submits `/prompt`, returns `{"prompt_id": "<uuid>", "length": "...", "status_path": "/api/v1/jobs/<uuid>"}` |
| `GET /api/v1/jobs/{prompt_id}` | Path UUID `prompt_id` | Returns `status` (`pending` \| `running` \| `complete` \| `failed` \| `unknown`) plus `videos[]` and `images[]` with `download_path` |
| `GET /api/v1/media` | `filename`, `subfolder=""`, `type="output"` (strict path-traversal guard) | Streams rendered `.mp4` or storyboard/turnaround `.png` from ComfyUI `/view` |

### Live End-to-End Smoke Test (`test_web_flow.py`)

With `brandhub-ai-service` running locally on `127.0.0.1:8082` and pointing to an active Vast.ai worker:

```bash
python test_web_flow.py flows/unbox/sneaker-reference.webp "20s POV sneaker unboxing on oak table" 9:16
```
