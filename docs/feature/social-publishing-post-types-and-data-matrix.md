# QUY ĐỊNH & THÔNG SỐ ĐĂNG BÀI MẠNG XÃ HỘI

## 1. Hỗ Trợ Thể Loại Bài Đăng Theo Từng Nền Tảng Mạng Xã Hội

| Thể loại bài đăng | Facebook | Instagram | Threads | TikTok |
| :--- | :---: | :---: | :---: | :---: |
| **`(TEXT)`** | Hỗ trợ | Không hỗ trợ | Hỗ trợ | Không hỗ trợ |
| **`(PHOTO)`** | Hỗ trợ | Hỗ trợ | Hỗ trợ | Không hỗ trợ |
| **`(CAROUSEL)`** | Hỗ trợ | Hỗ trợ | Hỗ trợ | Không hỗ trợ |
| **`(VIDEO)`** | Hỗ trợ | Hỗ trợ | Hỗ trợ | Hỗ trợ |

---

## 2. Chi Tiết Thông Số Kỹ Thuật & Giới Hạn Dữ Liệu Từng Nền Tảng

| Tiêu chí / Ràng buộc | Facebook | Instagram | Threads | TikTok |
| :--- | :--- | :--- | :--- | :--- |
| **Limit (Caption + Hashtags)**<br>*(Tính theo 1 ký tự Unicode; tiếng Anh & tiếng Việt có dấu đều tính 1 chữ = 1 ký tự)* | Tối đa **20.000 ký tự** (theo chuẩn DB hệ thống & FE Editor) | Tự động cắt còn **2.200 ký tự** (thêm `"..."` ở cuối nếu vượt quá) | Tự động cắt theo khoảng trắng gần nhất còn **500 ký tự** (kèm `"..."`; báo lỗi nếu sau khi cắt `< 100` ký tự) | Tự động cắt còn **4.000 ký tự** |
| **Giới hạn Hashtags** | Tối đa **30 hashtags/bài** (`<= 100` ký tự/tag). Khi xuất bản tự động nối vào cuối Caption (`\n\n#tag1 #tag2`) và tính chung vào tổng ký tự. | Nằm chung trong giới hạn **2.200 ký tự** của `caption` (tối đa 30 hashtags). | Nằm chung trong giới hạn **500 ký tự** của `text` (tối đa 30 hashtags). | Nằm chung trong giới hạn **4.000 ký tự** của `title` (tối đa 30 hashtags). |
| **Số lượng Media / Bài** | **0 (Text)**, **1 Video** (`<= 200MB`), **1 Ảnh** (`<= 20MB`), hoặc **Nhiều Ảnh** (`Carousel: not limit` - chỉ ảnh, no video) | **1 Ảnh** (`<= 20MB`), **1 Video (Reels)** (`<= 200MB`), hoặc **2–10 Ảnh/Video** (Carousel) | **0 (Text)**, **1 Ảnh** (`<= 20MB`), **1 Video** (`<= 200MB`), hoặc **2–20 Ảnh/Video** (Carousel) | Bắt buộc đúng **1 Video** (Tối đa **200MB** theo trần Kho lưu trữ Repository) |
| **Rate Limit & Cơ chế đồng bộ** | `0.5 request/giây` (1 call / 2s), phản hồi đồng bộ ngay lập tức | `0.5 request/giây`, bất đồng bộ (Tạo Container -> Poll mỗi 2s tối đa 30 lần / 60s -> Publish) | `0.5 request/giây`, bất đồng bộ (Tạo Container -> Poll mỗi 3s tối đa 20 lần / 60s -> Publish) | `0.5 request/giây`, khởi tạo phiên upload (`init`) -> `PUT` binary chunk |

---

## 3. Phân Loại Thể Loại Bài Đăng Mạng Xã Hội

| Mã thể loại | Định dạng Upload vào hệ thống (`MaterialUploadPolicy` & `MaterialContentValidator`) |
| :--- | :--- |
| **`(TEXT)`** | Không đính kèm file (chỉ `contentText` + `hashtags`). |
| **`(PHOTO)`** | **Chỉ cho phép 3 định dạng ảnh** (`<= 20 MB/file`, tối đa `40MP`):<br>- `image/jpeg` (`.jpg`, `.jpeg`)<br>- `image/png` (`.png`)<br>- `image/webp` (`.webp`)<br>*(Lưu ý: Frontend tự động nén/convert ảnh upload sang `.webp` qua `convertImageFileToWebp`)*. |
| **`(CAROUSEL)`** | Kết hợp nhiều file từ chuẩn **`IMAGE`** (`.jpg`, `.jpeg`, `.png`, `.webp` - `<= 20 MB/file`) hoặc **`VIDEO`** (`.mp4`, `.mov` - `<= 200 MB/file`). |
| **`(VIDEO)`** | **Chỉ cho phép đúng 2 định dạng video** (kiểm tra cấu trúc ISO box `moov`/`mdat`/`trak`):<br>- `video/mp4` (`.mp4`)<br>- `video/quicktime` (`.mov`)<br>*(Giới hạn đồng bộ toàn hệ thống theo trần Repository: **`<= 200 MB/file`** tại cả Post Editor Dropzone, Kho lưu trữ Repository và khi xuất bản lên 4 MXH)*. |
| **`(OTHER)`** | Các định dạng tài liệu trong kho (`pdf`, `txt`, `doc`, `docx`, `xls`, `xlsx` - chỉ dùng cho Task/Repository, không đăng MXH). |

