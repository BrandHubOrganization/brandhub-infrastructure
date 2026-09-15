# Trend Detection & Content Generation — GraphRAG + Streaming Analysis

Nguồn: `crawData.m4a` (transcript by user 2026-07-02).

## 1. Tóm tắt ý tưởng

Hệ thống crawl data (video/audio/text đa nguồn) → giải mã về text chuẩn → phân tích trend real-time → sinh prompt content cho AI generation. Kiến trúc chất = **GraphRAG** (Graph DB + Vector DB) kết hợp **streaming data analysis** bắt trend theo thời gian thực.

## 2. Data Pipeline

```
Crawl (video/audio/text) → Speech-to-Text (Whisper local, RTX 4050) →
Text normalize → Embedding (open-source model) →
  ├─ Vector DB (semantic search)
  └─ Graph DB (entity relationship)
→ BM25 keyword scoring → Prune low-score nodes → Context assembly → LLM prompt
```

- STT chạy local trên RTX 4050 (Whisper) — giảm phụ thuộc API trả phí.
- Backend: Spring Boot hoặc Node.js — quản lý background crawl jobs + xử lý luồng data lớn hàng ngày.

## 3. BM25 — keyword scoring

Chọn BM25 thay TF-IDF: giải quyết term frequency saturation, phạt văn bản dài, trích trending keyword chính xác hơn.

$$
\text{score}(D, Q) = \sum_{i=1}^{n} \text{IDF}(q_i) \cdot \frac{f(q_i, D) \cdot (k_1 + 1)}{f(q_i, D) + k_1 \cdot \left(1 - b + b \cdot \frac{|D|}{\text{avgdl}}\right)}
$$

Dùng để: rank keyword trend, prune node trước khi đẩy vào LLM context (tránh vượt token limit).

## 4. Storage: Graph DB vs Vector DB

| Đặc điểm | Graph DB (Neo4j) | Vector DB (Milvus/Qdrant) | Kết hợp (GraphRAG) |
|---|---|---|---|
| Thế mạnh | Quan hệ logic (A liên kết B) | Semantic search theo ý định | Semantic search → trích mạng lưới liên quan |
| Điểm yếu | Không hiểu ngữ nghĩa tương đồng | Mất ngữ cảnh tuyến tính/liên kết | Pipeline phức tạp, chi phí cao |
| Vai trò | Tìm entity liên kết mạnh trong cùng trend | Match prompt user ("gợi ý trend đồ ăn") | Trả prompt đủ sâu — keyword + context sự kiện |

Quyết định: không chọn 1 trong 2 — kết hợp cả hai (chuẩn kiến trúc Agentic AI long-term memory hiện tại).

## 5. Thách thức cần giải

### 5.1 Entity Resolution (chuẩn hóa thực thể)
Graph phình to mỗi ngày → node trùng ngữ nghĩa (vd "Trấn Thành" vs "MC Trấn Thành"). Cần cơ chế merge node — tránh rác Knowledge Graph.

**Hướng giải:** entity linking bằng embedding similarity + alias dictionary, hoặc LLM-based entity resolution job chạy định kỳ.

### 5.2 Độ trễ / Token limit
Ghép nhiều node thành context dài → vượt context window hoặc chậm response.

**Hướng giải:** prune theo điểm BM25 trước khi build context; giới hạn depth traversal trong graph; cache context đã build cho trend phổ biến.

### 5.3 Bản chất thuật toán nền tảng (TikTok/Facebook)
Nền tảng đánh giá không chỉ qua keyword mà qua Retention Rate. Prompt sinh ra cần có SEO keyword + "hook" 3 giây đầu.

**Hướng giải:** thêm scoring layer riêng cho "hook strength" khi build prompt — không chỉ trend keyword mà cả structure gợi ý (câu mở đầu, pattern giữ chân).

## 6. Việc cần làm tiếp (open items)

- [ ] Chọn Graph DB cụ thể (Neo4j vs alt) — cân nhắc chi phí vận hành trên infra hiện có
- [ ] Chọn Vector DB (Milvus/Qdrant) — check tương thích brandhub-ai-service
- [ ] Thiết kế entity resolution pipeline (merge node)
- [ ] Thiết kế prune strategy (BM25 threshold, depth limit)
- [ ] Thiết kế "hook scoring" cho prompt generation
- [ ] POC: Whisper local trên RTX 4050 — đo tốc độ/độ chính xác thực tế
