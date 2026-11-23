# Admin Plan Editor — spec

## Objective
Admin chỉnh giá, hạn mức và trạng thái mở bán của 6 gói (BASIC, PLUS, ENTERPRISE, STUDIO_FREE, STUDIO_PLUS,
STUDIO_PRO) ngay trên web, không cần viết migration SQL. Landing đọc bảng giá từ hệ thống thay vì ghi cứng.

## User Story
Là **Admin**, tôi muốn tăng/giảm AI Credit, dung lượng, số workspace… hoặc đổi giá của một gói và ghi lý do,
để vận hành điều chỉnh gói theo chi phí thực tế mà không làm ảnh hưởng khách đã trả tiền.

## Quyết định nghiệp vụ (đã chốt với chủ dự án 2026-11-22)
1. Sửa gói = tạo **phiên bản gói mới**. Khách đang dùng giữ phiên bản cũ đến hết kỳ đã trả.
2. Mua mới **và gia hạn** nhận phiên bản mới nhất (luồng đặt hàng hiện có đã chọn bản `is_sellable` mới nhất).
3. Admin sửa được: hạn mức, giá tháng, giá trả trước 3/6/12 tháng, bật/tắt bán.
4. Mỗi thay đổi bắt buộc nhập lý do; lưu người sửa, thời điểm, lý do; xem lại các phiên bản cũ.
5. Landing + trang chọn gói đọc giá/hạn mức từ API.

## Acceptance Criteria
- AC1 Trang `/admin?view=plans` liệt kê 6 gói theo 2 dòng (Studio / Agency): phiên bản hiện tại, giá tháng,
  giá 3/6/12, các hạn mức, trạng thái mở bán, số khách đang ở phiên bản đó.
- AC2 Sửa gói: form chứa giá trị hiện tại; lưu tạo version = max+1, các phiên bản cũ thôi bán, trạng thái mở bán
  giữ như bản trước. Không đổi gì → lỗi "không có thay đổi".
- AC3 Gói miễn phí (BASIC, STUDIO_FREE): giá cố định 0, không có giá trả trước. Gói trả phí: giá tháng > 0 và
  đủ 3 giá 3/6/12 > 0.
- AC4 Hai admin cùng sửa: người lưu sau nhận lỗi xung đột phiên bản (gửi `expectedVersion`).
- AC5 Bật/tắt bán chỉ đổi cờ trên bản mới nhất, cần lý do, được ghi lịch sử. Tắt bán → trang chọn gói không cho
  thanh toán gói đó; khách đang dùng không đổi.
- AC6 Lịch sử: danh sách phiên bản (mới → cũ) + các thay đổi (hành động, người sửa, thời điểm, lý do).
- AC7 Khách đang dùng phiên bản cũ: hạn mức, credit hàng tháng, dung lượng gói miễn phí, quota newsletter tiếp
  tục theo phiên bản cũ.
- AC8 Landing hiển thị giá/hạn mức từ `GET /api/v1/public/billing/plans?line=STUDIO|AGENCY` (không cần đăng nhập,
  giới hạn theo IP).
- AC9 i18n: key mới thêm song song `vi` + `en` (`admin.plans.*`, `landing.pricing.*`). Không chuỗi cứng trong JSX.
- AC10 Light/Dark: chỉ dùng token/biến theme và `dark:` variant có sẵn.

## API Contract
| Method | Path | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/v1/admin/billing/plans` | Admin | 6 gói, bản mới nhất + số khách |
| PUT | `/api/v1/admin/billing/plans/{code}` | Admin | Tạo phiên bản mới |
| POST | `/api/v1/admin/billing/plans/{code}/sale` | Admin | `{ sellable, reason }` |
| GET | `/api/v1/admin/billing/plans/{code}/history` | Admin | Phiên bản + nhật ký |
| GET | `/api/v1/public/billing/plans?line=` | Guest | Catalog một dòng gói |

PUT body: `expectedVersion, priceMonthly, cyclePrices{3,6,12}, maxActiveWorkspaces, maxInternalMembers, maxClients,
storageLimitBytes, monthlyAiCredits, maxConcurrentAiJobs, versionRetentionDays, trashRetentionDays,
activityRetentionDays, newsletterEmailQuota, reason`.

## Error Handling
- `PLAN_NOT_FOUND` (404) mã gói không hợp lệ.
- `PLAN_VERSION_CONFLICT` (409) `expectedVersion` khác bản mới nhất.
- `PLAN_UNCHANGED` (400) không có trường nào đổi.
- `VALIDATION_ERROR` (400) giá/hạn mức sai quy tắc AC3 hoặc ngoài giới hạn.

## Edge Cases
- Enterprise vốn không bán qua SePay (`Liên hệ sales`): bật bán chỉ đổi cờ, checkout vẫn không mở.
- Gói miễn phí: khách hiện có không bao giờ "gia hạn" nên giữ phiên bản cũ; công ty mới / hết hạn rơi về bản mới.

## Out of Scope
Mobile app; thêm/xóa gói mới; đổi tên gói; báo cáo SRS (Report 3–7).
- Gói miễn phí **không được tắt bán**: công ty mới được gán bản miễn phí `is_sellable` mới nhất
  (`AgencyServiceImpl`), tắt bán sẽ làm đăng ký công ty lỗi → `PLAN_SALE_LOCKED` (400).
