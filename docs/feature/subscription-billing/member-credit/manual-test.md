# Kịch bản test Credit trên Web

## Cập nhật: đã tích hợp AI và seed local — 20/10/2026

Mục này thay thế ghi chú cũ bên dưới về “chưa nối AI”/quỹ chưa được cấp. Đã chạy thêm `2026-10-20-credit-ai-execution.sql`, `2026-10-20-credit-dev-seed-source.sql` và `docs/database/seeds/2026-10-20-demo-agency-credit.sql` trên local `brandhub-postgres/brandhub`. Không init/Mongo/Atlas. Chỉ Demo Agency `23dc3d67-4c4b-4a0a-8b91-da5968dbbbb9`, Owner `user177@hotmail.com`, được cấp 100 DEV_SEED (used=0, held=0 lúc cấp). Seed chạy lại không cộng dồn. Không tạo subscription/giao dịch thanh toán giả; credit test hiển thị riêng, không phải credit mua thêm.

### Trước khi test AI

1. Restart Business bằng code mới và AI Service để áp dụng internal-key guard của hashtag; Gateway/Web chạy bình thường. Chỉ migrate nhưng giữ binary cũ thì chưa hạch toán AI đúng. Không đổi khóa nội bộ.
2. Chọn Workspace thuộc Demo Agency trên; Workspace thuộc Agency khác không có khoản 100 này.
3. Admin kiểm tra `/admin/credit-prices`. Lúc seed, giá mới nhất: CONTENT_GENERATE=3, AMBASSADOR_GENERATE=10. Thao tác khác chưa có giá phải cấu hình trước; không tự miễn phí. Không tự đổi giá để khớp ví dụ.
4. Manager/Creator cần membership Agency/Workspace hoạt động. Mặc định 10/kỳ nếu Owner chưa cấu hình; Owner không có trần cá nhân nhưng vẫn chịu quỹ chung. Đã chốt mở Editor và AI Studio cho Owner dùng AI; quyền sửa Task/gửi duyệt/xuất bản ở Backend không thay đổi.

### Kịch bản AI

| Thao tác | Kỳ vọng |
| --- | --- |
| Mở báo cáo Demo Agency trước lần tạo đầu | Tổng khả dụng 100; DEV_SEED 100; Plan/mua thêm/used/held=0. |
| Tạo nội dung thành công, giá vẫn 3 | Còn 97; usage người gửi tăng 3, held=0. Áp dụng lại kết quả vào Editor không trừ thêm. |
| Bấm tạo lại có chủ ý | Mã yêu cầu mới; thành công trừ thêm theo giá lúc gửi. |
| Retry kỹ thuật cùng payload và Idempotency-Key | Không gọi/trừ lần hai; đang chạy báo pending, đã xong trả kết quả đã lưu. Không đổi payload với cùng mã. |
| Thành viên trần 10, đã dùng 9, tạo thêm giá 3 | Chặn CREDIT_MEMBER_LIMIT_REACHED trước khi gọi AI. |
| Thao tác chưa có giá | CREDIT_PRICE_NOT_CONFIGURED; không gọi AI/giữ credit. |
| Ambassador thành công giá 10 | Trừ 10. Character Sheet/commercial cần giá riêng; không tính số panel thành nhiều ảnh. |
| Video đang xử lý | Giữ giá một video, chưa tăng used. Đóng Editor vẫn có worker đối soát. |
| Video COMPLETED có URL | Trừ đúng một lần theo giá lúc gửi; Admin đổi giá/poll lại không đổi khoản này. |
| Video FAILED/kết quả đồng bộ xác nhận không có đầu ra | Giải phóng hold, không tăng used. |
| Timeout/mất kết nối/HTTP 5xx chưa rõ kết quả | Báo cần đối soát, giữ credit; không tự hoàn/gọi lại provider. Không bấm tạo mới để retry kỹ thuật. Chưa có UI Admin xử lý thủ công kết quả mơ hồ. |

Không dùng seed để reset số đã dùng/đang giữ; không xóa reservation hoặc tạo thanh toán giả. Các test cấu hình phía dưới vẫn áp dụng, nhưng quỹ không còn 0 sau seed.

## 1. Trạng thái DB sau migration — 20/10/2026

