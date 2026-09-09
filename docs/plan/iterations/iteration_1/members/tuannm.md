# AI Iteration 1 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer |
| Iteration | Iteration 1 — Research & Evaluation |
| Ngày nộp | 2026-07-18 |

---

## 2. Tổng quan kết quả

Trong Iteration 1, tôi phụ trách nghiên cứu và đánh giá các hướng tạo virtual ambassador/fashion model có khả năng kiểm soát khuôn mặt, pose và chất lượng hình ảnh. Kết quả được tổng hợp trong báo cáo DA-59, với ba workflow được đánh giá thực tế là `InstantID`, `InstantID + ControlNet` và `Z-Image`.

Kết luận chính: `Z-Image` cho chất lượng hình ảnh tổng thể tốt nhất trong bộ thử nghiệm và phù hợp nhất cho ảnh chân dung, bán thân hoặc ba phần tư. `InstantID + ControlNet` hữu ích khi cần kiểm soát pose nhưng còn drift khuôn mặt và lỗi background. `InstantID` tạo nhanh và hiểu prompt khá tốt, nhưng drift khuôn mặt và thiên hướng anime khiến workflow chưa phù hợp làm pipeline production chính.

> **Traceability:** kế hoạch Iteration 1 dùng mã nội bộ `DA-AI01-01` và `DA-AI01-02`. Công việc thực tế được theo dõi trên Jira qua nhóm task DA-57/DA-58/DA-59; báo cáo versioned trong Git nằm ở DA-59.

---

## 3. Tasks được giao trong iteration

