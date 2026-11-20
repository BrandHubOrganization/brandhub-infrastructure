-- Post templates table (PostTemplate entity) + FPTU 2027 workspace templates previously hardcoded in brandhub-web.
BEGIN;

CREATE TABLE IF NOT EXISTS workspace_post_templates (
    id uuid PRIMARY KEY,
    workspace_id uuid NOT NULL,
    title varchar(200) NOT NULL,
    caption text NOT NULL,
    category varchar(60),
    platforms jsonb,
    hashtags jsonb,
    created_by uuid NOT NULL,
    deleted_at timestamptz,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_workspace_post_templates_ws
    ON workspace_post_templates (workspace_id, created_at DESC) WHERE deleted_at IS NULL;

INSERT INTO workspace_post_templates (id, workspace_id, title, caption, category, platforms, hashtags, created_by, created_at, updated_at)
SELECT v.id::uuid, w.id, v.title, v.caption, v.category, v.platforms::jsonb, '[]'::jsonb, w.created_by, v.created_at::timestamptz, v.created_at::timestamptz
FROM workspaces w
CROSS JOIN (VALUES
  ('7f3a0c01-2027-4f00-8000-000000000001',
   '[Tuyển sinh ĐH FPT] Khung bài giới thiệu Chuyên ngành & Học kỳ OJT',
   E'Khám phá chuyên ngành [Tên ngành] tại Trường Đại học FPT mùa tuyển sinh 2027.\n\n1. Thực hành trực tiếp tại hệ thống phòng Lab chuyên sâu ngay từ năm hai.\n2. Học kỳ thực tập doanh nghiệp (OJT) từ học kỳ 6 tại FPT Software, FPT Semiconductor và các đối tác toàn cầu.\n3. Cơ hội xét cấp Học bổng Nguyễn Văn Đạo mức 50%, 70% và 100% học phí toàn khóa.\n\nĐăng ký tư vấn hồ sơ khóa K23 tại: https://tuyensinh.fpt.edu.vn',
   'Kiến thức', '["FACEBOOK","INSTAGRAM","THREADS"]', '2026-10-30T03:00:00Z'),
  ('7f3a0c01-2027-4f00-8000-000000000002',
   '[Tuyển sinh ĐH FPT] Thông báo Chuỗi Workshop Trải nghiệm Tiện ích THPT',
   E'Lịch trình chuỗi Workshop hướng nghiệp & trải nghiệm tiện ích học đường Đại học FPT dành riêng cho học sinh lớp 12 tại [Tên trường THPT / Tỉnh thành].\n\n- Trực tiếp đeo kính thực tế ảo VR tham quan 5 cơ sở đào tạo và điều khiển mô hình Robotics.\n- Tìm hiểu đời sống nội trú, thư viện xanh, võ thuật Vovinam và hơn 40 câu lạc bộ sinh viên.\n- Giải đáp 1-1 quy chế xét tuyển & Học bổng Nguyễn Văn Đạo năm 2027.\n\nĐăng ký nhận mã QR check-in ngay tại phần bình luận!',
   'Tương tác', '["FACEBOOK","INSTAGRAM","TIKTOK","THREADS"]', '2026-11-02T04:30:00Z'),
  ('7f3a0c01-2027-4f00-8000-000000000003',
   '[Tuyển sinh ĐH FPT] Đếm ngược Ngày hội FPTU Open Day 2027',
   E'Chỉ còn [Số ngày] ngày nữa, Ngày hội FPTU Open Day 2027 chính thức mở cửa đón học sinh THPT và phụ huynh!\n\n- Thời gian: 07:30 - 16:30 Chủ nhật tuần này.\n- Hoạt động nổi bật: Tham quan 12 trạm tiện ích Campus, giao lưu cùng giảng viên AI, đại sứ sinh viên K19 và nhận cẩm nang xét tuyển đợt 1.\n- Nhà trường bố trí 08 tuyến xe buýt đưa đón miễn phí theo danh sách đăng ký trước.',
   'Ra mắt', '["FACEBOOK","INSTAGRAM","TIKTOK"]', '2026-11-06T07:00:00Z'),
  ('7f3a0c01-2027-4f00-8000-000000000004',
   '[Đa ngành - Công nghệ SaaS] Giới thiệu Tính năng Mới cho Doanh nghiệp',
   E'Cập nhật phiên bản [Tên phiên bản]: Rút ngắn thời gian phối hợp quy trình phê duyệt nội bộ cho đội ngũ vận hành.\n\n- Tập trung toàn bộ trao đổi và lịch sử chỉnh sửa trên một luồng duy nhất.\n- Phân quyền rõ ràng cho từng vai trò phụ trách.\n- Dùng thử 14 ngày tại đường dẫn chính thức trên trang cá nhân.',
   'Case Study', '["FACEBOOK","THREADS"]', '2026-11-08T09:15:00Z'),
  ('7f3a0c01-2027-4f00-8000-000000000005',
   '[Đa ngành - Ẩm thực F&B] Ra mắt Thực đơn Theo mùa tại Cửa hàng',
   E'Bộ sưu tập thức uống [Tên bộ sưu tập] chính thức có mặt tại toàn bộ cửa hàng từ tuần này.\n\n- Nguyên liệu trái cây tươi tuyển chọn theo mùa, vị thanh nhẹ ít ngọt.\n- Ưu đãi dùng thử trong khung giờ 14:00 - 17:00 cho khách đặt trước qua fanpage.',
   'Thương hiệu', '["FACEBOOK","INSTAGRAM","TIKTOK"]', '2026-11-10T10:00:00Z')
) AS v(id, title, caption, category, platforms, created_at)
WHERE w.id = 'b47477c4-13ad-44ff-8c49-f73f1837461b' AND w.created_by IS NOT NULL
ON CONFLICT (id) DO NOTHING;

SELECT count(*) AS templates FROM workspace_post_templates WHERE workspace_id = 'b47477c4-13ad-44ff-8c49-f73f1837461b';
COMMIT;
