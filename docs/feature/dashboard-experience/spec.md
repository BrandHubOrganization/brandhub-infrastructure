# Dashboard experience
Owner quản lý Agency; Member truy cập công việc theo Workspace; dashboard cá nhân là cổng tổ chức.
## Acceptance criteria
Không mock KPI/Task/Post/bảo mật; không suy trạng thái từ ID; không trộn Workspace khác Agency.
Tab mặc định có dữ liệu; chọn tay giữ nguyên khi refresh. Owner: credit/nhân sự/Workspace thật.
Member: Task phân trang theo Workspace, nhãn phạm vi trang rõ, mở đúng Task. Không tổng KPI từ một trang.
Skeleton, empty khác lỗi, retry riêng từng nguồn; logo có fallback, button/link keyboard accessible.
VI/EN: dashboard.experience.* trong vi/dashboard.json và en/dashboard.json; light/dark dùng token BrandHub.
## Contract / scope
Tái sử dụng API hiện tại; không đổi DB, quyền backend, publish hay approval. Không thêm aggregate API.