Đã áp dụng theo thứ tự trên PostgreSQL **local**, container `brandhub-postgres`, database/schema `brandhub.public`:

1. `2026-10-19-member-credit-configuration.sql` — COMMIT thành công.
2. `2026-10-20-credit-accounting.sql` — COMMIT thành công.

Preflight không có schema Credit 8 bảng cũ. Kiểm tra sau chạy đạt: 4 bảng mới, 9 cột bổ sung trên Agency/thành viên, index và trigger lịch sử giá. Không chạy init, không seed giá, không cấp credit, không chạm Mongo/Atlas. Số dòng trước/sau giữ nguyên: 53 Agency, 798 thành viên Agency, 50 ledger cũ, 50 hạn mức Creator cũ.

Tại thời điểm vừa migrate, cả 4 bảng Credit mới rỗng; hạn mức riêng/mặc định và cycle anchor đều NULL, revision cấu hình bằng 0. Dữ liệu ledger/Creator limit cũ vẫn còn nhưng không tự nhập vào báo cáo mới.

**Lưu ý:** các thao tác test bên dưới sẽ lưu cấu hình thật. Dùng Agency dành cho kiểm thử, ghi lại cấu hình/giá trước khi đổi; không dùng Agency của thành viên khác. Chưa có thao tác xóa override để quay lại kế thừa trên UI/API; dùng một thành viên khác chưa có override để kiểm tra kế thừa. Giá là lịch sử append-only: khôi phục bằng cách lưu phiên bản mới, không DELETE lịch sử.

## 2. Chuẩn bị

- Restart Business bằng code Credit compact mới nhất, chạy Gateway và Web hiện tại. Migration không tự khởi động lại service.
- Chuẩn bị Owner đúng Agency, hai thành viên nội bộ để thử kế thừa/override, Manager/Creator và một Admin. Client dùng để kiểm tra chặn truy cập. Manager/Creator phải thực sự thuộc Agency; role Workspace không thay thế membership Agency.
- Vào Agency, chọn **AI Credit**, hoặc mở `http://localhost:3000/agency/{agencyId}/credit`.
- Admin mở `http://localhost:3000/admin/credit-prices`.
- Ví dụ DB hiện có **Demo Agency**: `23dc3d67-4c4b-4a0a-8b91-da5968dbbbb9`. Chỉ dùng nếu bạn có đúng tài khoản Owner/thành viên của Agency đó; có thể chọn Agency test khác.
- Mở DevTools → Network khi cần xem request/status. Không gửi token hay thông tin đăng nhập cho người khác.

## 3. Những phần test được ngay

