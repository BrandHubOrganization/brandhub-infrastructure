# 08 — Subscription & Billing

> [<< Về Overview](00_Overview.md)

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
- Đây khớp với mô hình 3 tầng ở [01_Organization_Structure.md](01_Organization_Structure.md): User là Owner của Agency, Agency chứa nhiều Workspace — Plan giới hạn ở tầng User/Owner sẽ tác động toàn bộ Agency của họ.

### ACID cho Make Payment (3.9.3)
- Yêu cầu kỹ thuật rõ ràng: giao dịch thanh toán phải đảm bảo tính toàn vẹn ACID (Atomicity, Consistency, Isolation, Durability) — quan trọng vì liên quan tiền thật qua PayOS.

### Credit AI — 2 lớp kiểm soát
- **View AI Credit Tracking** (3.9.5): cả Creator (xem mình đã dùng bao nhiêu) và Owner (giám sát toàn Agency) đều xem được.
- **Set Credit** (3.9.7): CHỈ Owner mới đặt được hạn mức tiêu credit cho từng Creator — đây là cơ chế kiểm soát chi phí AI nội bộ Agency, ngăn 1 Creator dùng vượt quá ngân sách được cấp.
- **Buy Credit** (3.9.6): CHỈ Owner mua thêm — Creator không tự mua credit cho mình.
