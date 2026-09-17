# Use Cases — Index (105 UC, V2)

> [<< Về Overview](../00-overview.md)
> Nguồn gốc: `brandhub-infrastructure/Các FR của hệ thống - Use Case.csv` (105 UC, map 1-1 với FR trong `docs/BA/02-09`).
> **Thay thế hoàn toàn** giả định "60 UC" cũ trong `docs/plan/brandhub-master-plan.md` (Epic E03) / `docs/plan/document-plan.md` (EPIC D13) — 2 tài liệu đó chưa cập nhật theo CSV thật, cần re-scope riêng.

## Danh sách file theo domain

| File | Domain | UC range | Số lượng |
|---|---|---|---|
| [01-authentication-profile.md](01-authentication-profile.md) | Authentication & Profile | UC-01 → UC-12 | 12 |
| [02-agency-workspace.md](02-agency-workspace.md) | Agency & Workspace | UC-13 → UC-31 | 19 |
| [03-media-package-campaign.md](03-media-package-campaign.md) | Media Package & Campaign | UC-32 → UC-41 | 10 |
| [04-content-task-workflow.md](04-content-task-workflow.md) | Content & Task Workflow | UC-42 → UC-73 | 32 |
| [05-ai-features.md](05-ai-features.md) | AI Features | UC-74 → UC-82 | 9 |
| [06-publishing-social.md](06-publishing-social.md) | Publishing & Social | UC-83 → UC-89 | 7 |
| [07-subscription.md](07-subscription.md) | Subscription | UC-90 → UC-96 | 7 |
| [08-admin-management.md](08-admin-management.md) | Admin Management | UC-97 → UC-106 | 9 |
| **Tổng** | | UC-01 → UC-106 (105 UC, không có UC-XX trùng/gap) | **105** |

## Nhóm theo 6 Role (Actor)

| Role | UC chính (không đầy đủ tuyệt đối do nhiều UC multi-actor) |
|---|---|
| GUEST | UC-01, UC-02, UC-03 |
| USER | UC-04 → UC-12, UC-90, UC-92 |
| OWNER | UC-13 → UC-31 (phần lớn), UC-32, UC-34, UC-35, UC-91, UC-93, UC-94, UC-95, UC-96 |
| MANAGER | UC-21 → UC-31 (phần lớn), UC-32 → UC-39, UC-42 → UC-73 (phần lớn), UC-61, UC-63, UC-86 |
| CREATOR | UC-44 → UC-89 (phần lớn nhóm Content/Task/AI/Publishing) |
| CLIENT | UC-11, UC-12, UC-33 → UC-41, UC-44, UC-45, UC-46, UC-47, UC-50 → UC-57, UC-72, UC-73, UC-83 → UC-85 |
| ADMIN | UC-80, UC-97 → UC-106 |

> Ghi chú: nhiều UC liệt kê nhiều actor trong CSV gốc nhưng chỉ 1 actor thực sự thao tác (actor còn lại chỉ có quyền xem/duyệt) — xem chú thích "Note" trong từng UC chi tiết, đặc biệt UC-34, UC-38, UC-39.

## Quy tắc đọc

- Mỗi UC file con có: **Bảng tổng hợp** (ID, tên, actor, FR liên quan) + **chi tiết từng UC** (Actor(s), Description, Precondition, Main Flow, Alternate Flow, Postcondition khi có, Business Rule/Note khi có).
- Nguồn business rule chi tiết luôn dẫn chiếu về file FR gốc tương ứng (`docs/BA/02-09`).
- Câu hỏi nghiệp vụ chưa chốt được đánh dấu **[OPEN QUESTION]** — không tự quyết định thay BA.
