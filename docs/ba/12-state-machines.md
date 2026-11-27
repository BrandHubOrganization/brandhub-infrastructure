# 12 — Máy Trạng Thái Toàn Hệ Thống (System State Machines)

> Navigation: [← BA Index](./README.md) · [← 11 - Data Entities & Glossary](./11-data-entities-glossary.md) · [141 Use Cases →](./use-cases/README.md)
>
> Tài liệu này định nghĩa toàn bộ các Máy Trạng Thái (State Machines) đang vận hành trong hệ thống **BrandHub**, bao gồm cả vòng đời duyệt từng phần (`TaskSection`), tự duyệt 1 chạm (`Self-Approve` trong chế độ `PERSONAL`), hủy lịch tự động khi trả bài, và tạm giữ/quyết toán ví AI Credit.

---

## 1. Máy Trạng Thái Không Gian Làm Việc & Chế Độ Vận Hành (`Workspace` & `WorkspaceMode`)

### 1.1. Trạng thái Vòng đời `Workspace.status`
```text
[Tạo Workspace (3.4.14) hoặc Bootstrap Personal Studio]
                         │
                         ▼
                      ACTIVE ◄──── Khôi phục trong hạn 30 ngày (BR-16, Owner) ────┐
                         │                                                         │
                         └──── Delete Workspace (3.4.17, Owner) ───▶ INACTIVE / DELETED_PENDING
                               (Chỉ đọc, dừng mọi job xuất bản tự động, bảo lưu 30 ngày)
```

### 1.2. Chuyển đổi Chế độ `settings.workspaceMode` (`PERSONAL ↔ AGENCY`)
```text
┌───────────────────────────────────────────┐
│        workspaceMode = "PERSONAL"         │
│ • Không cần MediaPackage / Client         │
│ • Mở sẵn Chiến dịch & Tạo Task độc lập    │
│ • Hỗ trợ Tự duyệt 1 chạm (Self-Approve)   │
└─────────────────────┬─────────────────────┘
                      │  ▲
   Scale-up (3.4.16)  │  │ Simplify (3.4.16): Chỉ cho phép khi KHÔNG có
   (Giữ nguyên 100%   │  │ Client đang ACTIVE và không có phần chờ Client
    dữ liệu)          ▼  │ (Vi phạm → 409 WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT)
┌─────────────────────┴─────────────────────┐
│         workspaceMode = "AGENCY"          │
│ • Quy trình 3 bước: Gói → Chiến dịch → Việc│
│ • Có Client Portal & Duyệt 3 tầng         │
└───────────────────────────────────────────┘
```

---

## 2. Máy Trạng Thái Gói Dịch Vụ, Chiến Dịch & Yêu Cầu Nội Dung (`3.5.1` – `3.5.13`)

### 2.1. Gói Truyền thông của Workspace (`WorkspaceMediaPackage`)
```
DRAFT ──(Request 3.5.3)──▶ REQUESTED ──(Approve 3.5.4 bởi Owner/Manager)──▶ APPROVED (Mở khóa Chiến dịch)
```
*(Trong chế độ `PERSONAL`, hệ thống tự cấp ngầm gói khung ở trạng thái `APPROVED` ngay từ đầu).*

### 2.2. Chiến dịch Truyền thông (`MediaCampaign`)
```
DRAFT ──(Deploy / Approve 3.5.8)──▶ ACTIVE (Sinh Task cha + Subtask theo TaskCatalog)
                                      │
                        (Complete 3.5.9 bởi Manager)
                                      ▼
                                  COMPLETED
```

### 2.3. Yêu cầu Nội dung phát sinh (`ContentRequest` — `3.5.10`..`3.5.13`)
```text
                        ┌──(Hủy khi đang PENDING — 3.5.13)────────────────▶ CANCELLED
                        │
[Tạo mới 3.5.10] ──────▶ PENDING ──(Tiếp nhận 3.5.11)──▶ IN_PROGRESS ──(Chấp nhận 3.5.11)──▶ ACCEPTED (Tự sinh TaskDocument)
                                                               │
                                                               └──(Từ chối 3.5.11)────────▶ DENIED (Trạng thái cuối)
```

---

## 3. Máy Trạng Thái Phần Soạn Thảo (`TaskSection`) & Công Việc (`TaskDocument`)

### 3.1. Vòng đời Phần Soạn thảo (`TaskSection.status` — 8 Loại `TaskType`)
```
  ┌──────────(Luồng Tự duyệt 1 chạm: POST /tasks/{id}/self-approve CHỈ ở chế độ PERSONAL)──────┐
  │                                                                                            ▼
DRAFT ──(Chủ phần Submit)──▶ SUBMITTED ──(Owner/Manager/Supervisor Approve)──▶ INTERNAL_APPROVED (Cuối với phần I
  ▲                             │                                                │  hoặc khi requiresClientApproval=false)
  │◀──(Owner/Manager/Sup Return)┘                                                │
  │                                                           (Với phần O khi requiresClientApproval=true)
  │                                                                              ▼
RETURNED ◀────────────(Client Return + note)───────────────────────────── CLIENT_APPROVED (Trạng thái cuối phần O)
  ▲
  └───────────────────(Owner / Manager Reopen trước khi bài xuất bản)────────────┘
```
- **Quy tắc kế thừa Người giám sát (`effectiveSupervisor`)**: Nếu `Subtask` có `supervisorOverrideId` thì dùng người đó; nếu không có thì kế thừa **`task.supervisorId`** (Người giám sát của Task cha), sau đó mới fallback về `defaultManager` (`Owner`/`Manager`). `Creator` không bao giờ được làm Người giám sát cho phần/công việc do chính mình thực hiện.
- **Quy tắc tự động đồng bộ Subtask vai trò (`syncRoleSubtasks`)**:
  - Một `Subtask` có `subtaskRole != null` **tự động chuyển sang `FINISHED`** ngay khi toàn bộ các phần (`TaskSection`) mà vai trò đó sở hữu đạt trạng thái cuối (`finalState`: `INTERNAL_APPROVED` đối với phần `INTERNAL` hoặc khi `requiresClientApproval = false`, `CLIENT_APPROVED` đối với phần `OUTPUT` khi `requiresClientApproval = true`).
  - Nếu bất kỳ phần nào bị `Return` hoặc `Reopen`, `Subtask` đó tự động quay về `IN_PROGRESS`.

