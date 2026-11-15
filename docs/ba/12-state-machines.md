# 12 — Máy Trạng Thái Toàn Hệ Thống (System State Machines)

> [<< 11 - Data Entities & Glossary](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/11-data-entities-glossary.md) | [Overview](file:///D:/ProjectCode/BrandHub/brandhub-infrastructure/docs/ba/00-overview.md)
>
> Tài liệu này định nghĩa toàn bộ các Máy Trạng Thái (State Machines) đang vận hành trong hệ thống **BrandHub**, bao gồm cả vòng đời duyệt từng phần (`TaskSection`), tự duyệt 1 chạm (`Self-Approve` trong chế độ `PERSONAL`), hủy lịch tự động khi trả bài, và tạm giữ/quyết toán ví AI Credit.

---

## 1. Máy Trạng Thái Không Gian Làm Việc & Chế Độ Vận Hành (`Workspace` & `WorkspaceMode`)

### 1.1. Trạng thái Vòng đời `Workspace.status`
```
[Tạo Workspace (3.4.13) hoặc Bootstrap Personal Studio]
                         │
                         ▼
                      ACTIVE ◄──── Restore (3.4.18, Owner/Manager) ────┐
                      │    │                                           │
  Archive (3.4.17) ───┘    └──── Delete (3.4.16, Owner) ───▶ DELETED   │
         │                                                             │
         ▼                                                             │
     ARCHIVED (Chỉ đọc, dừng mọi job xuất bản tự động) ─────────────────┘
```

### 1.2. Chuyển đổi Chế độ `settings.workspaceMode` (`PERSONAL ↔ AGENCY`)
```
┌───────────────────────────────────────────┐
│        workspaceMode = "PERSONAL"         │
│ • Không cần MediaPackage / Client         │
│ • Mở sẵn Chiến dịch & Tạo Task độc lập    │
│ • Hỗ trợ Tự duyệt 1 chạm (Self-Approve)   │
└─────────────────────┬─────────────────────┘
                      │  ▲
   Scale-up (3.4.15)  │  │ Simplify (3.4.15): Chỉ cho phép khi KHÔNG có
   (Giữ nguyên 100%   │  │ Client đang ACTIVE và không có phần chờ Client
    dữ liệu)          ▼  │ (Vi phạm → 409 WORKSPACE_MODE_SWITCH_BLOCKED_BY_ACTIVE_CLIENT)
┌─────────────────────┴─────────────────────┐
│         workspaceMode = "AGENCY"          │
│ • Quy trình 3 bước: Gói → Chiến dịch → Việc│
│ • Có Client Portal & Duyệt 2 cấp          │
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

### 2.3. Yêu cầu Nội dung của Khách hàng (`ContentRequest` — `3.5.10`..`3.5.13`)
```
                       ┌──(Client hủy 3.5.13)──────────▶ CANCELLED
                       │
[Client tạo 3.5.10] ──▶ PENDING ──(Manager duyệt 3.5.12)──▶ APPROVED (Tự sinh TaskDocument)
                       │
                       └──(Manager từ chối 3.5.12)─────▶ REJECTED
```

---

## 3. Máy Trạng Thái Phần Soạn Thảo (`TaskSection`) & Công Việc (`TaskDocument`)

### 3.1. Vòng đời Phần Soạn thảo (`TaskSection.status` — 8 Loại `TaskType`)
```
  ┌──────────(Luồng Tự duyệt 1 chạm: POST /tasks/{id}/self-approve ở chế độ PERSONAL)──────────┐
  │                                                                                            ▼
DRAFT ──(Chủ phần Submit)──▶ SUBMITTED ──(Manager/Supervisor Approve)──▶ INTERNAL_APPROVED (Cuối với phần I
  ▲                             │                                           │  hoặc khi requiresClientApproval=false)
  │◀──(Manager Return + note)───┘                                           │
  │                                                      (Với phần O khi requiresClientApproval=true)
  │                                                                         ▼
RETURNED ◀────────────(Client Return + note)──────────────────────── CLIENT_APPROVED (Trạng thái cuối phần O)
  ▲
  └───────────────────(Manager Reopen trước khi Task đóng)──────────────────┘
```
- **Quy tắc tự động đồng bộ Subtask vai trò (`syncRoleSubtasks`)**:
  - Một `Subtask` có `subtaskRole != null` **tự động chuyển sang `FINISHED`** ngay khi toàn bộ các phần (`TaskSection`) mà vai trò đó sở hữu đạt trạng thái cuối (`INTERNAL_APPROVED` hoặc `CLIENT_APPROVED`).
  - Nếu bất kỳ phần nào bị `Return` hoặc `Reopen`, `Subtask` đó tự động quay về `IN_PROGRESS`.

### 3.2. Vòng đời Công việc Cha (`TaskDocument.status`)
```
          ┌──────────(1-Click Self-Approve trong chế độ PERSONAL)───────────┐
          │                                                                 ▼
TODO ──▶ IN_PROGRESS ──(Submit Task khi đủ phần INTERNAL_APPROVED)──▶ IN_REVIEW ──▶ FINISHED (APPROVED)
  ▲           ▲                                                         │               │
  │           └────────────(Manager / Client Return phần)───────────────┘               │
  └────────────────────────(Client Return phần sau khi đã FINISHED → Hủy lịch đăng)─────┘
```

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

### 5.1. Hóa đơn Thanh toán SePay / PayOS (`Invoice.status`)
```
PENDING (Hiển thị mã VietQR) ──(SePay Webhook xác nhận giao dịch hợp lệ)──▶ PAID (Cấp gói & Credit)
   │
   ├──(Quá hạn thanh toán TTL)──▶ EXPIRED
   └──(Người dùng hủy đơn)──────▶ CANCELLED
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
