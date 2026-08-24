# Spec — Workspace Detail UX Fixes (timezone, breadcrumb, invitation list)

## Objective
User phát hiện 3 vấn đề trên trang chi tiết workspace: (1) múi giờ vẫn là
Input tự gõ dù đã bỏ ở Settings cá nhân, (2) breadcrumb hiện UUID thô thay
vì tên workspace, (3) chưa có nơi hiển thị lời mời tham gia workspace trên
web (chỉ có email). Ngoài ra cần rà và bổ sung test case cho luồng mời
thành viên — phát hiện bug: mời lại cùng email trong lúc invitation cũ còn
PENDING sẽ tạo bản ghi trùng, không check trước.

## Phạm vi (4 phần)

### Phần A — Bỏ múi giờ thủ công ở Workspace Settings
Giống cách đã làm ở `SettingsPage.tsx` (user profile): bỏ Input "Múi giờ",
tự lấy `Intl.DateTimeFormat().resolvedOptions().timeZone` lúc submit form,
không cần user chọn/gõ gì.

### Phần B — Fix breadcrumb hiện UUID
`Navbar.tsx` `getBreadcrumbs()` không map được segment UUID (id workspace
trong URL `/workspaces/{id}/settings`) → fallback capitalize chuỗi thô →
hiện `Cd075a7d-1b34-4540-...`. Cần map segment UUID sang tên workspace thật
khi biết được (đang ở route `/workspaces/:id/...`).

Nguồn tên workspace: `Layout.tsx` đã fetch `workspaces` list qua
`workspaceService.list()` — Navbar cần nhận thêm cách tra tên theo id (từ
URL param) thay vì chỉ có `memberRole`.

### Phần C — Trang `/invitations` liệt kê lời mời đang chờ
Trang mới, danh sách lời mời PENDING gửi tới email của user đang đăng nhập,
mỗi lời mời có nút Accept (dùng lại `acceptInvitationRequest` đã có) /
Decline (cần API mới — hiện chỉ có accept, chưa có decline/reject).

Link truy cập: từ menu Profile Avatar dropdown (`Navbar.tsx`, cạnh mục
"Thiết lập"), không qua chuông thông báo (giữ nguyên chuông hiện tại là mock
demo, không đụng).

### Phần D — Fix bug + bổ sung test case mời thành viên
**Bug fix**: `WorkspaceServiceImpl.inviteMember` hiện KHÔNG kiểm tra
invitation PENDING cũ trước khi tạo mới, dù
`WorkspaceInvitationRepository.findByWorkspaceIdAndInvitedEmailAndStatus`
đã tồn tại sẵn nhưng chưa được gọi. Mời lại cùng email nhiều lần tạo nhiều
bản ghi PENDING trùng cho cùng workspace+email.

**Test case cần bổ sung** (rà theo luồng thật, không phải liệt kê hình
thức):
1. Mời thành công (happy path) — đã có test, giữ nguyên.
2. Mời email không đúng định dạng → `@Email` validation chặn ở tầng
   controller (400), không cần test service layer riêng (đã có Jakarta
   Validation, xác nhận qua test).
3. Mời user đã là thành viên active → đã có test
   (`inviteMember_alreadyActiveMember_throwsAlreadyInWorkspace`).
4. **Mời lại cùng email khi invitation cũ còn PENDING** → phải trả lỗi rõ
   ràng (case mới, hiện chưa test vì bug chưa fix).
5. Mời lại cùng email SAU KHI invitation cũ đã EXPIRED/DECLINED/ACCEPTED
   (không phải PENDING) → phải cho phép tạo invitation mới (không bị chặn
   nhầm).
6. Mời chính người gửi lời mời (currentUser mời chính email của mình) —
   xác nhận hành vi hiện tại (không có check riêng, rơi vào case "đã là
   thành viên active" nếu người mời đang active trong workspace đó — xác
   nhận đúng bằng test, không cần logic mới nếu đã đúng).

## Acceptance Criteria
- Form tạo/sửa workspace không còn Input múi giờ; `timezone` gửi tự động
  từ trình duyệt.
- Breadcrumb ở mọi trang `/workspaces/:id/...` hiện đúng tên workspace,
  không hiện UUID thô. Route không xác định được tên (workspace chưa load
  xong, hoặc lỗi fetch) → fallback hiện "..." hoặc rỗng, KHÔNG hiện UUID.
- `/invitations` hiện đúng danh sách PENDING invitation của email user
  hiện tại, có nút Accept/Decline hoạt động đúng.
- Mời lại email đang có invitation PENDING → 409 hoặc lỗi rõ ràng
  (`INVITATION_ALREADY_PENDING`), không tạo bản ghi trùng.
