# 12 — State Machines (sơ đồ trạng thái chi tiết)

> **Ưu tiên BA 2026-10-18 cho Task:** mục 4 hiện hành và [FR 3.6.9 v3](../feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/spec.md) thay quy tắc QC/trạng thái trung gian của các ghi chú cũ. Một bản POST qua /editor, khóa nội dung khi review; reject/withdraw hợp lệ về IN_PROGRESS, gửi lại lượt mới; FINISHED không tự publish. Giai đoạn 1 là tài liệu, chưa có implementation Approval.

> **BA mới đã chốt 2026-10-15:** Task chỉ còn TODO / IN_PROGRESS / IN_REVIEW / CANCELLED / FINISHED. Giao việc là metadata, không còn bước DETAIL_IDENTIFIED/ASSIGNED. Phải có mô tả + deadline hợp lệ trước giao; Creator được giao bấm bắt đầu mới IN_PROGRESS; sau đó Manager khóa sửa/giao lại. IN_REVIEW giữ QC → Manager → Client khi được cấu hình; reject về IN_PROGRESS, duyệt lại từ QC nếu có. Approval do thành viên khác triển khai. Autosave on-blur và action list chỉ assignment/deadline/start. Ghi chú mới này thay thế vòng đời Task lịch sử bên dưới; xem [spec mới](../feature/content-task-workflow/task-five-state-inline-edit/spec.md).

> [<< Về Overview](00-overview.md)
> Mục đích: mô tả chi tiết TỪNG cạnh chuyển trạng thái (transition) — điều kiện, ai được phép bấm — cho các entity có vòng đời phức tạp. Bổ sung cho mô tả bằng lời ở các file 04, 05, 07.

## 1. Content Request

> **Quyết định mới nhất 2026-10-14 thay thế các ghi chú lịch sử về xử lý Request sau hoàn thành bên dưới:** Task được chấp nhận gắn Campaign hiện tại và giữ Request nguồn; mọi Task chưa COMPLETED/CANCELLED và Request IN_PROGRESS chặn Manager hoàn thành Campaign. Sau hoàn thành thành công, PENDING tự hủy bằng durable queue; không tạo/sửa/tiếp nhận mới. Hủy Task là thao tác riêng có lựa chọn, lý do chung và xác nhận. Xem [Campaign closure](../feature/media-package-campaign/campaign-closure/spec.md).

```
        create (CLIENT)
              │
              ▼
         [PENDING] ──────update (CLIENT, chỉ khi PENDING)────────────┐
              │                                                        │
   set in_progress (MANAGER)                                          │
              │                                                        ▼
              ▼                                                  (vẫn PENDING)
      [IN_PROGRESS]
        │           │
 accept(MANAGER)  deny(MANAGER)
        │           │
        ▼           ▼
   [ACCEPTED]    [DENIED]
        │
        ▼
  tự động sinh 1 Task mới (xem mục 3)

  PENDING ──cancel (CLIENT tạo Request)──► CANCELLED (terminal)
```

| Từ | Đến | Ai bấm | Điều kiện |
|---|---|---|---|
| (mới) | PENDING | CLIENT | Create Content Request |
| PENDING | PENDING (update nội dung) | CLIENT | Chỉ khi đang PENDING |
| PENDING | CANCELLED | CLIENT tạo Request | Hủy mềm; chỉ khi PENDING |
| PENDING | IN_PROGRESS | MANAGER thuộc Workspace | Bấm “Tiếp nhận yêu cầu”; xem trang không chuyển trạng thái; lưu người/thời điểm |
| IN_PROGRESS | ACCEPTED | MANAGER | → tự sinh Task mới |
| IN_PROGRESS | DENIED | MANAGER | Kết thúc, không sinh Task |
| ACCEPTED/DENIED/CANCELLED | * | KHÔNG AI | Trạng thái cuối, không mở lại |

Xác nhận người dùng 2026-10-13: IN_PROGRESS hiển thị “Đang xem xét”, không phải Task đang thực hiện. Client chỉ sửa title/description/type/dueDate và hủy trong PENDING. Chỉ tạo mới khi Campaign IN_PROGRESS, deployment SUCCEEDED; không tạo khi COMPLETED. Request đã có tiếp tục xử lý sau hoàn thành, không tự hủy. Các thay đổi BA chung cần lead/team review theo team guide.

## 2. Media Package (đàm phán)

