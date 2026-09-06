# Kế hoạch sửa screenshot trùng nhau — 2026-08-26

## 1. Bối cảnh

Rà soát `docs/screenshots/` (136 file PNG) bằng md5 hash phát hiện **9 nhóm ảnh trùng byte-tuyệt-đối** — tổng **22 file thừa**. Ảnh trùng byte = FE render đúng 1 màn hình cho nhiều task/FR khác nhau → các FR đó **chưa được tách biệt về UI** (mỗi FR phải có màn hình/biến thể riêng để chứng minh tính năng đã build).

Nguồn: md5sum toàn bộ `*.png`, group theo hash. Phương pháp chỉ bắt trùng byte tuyệt đối — không bắt "giống mắt thường nhưng khác pixel" (không cần quan tâm ở phase 1).

## 2. Danh sách 9 nhóm cần xử lý

| # | Nhóm file trùng | Số file thừa | File giữ lại (gốc) | Mức nghiêm trọng |
|---|---|---|---|---|
| 1 | DA-D18-07, 08, 09, 10, 12, 14, 15, 16, 18, 19, 20, 22, 24 | 12 | DA-D18-07 | 🔴 Nghiêm trọng — 13 task cùng 1 UI |
| 2 | DA-D15-25, 26, 27 | 2 | DA-D15-25 | 🟡 Trung bình |
| 3 | DA-D18-02, 03, 05 | 2 | DA-D18-02 | 🟡 Trung bình |
| 4 | DA-D18-25, 26 | 1 | DA-D18-25 | 🟢 Thấp |
| 5 | DA-D15-20, 22 | 1 | DA-D15-20 | 🟢 Thấp |
| 6 | DA-D15-05, 09 | 1 | DA-D15-05 | 🟢 Thấp |
| 7 | DA-D15-13, 15 | 1 | DA-D15-13 | 🟢 Thấp |
| 8 | DA-D17-05, 22 | 1 | DA-D17-05 | 🟢 Thấp (cách xa nhau trong dãy D17) |
| 9 | DA-D16-24, 26 | 1 | DA-D16-24 | 🟢 Thấp |

Tổng: **22 file cần chụp lại** (không xóa file — thay bằng ảnh đúng của đúng FR).

## 3. Nguyên tắc xử lý chung

1. **Không xóa ảnh trước khi có ảnh thay thế.** Giữ file cũ làm placeholder tới khi chụp xong ảnh mới đúng FR, tránh mất track task nào chưa xong.
2. **Mỗi task/FR ID map với đúng 1 màn hình thể hiện đúng chức năng của nó** — không chụp lại màn hình cha/danh sách chung cho nhiều task con.
3. Chụp bằng chrome-devtools MCP, **theme LIGHT** (đúng convention đã dùng toàn bộ 136 ảnh hiện có).
4. Sau khi chụp lại, **chạy lại md5sum để verify không còn trùng** trong nhóm đó.
5. Không commit/push — Trung tự commit.

## 4. Việc cần làm trước khi chụp lại — xác định nội dung đúng của từng task

Vấn đề gốc rễ: file ảnh trùng vì **task Jira/FR tương ứng chưa được nhìn lại xem đúng nó yêu cầu UI gì**. Trước khi chụp, với mỗi ID trong bảng trên phải:

1. Tra Jira task ID tương ứng (map `DA-D{day}-{số}` → Jira task) để đọc **mô tả/AC (acceptance criteria)** — task đó yêu cầu thể hiện màn hình/luồng gì cụ thể.
2. Nếu 2+ task đang mô tả **cùng 1 chức năng** (bị trùng lặp task, không phải trùng ảnh) → đây là vấn đề khác, báo lại Trung để gộp/xóa task trùng trên Jira, KHÔNG chụp lại ảnh.
3. Nếu mỗi task có AC khác nhau rõ ràng nhưng ảnh đang trùng → xác nhận đúng là lỗi chụp ảnh (dùng nhầm ảnh cũ / chưa build đúng luồng riêng) → cần build/hoàn thiện UI riêng rồi mới chụp.

→ Bước này quyết định: **task nào có bug UI thật cần fix code**, và **task nào chỉ là lỗi Jira/chụp ảnh cần làm lại thao tác**.

## 5. Nguồn sự thật đã đối chiếu

Đã tra 2 tài liệu gốc để xác định đúng bản chất từng nhóm (không đoán):
- `FormReportDA/report_drafts/Missing_Screens_Tracking.md` — danh sách 8 task **NO UI thật sự** (backend thuần, không có màn hình để chụp).
- `FormReportDA/report_drafts/Section5_Requirement_Appendix.md` (BR-51 → BR-58) — mô tả chính xác từng task D18 publishing yêu cầu UI gì theo platform/post-type.

