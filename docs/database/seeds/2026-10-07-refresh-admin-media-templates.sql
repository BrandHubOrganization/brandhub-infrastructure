-- LOCAL DEVELOPMENT ONLY. Upgrade the ten existing Admin templates in place.
-- Preserve package IDs and historical workspace negotiation snapshots.
-- No users, agencies, workspaces or packages are inserted or deleted.
\set ON_ERROR_STOP on
BEGIN;

WITH catalogue(id, name, offering_model, package_type, duration_weeks, budget_amount,
               service_type, deliverable_name, quantity, unit, scope_description) AS (
    VALUES
    ('851c638d-f60b-4bad-9edb-1838ed029753'::uuid, 'Chiến dịch ra mắt sản phẩm', 'CAMPAIGN', 'BY_DURATION'::package_type, 6, 18000000::numeric, 'SOCIAL_POST', 'Bài đăng ra mắt', 12, 'bài', 'Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.'),
    ('0c566d1e-3368-4471-a830-1d380bd758df'::uuid, 'Chiến dịch truyền thông sự kiện', 'CAMPAIGN', 'BY_DURATION'::package_type, 8, 24000000::numeric, 'EVENT_PLANNING', 'Kế hoạch truyền thông sự kiện', 1, 'bản kế hoạch', 'Bàn giao kế hoạch sự kiện và nội dung truyền thông; không bao gồm quản lý hậu cần sự kiện.'),
    ('df2c77cb-2be8-44f1-b8f2-3a988e648b36'::uuid, 'Chiến dịch livestream giới thiệu sản phẩm', 'CAMPAIGN', 'BY_DURATION'::package_type, 6, 22000000::numeric, 'LIVESTREAM_PREPARATION', 'Bộ tài liệu chuẩn bị livestream', 2, 'buổi', 'Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.'),
    ('5a7ff4c7-4724-4a67-8da8-c03345dcef23'::uuid, 'Chiến dịch truyền thông báo điện tử', 'CAMPAIGN', 'BY_DURATION'::package_type, 8, 30000000::numeric, 'PRESS_RECOMMENDATION', 'Danh sách đối tác báo điện tử đề xuất', 1, 'danh sách', 'Gợi ý các bên báo điện tử phù hợp; không bao gồm booking hoặc quản lý đối tác.'),
    ('494cb9fe-7793-4f96-be6c-62f5598e59e1'::uuid, 'Chăm sóc kênh mạng xã hội hàng tháng', 'RETAINER', 'BY_DURATION'::package_type, 4, 12000000::numeric, 'SOCIAL_POST', 'Bài đăng mạng xã hội mỗi tháng', 12, 'bài/tháng', 'Sản lượng tính riêng từng tháng, không chuyển phần chưa dùng sang tháng sau.'),
    ('d4690a26-6b39-4f9f-847b-bb73d8015e49'::uuid, 'Nội dung thương hiệu hàng tháng', 'RETAINER', 'BY_DURATION'::package_type, 4, 15000000::numeric, 'SOCIAL_POST', 'Bài nội dung thương hiệu mỗi tháng', 16, 'bài/tháng', 'Manager chủ động tạo Campaign theo tháng; sản lượng tháng trước không được cộng dồn.'),
    ('9e0c218a-4785-428f-9b8b-be0ddc1b7540'::uuid, 'Hỗ trợ workshop hàng tháng', 'RETAINER', 'BY_DURATION'::package_type, 4, 10000000::numeric, 'WORKSHOP_SUPPORT', 'Buổi workshop hỗ trợ mỗi tháng', 2, 'buổi/tháng', 'Hỗ trợ tạo link Meet và survey; không quản lý agenda hoặc hậu cần sự kiện.'),
    ('f5a54341-f474-4458-b843-360607a89494'::uuid, 'Bộ 20 bài đăng mạng xã hội', 'DELIVERABLE_BUNDLE', 'BY_BUDGET'::package_type, 12, 16000000::numeric, 'SOCIAL_POST', 'Bài đăng mạng xã hội', 20, 'bài', 'Phân bổ số bài vào từng Campaign; tổng phân bổ không vượt sản lượng gói.'),
    ('fcf4421a-dfcc-4d66-9e3b-42b3b67ed15f'::uuid, 'Bộ hỗ trợ 4 buổi livestream', 'DELIVERABLE_BUNDLE', 'BY_BUDGET'::package_type, 12, 20000000::numeric, 'LIVESTREAM_PREPARATION', 'Bộ tài liệu chuẩn bị livestream', 4, 'buổi', 'Phân bổ số buổi vào từng Campaign; chỉ hỗ trợ chuẩn bị, không trực tiếp phát sóng.'),
    ('5a934e82-b3f4-4840-9e1e-d6bb773bc307'::uuid, 'Bộ kế hoạch 3 sự kiện', 'DELIVERABLE_BUNDLE', 'BY_BUDGET'::package_type, 12, 21000000::numeric, 'EVENT_PLANNING', 'Kế hoạch sự kiện bàn giao', 3, 'bản kế hoạch', 'Phân bổ kế hoạch vào từng Campaign; không bao gồm module hậu cần hay vận hành sự kiện.')
)
UPDATE media_packages p
SET name = c.name,
    package_type = c.package_type,
    duration_weeks = c.duration_weeks,
    budget_amount = c.budget_amount,
    scope_description = c.scope_description,
    offering_model = c.offering_model,
    offering_details = jsonb_build_object('maxChanges', 2, 'deliverables', jsonb_build_array(
        jsonb_build_object('id', md5(c.id::text || ':deliverable')::uuid,
                           'serviceType', c.service_type,
                           'name', c.deliverable_name,
                           'quantity', c.quantity,
                           'unit', c.unit,
                           'description', c.scope_description,
                           'acceptanceCriteria', 'Bàn giao và được khách hàng xác nhận'))),
    updated_at = now()
FROM catalogue c
WHERE p.id = c.id AND p.is_template = true AND p.agency_id IS NULL;

COMMIT;