```
  Manager chọn template
        │
        ▼
    [DRAFT] ──(Client request thay đổi)──► [CLIENT_REQUESTED_CHANGE]
        │                                          │
        │                          (Agency counter-offer)
        │                                          │
        │                                          ▼
        │                                [AGENCY_COUNTERED] ──(lặp lại negotiate)──┐
        │                                          │                                │
        │                                          ▼                                │
        └──────────────────► cả 2 bên đồng ý ──► [APPROVED] ◄───────────────────────┘
```

- Vòng lặp `CLIENT_REQUESTED_CHANGE ↔ AGENCY_COUNTERED` có thể xảy ra nhiều lần (FR 3.5.3: "Quá trình đó được diễn ra cho đến khi cả 2 bên chốt được gói cuối cùng").
- `APPROVED` yêu cầu **cả 2 phía xác nhận** (approvedByAgencyAt VÀ approvedByClientAt đều có giá trị) — không phải 1 bên approve là xong.
- Sau khi `APPROVED` → có thể tạo Media Campaign (mục tiếp).

## 3. Media Campaign

```
Package APPROVED
      │
      ▼
   [DRAFT] ──(Agency tạo nội dung chi tiết)
      │
      ▼
cả 2 bên approve
      │
      ▼
  [APPROVED] ──(nhấn triển khai)──► sinh Task backlog (N task) ──► [IN_PROGRESS]
                                                                          │
                                                            Manager mark completed
                                                                          │
                                                                          ▼
                                                                   [COMPLETED]
```

- Giống Package, `APPROVED` yêu cầu đồng thuận 2 phía.
- **[Cập nhật BA 2026-10-08]** `IN_PROGRESS` sau deploy thành công; Manager chủ động
  mark `COMPLETED` từ `IN_PROGRESS`. Được phép khi còn Task chưa hoàn thành nhưng
  bắt buộc ghi lý do; không đổi trạng thái hoặc tự khóa workflow các Task con.
- Một Workspace chỉ có một Campaign; chiến dịch mới dùng Workspace mới. Owner được
  chọn từng thành viên và tùy chọn timezone khi nhân bản Workspace (DA-1255);
  tài nguyên chờ module riêng. Đề xuất nhiều đợt
  trong cùng Workspace không còn áp dụng.

> **Campaign Addendum bên dưới là BA lịch sử cần review:** chưa có task riêng và
> không được tạo Campaign thứ hai trong cùng Workspace để lách quan hệ 1:1 mới.

**[CONFIRMED 2026-09-17] Campaign Addendum — bổ sung cho tính immutable:** Campaign gốc sau `APPROVED` vẫn immutable (không sửa trực tiếp), nhưng khi phát sinh khối lượng công việc lớn giữa chiến dịch (không phải 1 task lẻ qua Content Request hay Manager add thủ công), Agency tạo 1 **Campaign Addendum** — bản bổ sung link tới Campaign gốc (`parentCampaignId`), có thể chứa nhiều Task mới, cũng phải qua chu trình duyệt 2 phía riêng (Draft → Approved) như Campaign gốc. Mục đích: Task lớn phát sinh giữa kỳ vẫn truy vết được về đúng Campaign nào sinh ra nó, phục vụ báo cáo/billing — không để lẫn vào Task rời không rõ nguồn gốc như Manual Task đơn lẻ. Xem entity đề xuất tại [11-data-entities-glossary.md](11-data-entities-glossary.md).

## 4. Task — Approval Sequence (hiện hành 2026-10-18)

Nguồn: [spec FR3.6.9 v3](../feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/spec.md). Thay toàn bộ sơ đồ QC/ASSIGNED/skip-approval cũ cho luồng mới; không tự chuyển đổi/xóa dữ liệu legacy.

| Trước | Action hợp lệ | Sau |
|---|---|---|
| TODO | Assignee Creator bắt đầu; description + dueDate hợp lệ | IN_PROGRESS, ghi firstStartedAt/By |
| IN_PROGRESS | Assignee lưu bài POST hợp lệ và submit | IN_REVIEW / MANAGER |
| IN_REVIEW / MANAGER | Manager approve, không cần Client | FINISHED |
| IN_REVIEW / MANAGER | Manager approve, cần Client | IN_REVIEW / CLIENT |
| IN_REVIEW / CLIENT | Một Client active bất kỳ approve | FINISHED |
| IN_REVIEW / MANAGER hoặc CLIENT | Đúng người duyệt reject có lý do | IN_PROGRESS |
| IN_REVIEW / MANAGER, chưa decision | Assignee Creator withdraw | IN_PROGRESS |
| Task chưa kết thúc | Flow cancel được cấp quyền hiện có | CANCELLED |

