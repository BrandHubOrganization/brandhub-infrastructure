# Plan — Landing lab: 17 app thay thế

Repo: `brandhub-web` (chỉ frontend).

## Mô hình trạng thái
- `src/store/landingDemoStore.ts`: `activePage: number` → `activeTab: LabTabId`;
  `goToPage/setPage` → `goToTab/setTab`. `requestId` giữ nguyên ý nghĩa.
- `cinematic/lab/labTabs.ts`: 18 tab id, `LAB_STAGES` (8 giai đoạn: icon, key i18n,
  danh sách tab), `stageOf(tab)`, `LAB_TOUR` (thứ tự tour).

## Thành phần
- `cinematic/replacedApps.tsx`: thêm glyph Canva, Google Sheets, Hootsuite; bỏ text tiếng Việt
  hardcode (category/featureTitle/featureDesc/targetPage) — text chuyển sang i18n.
- `cinematic/lab/LabScreen.tsx`: banner "Thay cho X", dải tab trong giai đoạn, chọn màn theo tab.
  Bọc `@container` để màn tự co theo khung MacBook/iPhone.
- `cinematic/lab/ui.tsx`: primitive dùng chung (Card, Pill, Avatar, PlatformBadge, Bar).
- `cinematic/lab/screens/*.tsx` (8 file theo giai đoạn).
- `CinematicHero.tsx`: sidebar/launchpad/omnibox/spotlight/iPhone tab bar dùng `LAB_STAGES`;
  nội dung cửa sổ = `<LabScreen tab=… />`; bỏ banner cũ, bỏ `REPLACED_APPS_BY_PAGE`,
  bỏ 8 component trang cũ (OverviewPage…ApprovalPage) và helper chỉ chúng dùng.
- Section ngoài: `Features.tsx`, `HowItWorks.tsx`, `AIFeatures.tsx`, `AgencyWorkspace.tsx`,
  `Templates.tsx` đổi số trang → tab id.

## i18n
- Mới: `src/i18n/locales/{vi,en}/landingLab.json`.
- Sửa: `src/i18n/locales/{vi,en}/index.ts` đăng ký namespace `landingLab`.

## Rủi ro
- `CinematicHero.tsx` 5.7k dòng: sửa theo điểm, kiểm `tsc` (noUnusedLocals) sau khi xóa trang cũ.
- Key i18n trang cũ trong `landing.json` thành thừa — để lại, dọn ở đợt sau.
