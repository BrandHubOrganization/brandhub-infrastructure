# Tổng hợp kiến thức dựng video (10/11/2026)

Gom mọi nguồn anh đã sưu tập cho việc dựng video, nói rõ agent dựng tự động trên web đã dùng được gì và còn thiếu gì.

## 1. Các nguồn

| Nguồn | Nằm ở đâu | Nội dung chính | Agent web dùng chưa |
|---|---|---|---|
| **Bộ thể loại DemoVideo** | `F:\self\DemoVideo\docs\the-loai-video\` (README, 1-ke-chuyen … 5-microdrama, khung-cau-truc) | 19 thể loại: mục đích, thời lượng, nhịp cắt, khung theo mốc giây, chuyển cảnh, màu, nhạc, tiếng động, prompt dựng, phần "Kiểm khung" | **Có.** Đóng gói trong `brandhub-ai-service/app/resources/video-edit/docs/`. Agent nhận mục khớp thể loại (ẩm thực/đồ uống đã thêm từ khóa matcha, trà, cà phê, latte) |
| **Quy trình dựng chung DemoVideo** | `docs/video-edit/SKILL.md` + `references/` (QUY_TRINH, DUNG_THEO_THE_LOAI, DO_HOA_VA_AM_THANH, CONG_CU…) | Bước 0 soát nguồn → mục đích → dựng thô → chuyển cảnh → chữ → màu → 4 lớp âm thanh → QC → bàn giao | **Có**, chắt lọc vào `editing-playbook.md` |
| **Sổ lỗi DemoVideo** | `tools/edit/LOI_DA_GAP.md` | 13 quy tắc: thời gian tính bằng frame, đếm frame trước khi xuất, chữ không chồng nhau, không dùng sed cho regex… | **Có**, phần liên quan nằm trong playbook mục 8 và `server-lessons.md` |
| **Thư viện tiếng động** | `DemoVideo/tools/edit/sfx/` (72 tiếng CC0/public domain, NGUON.md) | Ẩm thực, chuyển cảnh, nhấn chữ, va chạm, không khí… | **Có** (đã đóng gói vào worker) |
| **Nhạc CC0 Video Space Lab** | `video-editor-lab/resources/assets/music`, worker `resources/product-video/music` | 5 bài kèm mood và BPM | **Có** |
| **Font OFL** | thư viện font Video Space | 24 font, worker có 6 (Be Vietnam Pro, Oswald, Montserrat, Playfair Display, Bangers, Quicksand) | **Có** |
| **HyperFrames 0.8.170 + GSAP** | DemoVideo `node_modules`, worker `tools/hyperframes` | Chữ và đồ họa động bằng HTML/GSAP, render nền trong suốt | **Có, qua 5 mẫu viết sẵn**: kinetic-slam, mask-reveal, highlight-sweep, cta-pill, editorial |
| **EditAtlas** (MCP `https://edit.trysometh.ing/mcp`, REST `/api/v1`) | Dịch vụ công khai | Kỹ thuật quay/dựng (match cut, match on motion, speed ramp, foley, b-roll đồ uống, macro), mẫu cấu trúc (Pour Ritual cho đồ uống, Meal Map, Recipe in Verbs), style (Beat Punch Cut…), SFX | **Một phần**: trợ lý chat đã lấy template + style theo chủ đề drink/food. Agent server dùng kiến thức đã chắt vào playbook, chưa gọi EditAtlas lúc chạy |
| **Skill cài trong Claude Code** | `~/.claude/skills`, plugin | `fk-sound-design`, `fk-cinematic-transitions`, `fk-camera-guide`, `fk-action-choreography`, `taste`, `video-editing`, `opus-video-prompts` (703 prompt motion), bộ `hyperframes:*`, `seecut-vn`, `remotion-video-creation`, `motion-*` | Gián tiếp: các nguyên tắc chuyển cảnh và âm thanh đã có trong tài liệu DemoVideo nên đã vào playbook. Prompt `opus-video-prompts` chưa dùng |
| **Bản dựng chuẩn của Claude DemoVideo** | `video-editor-lab/test-assets/matcha-studio-20261031/ban-dung-claude/` (HANDOFF.md, dung.py) | 3 shot dài nối khớp mạch; tránh frame lỗi 175; chữ kiểu tạp chí; foley rót khớp frame; nhạc né foley; chỉnh màu nhẹ; −14,3 LUFS | **Có**, dùng làm thước đo chất lượng trong playbook |

**Về lệnh `claude mcp add --transport http --scope user EditAtlas https://edit.trysometh.ing/mcp`:** lệnh này chỉ thêm EditAtlas cho **Claude Code trên máy anh**, không cấp cho backend. Worker và trợ lý chat gọi bản REST của cùng dịch vụ. Tôi chưa chạy lệnh vì nó sửa cấu hình chung của anh.

