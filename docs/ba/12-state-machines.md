# 12 — State Machines (sơ đồ trạng thái chi tiết)

> [<< Về Overview](00-overview.md)
> Mục đích: mô tả chi tiết TỪNG cạnh chuyển trạng thái (transition) — điều kiện, ai được phép bấm — cho các entity có vòng đời phức tạp. Bổ sung cho mô tả bằng lời ở các file 04, 05, 07.

## 1. Content Request

```
        create (CLIENT)
              │
              ▼
         [PENDING] ──────update/cancel (CLIENT, chỉ khi PENDING)──────┐
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
```

| Từ | Đến | Ai bấm | Điều kiện |
|---|---|---|---|
| (mới) | PENDING | CLIENT | Create Content Request |
| PENDING | PENDING (update nội dung) | CLIENT | Chỉ khi đang PENDING |
| PENDING | (xóa) | CLIENT | Cancel — chỉ khi đang PENDING |
| PENDING | IN_PROGRESS | MANAGER | Track Request Status |
| IN_PROGRESS | ACCEPTED | MANAGER | → tự sinh Task mới |
| IN_PROGRESS | DENIED | MANAGER | Kết thúc, không sinh Task |
| ACCEPTED/DENIED | * | KHÔNG AI | Trạng thái cuối, Client hết quyền sửa/xóa |

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
                                                            tất cả Task hoàn thành
                                                                          │
                                                                          ▼
                                                                   [COMPLETED]
```

- Giống Package, `APPROVED` yêu cầu đồng thuận 2 phía.
- Trạng thái `IN_PROGRESS`/`COMPLETED` của Campaign phụ thuộc tổng hợp trạng thái các Task con — không tự set tay.

**[CONFIRMED 2026-09-17] Campaign Addendum — bổ sung cho tính immutable:** Campaign gốc sau `APPROVED` vẫn immutable (không sửa trực tiếp), nhưng khi phát sinh khối lượng công việc lớn giữa chiến dịch (không phải 1 task lẻ qua Content Request hay Manager add thủ công), Agency tạo 1 **Campaign Addendum** — bản bổ sung link tới Campaign gốc (`parentCampaignId`), có thể chứa nhiều Task mới, cũng phải qua chu trình duyệt 2 phía riêng (Draft → Approved) như Campaign gốc. Mục đích: Task lớn phát sinh giữa kỳ vẫn truy vết được về đúng Campaign nào sinh ra nó, phục vụ báo cáo/billing — không để lẫn vào Task rời không rõ nguồn gốc như Manual Task đơn lẻ. Xem entity đề xuất tại [11-data-entities-glossary.md](11-data-entities-glossary.md).

## 4. Task — Approval Sequence (chi tiết nhất, có reject-loop)

```
[BACKLOG] (chỉ có tên + deadline thô)
    │
Manager: Identify Task Detail
    │
    ▼
[DETAIL_IDENTIFIED]
    │
Manager: Assign Task to Creator (+ quyết định CÓ/KHÔNG giao QC)
    │
    ▼
[ASSIGNED]
    │
Creator thực hiện nội dung
    │
    ▼
[IN_PROGRESS] ──submit──► ┌─────────────────────────────┐
                           │   Nếu CÓ giao QC:            │
                           │   [QC_REVIEW]                │
                           │     │approve      │reject    │
                           │     ▼             │          │
                           │  (tiếp Manager)   │          │
                           │                   ▼          │
                           │            quay về [ASSIGNED]│
                           │            (giữ approval QC  │
                           │             nếu step SAU QC  │
                           │             bị reject — xem  │
                           │             quy tắc dưới)    │
                           └─────────────────────────────┘
                                      │ (nếu KHÔNG giao QC, hoặc QC approve)
                                      ▼
                              [MANAGER_REVIEW]
                                 │approve         │reject
                                 ▼                ▼
                     requiresClientApproval?   quay về [ASSIGNED]
                        │yes         │no
                        ▼            ▼
                 [CLIENT_REVIEW]  [COMPLETED]
                   │approve   │reject
                   ▼          ▼
              [COMPLETED]  quay về [ASSIGNED]
```

**Quy tắc reject (SỬA 2026-09-17, override bản 2026-09-15):** dù bị reject ở bước nào (QC, Manager, hay Client), Task luôn **quay về đúng bước `[ASSIGNED]`** để Creator sửa lại nội dung. Các approval đã pass ở step TRƯỚC step bị reject **KHÔNG bị xoá khỏi lịch sử** — record `TaskApproval` của chính step bị reject bị đánh `reject`, các step trước đó giữ nguyên `approve` trong lịch sử (để audit).

**[CONFIRMED 2026-09-17]** Tuy nhiên khi Creator sửa lại và submit lại, Task **luôn đi lại từ `[QC_REVIEW]` (nếu Task có giao QC)**, kể cả khi QC đã approve ở lượt trước và bước bị reject là Manager/Client — không bỏ qua QC lần 2. Lý do: nội dung đã bị sửa nên bản QC duyệt trước không còn đảm bảo đúng với bản mới, cần QC xác nhận lại cho chắc.

Ví dụ: QC đã approve → Manager reject → quay về `[ASSIGNED]` → Creator sửa lại → submit lại → **đi lại từ `[QC_REVIEW]`** (nếu Task này có giao QC) → QC approve lại → mới tới `[MANAGER_REVIEW]`.

> Kỹ thuật: bảng `TaskApproval` phải lưu theo từng step riêng (không chỉ 1 field `status` tổng) để giữ lịch sử approve cũ khi step sau bị reject — xem [11-data-entities-glossary.md](11-data-entities-glossary.md).

Nếu Task loại `post` và đạt `[COMPLETED]` → chuyển tiếp sang hàng đợi Publish (xem mục 5).

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
[COMPLETED Task] ──► [PENDING publish] ──► [IN_PROGRESS] ──► [DONE] hoặc [FAIL]
```

- Tương ứng FR 3.8.8 View Status Tracking: "Pending, In Progress, Done, Fail".
- **[CONFIRMED 2026-09-17]** `FAIL` **có retry tự động, theo config** — số lần retry và backoff không hardcode, đọc từ setting (kế thừa tiền lệ retry 3 lần exponential backoff ở hệ thống cũ làm giá trị mặc định, nhưng phải config được để chỉnh khi cần mà không cần deploy lại code publisher-service).