| ID | Vai trò / thao tác | Kết quả mong đợi |
| --- | --- | --- |
| C01 | Owner mở AI Credit sau migration, trước khi cấu hình | Quỹ Plan/mua thêm/đang giữ đều 0. Hạn mức mặc định để trống vì chưa cấu hình, không tự ghi 0 hoặc cấp tiền. |
| C02 | Owner chọn một thành viên chưa có override | Một lần bấm mở chi tiết; hạn mức hiệu lực là 10 từ hệ thống. Không tải chi tiết Credit cho mọi thành viên ngay khi mở trang. |
| C03 | Owner lưu hạn mức mặc định 20 | Lưu thành công; revision tăng. Thành viên chưa có override nhận mức 20; quỹ vẫn 0. Reload trang vẫn giữ cấu hình. |
| C04 | Owner đặt riêng thành viên A là 30 | A có nguồn “Hạn mức riêng”, giữ 30 sau reload. Thành viên B chưa có override vẫn kế thừa 20. Mức 30 lớn hơn quỹ 0 vẫn được cấu hình vì đây là trần, không phải chia tiền. |
| C05 | Owner đổi mặc định 20 → 25 | A vẫn 30; B nhận 25 khi đọc lại. Nếu đang nhập draft chưa lưu ở form thành viên, refresh mặc định không được xóa draft. Bấm tải lại form để nhận giá trị đã lưu. |
| C06 | Owner đặt hạn mức riêng A là 0 | Hiển thị 0, không biến thành không giới hạn. Đăng nhập A thấy mức 0. Chưa dùng Generate để chứng minh bị chặn vì AI chưa nối Credit. |
| C07 | Owner đặt mặc định 0 | Thành viên chưa có override nhận 0; A có override vẫn theo mức riêng. Không xóa hoặc hoàn tiền bất kỳ khoản nào. |
| C08 | Nhập rỗng, -1, 1.5, 1e3 hoặc 9007199254740992 vào form hạn mức/giá | Lỗi tại ô nhập; không gửi PUT. Nhập số nguyên hợp lệ rồi Enter hoặc Lưu đều hoạt động. Không có hộp thoại mặc định của trình duyệt. |
| C09 | Hai tab Owner cùng đọc một phiên bản chính sách; tab A lưu 20, tab B lưu 30 mà chưa tải lại | Tab B nhận 409, giữ draft 30 và khóa lưu phiên bản cũ. Tải lại nhận 20, sau đó mới sửa/lưu tiếp. |
| C10 | Nhập draft 77 nhưng không lưu, bấm “Tải lại bản đã lưu” | Trở lại giá trị thực do server trả về, kể cả revision không đổi. Không tự gửi draft. |
| C11 | Owner mở “Xem sử dụng của tôi” | Có thông tin Owner không có trần cá nhân. Với DB chưa được cấp credit/cycle, phần usage hiển thị trạng thái chưa thiết lập kỳ, không dựng số liệu 0 giả. |
| C12 | Manager/Creator mở AI Credit | Chỉ thấy hạn mức hiệu lực, nguồn hạn mức, usage của mình và bảng giá chỉ đọc. Không có form đặt hạn mức hoặc quỹ chung của Owner. Network không gọi các API Owner-only. |
| C13 | Client mở URL AI Credit; thử cả URL có dấu / cuối | Không vào được màn hình Credit. Non-admin mở `/admin/credit-prices` cũng bị chặn. |
| C14 | Chuyển Agency hoặc đăng xuất rồi đăng nhập thành viên khác | Không giữ quỹ/form/quyền Owner của Agency hoặc người trước. Owner Agency A không có quyền chỉnh chính sách Agency B nếu chỉ là thành viên B. |
| C15 | Tìm thành viên theo tên/email rồi chọn A/B | Danh sách lọc đúng; chi tiết đúng người. Không có Owner trong danh sách chỉnh hạn mức riêng. Không lẫn input/usage giữa A và B. |

## 4. Admin cấu hình giá

Các con số sau **chỉ là giá test tự chọn**, không phải bảng giá nghiệp vụ đã chốt. Ghi lại trạng thái cũ trước khi thay đổi.

| ID | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| P01 | Admin mở trang giá sau migration chưa có giá | Ô giá trống và có trạng thái chưa cấu hình; không hiểu là miễn phí. |
| P02 | Chọn CONTENT_GENERATE, nhập giá test 3, bật sử dụng rồi lưu | Có phiên bản giá mới. Nếu chưa có lịch sử, revision là 1. Member mở bảng giá thấy 3 credit/yêu cầu. |
| P03 | Đổi cùng thao tác thành 5 và lưu | Revision tăng; API GET giá trả bản mới nhất. Không có nút sửa/xóa phiên bản lịch sử. |
| P04 | Đặt giá test 0 và bật sử dụng | Hiển thị 0 rõ ràng, khác với chưa cấu hình. Đây chỉ là cấu hình miễn phí có chủ đích, chưa chứng minh flow AI đã dùng giá này. |
| P05 | Ngừng sử dụng giá rồi mở bảng giá bằng Member | Giá vẫn hiển thị nhưng trạng thái tạm ngừng; không trở thành chưa cấu hình hoặc 0. |
| P06 | Lần lượt chọn nội dung/caption/hashtag, ảnh/đại sứ/bộ nhân vật và video | Hiện đơn vị theo yêu cầu, ảnh hoặc video thành công. Bộ nhân vật tính ảnh đầu ra, không tính số ô trong ảnh. |
| P07 | Hai tab Admin sửa cùng operation từ cùng revision | Một bản lưu thành công, bản cũ nhận 409 và yêu cầu tải lại; không ghi đè im lặng. |

## 5. Phân biệt chưa thiết lập kỳ với lỗi

**Kết quả đúng với DB vừa migrate:**