## 2. Nguyên tắc cốt lõi (rút gọn từ tất cả nguồn)

1. **Chọn thể loại theo điều người xem phải cảm thấy hoặc làm**, không theo nội dung footage.
2. **Soát nguồn trước khi dựng:** frame giật, khung đen, đứng hình, chữ dính sẵn trong hình, tay méo, giật ở frame đầu clip AI.
3. **Chỉ cắt khi cắt có ích.** Một hành động liền mạch (rót, lộ diện, nhấc ly) là nhân vật chính, cần giữ trọn. Không cắt giữa hai thời điểm của cùng một góc máy. Nối clip bằng match cut hoặc cut on motion.
4. **Chuyển cảnh mang nghĩa:** cắt (giữ nhịp), hòa hình (thời gian trôi), tối dần (kết chương), trắng lóa (ký ức/va chạm), trượt (bước tiếp theo). Không chồng hiệu ứng lên mọi nhát.
5. **Chữ:** ít chữ, đặt vào vùng trống của khung hình đúng lúc đó. Nằm trong vùng an toàn 9:16 (khoảng 12–75% chiều cao, tránh mép phải). Các lớp chữ không chồng lên nhau. Kiểu chữ hợp thể loại: editorial cho sản phẩm cao cấp, chữ "slam" cho affiliate/hype.
6. **Âm thanh 4 lớp:** thoại, foley, không khí, nhạc. Foley khớp đúng frame hành động. Nhạc né thoại (ít nhất 10 LU) và né foley. Master −14 LUFS, true peak ≤ −1 dBTP.
7. **Một grade màu chung** cho mọi clip, vì clip AI lệch màu nhau. Không làm sai màu sản phẩm.
8. **Xem lại như người xem** ở mọi chữ, mọi điểm nối và đoạn kết. QC đạt chưa có nghĩa là đẹp.

## 3. Khung cho quảng cáo đồ ăn/đồ uống (mục 13–14 DemoVideo + EditAtlas Pour Ritual)

| Mốc | Phần | Hình | Âm thanh | Chuyển |
|---|---|---|---|---|
| 0–3 s | Hook: hành động đẹp nhất hoặc thành phẩm, tên món | Cận, hành động đang diễn ra ngay frame đầu | Foley của hành động, nhạc vào nhẹ | — |
| 3–15 s | Các bước (rót, khuấy, vân lan) | Mỗi bước một shot trọn, chậm nhẹ ở khoảnh khắc ngon nhất | Foley khớp frame, nhạc né | Cắt khớp mạch / match cut |
| 15–20 s | Thành phẩm + lời mời | Tay nhấc ly, giữ hình | Nhạc dâng, fade out | Cắt hoặc hòa hình |

Kiểm khung: 3 giây đầu có hành động hoặc thành phẩm không? Âm thật có rõ hơn nhạc không? Có đúng một thông điệp và một lời mời không?

## 4. Đã đưa vào agent web (10/11/2026)

- `editing-playbook.md` thay các luật ép cắt cũ (6–12 shot, bắt buộc khớp beat, punch). Luật cũ chính là nguyên nhân jump cut ở lần chạy 3.
- Soát nguồn: `detect_scenes` trả số frame, cắt cảnh, frame giật, khung đen, đứng hình. Đã kiểm trên matcha: phát hiện đúng clip 02 frame 175 và clip 01 frame 181.
- `view_frames` ghi số frame lên từng ảnh.
- Cổng kiểm tra khi nộp plan:
  - shot không được đi qua lỗi nguồn hay cắt cảnh;
  - chặn jump cut (2 shot cùng góc máy không liền mạch);
  - chữ không chồng nhau;
  - phải xem bản nháp trước khi nộp.
- Âm thanh: `duck_music`, `lowpass_hz`, `fade_frames` cho foley; nhạc né foley.
- Chữ: mẫu HyperFrames `editorial` (dòng phụ + tiêu đề serif, không nền, bóng mờ tự đổi theo màu chữ, căn trái/giữa); `render_preview` có tùy chọn xem cận vùng chữ.
- Màu: `grade` (contrast, saturation, độ ấm) áp cho mọi clip.

## 5. Còn thiếu

- Video mẫu của brand (`BRAND_REFERENCE` trong repository) chưa được đưa cho agent xem.
- EditAtlas chưa được agent server gọi lúc chạy (hiện chỉ dùng kiến thức đã chắt lọc).
- Chuyển cảnh mới chỉ có cut/dissolve/dip/slide. Bảng DemoVideo còn iris, whip, zoom, wipe, gray, light leak.
- Chưa crop/pan có điểm lấy nét để tạo cận cảnh từ cùng một clip.
- Thư viện nhạc mới có 5 bài.
