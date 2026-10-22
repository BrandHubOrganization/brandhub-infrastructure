# UC — Update Trend Flow (Lean LLM-label pipeline T0→T7)

| | |
|---|---|
| FR Code | Internal — hỗ trợ FR 3.7.1 (View Trending Topics) |
| Feature | Update Trend Flow — thay pipeline cũ (BM25 + graph) bằng lean LLM label |
| Domain | AI Features (FR 3.7) — pipeline AI-05 |
| Role | SYSTEM (backend pipeline; Streamlit demo để test) |
| Version | 2.0 (2026-10-02) |
| Trạng thái tài liệu | Đã code — docs viết lại khớp code |

## 1. Objective

Thay pipeline trend cũ (8 tầng: T3 Topic dict, T4 BM25 spike, T5 engagement,
T6 graph Neo4j) bằng flow **lean 6 tầng** chạy AI trên HuggingFace, không cần
Neo4j graph ở khâu phát hiện trend. Nhãn do PhoBERT 3 model gộp 1 pass, fallback
Gemini. Thêm **emotion breakdown %** (softmax 6 lớp) thay cho 1 nhãn argmax đơn.

## 2. User Story

Là hệ thống trend pipeline,
tôi muốn gán nhãn topic/emotion/entity/keyphrase bằng LLM và tính dư luận
(sentiment comment) cùng emotion % cho từng trend,
để kết quả trend phản ánh đúng chủ đề + sắc thái cảm xúc thay vì 1 nhãn cứng.

## 3. Acceptance Criteria

- **AC-1 (Flow):** Pipeline chạy đúng `T0 Ingestion → T1 BotFilter → T2 LLM Label →
  T4 Burst → T5 Sentiment → T7 Fusion` (không còn T3 topic-dict / T6 graph).
- **AC-2 (Label):** T2 gán topic (12 lớp) + emotion (6 lớp) + NER (5 loại entity)
  + keyphrase cho mỗi post, PhoBERT là chính, thiếu nhánh nào thì Gemini bù (env key).
- **AC-3 (Emotion %):** T2 trả `emotion_dist` = softmax prob 6 lớp cho mỗi post;
  T7 gộp trung bình theo cluster → `emotion_dist` của trend.
- **AC-4 (Burst):** T4 tính burst = f(density + velocity + coverage + engage), ra
  `anomaly_scores` + `time_series` (trajectory ngày).
- **AC-5 (Sentiment):** T5 tính dư luận = comment emotion (PhoBERT trên comment) +
  reaction ratio (FB) + share/like ratio → `moods` từng post.
- **AC-6 (Fusion):** T7 cluster keyphrase → CandidateTrend, gán topic + emotion
  (author) + mood (dư luận) + emotion_dist → `brand_risk` + `status`
  (new/rising/peaking/declining).
- **AC-7 (Parity):** Demo (`trend-pipeline`) và production (`brandhub-ai-service`)
  cùng flow + cùng field, chỉ khác model ref (local dir vs HF repo) và Gemini client.

## 4. UI / UX

- Không có UI người dùng cuối. Demo: `streamlit run ui.py` (bảng xếp hạng + emotion
  breakdown từng trend).

## 5. API Contract (production)

`NormalizeTrendResponse.candidates[]` mỗi trend thêm field `emotion_dist`
(`{label: %}` 6 lớp), bên cạnh `topic`, `emotion`, `mood`, `brand_risk`, `status`.

## 6. Error Handling

- PhoBERT không load được (thiếu torch/model) → `predict_*` trả None → fallback
  Gemini; không có key Gemini → nhãn None, pipeline vẫn chạy không crash.
- `emotion_probs` chỉ có khi PhoBERT chạy; post dùng Gemini fallback → `None`,
  T7 bỏ qua post đó khi gộp `emotion_dist`.

## 7. Edge Cases

- Post không có comment → T5 mood fallback reaction ratio / share-like; vẫn `neutral`.
- Cluster 1 post → `emotion_dist` = chính softmax post đó.

## 8. Definition of Done

- Pipeline lean chạy end-to-end ra trend, mỗi trend có topic/emotion/mood/emotion_dist.
- Demo + production cùng output schema.
- Smoke test production pass (sau khi có đủ deps torch/groq).

## Out of Scope

- Neo4j graph virality (bỏ ở khâu phát hiện; GraphRAG tầng 4 vẫn riêng).
- Tune ngưỡng mood / class balance (neutral vẫn áp đảo — tune sau).

## Tham chiếu BA

[06-ai-features.md](../../BA/06-ai-features.md)
