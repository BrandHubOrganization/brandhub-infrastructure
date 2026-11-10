# Caption dùng ngữ cảnh trend từ Neo4j và ChromaDB

Trạng thái: đề xuất để review, chưa được phép triển khai code. Ngày 2026-11-03.

## Mục tiêu và hiện trạng

Creator chọn một trend và tạo ba caption có ngữ cảnh thật, phù hợp brand/task/platform. Giữ luồng gen caption thường, refine/adapt, moderation và credit hiện có.

Đối chiếu repo AI: `content.py` tra `trend_id` qua `trend_fit/store.py` (event từ Redis, moment/format từ nguồn hiện hữu). `caption_service.knowledge_chunks` chỉ truy vấn tài liệu brand trong collection `brandhub_rag`, lọc `clientId`; chưa truy vấn `social_trend_chunks` cho caption. Neo4j có Trend/CrawledPost/Entity và liên kết BELONGS_TO/MENTIONS/ASSOCIATED_WITH. Chroma trend metadata có trendId, postId, runId, sourceUrl, platform và thời gian. Các field tồn tại trong code không đảm bảo dữ liệu cũ đã đầy đủ; cần audit trước.

## BA và acceptance criteria

| BA | Phạm vi | Tiêu chí |
|---|---|---|
| BA-01 | P0: chọn cách dùng trend | Giữ gen thường và dùng trend đã chọn. Chỉ khi có lựa chọn trend mới truy xuất trend; không tự gắn trend khác. |
| BA-02 | P0: ngữ cảnh Neo4j | Tra trendId chính xác; đọc tên, ngày, score và các nguồn/thực thể liên quan có bằng chứng. Không bắt buộc post có Entity mới đủ điều kiện, không mở rộng graph vô hạn. |
| BA-03 | P0: ngữ cảnh Chroma | Tìm nội dung theo topic + brand/task + trend được chọn; prefilter trendId và runId hợp lệ, loại trùng post/chunk. Không query toàn bộ rồi nhận trend không liên quan. |
| BA-04 | P0: chất lượng dữ liệu | Chỉ dùng nguồn của run đã công bố; loại test/replay namespace, run đang chạy/failed/interrupted và batch failed. Run partial chỉ dùng phần đã publish và thành công, hiển thị nhãn thiếu dữ liệu. |
| BA-05 | P0: thời gian | Mặc định trend sự kiện trong 7 ngày theo Asia/Ho_Chi_Minh; không gọi một trend cũ là đang hot. Moment/format giữ quy tắc hiệu lực hiện tại, không ép sang graph/chunk. |
| BA-06 | P0: phù hợp thương hiệu | Giữ brand voice, mục tiêu, audience, platform, kỹ thuật trend-fit và ba loại HOOK_DRIVEN/STORYTELLING/DIRECT_CTA. Không ép mọi thương hiệu vào sự kiện nhạy cảm. |
| BA-07 | P0: phân biệt nguồn | Giá, ưu đãi và cam kết sản phẩm chỉ lấy từ dữ liệu brand đã xác nhận. Bài crawl là tham khảo xã hội, không mặc định là sự thật đã kiểm chứng. Nội dung nguồn không được trở thành chỉ dẫn cho model. |
| BA-08 | P0: xem bằng chứng | Trả metadata nguồn để creator xem trend, thời gian, link nguồn và trạng thái đầy đủ/thiếu dữ liệu; phần này nằm ngoài caption. Không nói nguồn được dùng chỉ vì đã retrieve nếu không có bằng chứng cấp từng câu. |
| BA-09 | P0: thiếu dữ liệu/sự cố | Trả trạng thái có cấu trúc khi trend hết hạn, không có nguồn phù hợp, thiếu Chroma hoặc DB timeout. Không thay trend âm thầm. Với trend không khả dụng, creator chọn lại hoặc chuyển rõ ràng sang gen thường. |
| BA-10 | P0: bảo toàn thao tác sau gen | Lưu context snapshot/provenance của generation; refine/adapt tái dùng ngữ cảnh đã chọn, không tự chuyển sang trend mới khi dữ liệu cập nhật. Giữ moderation và credit/idempotency hiện có. |
| BA-11 | P0: phân quyền | Business xác thực actor/workspace rồi truyền client_id nội bộ. Brand KB luôn lọc tenant; trend công khai tách khỏi dữ liệu brand/private namespace. Không nhận Cypher, filter tùy ý hoặc nguồn secret từ frontend. |
| BA-12 | P0: vận hành và đánh giá | Có giới hạn context, timeout, concurrency, telemetry; không crawl trong request caption, không thêm model/reranker nặng trong bản đầu. Đánh giá liên quan, độ mới, grounding, latency và RAM trước rollout. |
| BA-13 | P1: tự đề xuất trend | Khi creator bật chế độ tự tìm, trả tối đa ba trend phù hợp để chọn/xác nhận. Không âm thầm bắt trend; score kết hợp ngữ nghĩa, độ mới và brand-fit, cần hiệu chỉnh bằng bộ đánh giá. |

## UI/UX và i18n

Tái sử dụng trang gen caption và picker hiện có; hiển thị ngắn gọn “Ngữ cảnh trend” cùng nguồn tham khảo, trạng thái thiếu dữ liệu và hành động chọn lại/gen thường. Không đưa tên database hoặc query vào luồng creator. Hỗ trợ vi/en song song, dự kiến namespace `ai.caption.trendContext.*`; chốt key sau audit UI. Dùng token/theme hiện có; kiểm tra light/dark, mobile và bàn phím. Không thêm account hoặc trang admin mới.

## Contract dự kiến, tương thích

Giữ endpoint `/api/v1/ai/content/captions/variants` và endpoint public đang được Business cung cấp; xác minh path đầy đủ khi triển khai. Tái dùng `trend_id`; không bắt caller cũ đổi payload khi gen thường. Response thêm trường optional cho context/provenance, không đổi caption text/hashtags contract hiện hữu. Business phải forward và persist các field mới thay vì làm mất metadata qua record DTO.

Context dự kiến: status (`used`, `insufficient`, `unavailable`, `not_requested`), trendId, publication/run revision, window/asOf, source references, selection policy version. Reference tối thiểu gồm postId, platform, sourceUrl, publishedAt/crawledAt, chunkId và loại nguồn. Nội dung prompt đầy đủ và cookie/token không trả ra response/log.

## Ngoài phạm vi

Không thay model/provider/credit pricing, thuật toán chấm điểm trend, quy trình crawler hay sửa code production. Không sao chép nguyên bài của nguồn vào caption. Chưa triển khai code, backfill hoặc thay đổi schema trước review kế hoạch.