- Mời lại email có invitation cũ đã EXPIRED/DECLINED → tạo invitation mới
  thành công, không bị chặn nhầm bởi check PENDING.
- Backend test coverage đủ 6 case ở Phần D mục Test case.

## API Contract (mới/thay đổi)

`POST /api/v1/workspaces/{workspaceId}/members/invite` (đã có) — thêm check
PENDING trước khi tạo, lỗi mới `INVITATION_ALREADY_PENDING` (409).

`GET /api/v1/workspaces/invitations/my-pending` (mới)
- Trả danh sách invitation PENDING theo email user hiện tại (JWT `sub` →
  lookup email qua `UserRepository`).
- Response: `ApiResponse<List<InvitationResponse>>` —
  `InvitationResponse{id, workspaceId, workspaceName, role, invitedByName,
  expiresAt, token}`.

`POST /api/v1/workspaces/invitations/decline` (mới)
- Body: `{token: string}`.
- Set `status = "DECLINED"`, không tạo membership.
- Lỗi: token không hợp lệ/không PENDING → `INVALID_INVITATION` (dùng lại
  mã lỗi có sẵn).

## Error Handling
- `INVITATION_ALREADY_PENDING` — 409, message rõ ràng "Đã có lời mời đang
  chờ cho email này".
- Decline invitation không tồn tại/đã xử lý → `INVALID_INVITATION` (mã có
  sẵn, tái dùng).
- `/invitations/my-pending` — user không có invitation nào → mảng rỗng,
  200, không lỗi.

## Edge Cases
- Breadcrumb: user vào thẳng URL `/workspaces/{id}/settings` bằng link
  (chưa qua điều hướng từ Sidebar) — `Layout.tsx` vẫn phải fetch được
  workspace đó nếu user có quyền, tên hiện đúng ngay khi data về.
- Invitation hết hạn (`expiresAt` đã qua) nhưng `status` vẫn "PENDING" (do
  không có cron dọn dẹp) — mời lại phải coi invitation cũ là "hết hiệu lực
  thực tế" dù status field chưa update, cho phép tạo mới (check thêm
  `expiresAt` khi query PENDING, không chỉ status).
- User decline rồi được mời lại → invitation mới tạo bình thường (status
  cũ là DECLINED, không phải PENDING).

## UI States
- `/invitations`: loading skeleton giống pattern hiện có
  (`if (loading) return null;`), empty state "Không có lời mời nào".
- Breadcrumb: không có loading state riêng — nếu tên chưa sẵn sàng, ẩn
  segment đó tạm thời thay vì hiện placeholder xấu.

## i18n
Namespace mới `invitations.*` (title, description, acceptButton,
declineButton, empty, acceptSuccess, declineSuccess, roleLabel,
expiresLabel, invitedByLabel) — thêm đồng thời `vi.json` + `en.json`,
key-parallel. Thêm `nav.invitations` cho link trong Profile dropdown.

## Light/Dark mode
Tái dùng token đã kiểm chứng trong session (`border-border`, `bg-card`,
`text-muted-foreground`) — không cần token mới.

## Test Cases (sơ bộ)
1. Tạo workspace, không thấy Input múi giờ, lưu thành công, `timezone`
   trong response khớp timezone trình duyệt.
2. Vào `/workspaces/{id}/settings` — breadcrumb hiện tên workspace thật,
   không phải UUID.
3. Mời A@example.com — thành công, email gửi, invitation PENDING tạo.
4. Mời lại A@example.com ngay khi còn PENDING — 409
   `INVITATION_ALREADY_PENDING`.
5. B đăng nhập bằng email đã được mời — vào `/invitations` thấy lời mời,
   bấm Accept — thành member, invitation chuyển ACCEPTED.
6. C đăng nhập bằng email được mời khác — vào `/invitations`, bấm Decline
   — invitation chuyển DECLINED, không thành member.
7. Mời lại C (đã decline) — thành công, tạo invitation mới.
8. Unit test: 6 case Phần D mục Test case pass.

## Definition of Done
- Backend: check PENDING trước khi invite, endpoint `my-pending` +
  `decline`, unit test đủ 6 case, `mvn test` pass.
- Frontend: bỏ timezone Input, breadcrumb hiện tên thật, trang
  `/invitations` mới, `tsc`/`eslint` sạch.
- i18n key-parallel.
- Verify qua Chrome DevTools theo test.md.

## Out of Scope
- Cron job tự động expire invitation PENDING quá hạn (chỉ xử lý tại thời
  điểm query, không có background job).
- Resend invitation (gửi lại email cho invitation PENDING cũ) — không yêu
  cầu trong scope này.
- Push notification/real-time cho invitation mới — chỉ cần vào trang
  `/invitations` để xem, không cần badge/chuông real-time.
