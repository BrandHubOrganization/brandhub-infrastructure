# 07 — Publishing & Social + Third-party Collaborator (mở rộng mới)

> [<< Về Overview](00-overview.md)

## 1. Publishing & Social (FR 3.8.1 – 3.8.16) — tự động qua API

### Kết nối/ngắt tài khoản
- **Connect Social Account** (3.8.1): kết nối tài khoản để Client login vào toàn bộ tài khoản đăng bài tự động. Role: CLIENT.
- **Disconnect Account** (3.8.2): ngắt kết nối, log out khỏi mạng xã hội. Role: CLIENT.

### Dashboard & tracking
- **View Dashboard Post** (3.8.3): trang tổng quan trong workspace khi đăng thành công lên social. Role: MEMBER.
- **View Post Track Detail** (3.8.4): chi tiết bài đăng — reaction, comment, share count. Role: MEMBER.
- **View Comment Detail List** (3.8.5): danh sách chi tiết comment từ bài post. Role: MEMBER.
- **Preview Post** (3.8.6): xem trước layout theo từng mạng xã hội khi Creator sửa/làm bài. Role: MEMBER.
- **Schedule Platform Post** (3.8.7): trang lịch đăng bài, xem theo lịch cụ thể. Role: MEMBER.
- **View Status Tracking** (3.8.8): theo dõi tiến độ — Pending, In Progress, Done, Fail. Role: MEMBER.

### Publish theo từng platform (3.8.9 – 3.8.16)

| FR | Platform + loại content |
|---|---|
| 3.8.9 | Publish Facebook Post |
| 3.8.10 | Publish Facebook Story |
| 3.8.11 | Publish Facebook Reels |
| 3.8.12 | Publish Instagram Post |
| 3.8.13 | Publish Instagram Reels |
| 3.8.14 | Publish Instagram Story |
| 3.8.15 | Publish TikTok Video |
| 3.8.16 | Publish Threads Post |

Tất cả role: MEMBER. Đây là hàng đợi Publish nhận Task loại **Post** đã hoàn thành Approval Sequence (xem [05-content-task-workflow.md](05-content-task-workflow.md) mục 4).

**Lưu ý phạm vi**: nhóm FR này giữ nguyên các platform social hiện có (Facebook, Instagram, TikTok, Threads) — KHÔNG có Zalo OA (đã loại khỏi scope theo quyết định trước — xem lịch sử session, không thuộc phạm vi tài liệu BA này).

## 2. Third-party Collaborator — module MỞ RỘNG mới (chưa có trong CSV gốc, xác nhận qua hỏi-đáp)

**[CONFIRMED 2026-09-14]** Đây là điểm mở rộng nghiệp vụ lớn nhất ngoài phạm vi social media — phản ánh yêu cầu "mở rộng một chiến dịch truyền thông số rộng hơn, có tính lan tỏa nhiều hơn qua nhiều phương tiện truyền thông khác nhau" của Trung.

### Vấn đề
- FR 3.7.12 (Recommend Collaborator) chỉ gợi ý AI cho đối tác truyền thông ngoài social media: **báo điện tử, đối tác chạy banner, kênh TV**.
- Các đối tác này **không có API** như Facebook/TikTok — không thể tự động hóa đăng bài.
- Nhưng Agency vẫn cần **theo dõi trạng thái hợp tác** với các đối tác đó như 1 phần của Media Campaign.

### Giải pháp đã chốt
- Cần **1 module/entity riêng** — "Third-party Collaborator" (tên đề xuất, chưa chốt chính thức) — để lưu:
  - Thông tin liên hệ đối tác (tên báo/đài/đơn vị chạy banner, người liên hệ, kênh liên hệ).
  - Trạng thái hợp tác: **đã liên hệ → đang đàm phán → đã chốt → đã lên sóng**.
- **Không tự động hóa đăng bài** lên các kênh này — chỉ là tracking thủ công do Manager/Creator cập nhật tay.
- Gắn với **Media Campaign hoặc Task cụ thể** — 1 Campaign có thể có nhiều Collaborator khác nhau.
- AI Recommend Collaborator (FR 3.7.12, xem [06-ai-features.md](06-ai-features.md)) chỉ đưa ra gợi ý ứng viên ban đầu — không tác động vào trạng thái hợp tác.

### Việc CẦN LÀM tiếp (chưa thiết kế chi tiết)
- Chưa có entity/DB schema chính thức cho Third-party Collaborator — cần thiết kế field cụ thể (tên đối tác, loại kênh, chi phí, người phụ trách, ghi chú, trạng thái, lịch sử thay đổi trạng thái...).
- Chưa có FR số hiệu chính thức trong CSV — đây là module PHÁT SINH ngoài 109 FR gốc, cần bổ sung số FR mới khi cập nhật CSV chính thức (đề xuất: nhóm vào 3.8, ví dụ 3.8.17 – 3.8.2x, hoặc nhóm riêng 3.11 "Third-party Media Collaboration").
