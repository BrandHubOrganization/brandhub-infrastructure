# Thư viện flow video sản phẩm (`flows/`)

- Quay lại: [Wan VACE Worker & Bundle Manual](../README.md) · [GPU Workers](../../README.md)
- Quy tắc viết prompt & chống "nhựa": [`../wan-vace-bundle/director/prompt-rules-wan.md`](../wan-vace-bundle/director/prompt-rules-wan.md)

Mọi flow ComfyUI nằm tại đây, mỗi thể loại một thư mục: kịch bản JSON (nguồn), flow `*_GUI.json` (build ra) và ảnh mẫu.
Build lại toàn bộ + đóng zip: chạy [`../package_vace.py`](../package_vace.py) (`python package_vace.py` từ thư mục `gpu-workers/wan-vace`, xuất `wan-vace-bundle.zip`).

| Thể loại | Thư mục | Flow | Sản phẩm | Độ dài | Cách dựng |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Unbox / trải nghiệm POV** | [`unbox/`](unbox/) | `WanVACE_unbox_sneaker_20s_GUI`, `WanVACE_unbox_perfume_20s_GUI` | giày, nước hoa | 20 s | 4 đoạn nối, tay cầm, xoay, mở nắp |
| **Hero shot / turntable** | [`hero/`](hero/) | `WanVACE_hero_watch_20s_GUI` | đồng hồ | 20 s | 4 đoạn nối, mỗi đoạn xoay ¼ vòng: mặt số → núm bên phải → đáy → cạnh trái trơn → về mặt số (lặp vòng) |
| **TVC (khung ABCD)** | [`tvc/`](tvc/) | `WanVACE_tvc_tumbler_20s_GUI` | bình giữ nhiệt | 20 s, 16:9 | 6 cảnh cắt cứng: hook đá rơi (logo ngay 2 s đầu) → leo núi nóng, lau mồ hôi → lấy bình ra uống → hoàng hôn vẫn còn đá → cận tay cầm → pack shot đẩy máy, chừa chỗ logo |
| **Lifestyle** | [`lifestyle/`](lifestyle/) | `WanVACE_lifestyle_headphones_16s_GUI` | tai nghe | 16 s | 3 đoạn nối, đi trong công viên, quay từ phía sau (không thấy mặt) |
| **ASMR / macro** | [`asmr/`](asmr/) | `WanVACE_asmr_lipstick_16s_GUI` | son môi | 16 s | 3 đoạn nối: rút nắp → vặn son lên → quẹt lên cổ tay |
| **Before / After** | [`before-after/`](before-after/) | `WanVACE_before_after_backpack_20s_GUI` | balo | 20 s | 4 đoạn nối: balo rỗng + đồ → nhét áo, laptop → kéo khóa, dựng đứng → xách lên thử nặng |
| **UGC review có nói** | [`ugc/`](ugc/) | `S2V_ugc_sunscreen_GUI` | kem chống nắng | 19 s | Wan S2V 4 khúc, khớp môi theo file giọng đọc upload (≥ 20 s) |
| **Đồ ăn: food hero** | [`food/`](food/) | `WanVACE_food_burger_19s_GUI` | burger phô mai | 19 s | 6 cảnh cắt, mỗi cảnh 1 chuyển động: xèo xèo → phô mai chảy → ấn bánh → cắt đôi bốc khói → kéo phô mai → hero đẩy máy |
| **Công nghệ: demo 1 tính năng** | [`tech/`](tech/) | `WanVACE_tech_speaker_20s_GUI` | loa JBL | 20 s | 6 cảnh cắt: mưa đập lên loa (logo 2 s đầu) → tiệc bị mưa → loa vẫn phát dưới mưa → cầm quai nhấc lên → nhảy dưới hiên → pack shot tạnh mưa |
| **So sánh** | [`compare/`](compare/) | `WanVACE_compare_knife_19s_GUI` | dao bếp | 19 s | 7 cảnh cắt qua lại: dao rẻ (ánh lạnh) vs dao mình (ánh ấm) với cà chua, giấy, bánh mì → hero |
| **Thời trang: lookbook** | [`fashion/`](fashion/) | `WanVACE_fashion_dress_19s_GUI` | váy sequin đen | 19 s | Ngồi cầm váy trên móc → mặc vào catwalk xoay → cận vuốt tóc chỉnh dây → selfie gương. Có thể thêm ảnh người mẫu (`extra_images`) |
| **Nội thất: tour phòng** | [`home/`](home/) | `WanVACE_home_armchair_20s_GUI` | ghế bành | 20 s, 16:9 | 4 đoạn nối: đi từ cửa vào → vòng quanh ghế → cận vải và chân gỗ → có người ngồi đọc sách, nắng chuyển vàng |

**Bảng 4 góc (turnaround):** mọi flow VACE có node `"Turnaround 4 góc sản phẩm"`: Qwen vẽ sản phẩm từ 4 phía (lưu ở `output/video/turnaround*.png`), rồi đưa vào mọi storyboard làm ảnh 2, để khung nào lộ mặt sau, đế, nắp... vẽ đúng thay vì đoán. VACE vẫn dùng ảnh sản phẩm gốc làm tham chiếu. 4 góc khai báo ở trường `views` trong kịch bản.

Ảnh sản phẩm mẫu (ngoài giày, nước hoa) lấy từ Wikimedia Commons, giấy phép tự do, chỉ để test.

Mọi flow dài 15–20 s. TVC và ASMR chỉ xuất hình: nhạc, tiếng, chữ, logo ghép thêm ở khâu dựng hậu kỳ.

Quy tắc chống "nhựa" và khung TVC: xem [`../wan-vace-bundle/director/prompt-rules-wan.md`](../wan-vace-bundle/director/prompt-rules-wan.md).

## Kịch bản JSON (VACE — [`../build_vace_flow.py`](../build_vace_flow.py))
- `extra_images` (ảnh phụ cho storyboard, ví dụ ảnh người mẫu: thành image 3 sau turnaround), `views` (4 góc cho turnaround, bỏ trống = không vẽ), `product_name`, `size` `[rộng, cao]` (mặc định `[576, 1024]`), `storyboard_prompt` (hoặc `storyboard_prompts` nhiều lưới → `K0..K7...`).
- Mỗi `segments[i]`: `prompt`, `end_panel` (số hoặc `null`), `start`: `"prev"` (nối 8 khung, mặc định), số khung (cắt cảnh), hoặc `"free"`.

## Video bị "nhựa": nguyên nhân và cách giảm
1. Khung storyboard do Qwen vẽ: VACE giữ gần nguyên khung ghim. Kịch bản mới đã thêm chi tiết bề mặt (vân da, nếp nhăn, bụi nhẹ).
2. LoRA `lightx2v` 4 bước làm mịn quá: dùng chế độ chất lượng cao 20 bước (xem [`../README.md`](../README.md)).
3. Hậu kỳ: thêm film grain nhẹ `ffmpeg -i in.mp4 -vf noise=alls=6:allf=t out.mp4`.
