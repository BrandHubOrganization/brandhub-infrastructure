# Prompt rules for Wan 2.2 Fun VACE product videos

Carried over from the LTX renders (still true) plus what changes with VACE.

## Pipeline
- Storyboard: ONE 2x2 Qwen grid from the product photo = K0..K3. Panels are pinned frames: VACE keeps them almost
  unchanged, so every panel must already be correct (product, hands, cap state).
- Video: 4 segments of 85 frames at 16 fps (5.3 s). Segment 1 starts on K0; segments 2-4 start on the previous
  segment's last 8 frames. Each segment ends on `end_panel` (0-3) or runs free (`null`).
- The product photo is the VACE reference image in every segment: a clean product shot on a plain background works best.
- No audio. Do not write sound in the prompts.

## Writing a segment prompt (Wan)
- One paragraph, about 120-180 words, present tense: film line, camera sentence, hands sentence, product identity,
  light, then ONE action that leads from the start state to the end panel. No timestamps: a segment is only 5 s.
- Reuse the camera, hands and product sentences word for word in every segment and in the storyboard.
- Rotation is allowed (this is why VACE was chosen), but one smooth turn per segment, and the end panel must show the
  turned state. Name the axis: "a smooth quarter turn around its vertical axis".
- State what must not change ("the black cap lies still on the table on the LEFT").
- Positive phrasing: describe the wanted surface ("plain smooth clear glass"), not what is absent.
- Do not write "nozzle" (drawn as a curved spout) or "no logo" in the storyboard tail (it erases real logos).

## Storyboard
- Restate the product identity; count objects ("exactly two hands and exactly one sneaker").
- Draw every hidden part before a segment needs it (cap off, spray head, outsole).
- "the WHOLE product ... the same size" whenever hands work on a detail.
- Same camera position in all four panels.

## Chống "nhựa" (checklist áp cho mọi kịch bản)
| Dấu hiệu giả | Viết vào prompt |
|---|---|
| Da/bề mặt quá mịn | "real skin with fine pores, knuckle creases, slightly dry fingertips"; vật liệu có xước, bụi, dấu vân tay |
| Ánh sáng không nguồn | Một nguồn có hướng: "low window light from the left, one side lit, shadows fall to the right" |
| Máy quá mượt | "handheld: the frame drifts and bobs slightly, focus breathes and lands a moment late" (hero turntable: chỉ "faint focus breathing") |
| Không trọng lượng | "her wrists dip as she lifts it", "liquid sloshes", "sets it down with a soft heavy thud" |
| Quá sạch, quá cân | "a coffee ring, a few crumbs, framing slightly off-centre" |
| Sai tỉ lệ | Neo kích thước: "about the height of her palm", "she is about half the frame height" |
| Nhìn vào máy | "she never looks at the camera" (trừ UGC: nói với máy là đúng thể loại) |
| Chữ khiến ra CG | Bỏ "photorealistic, tack-sharp, high-resolution"; dùng "shot on a 35mm film camera, Kodak Portra 400, visible grain, unretouched, a real photograph, not a render" |
| Câu chuyện | Trường `story` trả lời "để làm gì?" trước khi viết prompt |
Negative prompt của builder đã thêm: 塑料质感, 蜡像质感, 磨皮, CG渲染, plastic skin, waxy, airbrushed, CGI, 3D render.
Âm thanh: VACE câm, SFX thêm lúc dựng.

## TVC: khung Google ABCD (Attention, Branding, Connection, Direction)
1. Hook 0-2 s: nhiều hơn 2 khung hình trong 5 s đầu, chỉ hình ảnh.
2. Brand trong 5 s đầu (logo/sản phẩm thấy rõ ngay ở hook).
3. Vấn đề → dùng sản phẩm → bằng chứng → chi tiết: mỗi cảnh 1 ý, 2-4 s (`frames` 33-65), cắt cứng (`start` = số khung).
4. Pack shot cuối 4-5 s, giữ yên, chừa khoảng trống cho logo + câu kêu gọi.
