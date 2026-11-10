# Media Package và Campaign

## Spec hiện hành

BA chốt ngày 2026-11-05 nằm tại [Guest sharing và hành trình do Manager quản lý](guest-sharing-manager-led/spec.md). Đây là đặc tả cho đợt thay đổi tiếp theo. Code, API/DB contract, migration và bằng chứng kiểm thử cũ cần được đánh giá khi lập plan triển khai.

- Owner quản lý gói quảng bá của Agency, xuất ảnh/PDF hoặc chia sẻ link guest.
- Guest xem không cần tài khoản. Owner chia sẻ gói Agency; Manager phụ trách/Owner có quyền quản lý cũng chia sẻ được Custom Package workspace. Cùng một link luôn hiển thị bản mới nhất đã lưu của đúng gói được chia sẻ; hỗ trợ xuất ảnh/PDF cho cả hai phạm vi.
- Owner tạo workspace và gán Manager trước khi có Client. Manager thống nhất gói với Client bên ngoài hệ thống.
- Manager chọn gói Agency để tùy chỉnh hoặc tạo gói workspace mới. Lưu gói hợp lệ tự tạo một Campaign DRAFT và task lớn theo gói.
- Client được mời vào để xem gói đã ghi nhận, xem Campaign và comment góp ý cả khi còn DRAFT.
- Luồng mới bỏ Client chọn/đàm phán/duyệt gói và bỏ duyệt Campaign hai phía.
- Manager sửa gói trước triển khai, đồng bộ kế hoạch/task có kiểm soát. Bản gói/kế hoạch được cố định khi triển khai và khóa sau triển khai.
- Manager chủ động triển khai khi đủ điều kiện. Thành viên bắt đầu thực hiện khi Campaign IN_PROGRESS.

Một workspace tiếp tục có một Campaign. Duyệt kết quả Task/bài đăng, xuất bản, Content Request và điều kiện đóng Campaign theo các spec riêng.

## Tài liệu đối chiếu

| Nội dung | Tài liệu |
|---|---|
| Quy tắc BA chung | [04-media-package-campaign.md](../../ba/04-media-package-campaign.md) |
| Workspace và thời điểm mời Client | [01-organization-structure.md](../../ba/01-organization-structure.md) |
| Vòng đời Package/Campaign | [12-state-machines.md](../../ba/12-state-machines.md) |
| Tạo gói Agency, lưu gói workspace | [FR 3.5.1](3-5-1-create-media-package/spec.md) |
| Guest view và Client xem gói | [FR 3.5.2](3-5-2-view-the-template-media-package/spec.md) |
| Chốt ngoài hệ thống, chỉnh trước triển khai | [FR 3.5.3](3-5-3-request-media-package/spec.md) |
| Thay flow duyệt Package | [FR 3.5.4](3-5-4-approve-media-package/spec.md) |
| Campaign DRAFT từ gói | [FR 3.5.5](3-5-5-create-media-campaign/spec.md) |
| Góp ý, triển khai và bỏ duyệt Campaign | [FR 3.5.6](3-5-6-approve-media-campaign/spec.md) |
| Task/subtask từ gói | [Package-driven campaign tasks](./3-5-5-create-media-campaign/package-driven-campaign-tasks/spec.md) |
| Hoàn thành Campaign | [Campaign closure](campaign-closure/spec.md) |

## Phạm vi tài liệu cũ

Các plan, task, test, sequence/class diagram, offering-models, phase-1-design, remaining-work và roadmap trước ngày 2026-11-05 lưu bối cảnh triển khai cũ. Những đoạn yêu cầu Client chọn gói, thương lượng/duyệt Package hai phía, duyệt Campaign hoặc khóa theo APPROVED đã được spec mới thay thế trong phạm vi nêu trên.

Không dùng kết quả kiểm thử hay trạng thái Implemented của flow cũ để xác nhận flow mới đã hoàn thành. Đợt hiện tại chỉ cập nhật spec và BA liên quan. Khi triển khai cần cập nhật lần lượt plan, task và test, xác định ảnh hưởng lên quyền truy cập, endpoint, dữ liệu cũ và các module liên quan.

Các điểm còn thuộc bước thiết kế kỹ thuật được liệt kê ở mục 11 của spec mới. Không tự chuyển đổi approval/historical data hoặc tạo lượt duyệt giả cho Client.
