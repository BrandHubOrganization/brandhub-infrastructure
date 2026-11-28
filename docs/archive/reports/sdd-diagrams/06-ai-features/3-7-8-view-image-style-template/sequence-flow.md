# Sequence Flow — View Image Style Template

> Supplements `spec.md` (FR 3.7.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `ImageGeneratorUI`.
- **System** — `AiGenerationController` / `AiServiceClient`.

---

## Flow A — Luồng thực thi chính: View Image Style Template

1. imagegeneratorui -> aigenerationcontroll: `GET /api/v1/ai/image-style-templates?category={category}`
2. creator -> imagegeneratorui: `opens generator studio & browses style gallery (filters by category: food, cosmetics, fashion, tech, living)`
3. aigenerationcontroll -> aiserviceclient: `get("/api/v1/ai/templates?category=" + category)`
4. aiserviceclient -> aimicroservice: `GET /api/v1/ai/templates?category={category} (header: X-Internal-Key)`
5. aimicroservice --> aiserviceclient: `200 OK (TemplateListResponse: master templates catalog, thumbnails, presets)`
6. aiserviceclient --> aigenerationcontroll: `JsonNode (templates)`
7. aigenerationcontroll --> imagegeneratorui: `200 OK (List<ImageStyleTemplateResponse>)`
8. imagegeneratorui --> creator: `render style template cards (thumbnail preview, category badge, sample prompt, aspect ratio)`
9. aimicroservice --> aiserviceclient: `503 Service Unavailable / Connection Timeout`
10. aiserviceclient --> aigenerationcontroll: `throw AiServiceException (503 SERVICE_UNAVAILABLE)`
11. aigenerationcontroll --> imagegeneratorui: `503 Service Unavailable (AI_SERVICE_UNAVAILABLE)`
12. imagegeneratorui --> creator: `show error toast ('Unable to load style templates, please retry')`
13. creator ->> imagegeneratorui: `selects template card (e.g. 'Traditional Vietnamese Iced Coffee')`
14. aigenerationcontroll ->> aiserviceclient: `get("/api/v1/ai/templates/" + templateId)`
15. imagegeneratorui ->> aigenerationcontroll: `GET /api/v1/ai/image-style-templates/{templateId}`
16. aiserviceclient ->> aimicroservice: `GET /api/v1/ai/templates/{templateId} (header: X-Internal-Key)`
17. aimicroservice --> aiserviceclient: `200 OK (PromptTemplate: style tokens, recommended CFG, steps, aspect ratio)`
18. aiserviceclient --> aigenerationcontroll: `JsonNode (template detail)`
19. aigenerationcontroll --> imagegeneratorui: `200 OK (ImageStyleTemplateDetailResponse)`
20. imagegeneratorui --> creator: `apply template settings to form (base prompt, style preset, recommended aspect ratio & camera angle)`
21. aimicroservice --> aiserviceclient: `404 Not Found (detail: 'Template not found')`
22. aiserviceclient --> aigenerationcontroll: `throw AiServiceException (404 NOT_FOUND)`
23. aigenerationcontroll --> imagegeneratorui: `404 Not Found (TEMPLATE_NOT_FOUND)`
24. imagegeneratorui --> creator: `show error toast ('Style template not found')`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
