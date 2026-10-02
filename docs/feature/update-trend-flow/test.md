# Test — update-trend-flow

## 1. Smoke test (production, offline — monkeypatch label)

File: `brandhub-ai-service/tests/unit/services/test_trend_pipeline_smoke.py`

| # | Input | Mong đợi | Kết quả |
|---|---|---|---|
| 1 | 8 post nền + 8 post "điện thoại ai" nhiều likes + 1 lẻ | ra candidate, rank=1, topic=`công_nghệ`, mood=`neutral`, final>0 | ⏳ (chưa chạy — thiếu `groq`) |
| 2 | `_fake_label` trả 5-tuple | T2 unpack không crash, `emotion_dist` set | ⏳ |

## 2. Full data quality (demo)

Command: `python run.py --limit 0 --top 20`

| # | Check | Mong đợi | Kết quả |
|---|---|---|---|
| 3 | T2 label | topics=3426, emotions=3426, entities=2468 | ✅ |
| 4 | T4 burst | 67 phrases | ✅ |
| 5 | T5 sentiment | 3426 posts, 33567 comment emotion | ✅ |
| 6 | T7 fusion | 60 trends | ✅ |
| 7 | emotion_dist đa dạng | mood: neutral 45 / positive 9 / controversy 4 / negative 2 | ✅ |
| 8 | top trend hợp lý | FIFA ASEAN Cup, ASIAD 20, iPhone 18 Pro… | ✅ |
| 9 | status lifecycle | new 28 / rising 19 / declining 12 / peaking 1 | ✅ |

## 3. Edge case

| # | Input | Mong đợi |
|---|---|---|
| 10 | `--limit 150` (post cũ thưa) | 0 trend — đúng vì thiếu density (không phải bug) |
| 11 | Post không có comment | T5 mood fallback reaction/share, mặc định neutral |
| 12 | PhoBERT không load | label None → Gemini fallback, pipeline không crash |

## Ghi chú

- Production smoke test chưa chạy được trong shell hiện tại: `ModuleNotFoundError: No module named 'groq'` (thiếu dep từ trước, không liên quan thay đổi). Verify bằng `py_compile` đã pass.
