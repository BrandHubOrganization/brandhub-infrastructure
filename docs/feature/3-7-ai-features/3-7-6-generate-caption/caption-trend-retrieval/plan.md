# Kế hoạch kỹ thuật

## Luồng mục tiêu

Business xác thực workspace và lấy brand/task → AI resolve trendId → Neo4j trả graph context và danh sách run/post được phép → embedding query → Chroma truy xuất evidence thuộc trend/run đó → hợp nhất với brand KB đã lọc tenant → tạo một context snapshot → LLM tạo ba variant → kiểm tra chất lượng/moderation → lưu kết quả và provenance.

Neo4j cung cấp thực thể/quan hệ, Chroma cung cấp ngữ cảnh văn bản. Redis có thể tiếp tục cache hoặc cung cấp trạng thái publication theo cơ chế hiện có; không dùng Redis thay cho nguồn evidence graph/vector trong tính năng này. Không dựng thêm một hệ thống GraphRAG tổng quát hay nâng major database ở P0.

## Giai đoạn 1: audit và chuẩn hóa dữ liệu

1. Audit read-only schema, collection metadata, index, embedding model/dimension, phân bố runId/trendId/postId và tỷ lệ thiếu sourceUrl/time. Kiểm tra join thực giữa Neo4j và Chroma, không chỉ so tên field.
2. Chuẩn hóa post identity (platform + postId) vì graph dùng ID có platform prefix còn Chroma lưu postId và platform riêng. Trend ID có ngày/category nên không join chỉ bằng keyword. Không yêu cầu mọi post có Entity.
3. Hiện chunk ID v2 gộp theo trend/platform/post và có thể bị upsert qua nhiều run. Đánh giá nhu cầu schema v3 thêm runId vào identity hoặc dùng revision mapping để không overwrite evidence đang được generation tham chiếu. Giữ v2, backfill có dry-run/idempotence; không xóa collection hiện hữu.
4. Thiết kế publication allowlist. Nếu graph chưa có run publication marker, đọc trạng thái publish hiện có ở Redis một cách tường minh. Bền vững hơn: lưu publication manifest/revision trong Neo4j sau khi graph/vector writes được xác nhận. Không giả định có transaction chung hai DB. Nội dung chưa publish vẫn là staging, không đủ điều kiện retrieve.
5. Thiếu metadata/version không được đoán từ ngày trend để coi là nguồn hiện hành. Backfill được provenance thì đưa vào; không chứng minh được thì loại khỏi retrieval mới và báo coverage thiếu.

## Giai đoạn 2: retrieval trong AI

Thêm `caption_trend_context.py` điều phối và model context/provenance riêng. Tái sử dụng Neo4j driver, VectorStoreService/EmbeddingService và trend-fit safety thay vì mở client/model mới mỗi request.

- Neo4j query tham số hóa, graph depth tối đa 1 ở P0, giới hạn số entity/post; không gọi Graph UI expansion API cho mỗi caption.
- Query `social_trend_chunks` với filter trendId + allowlisted runId/namespace và post identity khi có. Query brand KB tách biệt, luôn `clientId` lấy từ Business.
- Dùng cùng embedding model, dimension, normalization và query/passage prefix của indexing. Không đổi embedding model trực tiếp trên collection đã có. Retrieval chỉ đọc collection, không dùng `get_or_create` để tự tạo collection sai cấu hình trong request.
- Lọc ngày publish/crawl theo policy minh bạch, ưu tiên ngữ nghĩa và tính đa dạng nguồn; cosine distance không gọi là confidence tuyệt đối. Calibrate threshold bằng dữ liệu đánh giá.
- Khởi điểm để đo: lấy tối đa 20 candidate chunks, chọn 4–6 chunks, tối đa 2 chunk/post; context trend khoảng 2.000 tokens. Graph/vector timeout mục tiêu 2–3 giây mỗi nguồn, tổng retrieval budget khoảng 5 giây; là tham số đề xuất, chưa phải SLA đã đo.
- Cache ngắn hạn theo workspace/brand revision + topic + platform + trendId + publication revision + policy version. Giới hạn kích thước cache, không giữ toàn bộ collection trong RAM. Tái dùng singleton embedding; hạn chế concurrent embedding query để không tái tạo OOM khi crawler chạy cùng.

## Giai đoạn 3: tích hợp caption, Business và UI

1. `content.py`: resolve event trend từ ngữ cảnh mới; moment/format đi nhánh hiện hữu; phân biệt invalid ID với DB unavailable. Không bọc lỗi retrieval thành caption giả.
2. `caption_service.py`: thêm evidence block tách biệt brand facts/social reports; bỏ việc gắn nhãn toàn bộ bài crawl là verified. Không dùng một con số từ bài xã hội làm bằng chứng cho giá/ưu đãi của brand.
3. Giữ một LLM call tạo ba variant; giữ kiểm tra schema, độ dài, số/claim, trend fit và moderation. Xem lại heuristic `trend_used` hiện chỉ khớp keyword để không coi đó là chứng minh grounding.
4. `AiCaptionService.java` và DTO/context persistence: bổ sung metadata optional, tenant context từ server; idempotent request reuse snapshot, không thu thêm credit chỉ do retry retrieval.
5. Web mở rộng picker/context preview trong luồng hiện có, vi/en và theme song song; nguồn tham khảo có link/thời gian, không nhét technical metadata vào caption. Refine/adapt dùng generation context được xác thực thay vì tin context tùy ý từ client.

## Giai đoạn 4: đánh giá và rollout

Feature flag mặc định tắt; dev → staging/QA → production sau duyệt. Đầu tiên selected-trend P0; P1 auto-suggest chỉ sau khi P0 có số liệu. Rollback tắt flag và về gen thường/chọn trend theo luồng cũ có thông báo phù hợp, không xóa graph/vector. Không thay cấu hình/code trực tiếp production.

Tài liệu tham chiếu kỹ thuật: [Chroma query/filter](https://github.com/chroma-core/docs/blob/main/docs/usage-guide.md), [Cypher parameters](https://neo4j.com/docs/cypher-manual/current/syntax/parameters/). Kiểm tra cú pháp bằng chính phiên bản Neo4j/Chroma đang dùng trước triển khai; không lấy tính năng mới ở bản cloud/latest để áp mặc định cho bản local.
