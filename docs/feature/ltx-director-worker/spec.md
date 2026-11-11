# LTX director worker

Continue the approved Claude design: a 20-second product film, with `review` when a character image is supplied and `cinematic` otherwise. Claude on the application backend writes a validated director script. Qwen builds K0–K3; LTX renders two connected parts; VieNeu mixes optional narration and music.

## Acceptance
- Preserve Tuấn's architecture: backend-only `X-API-Key`, multipart submit, `prompt_id`, job polling, S3 output or authenticated media download.
- Keep existing motion-reference and 5/10/15-second image video routes intact. Select LTX for 20-second image jobs only when LTX is configured.
- Optional character image travels through the existing web and Business request into AI; no raw workflow or secret is accepted from the browser.
- Validate the director schema and selected mode before ComfyUI submission. Override upload filenames and output prefixes server-side.
- Convert generated GUI subgraphs into executable API nodes using the running server's node schema; reject unsupported serialization rather than submitting a guessed graph.
- Deployment ZIP includes everything required to build the graph; installation preserves model files and running ComfyUI.
- UI: optional character upload uses parallel Vietnamese/English keys and existing light/dark theme components. Character image means review; otherwise cinematic.
- Invalid key, missing character, malformed script and unavailable ComfyUI return bounded actionable errors; failed generation retains existing credit handling.

## Verification boundary
Use mocked Claude/ComfyUI and real generated graphs locally. A live GPU render and listening to a selected voice remain hardware acceptance checks; do not claim them from mocked tests.
