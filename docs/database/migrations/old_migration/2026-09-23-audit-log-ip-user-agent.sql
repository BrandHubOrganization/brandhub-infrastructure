-- Thêm cột ip_address / user_agent cho bảng audit_logs
-- để lưu thông tin thiết bị khi ghi audit log (vd logout).
ALTER TABLE audit_logs
    ADD COLUMN IF NOT EXISTS ip_address VARCHAR(45);

ALTER TABLE audit_logs
    ADD COLUMN IF NOT EXISTS user_agent VARCHAR(512);
