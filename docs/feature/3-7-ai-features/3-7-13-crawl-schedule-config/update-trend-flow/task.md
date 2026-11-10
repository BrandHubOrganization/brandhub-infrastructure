# Task — update-trend-flow

- [x] Đối chiếu spec: flow lean T0→T7 (bỏ T3 topic-dict / T6 graph), emotion % + sentiment.
- [x] Viết plan kỹ thuật (plan.md) — 2 lớp cảm xúc, model ref demo/production, file chạm.
- [x] Thêm field context/model: `emotion_dists`, `RawComment`/`raw_comment_objects`, `CandidateTrend.emotion_dist`.
- [x] `phobert.predict_emotion_probs` (softmax 6 lớp) + `label_posts` return 5-tuple.
- [x] T2 lưu `emotion_dists`; bỏ mood-mapping khỏi T2 (mood thuộc T5).
- [x] T4 burst 4 signal (density/velocity/coverage/engage).
- [x] T5 sentiment (dư luận): comment emotion + reaction ratio + share/like ratio.
- [x] T7 fusion: gộp `emotion_dist`, mood từ `ctx.moods`, emotion từ `ctx.emotions`.
- [x] Wire step list: `trend_service.py` (production) + `run.py` (demo) + `ui.py` hiển thị breakdown.
- [x] Demo full run: 3426 posts → 60 trends; emotion_dist đa dạng (trung_lập/vui/buồn/lo_sợ/tức_giận).
- [x] Cập nhật smoke test production cho 5-tuple.
- [x] `py_compile` pass toàn bộ file demo + production.

- [ ] Chạy smoke test production thật (đang chặn `ModuleNotFoundError: groq` — cần cài dep).
- [ ] Mirror kiểm chứng bằng 1 test/benchmark cho emotion_dist (nếu cần sau khi test thật).
- [ ] Nghiệm thu FR 3.7.1 sau khi nối phụ thuộc (xem implementation status).
