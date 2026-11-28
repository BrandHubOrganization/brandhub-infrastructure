# Sequence Flow — Generate Image

> Supplements `spec.md` (FR 3.7.5). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `ImageGeneratorUI`.
- **System** — `AiGenerationController` / `AiServiceClient`.

---

## Flow A — Luồng thực thi chính: Generate Image

1. creator -> imagegeneratorui: `configures prompt, selects Ambassador model (FR 3.7.3), reference assets, style template (FR 3.7.4) & clicks "Generate Image"`
2. imagegeneratorui -> aigenerationcontroll: `POST /api/v1/ai/generate-image (prompt, ambassadorId, referenceAssetIds, styleTemplateId, aspectRatio)`
3. aigenerationcontroll -> aicreditledgerreposi: `findByAgencyIdAndMonth(agencyId, currentMonth)`
4. aicreditledgerreposi --> aigenerationcontroll: `creditLedger (usedAmount, monthlyLimit)`
5. aigenerationcontroll --> imagegeneratorui: `402 Payment Required (INSUFFICIENT_AI_CREDIT)`
6. imagegeneratorui --> creator: `show error dialog ('Insufficient AI credits, please contact Agency Manager')`
7. aiserviceclient ->> aimicroservice: `POST /api/v2/ai/image/commercial/generate (prompt, ambassador, referenceImages, stylePreset, LoRA, tenantContext)`
8. aigenerationcontroll ->> aiserviceclient: `post("/api/v2/ai/image/commercial/generate", enrichedRequest)`
9. aimicroservice --> aiserviceclient: `400 Bad Request (PROMPT_REJECTED: policy violation)`
10. aiserviceclient --> aigenerationcontroll: `throw AiServiceException (400 PROMPT_REJECTED)`
11. aigenerationcontroll --> imagegeneratorui: `400 Bad Request (PROMPT_REJECTED)`
12. imagegeneratorui --> creator: `show error toast ('Prompt rejected: content violates safety policy')`
13. aimicroservice --> aiserviceclient: `503 Service Unavailable / GPU Out of Memory`
14. aiserviceclient --> aigenerationcontroll: `throw AiServiceException (503 SERVICE_UNAVAILABLE)`
15. aigenerationcontroll --> imagegeneratorui: `503 Service Unavailable (GPU_ENGINE_UNAVAILABLE)`
16. imagegeneratorui --> creator: `show error toast ('AI generation service temporarily unavailable, 0 credits billed')`
17. aimicroservice --> aiserviceclient: `200 OK (CommercialGenerateResponse: imageUrl, s3Key, seedUsed, inferenceTimeMs)`
18. aiserviceclient --> aigenerationcontroll: `JsonNode (generationResult)`
19. aigenerationcontroll ->> aicreditledgerreposi: `save(creditLedger with usedAmount = usedAmount + 1)`
20. aicreditledgerreposi --> aigenerationcontroll: `savedLedger`
21. aigenerationcontroll --> imagegeneratorui: `200 OK (imageUrl, creditsUsed=1, remainingCredits)`
22. imagegeneratorui --> creator: `display generated commercial image preview with LoRA details & update credit counter`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
