# FR 3.5.4 — Thay bước duyệt Package bằng ghi nhận gói của Manager

Cập nhật BA 2026-11-05. Bước duyệt Package hai phía trong spec cũ đã được thay thế bởi [hành trình Manager quản lý](../guest-sharing-manager-led/spec.md).

## Quy tắc hiện hành

- Manager chốt nội dung với Client bên ngoài và lưu gói workspace theo thỏa thuận.
- Không yêu cầu Client chọn hoặc bấm duyệt gói trong hệ thống. Không chờ timestamp/version approval của Client để tạo Campaign/task.
- Lưu gói đủ điều kiện tự tạo Campaign DRAFT và task lớn theo gói. Không có nút Manager xác nhận gói riêng sau bước lưu này.
- Các lần lưu sau dùng cùng gói/Campaign và đồng bộ phần thay đổi trước triển khai.
- Client được mời vào để xem gói đã ghi nhận và góp ý Campaign. Membership không phụ thuộc vào việc Client hoàn thành thao tác duyệt Package.
- Manager có thể chuẩn bị gói/Campaign trước khi workspace có Client. Module nào cần Client để duyệt kết quả Task vẫn kiểm tra điều kiện riêng của module đó.
- Thay điều kiện khóa theo Package APPROVED bằng thời điểm cố định bản triển khai và khóa sau triển khai theo spec mới.

## Tương thích và UI

Lịch sử duyệt cũ là dữ liệu lịch sử cần giữ. Chuyển đổi trạng thái/field legacy được thiết kế riêng trước implementation, không suy approval mới cho Client. UI mới bỏ CTA/gate/checklist duyệt gói của Client và có vi/en, light/dark, loading/error/permission states tương ứng.

Tài liệu này thay hành vi FR cũ, chưa phải hợp đồng endpoint hoặc migration đã được triển khai.