---

## 4. Quy Định Theo Vị Trí Hiển Thị (`FEED`, `REELS`, `STORY`)

| Nền tảng | `FEED` | `REELS` | `STORY` |
| :--- | :--- | :--- | :--- |
| **Facebook Page** | - **Text**: max 20.000 ký tự<br>- **1 Ảnh**: max 20MB/file<br>- **Carousel**: (not limit) (chỉ ảnh, no video)<br>- **1 Video**: max 200MB/file (thời lượng tối đa 240 phút) | - **1 Video**: max 200MB/file (thời lượng `< 90s`, tỉ lệ dọc `9:16`)<br>- Hiện tại khi đăng 1 Video lên Facebook, code đẩy vào `/{pageId}/videos` (Facebook tự hiển thị trên cả Feed & tab Video/Reels nếu video dọc `9:16 < 90s`). | - **1 Ảnh**: max 10MB (FB) / 20MB (Repo) qua `/{pageId}/photo_stories`.<br>- **1 Video**: max 200MB (Repo), thời lượng `3 giây – 60 giây (1 phút)` qua `/{pageId}/video_stories`.<br>- Không hỗ trợ Text thuần, Carousel, Caption hoặc gắn thẻ bài Feed (do giới hạn của Meta Content Publishing Graph API).<br>- Không gắn được Music Sticker (chỉ phát nhạc có sẵn ở trong file video). |
| **Instagram** | - **Text**: không hỗ trợ<br>- **Caption + Hashtag**: max 2.200 ký tự<br>- **1 Ảnh**: max 8MB (IG API) / 20MB (Repo)<br>- **Carousel**: (max 10 items) (ảnh + video)<br>- **1 Video (trong Carousel)**: max 200MB/file (`3s – 60s`) *(Nếu đăng 1 Video lẻ thì tự động chuyển sang luồng REELS)* | - **1 Video duy nhất**: max 200MB/file (`3s – 15 phút`, khuyến nghị `15s – 90s`) qua `media_type=REELS`.<br>- **Caption + Hashtag**: max 2.200 ký tự.<br>- Hiển thị ở cả tab Reels và lưới Feed của Instagram. | - **1 Ảnh**: max 8MB (IG API) / 20MB (Repo), tỉ lệ khuyến nghị `9:16` qua `media_type=STORIES`.<br>- **1 Video**: max 100MB (IG API) / 200MB (Repo), thời lượng `3 giây – 60 giây (1 phút)` qua `media_type=STORIES`.<br>- Không hỗ trợ Text thuần, Carousel, Caption hoặc gắn thẻ bài Feed (do giới hạn của Meta Content Publishing Graph API).<br>- Không gắn được Music Sticker (chỉ phát nhạc có sẵn ở trong file video). |
| **Threads** | - **Text**: max 500 ký tự<br>- **1 Ảnh**: max 8MB (Threads API) / 20MB (Repo)<br>- **Carousel**: (max 20 items) (ảnh + video)<br>- **1 Video**: max 200MB/file (max `5 phút`) | - **Không có tab Reels riêng**<br>*(Mọi video ngắn đều đăng với `media_type=VIDEO` lên luồng Feed chính)*. | - **Không hỗ trợ**<br>*(Bản thân nền tảng Threads của Meta không có tính năng Story 24h)*. |
| **TikTok** | - **Text thuần / Ảnh tĩnh / Carousel**: Không hỗ trợ<br>- **Short Video / Reels**: Chính là luồng Video ở cột `REELS` bên cạnh. | - **1 Video duy nhất**: max 200MB/file (`3s – 60s` Direct Post `FILE_UPLOAD` / tối đa `10 phút` TikTok API).<br>- **Caption + Hashtag**: max 4.000 ký tự. | - **Không hỗ trợ**<br>*(TikTok Content Posting API v2 không mở endpoint đăng Story 24h)*. |
