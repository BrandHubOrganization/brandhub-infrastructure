# BrandHub Mobile App — Design & Phasing Plan

> Trạng thái: DRAFT — chờ xác nhận trước khi bắt đầu implementation.
> Phạm vi: mở rộng `brandhub-mobile-app` (Expo/React Native) từ "approval + notification only" thành bản thu nhỏ đầy đủ của web, cộng thêm tính năng mới Creator Upload.
> Đây KHÔNG phải FR chính thức trong SRS (125 FR) — coi là hạng mục kỹ thuật bổ sung, không sửa `docs/ba/` hay `docs/plan/document-plan.md`.

## 1. Bối cảnh & quyết định đã chốt

- **Stack:** giữ Expo (managed) + React Native đã scaffold trong `brandhub-mobile-app` — không đổi sang PWA/Safari, không eject bare RN ở các giai đoạn đầu.
  - Lý do: PWA trên iOS Safari không hỗ trợ background upload/sync bền (WebKit limitation), push notification yếu. Expo RN không bị giới hạn cứng này, chỉ hạn chế hơn bare RN cho background task — có thể nâng cấp sau (prebuild + native module) mà không cần đổi stack.
- **Background upload:** giai đoạn đầu KHÔNG làm app chạy nền khi bị kill/minimize. Upload chạy khi app đang mở (foreground). Nếu cần background thật (iOS `URLSession background transfer`, Android `WorkManager`), đó là nâng cấp sau, cần Expo prebuild + native module riêng.
- **Demo/build:** không cần App Store public release. Dùng Expo Go cho demo nhanh, hoặc EAS Build + TestFlight/ad-hoc nếu cần test native module thật trên thiết bị. Cần xác nhận team đã có Apple Developer account hay chưa trước khi tới giai đoạn cần build thật.
- **Mục tiêu cuối:** mobile app là bản thu nhỏ đầy đủ của web — user dùng mobile thay web được cho hầu hết tác vụ chính, cộng thêm tính năng Creator Upload (không có bên web).
- **Thứ tự triển khai:** Auth đầy đủ → Creator Upload (điểm nhấn kỹ thuật mới) → các domain còn lại của web (Agency/Workspace, Package/Campaign, Task, AI Features, Subscription/Billing).

## 2. Creator Upload — mô tả tính năng mới (điểm nhấn)

Pain point gốc: nhà sáng tạo nội dung quay xong clip tại hiện trường (sự kiện, livestream BTS...), cần đưa file vào hệ thống nhanh, không phải mang máy về mở web upload.

**Giai đoạn 1 (MVP):**
1. Creator mở app, thấy list Task được Manager giao sẵn (không tự tạo Task mới ở bước này).
2. Chọn 1 Task → trong Task Detail có nút: quay video trong app (camera native) **hoặc** chọn file có sẵn từ thư viện máy.
3. App xin presigned PUT URL từ `brandhub-business-service` (theo pattern `S3FileStorageService`/`UploadS3Controller` đã có), PUT file thẳng lên S3 — không qua server trung gian.
4. Có progress bar; hỗ trợ retry/resume khi mất mạng giữa chừng (video raw thường vài trăm MB, mạng di động không ổn định).
5. Upload xong → gắn file vào Task đó, lưu vào Material Repository với phân loại **raw** (đúng field raw/retouched đã có ở FR 3.6.11–3.6.14).
6. **Dừng ở đây.** Chưa làm AI auto-edit, chưa auto-caption, chưa auto-tạo Task mới.

**Giai đoạn 2 (sau, chưa thiết kế chi tiết — placeholder):**
- AI xử lý raw footage (cắt short, chọn đoạn đẹp, auto-caption) — cần làm rõ: dùng tool edit video thật (ví dụ ffmpeg-based service) vì `AiVideoService`/Veo hiện tại là *generate* video từ prompt, không phải *edit* video có sẵn — đây là năng lực kỹ thuật MỚI, chưa tồn tại trong `brandhub-ai-service`.
- Khi AI xong, tạo Task mới ở trạng thái `IN_REVIEW` / MANAGER theo Approval Sequence đã có (FR 3.6.9), không bỏ qua approval, không tự publish.
- Chi tiết đầy đủ giai đoạn 2 sẽ viết thành doc riêng sau khi giai đoạn 1 chạy ổn và biết rõ năng lực AI edit thật có khả thi trong thời gian còn lại của capstone không.

### Điểm chạm hệ thống hiện có (đã đọc code, không đoán)
- `brandhub-business-service/.../controller/UploadS3Controller.java` — mẫu test endpoint upload hiện tại, cần thiết kế lại thành endpoint chính thức cấp presigned URL + xác nhận gắn Task/Material.
- `brandhub-business-service/.../service/FileStorageService.java` + `S3FileStorageServiceImpl.java` — nền tảng S3 có sẵn.
- `brandhub-business-service/.../document/MaterialDocument.java` — Material Repository entity, cần xác nhận field raw/retouched map đúng với yêu cầu mobile.
- `brandhub-business-service/.../service/ai/AiVideoService.java` — AI video generate (Veo) có sẵn, KHÔNG dùng được cho "edit raw footage" ở giai đoạn 2 mà không viết thêm service mới.
- `brandhub-ai-service/app/services/caption_service.py` — có sẵn, dùng được cho auto-caption ở giai đoạn 2.

