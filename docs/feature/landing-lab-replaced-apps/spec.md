# Spec — Landing lab: 17 app thay thế

## Objective
Màn MacBook/iPhone mô phỏng trên landing (`CinematicHero`) phải cho người xem thấy rõ
BrandHub thay được những công cụ nào, theo đúng luồng làm việc của agency. Hiện tại
mỗi trang gắn 2-3 chip app nhưng bấm chip nào cũng ra cùng một màn, và vài mô tả nói
quá so với sản phẩm.

## User Story
Là khách truy cập landing, tôi muốn bấm vào một công cụ quen thuộc (Buffer, Asana, Canva…)
và thấy ngay màn BrandHub làm việc đó, kèm 1-2 điểm BrandHub làm tốt hơn, để tin rằng một
gói BrandHub thay được nhiều app rời.

## Cấu trúc (đã chốt với user 2026-11-22)
Sidebar = 8 giai đoạn theo luồng sản phẩm; mỗi app là một tab riêng (17 tab + Tổng quan).

| Giai đoạn | Tab → app thay thế | Tính năng thật trong web |
|---|---|---|
| Tổng quan | overview | dashboard, ma trận "17 app → 1" |
| Brief | typeform · notion | public-survey (7 loại câu hỏi) · content-writing |
| Kế hoạch | asana · jira | campaign timeline Gantt · tasks Kanban (task type, subtask role) |
| Sáng tạo AI | jasper · canva · capcut | AI caption/hashtag theo kênh · AIImageStudioPanel + templates · product-video / video-space |
| Tài sản & Team | drive · brandfolder · slack | library (folder, version, thùng rác) · client profile + knowledge base · chat realtime |
| Duyệt | frameio | task-approvals nhiều cấp, client portal |
| Xuất bản | buffer · hootsuite · mailchimp | lịch đăng FB/IG/TikTok/Threads · social-accounts + bình luận theo bài · mail-templates (khối, gửi theo đợt, hủy đăng ký) |
| Đo lường | sprout · buzzsumo · sheets | publish dashboard · workspace-trends · reports + XLSX + báo cáo định kỳ |

## Acceptance Criteria
1. Mỗi tab có màn riêng, nội dung khác nhau, mô phỏng đúng tính năng có thật (cột phải).
2. Không mô phỏng tính năng chưa có: không gọi thoại, không hộp thư hợp nhất, không timeline
   cắt ghép video, không Livestream, không nền tảng ngoài 4 kênh, không cổng thanh toán khác SePay.
3. Đầu mỗi màn app có banner "Thay cho <App>" + 2 điểm khác biệt. Không ghi giá đối thủ.
4. Dưới banner có dải tab các app cùng giai đoạn để chuyển qua lại.
5. Bấm icon app trên Dock → mở đúng tab. Bấm mục sidebar → tab đầu của giai đoạn.
6. Tour tự chạy (menu Apple "Xem lại tour") đi lần lượt 17 tab rồi về Tổng quan.
7. Vai trò mặc định: Owner → Tổng quan, Manager → Kế hoạch, Creator → Sáng tạo AI, Client → Duyệt.
8. Các section ngoài (Features, HowItWorks, AIFeatures, AgencyWorkspace, Templates) mở đúng tab.
9. Mọi màn hiển thị gọn trong cả khung MacBook và iPhone (container query, không tràn ngang).
10. Thanh URL hiện `brandhub.id.vn/dashboard/<slug của tab>`.

## UI/UX
- Giữ toàn bộ chrome macOS/Safari/Dock hiện có. Chỉ thay nội dung cửa sổ app.
- Màu thương hiệu cam `#F05A28`, khung app nền sáng như hiện tại.
- Icon dùng `lucide-react`; logo app đối thủ là glyph SVG trong `replacedApps.tsx`.

## i18n
- Namespace mới `landingLab` (`src/i18n/locales/{vi,en}/landingLab.json`), key song song 2 file.
- Nhóm key: `landingLab.stages.*`, `landingLab.apps.<id>.{category,title,diff1,diff2}`,
  `landingLab.banner.*`, `landingLab.<screen>.*`.
- Không hardcode chuỗi hiển thị trong JSX; dữ liệu mẫu dạng mảng đọc bằng `returnObjects`.

## Light/Dark mode
Cửa sổ app mô phỏng luôn ở giao diện sáng (giống hiện tại, vì nó là "ảnh chụp" app trên nền
wallpaper). Không phụ thuộc theme site, nên đổi theme site không đổi màu bên trong cửa sổ.
Chữ/nền đạt contrast WCAG AA trên nền trắng.

## Edge Cases
- Tab id không hợp lệ → về `overview`.
- Đổi ngôn ngữ khi đang ở một tab → giữ tab, đổi chữ.
- `prefers-reduced-motion` → không chạy auto-demo.

## Definition of Done
`tsc -b` sạch, lint sạch trên file đổi, test.md pass trên trình duyệt ở MacBook + iPhone, vi + en.

## Out of Scope
Trang landing khác ngoài lab; mobile app; backend.
