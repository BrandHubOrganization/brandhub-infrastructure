# Plan — 3.7.2 Generate Caption

1. **DB:** migration `2026-10-08-ai-credit-usages.sql` — bảng `ai_credit_usages` (mỗi lần dùng AI: agency, user, workspace, feature, credits, month, refunded_at). Dùng chung cho 3.7.7 (hoàn credit) và 3.9.5 (Tuấn đọc để theo dõi).
2. **Business:** `AiCreditService` (balance / ensureAvailable / charge có khoá dòng ledger / refund), `AiCaptionService` (gọi `/api/v1/ai/content/captions/generate`, tính giá cấu hình được), `AiCaptionController`, `ErrorCode.INSUFFICIENT_AI_CREDIT` (402) + `AI_SERVICE_UNAVAILABLE` (502).
3. **AI service:** dùng endpoint có sẵn; môi trường dev chuyển `LLM_PROVIDER=gemini` vì key Groq không còn hợp lệ.
4. **Web:** `services/aiCaptionService.ts`, `content-writing/components/AiCaptionDialog.tsx`, thêm nút + dialog vào `content-writing/index.tsx` (màn của Trung, chỉ thêm, không sửa logic có sẵn).
5. **Locale:** `src/i18n/locales/{vi,en}/editor.json` (`aiCaption.*`).
6. Rủi ro: giá có thể đổi (cấu hình); credit mua thêm (3.9.6) chưa được cộng vào hạn mức cho tới khi Tuấn lưu nó.