## 3. Các giai đoạn tổng thể

| Giai đoạn | Nội dung | Ghi chú |
|---|---|---|
| G0 | Viết design doc + xác nhận scope (đang làm) | File này + các file con bên dưới |
| G1 | Auth đầy đủ: Sign In Email, Sign In Google OAuth, Forgot/Reset Password | Khớp FR 3.2.1–3.2.9, tái dùng `expo-secure-store` đã có |
| G2 | Creator Upload giai đoạn 1 (mô tả mục 2) | Điểm nhấn kỹ thuật mới của đồ án |
| G3 | Agency/Workspace: list/view Agency, Workspace, invite member | |
| G4 | Media Package/Campaign: xem + approve (Owner/Client) | |
| G5 | Task management đầy đủ: list/kanban/calendar/detail/comment (không chỉ approval queue như hiện tại) | |
| G6 | AI Features: generate caption/image/video từ mobile, xem credit | |
| G7 | Subscription/Billing: xem/mua plan, invoice history | |
| G8 (sau) | Creator Upload giai đoạn 2: AI edit raw + auto-caption + auto-queue Task IN_REVIEW | Chưa thiết kế chi tiết, phụ thuộc khả năng AI edit thật |

Mỗi giai đoạn G1–G7 có 1 folder riêng trong `docs/mobile/features/<giai-đoạn>/spec.md` (feature spec đầy đủ: mục tiêu, FR tham chiếu, API thật đọc từ code, luồng màn hình, state/cache, business rule, non-goal, rủi ro/câu hỏi mở). Đã viết xong cả 7 file, dựa trên đọc code thật (business-service, mobile-app, web) — không đoán. Danh sách:

- [`features/g1-auth/spec.md`](features/g1-auth/spec.md)
- [`features/g2-creator-upload/spec.md`](features/g2-creator-upload/spec.md)
- [`features/g3-agency-workspace/spec.md`](features/g3-agency-workspace/spec.md)
- [`features/g4-package-campaign/spec.md`](features/g4-package-campaign/spec.md)
- [`features/g5-task-management/spec.md`](features/g5-task-management/spec.md)
- [`features/g6-ai-features/spec.md`](features/g6-ai-features/spec.md)
- [`features/g7-subscription-billing/spec.md`](features/g7-subscription-billing/spec.md)

**Phát hiện quan trọng từ việc đọc code thật (cần team xác nhận, xem mục "Rủi ro/câu hỏi mở" mỗi file để chi tiết):**
- G1: Google OAuth flow backend hiện tại đã bị BA đánh dấu "chưa chạy được"; refresh token dùng HttpOnly cookie, mobile không có — cần BE đổi flow.
- G2: presigned PUT upload chưa tồn tại (chỉ có presigned GET); Material chưa có field `taskId` — đều là việc mới cần thêm ở backend.
- G3: role thật per-Workspace chỉ có OWNER/MANAGER/CREATOR/CLIENT (không có ADMIN/GUEST ở cấp này — khác giả định ban đầu).
- G4: approve Campaign KHÔNG tự đẩy Task vào backlog — có bước `/deploy` riêng, khác với mô tả trong BA doc 04.
- G5: tồn tại 2 model Task (SQL rỗng vs MongoDB thật) — phải build theo MongoDB; đề xuất bỏ Gantt view và content-editor khỏi scope mobile (chưa được xác nhận).
- G7: cổng thanh toán thật là SePay (QR chuyển khoản), không phải PayOS như BA doc ghi; đề xuất mobile chỉ xem plan/invoice, hành động mua/upgrade mở browser ngoài (an toàn chính sách IAP) — đề xuất của tôi, chưa được xác nhận.

## 4. Việc cần làm tiếp (không code)

1. Xác nhận file plan này đúng ý trước khi viết chi tiết G1.
2. Viết `docs/mobile/g1-auth.md` — chi tiết hoá Auth đầy đủ trên mobile.
3. Viết `docs/mobile/g2-creator-upload.md` — chi tiết hoá Creator Upload giai đoạn 1 (API cần thêm ở business-service, UI flow, error case).
4. Sau khi G1+G2 doc được duyệt, mới chuyển qua `superpowers:writing-plans` để lên implementation plan thật (bước code).

## 5. Rủi ro đã biết

- Apple Developer account: chưa xác nhận team đã có — cần thiết nếu muốn test build thật qua TestFlight/EAS (không cần cho Expo Go demo).
- AI edit raw footage (giai đoạn 2) là năng lực mới, không có sẵn trong `brandhub-ai-service` — cần đánh giá effort riêng trước khi cam kết đưa vào giai đoạn 2.
- Scope mobile mở rộng toàn bộ web là effort lớn cho capstone — cần theo dõi tiến độ G3–G7 so với deadline cuối tháng 11/2026, có thể phải cắt bớt nếu không kịp.
