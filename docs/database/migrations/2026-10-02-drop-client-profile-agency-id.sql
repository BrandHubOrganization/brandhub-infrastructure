-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-10-02-drop-client-profile-agency-id.sql
-- ClientProfile thuộc sở hữu user, độc lập với agency (BA sửa lại: 1 user có
-- thể sở hữu nhiều ClientProfile đại diện nhiều khách hàng/brand, mỗi profile
-- dùng được ở nhiều workspace/agency qua workspace_members.client_profile_id).
-- agency_id (thêm ở 2026-09-23-agency-workspace-branding-and-client-profile-rework.sql)
-- ràng buộc sai 1 profile/agency — xoá hẳn.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

DROP INDEX IF EXISTS idx_client_profiles_agency_id;
ALTER TABLE client_profiles DROP COLUMN IF EXISTS agency_id;

COMMIT;
