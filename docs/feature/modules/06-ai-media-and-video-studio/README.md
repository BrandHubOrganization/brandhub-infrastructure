# 06-ai-media-and-video-studio — AI Commercial Image, Product Video & Conversational Video Studio (3 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 3.7 AI Features](../../srs/06-ai-features/README.md) · [AI Video Research](../../../ai-models/video-generation-research-report.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Multimodal commercial media generation and editing pipelines uniting Qwen Image 2.1 Virtual Brand Ambassadors, multi-scene Wan 2.2 Fun VACE 14B + S2V 14B Product Video production (`gpu-workers/wan-vace/`), CapCut project export, and the containerized Claude FFmpeg Video Space worker (`Edit_Video`).

---

## 1. Production Codebase & Persistence Mapping

- **Primary Services:** `brandhub-ai-service` (`ltx_director.py`, `image_gen.py`, `ambassador.py`, `video_space.py`), `gpu-workers/wan-vace/` (ComfyUI + `start_api.py` 13 VACE/I2V/S2V workflows), `Edit_Video` (`prod/hosts/edit-video/edit-video.compose.yaml`), and `brandhub-business-service` (`ProductVideoController`, `VideoSpaceController`, `AmbassadorController`).
- **Storage & Runtime State:**
  - **PostgreSQL 17:** `product_video_projects`, `product_video_scenes`, `brand_ambassadors`.
  - **MongoDB 7.0:** `video_space_sessions`, `ai_generation_jobs`.
  - **AWS S3 (`brandhub-media-134875421878`):** `K0..K7` storyboard keyframes, 4-angle ambassador turnarounds, rendered `16 FPS` scene clips, final stitched MP4s, and `.zip` CapCut Desktop project bundles.
- **Related Canonical SRS Domain:** [06-ai-features (`3.7.8`–`3.7.13`, `3.7.19`)](../../srs/06-ai-features/README.md).

---

## 2. Consolidated Modules (`3`)

| Module Slug | Scope & Engineering Title | Core Codebase Touchpoints | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `commercial-image-and-qwen-ambassador` | **Commercial Advertising Image Presets & Qwen Image 2.1 ComfyUI Virtual Ambassador Pipeline** | Studio ad presets, 4-angle Qwen Image 2.1 turnaround consistency (`front`, `left`, `right`, `3/4`), product composite relighting | [Spec](./commercial-image-and-qwen-ambassador/spec.md) · [Plan](./commercial-image-and-qwen-ambassador/plan.md) · [Task](./commercial-image-and-qwen-ambassador/task.md) · [Test](./commercial-image-and-qwen-ambassador/test.md) |
| `wan-vace-product-video-pipeline` | **Multi-Scene Product Video Production Pipeline (LTX Director, Wan 2.2 VACE / I2V Workers & CapCut Export)** | `ltx_director.py` ABCD TVC scripting, `gpu-workers/wan-vace` (`4n+1` frames, `8`-frame seam overlap), Wan 2.2 S2V lip-sync, CapCut export | [Spec](./wan-vace-product-video-pipeline/spec.md) · [Plan](./wan-vace-product-video-pipeline/plan.md) · [Task](./wan-vace-product-video-pipeline/task.md) · [Test](./wan-vace-product-video-pipeline/test.md) |
| `video-space-and-claude-edit-worker` | **Video Space Nonlinear Editor, Conversational Auto-Edit Agent & Containerized Claude FFmpeg Worker** | Nonlinear browser timeline, conversational edit agent, isolated `Edit_Video` EC2 FFmpeg render container (`:8090` over VPC) | [Spec](./video-space-and-claude-edit-worker/spec.md) · [Plan](./video-space-and-claude-edit-worker/plan.md) · [Task](./video-space-and-claude-edit-worker/task.md) · [Test](./video-space-and-claude-edit-worker/test.md) |

---

## 3. Architectural Invariants

1. Heavy GPU synthesis (`Wan 2.2 Fun VACE 14B`) and FFmpeg rendering (`Edit_Video`) run asynchronously off the API thread with idempotent webhook/polling completion and automatic credit `RELEASE` on worker failure.
2. Storyboard scene transitions strictly obey `16 FPS`, `4n + 1` frame counts, and `8`-frame seam overlap (`gpu-workers/wan-vace/wan-vace-bundle/director/prompt-rules-wan.md`).
