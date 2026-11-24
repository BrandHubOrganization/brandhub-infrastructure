# Director Prompt & Storyboard Rules (`Wan 2.2 Fun VACE 14B` & `S2V 14B`)

Authoritative prompt-engineering, turnaround anchoring, storyboard grid, lip-sync, and cinematography rules shared by `gpu-workers/wan-vace/flows/*` and `brandhub-ai-service/app/services/ltx_director.py`.

- Back to [Wan VACE Worker Manual](../../README.md) · [12-Genre Flow Library](../../flows/README.md) · [GPU Workers](../../../README.md)

---

## 1. Visual Pipeline Contract (`Wan 2.2 Fun VACE 14B` + `Qwen Image 2.1`)

- **4-Angle Turnaround Sheet (`views`)**: Before drawing any storyboard panel, Qwen Image 2.1 renders a 4-angle product turnaround sheet (`front`, `right/side`, `back`, `top/bottom/open-cap` declared in `script.views`) from the white-padded product photo (`Image 1`). `build_vace_flow.py` automatically wires this sheet as **`Image 2`** into every storyboard node so rear labels, soles, clasps, and open caps stay geometrically consistent instead of guessed.
- **Optional Character / Model Reference (`extra_images`)**: When a person or brand ambassador photo is supplied (`fashion`, `lifestyle`), it enters every storyboard node as **`Image 3`** right after the turnaround sheet.
- **Pinned Storyboard Grids (`K0..K3` and 2-Grid `K0..K7`)**:
  - **Single `2×2` Grid (`storyboard_prompt`)**: Produces panels `K0..K3` for 3–4 segment chained flows (`unbox`, `hero`, `lifestyle`, `asmr`, `before-after`, `fashion`, `home`).
  - **Dual `2×2` Grids (`storyboard_prompts: [grid1, grid2]`)**: Produces 8 pinned panels `K0..K7` for 6–7 scene hard-cut genres (`tvc`, `food`, `tech`, `compare`).
  - VACE treats pinned start/end panels almost literally — every panel must already depict the exact product scale, hand count, and cap/lid state required at that cut.
