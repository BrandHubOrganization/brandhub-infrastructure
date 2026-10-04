# Plan — Update Trend Flow (lean LLM-label pipeline)

## 1. Luồng mới

```
T0 Ingestion → T1 BotFilter → T2 LLM Label → T4 Burst → T5 Sentiment → T7 Fusion
```

| Tầng | Nhiệm vụ | Output context |
|---|---|---|
| T0 | Nạp + dedup crawl | `raw_items` |
| T1 | Lọc bot (KB1/2/3A/3B/5/6) | drop/blacklist/trend_signal |
| T2 | Clean text → PhoBERT topic+emotion+NER → fallback Gemini | `topics`, `emotions`, `emotion_dists`, `ner_entities`, `keyphrases` |
| T4 | Burst = density+velocity+coverage+engage | `anomaly_scores`, `time_series` |
| T5 | Sentiment (dư luận) = comment emotion + reaction + share/like | `moods`, `mood_stats` |
| T7 | Cluster keyphrase → CandidateTrend + nhãn + rank | `final_candidates` |

## 2. Hai lớp cảm xúc (tách bạch)

- `ctx.emotions` (T2) = **author sentiment** — emotion trên text post (6 lớp).
- `ctx.emotion_dists` (T2) = softmax % 6 lớp từng post.
- `ctx.moods` (T5) = **dư luận/user sentiment** — emotion trên comment + reaction.

T7 gộp: `emotion` (author, majority), `mood` (dư luận, majority),
`emotion_dist` (trung bình softmax cluster), `brand_risk` = f(mood).

## 3. Model

| Nhánh | Demo (local dir) | Production (HF repo) |
|---|---|---|
| Base | `vinai/phobert-base-v2` | `vinai/phobert-base-v2` |
| Emotion 6 lớp (v12) | `khongpush_gihub_MCP/dataset_final/emotion_v12_adversarial_model` | `anha12/brandhub-phobert-V12-emotion` |
| Topic 12 lớp (V5) | `khongpush_gihub_MCP/dataset_final/topic_model` | `anha12/brandhub-phobert-V5-topic` |
| NER 5 loại | `khongpush_gihub_MCP/dataset_final/ner_model` | `anha12/brandhub-phobert-ner` |

Gemini fallback: demo `LLM_API_KEY`/`LLM_MODEL` (urllib); production
`settings.gemini_api_key`/`settings.gemini_model` (GeminiClient httpx).

## 4. Files chạm

**Production (`brandhub-ai-service`):**
- `app/services/pipeline/llm_label.py` — `label_posts` return 5-tuple (thêm `emotion_probs`)
- `app/services/pipeline/phobert.py` — thêm `predict_emotion_probs` (softmax)
- `app/services/pipeline/steps/t2_nlp_step.py` — unpack 5, lưu `emotion_dists`
- `app/services/pipeline/steps/t4_burst_step.py` — burst 4 signal
- `app/services/pipeline/steps/t5_sentiment_step.py` — dư luận
- `app/services/pipeline/steps/t7_fusion_step.py` — gộp `emotion_dist`
- `app/services/pipeline/context.py` — thêm `emotions`, `emotion_dists`, `keyphrases`
- `app/models/trend_models.py` — `CandidateTrend.emotion_dist`
- `app/models/crawler_models.py` — `RawComment` + `raw_comment_objects`
- `app/services/adapters/facebook_playwright_adapter.py` — giữ author+time comment
- `app/services/trend_service.py` — step list lean

**Demo (`trend-pipeline`):**
- `pipeline/{llm_label,model_inference,context,models}.py` + `pipeline/steps/t{2,4,5,7}_*.py` + `loader.py` + `run.py` + `ui.py`

## 5. Thứ tự build

1. Context/model thêm field (`emotion_dists`, `RawComment`, `emotion_dist`).
2. `phobert.predict_emotion_probs` + `label_posts` 5-tuple.
3. T2 lưu dist → T4 burst → T5 sentiment → T7 gộp + rank.
4. Wire step list `trend_service.py` / `run.py`.
5. Demo UI hiển thị breakdown; smoke test cập nhật 5-tuple.

## 6. Rủi ro

- Neutral áp đảo (emotion v12 classify comment ngắn → trung_lập) → mood thiếu phân
  biệt; chấp nhận v1, tune ngưỡng sau.
- Production smoke test bị chặn bởi dep thiếu (`groq`/`torch`) — xác minh bằng
  `py_compile`; cần env đủ deps để chạy test thật.