Kết luận: trong 9 nhóm, **1 nhóm là false positive** (D18-25/26 — đúng là không có UI, không phải bug), **8 nhóm còn lại là bug UI thật** cần build/chụp lại.

## 6. Phương pháp fix cụ thể từng nhóm

### Nhóm 1 — DA-D18-07→24 (12 file thừa) — 🔴 P0, BUG THẬT
**Nguồn:** BR-53/BR-54 — `D18-06..24` = publish targets (Facebook Page, Instagram image/reel/carousel/story, TikTok video, Threads, Zalo OA text/image/template/broadcast/schedule, YouTube) × post type (text/image/video/carousel/scheduled), mỗi cái phải có màn preview publish riêng.
**Nguyên nhân:** trang `/publish` hiện chỉ render **1 preview mock chung**, không đổi UI theo platform/post-type đã chọn — nên mọi lựa chọn ra cùng 1 ảnh.
**Fix code:**
1. Vào `src/pages/publish/` (hoặc route tương ứng), tìm component render preview (`PlatformPreviewModal`/`PublishPreview`).
2. Preview phải nhận `platform` + `postType` làm prop và render mockup **khác nhau thật sự theo từng platform**: layout Instagram carousel khác Facebook feed khác TikTok video khác Zalo template khác YouTube. Có thể tái dùng logic đã có ở `editor/components/PlatformPreviewModal` (đã có multi-platform mockup cho Editor) — audit xem `/publish` có đang gọi đúng component này với đúng props không, hay đang hardcode 1 platform.
3. Sau khi UI phân biệt đúng, chụp lại 13 ảnh: mỗi ảnh ứng 1 platform/post-type cụ thể theo bảng D18-06..24 trong Jira.
**Giao việc:** cần sửa code → theo `rule_ai_team_assignment`, Lộc chia AI team, Trung duyệt trước khi merge.

### Nhóm 2 — DA-D15-25, 26, 27 (2 file thừa) — 🟡 BUG THẬT (PARTIAL)
**Nguồn:** Missing_Screens_Tracking ghi D15-25 = Revoke Role (PARTIAL), D15-26 = View Permissions/ma trận quyền (PARTIAL), cả 2 đều route `/workspaces/:id/members`. D15-27 = Permission Check Enforcement — theo bảng NO UI (8 task) đây **có thể là backend thuần** — cần xác nhận lại trong Jira trước khi build UI cho nó.
**Fix:**
1. D15-25 (Revoke Role): trong `useWorkspaceMembers.ts` (đã đọc — có sẵn `handleRemove`/`removeTarget` cho Remove Member, nhưng **chưa có action Revoke Role riêng** — hiện chỉ có set role qua dropdown chung). Cần UI riêng: nút "Revoke Role" hạ role về mức thấp nhất/guest, có confirm dialog riêng biệt với Remove Member.
2. D15-26 (View Permissions): thêm màn/modal hiển thị **ma trận quyền** (role × permission) dạng bảng, đọc từ `MANAGE_ROLES`/`ALL_ROLES` đã có ở `useWorkspaceMembers.ts:10-17`.
3. D15-27: kiểm tra Jira trước — nếu xác nhận NO UI (backend enforcement thuần) thì **bỏ khỏi danh sách phải tách ảnh**, giữ nguyên hoặc đánh dấu "no screenshot" thay vì cố tách.
**Giao việc:** Lộc chia AI team.

### Nhóm 3 — DA-D18-02, 03, 05 (2 file thừa) — 🟡 BUG THẬT
**Nguồn:** BR-51/BR-58 — `D18-01..05` = social account OAuth connect theo từng platform + rate-limit display. D18-02/03 nhiều khả năng là 2 platform OAuth connect khác nhau (vd Instagram vs TikTok), D18-05 = màn hình rate-limit usage/limit.
**Fix:**
1. Xác nhận trong Jira D18-02, 03 là platform nào — UI connect-account phải đổi logo/tên platform + OAuth scope hiển thị theo đúng platform đó (không dùng chung 1 mock "Connect Account" generic).
2. D18-05 (rate limit): cần màn/badge riêng hiển thị current usage/limit theo platform, khác hẳn màn OAuth connect — build UI riêng, không tái dùng ảnh connect.
**Giao việc:** Lộc chia AI team.

### Nhóm 4 — DA-D18-25, 26 (1 file thừa) — 🟢 FALSE POSITIVE, KHÔNG PHẢI BUG
**Nguồn:** Missing_Screens_Tracking xác nhận rõ: D18-25 = Retry (NO UI), D18-26 = DLQ/Dead Letter Queue (NO UI) — cả 2 là **backend thuần** (BR-55: retry auto + DLQ RabbitMQ), không có màn hình để tách.
**Fix:** KHÔNG chụp lại, KHÔNG build UI giả. Đánh dấu trong tracking là "no screenshot — backend only", giữ 2 file trùng hiện tại hoặc thay bằng 1 slide chú thích chung "Không có UI — xử lý backend (retry/DLQ)" để tránh gây hiểu nhầm là thiếu ảnh.