- **Segment Timing & Chaining**:
  - Frame counts must satisfy **`4n + 1`** at **`16 fps`** (default `85` frames = `5.3 s`; rapid TVC/food cuts use `33`–`65` frames = `2.1`–`4.1 s`). Total video duration after overlaps must land within **`15.0`–`21.0 s`**.
  - `start`: Segment 1 starts on panel `0` (`K0`). Subsequent segments use `"prev"` (chaining the previous segment's last `8` frames seamlessly) or an integer panel index `0..7` (hard cut). Each segment ends on `end_panel` (`0..7`) or runs free (`null`).
  - VACE renders **silent video only** (`CreateVideo` has no audio input). Never describe sound effects, dialogue, or music in VACE prompts; `ltx_director.py` mixes the selected CC0 soundtrack via `ffmpeg` after download.

---

## 2. Writing a Segment Prompt (`120–180` Words, Present Tense)

1. **Deterministic Paragraph Structure**: Write a single present-tense paragraph (`120–180` words) in this exact order:
   - **Film stock & lens line** → **Camera behavior sentence** → **Hands / subject sentence** → **Verbatim product identity sentence** → **Directional lighting sentence** → **ONE continuous physical action** leading from the start state to `end_panel`.
2. **Verbatim Anchor Reuse**: Copy the camera, hands/subject, and product identity sentences **word-for-word** across every segment prompt and the storyboard prompt(s) so color temperature, wardrobe, and packaging typography never drift.
3. **Controlled Rotation**: 3D rotation is VACE's core strength (`hero` turntables, `unbox` reveals), but restrict each segment to **one smooth rotation** around an explicitly named axis (*"a smooth quarter turn clockwise around its vertical axis"*) whose final angle matches `end_panel`.
4. **Explicit Invariants & Positive Phrasing**:
   - Explicitly lock stationary props (*"the matte black cap rests motionless on the oak table to the LEFT"*).
   - Describe desired surfaces positively (*"plain smooth clear glass bottle"*) rather than negating missing parts.
   - **Forbidden tokens**: Never write `"nozzle"` (Qwen/Wan draws a curved kettle spout; write *"tiny flat mist spray head"* instead) and never append `"no logo"` in storyboard tails (it erases real product branding). No timestamps (`0:00–0:03`) inside a 5-second segment.

---

## 3. Storyboard Prompt Rules (`2×2` Panels)

- Restate the exact product identity and explicitly count limbs and objects (*"exactly two hands and exactly one sneaker in every panel"*).
- Pre-draw every state change before a video segment transitions into it (lid removed, zipper opened, burger halved, outsole visible).
- Include *"the WHOLE product remains in frame at the same real-world scale"* whenever hands manipulate a cap, button, or strap so Qwen does not zoom into an unanchorable macro crop.
- Keep camera angle and focal length unified across all 4 panels of achained flow; vary framing across `K0..K7` only on intentional hard-cut genres (`tvc`, `food`, `tech`, `compare`).

---

## 4. Lip-Synced Talking-Review Rules (`Wan 2.2 S2V 14B` — `ugc` Genre)

- **Presenter Synthesis (`presenter_prompt`)**: Qwen Image 2.1 generates one natural smartphone-framed portrait of a creator holding the exact product (`Image 1`) at chest/chin level; `build_ugc_flow.py` routes this single image into all `3`–`4` S2V chunks (`77` frames/chunk = `14.4 s` or `19.3 s` @ `16 fps`).
- **Speaking Motion (`prompt`)**: Keep camera framing steady (front-facing handheld phone, natural eye contact with the lens — `ugc` is the **only** genre where looking into the camera is expected), subtle head nods, natural blinking, and small hand gestures holding the product steady without occluding the face or mouth.
- **Voice Track Requirement (`voice_audio`)**: Must be clean speech (`mp3`/`wav`) at least as long as the rendered chunk duration (`>= 20 s` for 4 chunks) with minimal background music so `wav2vec2` mouth articulation stays crisp.

---

## 5. Anti-"Plastic" Realism Checklist (Mandatory Across All Genres)

| Synthetic CGI Tell | Required Prompt Antidote |
| :--- | :--- |
| Airbrushed / waxy skin & surfaces | `"real skin with fine pores, knuckle creases, faint veins, slightly dry fingertips"`; micro-scratches, paper grain, dust motes, condensation droplets |
| Flat sourceless lighting | Single directional key light: `"low morning window light from the left, one side lit, soft shadows falling to the right"` |
| Robotic tripod / gimbal motion | `"handheld 35mm camera: the frame drifts and bobs slightly, focus breathes and lands a fraction of a second late"` (`hero` turntable: `"locked tripod with faint focus breathing"`) |
| Weightless objects | Physical mass cues: `"her wrists dip slightly under its weight"`, `"liquid sloshes inside"`, `"sets it down with a solid cushioned settle"` |
| Sterile showroom table | Lived-in context: `"scuffed oak tabletop, a linen napkin edge, framing slightly off-centre"` |
| Drifting product scale | Explicit anatomical anchors: `"bottle about the height of her palm"`, `"backpack spans her upper torso"` |
| Uncanny camera stare | `"she keeps her eyes on the product and never looks at the camera"` *(except `ugc`)* |
| CGI trigger buzzwords | Omit `"photorealistic, 8k, hyper-detailed, tack-sharp"`; use `"shot on 35mm film, Kodak Portra 400, natural grain, unretouched real photograph, not a 3D render"` |

*(Note: `build_vace_flow.py` automatically injects Chinese + English anti-CGI negative prompts: `塑料质感, 蜡像质感, 磨皮, CG渲染, plastic skin, waxy, airbrushed, CGI, 3D render`.)*

---

## 6. Commercial TVC Structure: Google ABCD Framework (`tvc` Genre)

1. **Attention (`0–2 s` Hook)**: Open immediately on high-contrast physical motion (ice cubes splashing, rain hitting speaker mesh) — at least 2 distinct cuts within the first 5 seconds.
2. **Branding (`0–5 s` Early Product Presence)**: Display the unmistakable product silhouette and real brand mark clearly inside the opening hook.
3. **Connection (`5–15 s` Problem → Action → Proof)**: Dedicate each hard-cut scene (`33`–`65` frames, `start = panel_index`) to **one clear visual beat** showing human context and tangible product proof.
4. **Direction (`15–20 s` Clean Pack Shot)**: Hold a calm, well-lit 4–5 second closing hero shot with clean negative space reserved for post-production logo lockup and CTA typography.
