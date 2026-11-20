# Video sản phẩm bằng Wan 2.2 (Fun VACE + S2V), không tiếng trừ UGC

## Thuê máy (Vast)
- GPU 48 GB VRAM trở lên (L40S, A6000, RTX 6000 Ada); 80 GB (A100/H100) chạy nhanh hơn.
- RAM 96 GB trở lên, ổ đĩa 160 GB (model khoảng 92 GB; bỏ UGC bằng `NO_S2V=1` thì khoảng 75 GB).

## Cài và chạy
```bash
cd /workspace && unzip -o wan_vace_bundle.zip && bash wan_vace_bundle/setup.sh
```
Mở ComfyUI → Workflows → mỗi thể loại một thư mục (unbox, hero, tvc, lifestyle, asmr, before_after, ugc) → chọn flow → Run.
Danh sách thể loại: `flows/README_VI.md`.

## Flow VACE (unbox, hero, tvc, lifestyle, asmr, before_after)
1. **Storyboard**: Qwen vẽ lưới 2x2 từ ảnh sản phẩm → khung K0..K3 (cùng cỡ video). Lưu ở `output/video/storyboard*.png`.
2. **Ảnh tham chiếu**: ảnh sản phẩm gốc, đệm nền trắng, đưa vào **mọi** đoạn để giữ đúng sản phẩm.
3. **Các đoạn (NODE 1..n)**, mỗi đoạn 85 khung, 16 fps (5.3 s). Mỗi đoạn bắt đầu bằng:
   - **8 khung cuối của đoạn trước** (nối liền, mặc định), hoặc
   - **một khung storyboard** = cắt cảnh (TVC), và kết thúc ở khung storyboard đã chọn hoặc tự do.
4. Ghép lại → `output/video/WanVACE_*`.

## Flow UGC (người review nói, khớp môi)
- Model Wan 2.2 S2V. Qwen vẽ ảnh người review cầm sản phẩm từ ảnh sản phẩm.
- **Upload file giọng đọc** (mp3/wav, ≥ 20 s) vào node "GIỌNG ĐỌC" trước khi chạy.
- 4 khúc x 77 khung = 19.3 s (số khúc: trường `chunks` trong kịch bản). File giọng nên dài ≥ 20 s.

## Sửa prompt / tạo flow mới
- Prompt mỗi đoạn: ô **"NODE n ... PROMPT"** trong khung xanh. Storyboard: node **"Storyboard"**.
- Sửa kịch bản JSON trong `flows/<thể loại>/` rồi build lại cả thư viện (trên máy có Python, không cần GPU):
```bash
python package_vace.py
```
Quy tắc viết prompt: `director/PROMPT_RULES_WAN.md`.

## Chất lượng cao hơn, bớt "nhựa" (chậm hơn khoảng 5 lần)
Tắt (bypass) 2 node "lightx2v 4-step LoRA", rồi ở 2 sampler mỗi đoạn đặt steps 20, cfg 3.5, chia bước 0-10 / 10-20; shift giữ 8.