- `GET /api/v1/agencies/{agencyId}/credit/balance` bằng Owner trả 200 với quỹ 0.
- Các GET/PUT policy và hạn mức hoạt động sau khi Business đã nạp API mới.
- `GET .../credit/usage/me` hoặc `GET .../credit/members/{memberId}/usage` trả **409 CREDIT_ACCOUNT_NOT_READY**, vì chưa có grant hợp lệ thiết lập `credit_cycle_anchor`.
- Web vẫn xem/sửa được cấu hình; báo cáo theo kỳ hiện thông báo chuẩn bị tích hợp, không coi đó là thiếu migration.
- Nếu vẫn nhận **503 CREDIT_SCHEMA_NOT_READY**, kiểm tra Business có kết nối đúng PostgreSQL local `brandhub`, đúng code/schema compact hay không. Không chạy init hoặc xóa bảng để thử.
- Nếu nhận 404 endpoint mới, kiểm tra/restart đúng Business build và Gateway. Nếu 401, đăng nhập lại và kiểm tra luồng xác thực, không seed DB để xử lý lỗi quyền.

## 6. Phần chưa test được xuyên suốt từ Web

Hiện chưa nối các API AI và thanh toán/subscription vào accounting. Vì vậy:

- Bấm Generate chưa phải bằng chứng credit đã được giữ/trừ/hoàn.
- Mua/gia hạn subscription không được giả định đã cấp quỹ mới.
- Chưa có nút cấp tiền, grant/reserve/settle public hoặc bộ lọc lịch sử nhiều kỳ trên Web.
- Không tự INSERT grant/transaction giả hoặc chỉnh cycle anchor trên DB đang dùng để làm báo cáo có số liệu.

Khi có môi trường test riêng và nguồn grant hợp lệ, kiểm tra tiếp:

| ID | Điều kiện / thao tác | Mong đợi |
| --- | --- | --- |
| F01 | Quỹ ban đầu Plan 100 + mua thêm 50, thành viên có trần 10; giữ 2 ảnh giá test 3/ảnh | Plan khả dụng 94, mua thêm 50, tổng khả dụng 144, đang giữ 6. Hạn mức cá nhân còn 4. |
| F02 | Tác vụ F01 chỉ thành công 1 ảnh, xác nhận quyết toán | Đã dùng 3, đang giữ 0, Plan khả dụng 97, tổng khả dụng 147; hạn mức còn 7. Hoàn phần giữ dư về đúng nguồn. |
| F03 | Gửi lại cùng request kỹ thuật / nhận callback lặp | Không giữ/trừ lặp. Chủ động tạo lại nội dung là yêu cầu mới. |
| F04 | Hai yêu cầu đồng thời vượt trần cá nhân/quỹ chung | Không vượt giới hạn; chỉ yêu cầu đủ điều kiện được giữ tiền. |
| F05 | Sang kỳ subscription tiếp theo | Usage kỳ mới tính lại; hạn mức Owner đã đặt giữ nguyên. Credit Plan cũ không rollover, mua thêm còn dư vẫn được dùng. |
| F06 | Tác vụ kỳ cũ hoàn tất sau khi sang kỳ mới | Tính theo giá và kỳ của yêu cầu gốc; không cộng vào usage kỳ mới. |

Các ca lõi này đã được kiểm tra bằng service/JDBC trên PostgreSQL cô lập; **chưa xác nhận flow browser → provider/payment thật**.

## 7. Kiểm tra UI và ghi nhận lỗi

- Chuyển Việt/Anh, sáng/tối; thử 375/768/1440px. Nhãn/số liệu không tràn trang; bảng được phép cuộn nội bộ khi dữ liệu dài.
- Thử bàn phím, Enter lưu, nút `?`, tìm/chọn thành viên. Thông báo lỗi không làm mất nội dung chưa lưu.
- Dùng DevTools Request blocking chặn riêng GET `/credit/usage/me`, rồi bấm làm mới: hiện lỗi và thử lại, không thay bằng usage 0. Bỏ chặn rồi thử lại; không cần tắt toàn bộ mạng hoặc reload khi đang offline.
- Khi báo lỗi, gửi vai trò, Agency ID, URL, thao tác, status/error code và requestId. Không gửi Authorization/Cookie/token.
- Không gọi các endpoint Billing placeholder: `/api/v1/billing/credits/buy`, `/api/v1/billing/credits/{agencyId}/usage`, `/api/v1/billing/credits/{agencyId}/limits`.