### Nhóm 5 — DA-D15-20, 22 (1 file thừa) — 🟡 CẦN TRA JIRA
**Fix:** chưa có source local xác nhận nội dung 2 task này (không nằm trong Missing_Screens_Tracking = đã build sẵn từ trước, không phải task mới build). Việc cần làm: tra 2 task Jira D15-20/D15-22 lấy route/AC thật, xác định UI hiện có (`/profile`, `/security`, `/workspaces/:id/settings`...) đã phân biệt đúng 2 chức năng chưa. Nếu UI đã có nhưng chụp nhầm ảnh cũ → chụp lại đúng theo route. Nếu UI thật sự thiếu 1 trong 2 → build bổ sung.

### Nhóm 6 — DA-D15-05, 09 (1 file thừa) — 🟡 CẦN TRA JIRA
**Fix:** tương tự nhóm 5 — D15-05 = Two-Factor Authentication (`/security`, đã xác nhận trong Missing_Screens_Tracking). D15-09 không có trong tracking → tra Jira riêng, đối chiếu route có tách biệt khỏi `/security` (2FA) không. Nếu D15-09 là 1 sub-step của 2FA (vd nhập OTP) mà đang dùng chung ảnh — chụp thêm state riêng của bước đó (không phải màn tĩnh, mà 1 step khác trong cùng flow).

### Nhóm 7 — DA-D15-13, 15 (1 file thừa) — 🟡 BUG THẬT (khớp Missing_Screens_Tracking)
**Nguồn:** D15-13 = Update Profile, D15-15 = Identity Verification. Cả 2 đều build mới ở `/profile` theo Missing_Screens_Tracking, ghi chú "gộp D15-12/13/14 vào /profile" — **rủi ro chính là do gộp nhiều FR vào 1 trang `/profile` nhưng chưa tách state/section riêng khi chụp**.
**Fix:** `/profile` cần có section/tab riêng biệt cho Update Profile (form chỉnh info) và Identity Verification (upload giấy tờ/xác minh danh tính) — 2 UI-state khác nhau rõ rệt trong cùng trang. Chụp 2 ảnh ở 2 state/tab khác nhau của `/profile`, không chụp cùng 1 view mặc định 2 lần.

### Nhóm 8 — DA-D17-05, 22 (1 file thừa) — 🟢 FALSE POSITIVE, KHÔNG PHẢI BUG
**Nguồn:** Missing_Screens_Tracking xác nhận cả D17-05 (Anti-hallucination) và D17-22 (Embedding) đều nằm trong nhóm **8 task NO UI (backend thuần)**. 2 số cách xa nhau trong dãy đúng như dự đoán ban đầu — không liên quan UI, cùng lý do "không có màn hình" nên vô tình trùng ảnh placeholder.
**Fix:** KHÔNG chụp lại. Đánh dấu "no screenshot — backend only" giống nhóm 4.

### Nhóm 9 — DA-D16-24, 26 (1 file thừa) — 🟡 CẦN TRA JIRA
**Fix:** không có trong Missing_Screens_Tracking (D16 chỉ liệt kê D16-08, D16-20 build mới) → 2 task này thuộc nhóm đã build từ trước. Tra Jira D16-24/26 lấy route/AC, đối chiếu UI hiện tại (`/calendar`, `/portal` là 2 route D16 đã biết) có tách đúng 2 chức năng chưa; nếu route đúng nhưng ảnh chụp nhầm → chụp lại.

## 6. Thứ tự thực hiện

1. Tra AC 22 task liên quan trên Jira (dùng MCP jira, board DA-D15..D19).
2. Phân loại: bug UI thật (cần code fix) vs lỗi thao tác chụp (chỉ cần chụp lại).
3. Với phần cần code fix — báo Lộc chia AI team, chờ merge xong mới chụp.
4. Với phần chỉ cần chụp lại — chụp ngay bằng chrome-devtools MCP, theme light, đúng route/state của từng task.
5. Chạy lại md5sum toàn thư mục `screenshots/`, xác nhận 0 nhóm trùng còn lại.
6. Cập nhật lại comment/attachment trên Jira task nếu ảnh cũ đã đính kèm sai.
7. Trung tự commit.

## 7. Việc KHÔNG làm trong plan này

- Không xóa file ảnh cũ tới khi có ảnh thay thế xác nhận đúng.
- Không tự ý sửa code nếu chưa xác định rõ là bug UI thật (tránh sửa nhầm khi vấn đề chỉ là thao tác chụp).
- Không commit/push.
- Không đổi theme chụp (giữ light, đồng bộ 136 ảnh hiện có).