- Không có QC; chỉ năm trạng thái. reviewStep chỉ có MANAGER/CLIENT lúc IN_REVIEW, null ngoài review.
- Lượt đầu 1, mỗi submit lại thành công sau reject/withdraw tăng lượt; decision cũ append-only nhưng không hiệu lực cho lượt mới. Chỉ APPROVE/REJECT tạo decision, tối đa hai/lượt.
- Withdraw không được sau Manager decision; race với decision chỉ một bên thắng. Client đầu tiên quyết định hợp lệ kết thúc bước Client; người khác dùng màn hình cũ bị conflict.
- Thiếu Client active khi được yêu cầu thì chặn submit, báo Manager bổ sung. Hết Client khi đã chờ thì giữ bước/Manager approval, không tự skip. Thay Manager thì Manager active hiện tại được duyệt.
- POST dùng /editor và một Post hiện tại; khóa sửa khi review, reject/withdraw hợp lệ mới sửa lại. Chưa quản lý snapshot/khôi phục nội dung lượt trước; lịch sử là decision, không phải bản nội dung.
- First-start evidence giữ nguyên qua reject/withdraw; Manager vẫn khóa sửa brief/deadline/giao lại. Task FINISHED/CANCELLED không reopen; bình luận vẫn theo FR3.6.3.
- Cancel phải xóa bước chờ/đóng metadata, không xóa decision. Không duyệt sau hủy/hoàn thành Campaign; giữ điều kiện Campaign closure hiện có.
- FINISHED không tự enqueue Publish. Xuất bản là action/module riêng; Admin moderation không thay decision Task.
- Đây là contract đích của giai đoạn 1, chưa phải implementation đã chạy. Legacy QC/thiếu reviewStep/round chỉ đọc và inventory riêng, không tự backfill.

## 5. Task loại Livestream — trạng thái riêng

```
[PRE_LIVE] ──(bắt đầu buổi live)──► [LIVE] ──(kết thúc buổi live)──► [POST_LIVE] ──► [DONE]
    │                                  │
    └──────────(hủy buổi live)─────────┴──────────────────────────────────────► [CANCEL]
```

- `PRE_LIVE`: chuẩn bị (idea, script, setup, quay chuẩn bị — xem checklist ở [05-content-task-workflow.md](05-content-task-workflow.md) mục 3).
- `LIVE`: đang phát trực tiếp.
- `POST_LIVE`: xử lý sau live (retouch, cắt clip highlight để chạy hook).
- `DONE`/`CANCEL`: 2 trạng thái kết thúc — Cancel có thể xảy ra ở bất kỳ giai đoạn PRE_LIVE hoặc LIVE.
- State này lồng bên trong Task chính (Task cha vẫn đi qua Approval Sequence ở mục 4 sau khi Livestream state đạt DONE).

## 6. Third-party Collaborator — trạng thái hợp tác

```
[CONTACTED] ──► [NEGOTIATING] ──► [CONFIRMED] ──► [LIVE_ON_AIR]
```

- Cập nhật hoàn toàn thủ công bởi Manager/Creator — không có transition tự động, không có API bên thứ 3 kích hoạt chuyển trạng thái (khác hẳn Task/Post publish tự động qua API).
- Có thể revert lùi trạng thái (ví dụ từ NEGOTIATING quay lại CONTACTED nếu đàm phán đổ vỡ) — không phải chuỗi 1 chiều cứng nhắc như Task Approval Sequence.

## 7. Post — trạng thái Publish (sau khi Task hoàn thành)

```
[FINISHED Task] --thao tác xuất bản riêng--> [PENDING publish] ──► [IN_PROGRESS] ──► [DONE] hoặc [FAIL]
```

- Tương ứng FR 3.8.8 View Status Tracking: "Pending, In Progress, Done, Fail".
- BA 2026-10-18: cạnh xuất bản trên là thao tác riêng của module publishing, không phải side-effect tự động của Task approval. Không đổi queue/callback hoặc cơ chế retry của module đó.
- **[CONFIRMED 2026-09-17]** `FAIL` **có retry tự động, theo config** — số lần retry và backoff không hardcode, đọc từ setting (kế thừa tiền lệ retry 3 lần exponential backoff ở hệ thống cũ làm giá trị mặc định, nhưng phải config được để chỉnh khi cần mà không cần deploy lại code publisher-service).