| Task ID | Jira Link | Mô tả | Priority | Status cuối iteration |
|---|---|---|---|---|
| DA-AI01-01 | [DA-AI01-01](https://letritrung2605.atlassian.net/browse/DA-AI01-01) | Research and compare InstantID vs IP-Adapter vs ControlNet for face-consistent virtual ambassador generation | 🔴 Critical | ✅ Done |
| DA-AI01-02 | [DA-AI01-02](https://letritrung2605.atlassian.net/browse/DA-AI01-02) | Test 3 virtual ambassador tools on 5 sample images and write a comparison table | 🔴 Critical | ✅ Done — evidence gap noted below |

**Tổng:** 2 tasks | **Done:** 2 | **In Review:** 0 | **Chưa hoàn thành:** 0

### Jira tasks liên quan trong board thực tế

| Jira ID | Mô tả | Status quan sát tại thời điểm lập report |
|---|---|---|
| [DA-57](https://letritrung2605.atlassian.net/browse/DA-57) | Evaluate 3 models: InstantID vs IP-Adapter vs ControlNet | ✅ Done |
| [DA-58](https://letritrung2605.atlassian.net/browse/DA-58) | Test 3 virtual ambassador tools with 5 different images | ✅ Done |
| [DA-59](https://letritrung2605.atlassian.net/browse/DA-59) | Investigate and analyze 3 AI fashion model generation platforms | ✅ Done |

---

## 4. Chi tiết công việc đã làm

### [DA-AI01-01] Research and compare ambassador approaches

| Evidence | Chi tiết |
|---|---|
| Branch | `docs/DA-59-analyze-ai-fashion-model-platforms` |
| Commit | `3ba1704` — `docs(DA-59): write report analyze AI model fashion` |
| Files changed | `docs/AI_Models/DA-59_AI_Fashion_Model_Generation_Platforms.md`; ghi chú hỗ trợ cục bộ `Model AI.docx` |
| Thời gian | Khoảng 2 giờ trong tổng 4 giờ đã ghi nhận cho DA-59 |

**Công việc thực hiện:**

- Xác định tiêu chí đánh giá theo use case BrandHub: hiểu prompt, độ ổn định khuôn mặt, pose/body, độ thực tế trang phục, texture, background, tốc độ, chi phí vận hành và mức sẵn sàng production.
- Nghiên cứu vai trò của InstantID trong identity conditioning và ControlNet trong kiểm soát cấu trúc/pose.
- Phân biệt rõ ControlNet standalone là công cụ structural guidance, không phải giải pháp face-ID độc lập.
- Ghi nhận IP-Adapter và ControlNet standalone chưa có demo đủ ổn định trong phạm vi test nên không đưa vào nhóm ba kết quả thực nghiệm cuối cùng.
- Đánh giá rủi ro license theo từng base model, checkpoint, LoRA và dependency trước khi dùng thương mại.

**Kết quả:** tạo được khung quyết định kỹ thuật và thu hẹp lựa chọn cho BrandHub. Z-Image được đề xuất làm ứng viên chính cho visual chất lượng cao; InstantID + ControlNet giữ vai trò R&D khi cần kiểm soát pose.

### [DA-AI01-02] Test tools and consolidate comparison

| Evidence | Chi tiết |
|---|---|
| Branch | `docs/DA-59-analyze-ai-fashion-model-platforms` |
| Commit | `3ba1704` — báo cáo tổng hợp kết quả test và comparison matrix |
| Files changed | `docs/AI_Models/DA-59_AI_Fashion_Model_Generation_Platforms.md` |
| Thời gian | Khoảng 2 giờ trong tổng 4 giờ đã ghi nhận cho DA-59 |

**Công việc thực hiện:**

- Tổng hợp kết quả test cho `InstantID`, `InstantID + ControlNet` và `Z-Image`.
- So sánh chất lượng prompt, face consistency, pose, fashion realism, background, texture, tốc độ, chi phí self-host và production readiness.
- Ghi nhận InstantID tạo nhanh nhưng drift mặt cao và thiên anime; InstantID + ControlNet giữ pose tốt hơn nhưng background dễ hỏng; Z-Image cho hình ảnh tốt nhất nhưng giảm chất lượng khuôn mặt ở full-body và workflow đã test không hỗ trợ LoRA.
- Viết comparison matrix, xếp hạng ba lựa chọn và đề xuất giới hạn vận hành: ưu tiên portrait/half-body/three-quarter, tránh full-body khi chi tiết khuôn mặt là yêu cầu chính, luôn có bước manual QA trước khi dùng cho marketing.

**Kết quả:** có báo cáo phân tích ba workflow và recommendation rõ ràng, đủ làm đầu vào cho quyết định kiến trúc AI image/ambassador ở iteration sau.

---

## 5. Hạn chế và evidence gap

- Báo cáo Git hiện có chủ yếu lưu kết quả định tính; chưa lưu raw output của đủ 5 ảnh mẫu trong repository.
- Chưa có bảng số liệu định lượng theo từng ảnh cho generation time, cost/image, cosine face similarity và realism score 1–5 như acceptance criteria gốc của DA-AI01-02.
- IP-Adapter và ControlNet standalone không có demo ổn định trong phạm vi test, vì vậy báo cáo cuối sử dụng `InstantID + ControlNet` và `Z-Image` để tạo đủ ba workflow có kết quả thực tế.
- Thời gian 2 giờ/task là phân bổ ước tính từ tổng thời gian khoảng 4 giờ đã ghi trong Sprint 3 report; không có worklog Jira chi tiết theo từng task trong nguồn cục bộ.

Các điểm trên không làm mất giá trị của kết luận định tính, nhưng cần được bổ sung trước khi dùng báo cáo để bảo vệ một quyết định production hoặc tuyên bố đạt đầy đủ acceptance criteria thực nghiệm.

---

## 6. Đóng góp ngoài tasks chính

- Liên kết kết quả model research với hướng thiết kế AI fashion model cho BrandHub.
- Chuẩn hóa cách tách kết quả đã test khỏi nhận định lý thuyết để tránh overclaim.
- Đề xuất chiến lược triển khai theo giai đoạn: dùng Z-Image cho visual ưu tiên chất lượng, giữ InstantID + ControlNet cho thử nghiệm pose/identity, và trì hoãn production automation cho đến khi có benchmark định lượng.

---

## 7. Học được trong iteration

1. Identity consistency, pose control và image quality là ba trục độc lập; không nên dùng một tiêu chí duy nhất để chọn model.
2. Demo trực quan chưa đủ để kết luận production readiness; cần log prompt, seed, latency, cost và face-similarity score để tái lập kết quả.
3. Full-body generation làm giảm số pixel dành cho khuôn mặt, vì vậy nên tách benchmark theo portrait, half-body và full-body.
4. “Open-source” không đồng nghĩa tự động được phép sử dụng thương mại; phải kiểm tra toàn bộ dependency chain.

---

## 8. Feedback và đề xuất

- Tạo một benchmark manifest cố định gồm 5 reference images, prompt, negative prompt, seed, kích thước và cấu hình model.
- Lưu raw outputs theo cấu trúc `model/reference/prompt` và đính kèm link artifact vào Jira thay vì chỉ ghi nhận bằng mô tả.
- Bổ sung script InsightFace để tính cosine similarity, đồng thời đo mean/min/max, tỉ lệ đạt ngưỡng và latency p50/p95.
- Xác minh license của Z-Image và các checkpoint trước khi đưa vào chiến dịch thương mại.
- Re-test IP-Adapter FaceID-Plus và ControlNet standalone khi có runtime/demo ổn định, dùng cùng input và prompt để bảo đảm so sánh công bằng.

---

## 9. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 4/5 | Các task trên board đã Done; báo cáo versioned được commit ngày 2026-06-30 |
| Chất lượng deliverable | 4/5 | Có tiêu chí, comparison matrix, recommendation và giới hạn sử dụng rõ ràng; còn thiếu artifact/metric định lượng |
| Giao tiếp với team | 4/5 | Kết quả được tổng hợp thành tài liệu dùng chung và liên kết với định hướng AI của BrandHub |
| Chủ động xử lý blocker | 3/5 | Đã loại các demo không đủ bằng chứng và ghi rõ hạn chế; cần chuẩn hóa benchmark sớm hơn |
| **Tổng** | **15/20** | Đạt mục tiêu nghiên cứu và ra quyết định sơ bộ, chưa đạt mức benchmark production đầy đủ |

---

## 10. Tài liệu tham chiếu

- [DA-59 — AI Fashion Model Generation Platforms](../../../../AI_Models/DA-59_AI_Fashion_Model_Generation_Platforms.md)
- `Model AI.docx` — ghi chú cục bộ về SD 1.5, SDXL, LoRA, ComfyUI và cấu hình cloud thử nghiệm
- Commit `3ba1704` trên branch `docs/DA-59-analyze-ai-fashion-model-platforms`

---

*Nộp: 2026-07-18 | AI Iteration 1 — Research & Evaluation*
