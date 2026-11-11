-- Local demo data only: FPT Shop x AIM Academy. Not real trend-search results.
-- Stable IDs prevent reruns from restoring soft-deleted test entries.
BEGIN;
SET LOCAL lock_timeout = '5s';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM workspaces
        WHERE id = 'bb996948-4b50-4761-a682-07a3e7a43eba'
          AND name = 'FPT Shop x AIM Academy' AND deleted_at IS NULL
          AND status = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION 'Expected active demo workspace not found';
    END IF;
    IF (SELECT count(*) FROM workspace_members wm JOIN users u ON u.id = wm.user_id
        WHERE wm.workspace_id = 'bb996948-4b50-4761-a682-07a3e7a43eba'
          AND wm.is_active AND u.is_active
          AND ((u.id = '12adcef2-8964-4ed6-95a5-bbb9a601803c' AND wm.role = 'CREATOR')
            OR (u.id = 'dbdc427b-e39f-4cdd-b7c2-1de84fec003f' AND wm.role = 'MANAGER'))) <> 2 THEN
        RAISE EXCEPTION 'Expected active demo Creator and Manager not found';
    END IF;
END $$;

WITH samples(ordinal, tag, purpose) AS (
    VALUES
      (1, 'FPTShop', 'BRAND'),
      (2, 'AIMAcademy', 'BRAND'),
      (3, 'FPTShopOfficial', 'BRAND'),
      (4, 'CongNgheChoMoiNha', 'BRAND'),
      (5, 'DongHanhCungFPT', 'BRAND'),
      (6, 'TraiNghiemFPTShop', 'BRAND'),
      (7, 'TuVanCongNghe', 'BRAND'),
      (8, 'KetNoiTuongLai', 'BRAND'),
      (9, 'DemoBackToSchool', 'CAMPAIGN'),
      (10, 'DemoLaptopSinhVien', 'CAMPAIGN'),
      (11, 'DemoUuDaiCuoiTuan', 'CAMPAIGN'),
      (12, 'DemoDoiMayMoi', 'CAMPAIGN'),
      (13, 'DemoSanDealCongNghe', 'CAMPAIGN'),
      (14, 'DemoMuaSamThongMinh', 'CAMPAIGN'),
      (15, 'DemoQuaTangCongNghe', 'CAMPAIGN'),
      (16, 'DemoTraiNghiemSanPham', 'CAMPAIGN'),
      (17, 'DemoTechTrend', 'TRENDING'),
      (18, 'DemoAIChoSinhVien', 'TRENDING'),
      (19, 'DemoGocHocTap', 'TRENDING'),
      (20, 'DemoSetupBanLamViec', 'TRENDING'),
      (21, 'DemoReviewDienThoai', 'TRENDING'),
      (22, 'DemoMeoCongNghe', 'TRENDING'),
      (23, 'DemoSongSo', 'TRENDING'),
      (24, 'DemoSangTaoNoiDung', 'TRENDING')
), attributed AS (
    SELECT *, CASE WHEN ordinal % 2 = 1
        THEN '12adcef2-8964-4ed6-95a5-bbb9a601803c'::uuid
        ELSE 'dbdc427b-e39f-4cdd-b7c2-1de84fec003f'::uuid END AS actor
    FROM samples
)
INSERT INTO workspace_hashtags (
    id, workspace_id, tag, normalized_tag, purpose, added_by, added_by_name,
    is_required, campaign_id, created_at, updated_at, version
)
SELECT md5('brandhub:hashtag-demo:2026-10-27:fpt-aim:' || s.ordinal)::uuid,
    'bb996948-4b50-4761-a682-07a3e7a43eba', s.tag, lower(s.tag), s.purpose,
    u.id, u.full_name, false, NULL,
    now() - s.ordinal * interval '1 minute', now(), 0
FROM attributed s JOIN users u ON u.id = s.actor
ON CONFLICT DO NOTHING;

COMMIT;
