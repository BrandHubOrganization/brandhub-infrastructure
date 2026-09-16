# Sprint Plan V2 — Tổng quan định hướng (Sprint 8–12)

> Bản tóm tắt dễ đọc. Chi tiết task ID, Goal/AC đầy đủ nằm trong `brandhub-master-plan.md` (Phần 1.5, 1.6, Phần 2). File này chỉ để nắm hướng đi nhanh.
>
> Chưa đẩy Jira — chờ Trung duyệt.

## Bức tranh lớn

5 sprint (10 tuần), 5 người (Trung, Lộc, Phước, Tuấn, Ân), 4 domain nghiệp vụ mới hoàn toàn (Media Package/Campaign, Task & Content Workflow, Publishing & Social OAuth, Analytics/Notification/Admin) + phần nền tảng cần sửa (Agency, RBAC, Billing).

Sprint 13–14 Trung tự lo (chuẩn bị bảo vệ) — không nằm trong 5 sprint này.

## Con đường khoá chặn (phải xong đúng thứ tự)

```
Trung: E13 RBAC refactor → E14 permission → E16 Agency
                                                 │
                    ┌────────────────────────────┼──────────────────────┐
                    ▼                             ▼                      ▼
        Lộc: E50 Media Package/Campaign     Tuấn: E17 Billing      (không ai khác chờ)
                    │
                    ▼ (E50-07: approve Campaign → sinh Task)
        Lộc/Phước/Tuấn/Trung: E51 Task & Content Workflow
                    │
                    ▼ (cần data thật từ E50/E51)
        Ân/Tuấn: E53 Analytics/Notification/Admin
```

**Phước (E52 Publishing OAuth) và một phần Tuấn/Ân (E51 Material/Hashtag, E53 Notification/User-mgmt) hoàn toàn độc lập với chuỗi trên** — chạy song song từ Sprint 8, không ai phải ngồi chờ Trung.

## Lịch theo sprint (tổng quan)

| Sprint | Trọng tâm | Ai bận nhất | Ai còn nhẹ |
|---|---|---|---|
| **8** (08/09–22/09) | Trung dựng nền Agency/RBAC (task chặn cả dự án). Các nhánh độc lập chạy full: Phước làm OAuth Facebook/TikTok/Threads, Tuấn làm Material Repository, Ân làm Notification | Trung, Phước | — |
| **9** (14/09–28/09) | Trung hoàn tất Agency → mở khoá Lộc (Media Package) và Tuấn (Billing) chạy full tốc | Trung, Lộc | Ân (chờ data để làm Analytics) |
| **10** (đầu tháng 10) | Lộc vào phần khó nhất của Media Package (đàm phán 2 bên approve). Trung xong hết phần nền, chuyển sang phụ E51 (Mail Template). Phước bắt đầu các view Task (List/Calendar/Kanban) | Lộc | Ân (vẫn chờ) |
| **11** (giữa/cuối tháng 10) | Lộc chốt Media Package → sinh Task backlog → mở khoá Approval Sequence. Ân bắt đầu code Analytics thật (đã có data). Tuấn làm Compliance/Copyright check. Trung viết QA/integration test cho E13/E14/E16 đã code Sprint 8-9 (task thật, có checklist AC — không phải "hỗ trợ" chung) | Lộc, Ân | — (không ai rảnh, Trung có việc QA cụ thể) |
| **12** (đầu/giữa tháng 11) | Phước làm Approval Sequence — **task rủi ro kỹ thuật cao nhất toàn dự án**, không giao thêm việc khác cho Phước sprint này. Ân hoàn thiện Admin, thay hết mock service bằng API thật. Trung QA tiếp E50/E17. Tuấn QA lại toàn bộ phần E51 mình đã code (Material/Hashtag/Compliance/Copyright) | Phước | — (Trung/Tuấn có task QA cụ thể, không rảnh) |

## Ai làm gì, từng sprint (chi tiết theo người)

Task ID đầy đủ (Goal/AC/Technical Notes) xem trong `brandhub-master-plan.md` Phần 2 — mục dưới chỉ nêu task ID và nội dung ngắn theo thứ tự làm.

### Trung

| Sprint | Task | Nội dung |
|---|---|---|
| 8 | DA-E13-05 → E13-06 → E14-05 → E14-06 → E16-05 → E16-06 | Refactor role RBAC, mở Agency Entity (task chặn cả dự án) + tạo Agency |
| 9 | DA-E16-07 → 08 → 09 → 10 → 12 → 11 | Hoàn tất Agency: profile, xoá mềm, member, FK Workspace, template |
| 10 | DA-E51-06e → E51-10 → 10b → 10c → 10d → 10e | Watermark (FR 3.6.15) + toàn bộ Mail Template CRUD/Send |
| 11 | QA-E13 → QA-E14 → QA-E16 | Viết integration test, verify từng AC cho E13/E14/E16 đã code Sprint 8-9 |
| 12 | QA-E50 → QA-E17 | Viết integration test, verify AC cho E50 (Lộc) và E17 (Tuấn) |

