# Công việc để review

- [x] Rà soát caption endpoint, trend-fit store, vector collections, graph schema và Business context hiện có.
- [x] Soạn spec/BA, plan, task, test; chưa triển khai code.
- [ ] Review BA-01..12, policy partial run và cửa sổ 7 ngày; BA-13 là P1.
- [ ] Audit dữ liệu read-only ở dev/staging, chốt coverage/join và embedding compatibility.
- [ ] Chốt publication allowlist, identity/revision và backfill dry-run; bổ sung spec trước nếu cần migration.
- [ ] Triển khai AI retrieval service + model context/provenance; unit tests query filtering, freshness, unavailable và injection.
- [ ] Tích hợp vào generate/refine/adapt; bảo toàn ba variant, moderation, brand facts và tín dụng.
- [ ] Cập nhật Business DTO, access checks, generation snapshot/idempotency.
- [ ] Cập nhật UI/context preview, i18n vi/en, light/dark/mobile/keyboard; không đặt test dưới src.
- [ ] Tạo bộ đánh giá tiếng Việt, so sánh baseline không retrieval và phiên bản mới.
- [ ] Chạy CI tương ứng AI/Business/Web; integration Neo4j+Chroma thật trong môi trường QA; đo latency/RAM khi chạy cùng crawler.
- [ ] Hoàn thành bằng chứng test.md, feature flag/rollback và review trước rollout.

Ưu tiên thứ tự: dữ liệu và publication → selected-trend retrieval → API/UX → đánh giá → auto-suggest P1. Không chốt thời gian migration trước khi có audit coverage.
