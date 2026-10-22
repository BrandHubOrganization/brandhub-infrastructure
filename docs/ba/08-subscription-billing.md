# 08 — Subscription & Billing

> [<< Về Overview](00-overview.md)

## Quyết định hiện hành — 2026-10-19

**Bổ sung đã chốt 2026-10-20:** hạn mức fallback hệ thống 10 credit/thành viên/kỳ; Owner được đặt mặc định Agency hoặc mức riêng để ghi đè. Nội dung/hashtag tính theo yêu cầu thành công, ảnh/video theo từng sản phẩm thành công (thành công một phần chỉ tính phần thành công). Ví dụ 3 credit/ảnh không phải giá đã chốt. Subscription hết hạn vẫn reset hạn mức hàng tháng theo anchor chu kỳ cũ; credit mua thêm không hết hạn. Cấp số dư qua đầu nối Subscription/Payment có chống trùng, không tự suy thanh toán từ trạng thái ACTIVE.

Chủ sản phẩm chốt quản lý credit theo **thành viên trong một Agency**, không chỉ Creator:

- Owner/Manager/Creator dùng AI; Client không dùng. Owner không có hạn mức cá nhân nhưng vẫn bị giới hạn bởi số dư chung Agency.
- Owner đặt hạn mức mặc định Agency và ghi đè từng thành viên; tổng hạn mức có thể lớn hơn quỹ chung vì đây là trần cá nhân, không phải chia ví. Mặc định hệ thống đã chốt là 10 credit/thành viên/kỳ; không phải khoản cấp tiền.
- Usage reset theo kỳ subscription; giữ nguyên hạn mức cấu hình. Credit Plan không rollover; dùng trước credit mua thêm. Credit mua thêm không hết hạn và vẫn dùng được khi subscription hết hạn/hủy.
- Admin cấu hình giá từng thao tác; giữ giá phiên bản tại thời điểm nhận yêu cầu AI. Giá mới không thay giá tác vụ đang chạy.
- Subscription/Payment do thành viên khác phụ trách; đợt này quản lý một Agency, không tự cấp nhân đôi định mức subscription của Owner sang các Agency khác.

Các mục Creator/tháng bên dưới là mô tả lịch sử; quyết định này ưu tiên khi khác nhau. Xem [đặc tả và trạng thái triển khai](../feature/subscription-billing/member-credit/spec.md). DA-974 hiện đã có cấu hình, báo cáo và giữ/quyết toán Credit trên các API AI theo đơn giá thao tác đã chốt lúc gửi. Thanh toán tự động và tính phí theo token/tài nguyên self-host Vast chưa nằm trong phần triển khai này.

## Danh sách FR đầy đủ (3.9.1 – 3.9.7)

| FR | Tên | Role | Mô tả |
|---|---|---|---|
| 3.9.1 | Upgrade Plan | USER | Default user mới tạo = gói **Basic**. Upgrade lên Pro/Enterprise để tạo nhiều workspace, nhiều credit AI, dùng tính năng nâng cao |
| 3.9.2 | Downgrade Plan | OWNER | Hủy gói khi không còn nhu cầu |
| 3.9.3 | Make Payment (PayOS) | USER | Tạo Transaction cho upgrade gói, mua thêm credit — **tuân thủ ACID** |
| 3.9.4 | View Invoice History | OWNER | Xem lịch sử giao dịch tài khoản |
| 3.9.5 | View AI Credit Tracking | CREATOR, OWNER | Giám sát lượng credit Creator đã dùng cho AI feature trong tháng (tạo ảnh, content, video) |
| 3.9.6 | Buy Credit | OWNER | Mua thêm credit khi hết credit trong gói Pro/Enterprise |
| 3.9.7 | Set Credit | OWNER | Owner đặt hạn mức tiêu credit cho Creator |

## Ghi chú nghiệp vụ quan trọng

### Gắn Plan với Agency, không phải Workspace
- Plan (Basic/Pro/Enterprise) là thuộc tính của **User/Owner**, ảnh hưởng số lượng Workspace được tạo và credit AI khả dụng — không phải mua riêng theo từng Workspace.
- Đây khớp với mô hình 3 tầng ở [01-organization-structure.md](01-organization-structure.md): User là Owner của Agency, Agency chứa nhiều Workspace — Plan giới hạn ở tầng User/Owner sẽ tác động toàn bộ Agency của họ.

### ACID cho Make Payment (3.9.3)
- Yêu cầu kỹ thuật rõ ràng: giao dịch thanh toán phải đảm bảo tính toàn vẹn ACID (Atomicity, Consistency, Isolation, Durability) — quan trọng vì liên quan tiền thật qua PayOS.

### Credit AI — 2 lớp kiểm soát
- **View AI Credit Tracking** (3.9.5): cả Creator (xem mình đã dùng bao nhiêu) và Owner (giám sát toàn Agency) đều xem được.
- **Set Credit** (3.9.7): CHỈ Owner mới đặt được hạn mức tiêu credit cho từng Creator — đây là cơ chế kiểm soát chi phí AI nội bộ Agency, ngăn 1 Creator dùng vượt quá ngân sách được cấp. **[CONFIRMED 2026-09-17]** Hạn mức là **cứng (hard limit)** — khi Creator dùng hết credit được cấp, hệ thống **chặn hẳn** thao tác AI tiếp theo của Creator đó (không phải chỉ cảnh báo/soft warning), cho tới khi Owner cấp thêm hoặc reset hạn mức tháng sau.
- **Buy Credit** (3.9.6): CHỈ Owner mua thêm — Creator không tự mua credit cho mình.