### 3.2. Vòng đời Công việc Cha (`TaskDocument.status`) & Tự động Chốt (`Auto-Settlement`)
```
          ┌──────────(1-Click Self-Approve CHỈ trong chế độ PERSONAL)───────────────┐
          │                                                                         ▼
TODO ──▶ IN_PROGRESS ──(Đủ 100% phần INTERNAL_APPROVED & cần Client)──▶ IN_REVIEW (CLIENT) ──▶ FINISHED (APPROVED)
          │   ▲   ▲         │                                                  │                    │
          │   │   │         └──(Đủ 100% phần INTERNAL_APPROVED & KHÔNG cần Client → TỰ ĐỘNG CHỐT)───┘
          │   │   └────────────(Owner / Manager / Supervisor / Client Return phần)──────────────────┤
          │   └────────────────(Client Return hoặc Owner/Manager Reopen phần trước giờ đăng)────────┘
          └────(Task đơn không chia Subtask: Submit → IN_REVIEW [MANAGER → CLIENT] → Approve → FINISHED)
```
- **Rào chắn Chống Nhảy Cóc (`Anti-Bypass`)**: API `PATCH /tasks/{id}/status`, kéo thả Kanban và Thanh thao tác hàng loạt (`Bulk Action`) **bị chặn tuyệt đối (`409 TASK_WORKFLOW_REQUIRED`)** không cho chuyển thẳng sang `IN_REVIEW` hoặc `FINISHED` khi chưa đi qua luồng nộp và phê duyệt hợp lệ; thao tác chuyển sang `CANCELLED` chỉ dành cho `Owner` và `Manager`.

---

## 4. Máy Trạng Thái Bài Đăng MXH (`PostDocument`) & Bản Tin Email (`MailBatch`)

### 4.1. Bài đăng Mạng xã hội (`PostDocument.status` — FB, IG, TikTok, Threads)
```
DRAFT ──(Task cha đạt FINISHED/APPROVED)──▶ APPROVED / SCHEDULED (scheduledAt)
  ▲                                                  │
  │ (Tự động về DRAFT & xóa scheduledAt              │ (Publish Now hoặc PostSchedulePublishJob
  │  nếu Client trả lại phần trước giờ đăng)          │  đẩy qua RabbitMQ sang publisher-service)
  │                                                  ▼
  └───────────────────────────────────────────── PUBLISHING
                                                     │
                        ┌────────────────────────────┼────────────────────────────┐
                        ▼                            ▼                            ▼
                    PUBLISHED               PARTIALLY_PUBLISHED                 FAILED
              (Thành công mọi kênh)       (Thành công một số kênh)         (Cho phép Retry)
```

### 4.2. Đợt gửi Email Mẫu & Newsletter (`MailBatch.status`)
```
QUEUED / SCHEDULED ──(MailDeliveryService claimNext)──▶ PROCESSING
       │                                                    │
 (Cancel khi Client                                         ├──(Đủ quota)────────────▶ COMPLETED
  trả phần EMAIL)                                           │
       ▼                                                    └──(Chạm trần ngày/tháng)─▶ DEFERRED (Chờ chu kỳ kế tiếp)
   CANCELLED
```

---

## 5. Máy Trạng Thái Hóa Đơn SePay, Tạm Giữ AI Credit & Kiểm Duyệt Admin

### 5.1. Hóa đơn Thanh toán SePay (VietQR — `3.9.2`, `3.9.3`)
```text
PENDING (Hiển thị mã VietQR SePay) ──(SePay Webhook xác nhận giao dịch hợp lệ)──▶ PAID (Cấp gói & Credit)
   │
   ├──(Quá hạn thanh toán TTL)──▶ EXPIRED
   └──(Hủy đơn / lỗi giao dịch)──▶ FAILED / CANCELLED
```

### 5.2. Giao dịch Tạm giữ & Quyết toán AI Credit (`CreditReservation.status`)
```
[Gọi tác vụ AI tính phí: CONTENT / AMBASSADOR / IMAGE / VIDEO]
                         │
                         ▼
                 HOLD (Reserved)
                 ├──(AI trả kết quả thành công)──▶ SETTLED (Trừ Plan Credit trước, Purchased Credit sau)
                 └──(AI lỗi hoặc Timeout)────────▶ RELEASED (Hoàn trả 100% số dư khả dụng)
```

### 5.3. Hàng đợi Kiểm duyệt Nội dung của Admin (`ModerationItem.status` — `3.10.4` & `3.10.5`)
```
[Bài viết bị gắn cờ tại bước 3.6.33 Check Compliance Content]
                         │
                         ▼
                   PENDING_REVIEW
                   ├──(Admin Approve)──▶ APPROVED (Gỡ cờ cảnh báo)
                   └──(Admin Reject)───▶ REJECTED (Chặn nội dung + Cập nhật Violation Status 3.10.5)
```

> **Ghi chú tuân thủ `AGENTS.md`**: Máy trạng thái `LivestreamSession` đã được gỡ bỏ hoàn toàn khỏi hệ thống.