### Lộc

| Sprint | Task | Nội dung |
|---|---|---|
| 8 | DA-E51-01 → E51-02 → E50-01 (nếu kịp) | Collection `tasks`/`task_approvals` + bắt đầu Entity MediaPackage |
| 9 | DA-E50-01 (nếu chưa xong) → 02 → 03 → 08 | Media Package selection flow + WorkspaceMediaPackage + ThirdPartyCollaborator |
| 10 | DA-E50-04 → 05 → 06 → 09 | Negotiation loop 2-bên-approve (Complex nhất E50) + MediaCampaign + CampaignCollaborator |
| 11 | DA-E50-07 → E50-10 → E51-04 | Approve Campaign → sinh Task backlog + Content Request + Task Assign |
| 12 | DA-E51-02/03 phối hợp Phước | Hỗ trợ kỹ thuật trực tiếp cho Approval Sequence (đã làm nền từ Sprint 8) |

### Phước

| Sprint | Task | Nội dung |
|---|---|---|
| 8 | DA-E52-01 → 02 → 03 → 04 | Meta OAuth (Facebook/Instagram) + TikTok/Threads OAuth |
| 9 | DA-E52-05 → 06 → 07 → 08 | Token refresh job + callback webhook + retry backoff — xong hết E52 |
| 10 | DA-E51-05 | Task views: List/Calendar/Gantt/Kanban/Filter |
| 11 | DA-E51-08 → 08b → 08c → 08d → 09 → 09b | Livestream idea/script/status/meeting-link + Survey creation/analysis |
| 12 | DA-E51-03 → E51-14 | **Approval Sequence state machine (rủi ro cao nhất dự án)** + `posts` collection |

### Tuấn

| Sprint | Task | Nội dung |
|---|---|---|
| 8 | DA-E51-06 → 06b → 06c → 06d → 06f → 06g → E53-06 | Material Repository (view/add/update/remove/download) + Brand Collection + System Health |
| 9 | DA-E17-05 → 06 → E51-07 → 07b → 07c → 07d → 07e | UserSubscription/Transaction rename + Hashtag Collection full CRUD |
| 10 | DA-E17-07 → E51-13 | AI Credit Ledger + Content History no-double-charge |
| 11 | DA-E51-11 → 12 | Compliance check + Copyright infringement check |
| 12 | QA-E51-Tuấn | Test lại toàn bộ Material/Hashtag/Compliance/Copyright mình đã code |

### Ân

| Sprint | Task | Nội dung |
|---|---|---|
| 8 | DA-E53-04 → 05 → 08 → 09 | Notification CRUD + trigger event + User view/create/update + verify/disable |
| 9 | E53-04/05 dở (nếu còn) → research aggregation | Chờ E50/E51 có data — dùng thời gian chuẩn bị khung E53-01 |
| 10 | E53-08/09 dở (nếu còn) → viết khung E53-01 | Vẫn chờ data thật — research trước, code sau |
| 11 | DA-E53-01 → 02 → 03 | Analytics aggregation API + report PDF + thay mock service (data đã có từ E50/E51) |
| 12 | DA-E53-07 → E53-10 | Content Moderation Queue + thay toàn bộ mock service Admin bằng API thật (task đóng epic E53) |

## Điểm rủi ro cần để mắt

1. **DA-E16-05 (Agency Entity, Trung, Sprint 8)** — chặn gần như mọi domain khác. Trễ task này = trễ dây chuyền cả Lộc và Tuấn.
2. **DA-E50-04/05 (Negotiation loop 2-bên-approve, Lộc, Sprint 10)** — phức tạp nhất của Media Package, có rule ACID khó (sửa terms phải reset approval).
3. **DA-E51-03 (Approval Sequence, Phước, Sprint 12)** — rủi ro cao nhất toàn dự án: reject ở bước nào phải giữ nguyên approval các bước trước, không xoá.
4. **Ân nhẹ tay ở Sprint 9–10** — không phải rảnh vô ích, mà đang chờ Lộc/Trung tạo ra data thật để Analytics có gì mà tổng hợp. Nếu Sprint 8–9 Trung/Lộc trễ, Ân trễ theo dây chuyền.

## Epic nào kéo dài mấy sprint

- **E16 (Agency)** — Trung, Sprint 8–9 (2 sprint)
- **E50 (Media Package/Campaign)** — Lộc, Sprint 8–11 (4 sprint, xuyên suốt)
- **E51 (Task & Content Workflow)** — Lộc/Phước/Tuấn/Trung cùng góp, Sprint 8–12 (toàn bộ 5 sprint, domain lớn nhất)
- **E52 (Publishing OAuth)** — Phước, Sprint 8–9 (xong sớm, gọn)
- **E53 (Analytics/Notification/Admin)** — Ân/Tuấn, Sprint 8–12 (kéo hết vì phải chờ data)
- **E17 (Billing)** — Tuấn, Sprint 9–10 (ngắn)
