# Report 2 — Checklist sửa theo BA V2 + Feature

> Mục đích: đối chiếu `FormReportDA/reports/BrandHub_Report2_Project_Management_Plan.docx` với nghiệp vụ mới trong `docs/ba/` (V2, 2026-09-14) và `docs/feature/`, liệt kê từng điểm cần sửa + cách sửa cụ thể.
>
> Nguồn sự thật: `docs/ba/00-overview.md` (109 FR, 105 UC, 9 domain, deadline 19/12/2026), `docs/feature/` (124 folder), `docs/plan/sprint-plan-v2-overview.md`, `docs/plan/brandhub-master-plan.md`.

---

## Tổng quan vấn đề

Report 2 đang là **skeleton theo mô hình CŨ**: 1-tầng Workspace, RBAC 6 role cố định, 16 sprint, ~46 epic, ~406 task, deadline tháng 11/2026. BA V2 đã thay đổi nền tảng nghiệp vụ, nên toàn bộ phần **Scope & Estimation** và **mô hình org/RBAC** lệch nặng, còn lại là chỉnh số liệu lẻ.

Thứ tự ưu tiên sửa: **(1) Scope/WBS → (2) mô hình org → (3) risk → (4) training/tech → (5) responsibility → (6) linh tinh.**

---

## 1. Scope & Estimation (§1.1) — số liệu cũ toàn bộ

| Mục | Hiện tại (Report 2) | Sửa thành | Cách sửa |
|---|---|---|---|
| Số sprint | 16 sprints + 4 AI iterations | Re-scope. Sprint plan V2 chỉ chốt Sprint 8–12 (5 sprint / 10 tuần); Sprint 13–14 Trung tự lo | Cập nhật theo `sprint-plan-v2-overview.md`, bỏ khái niệm "16 sprint cứng" |
| Số epic/task | ~46 epics, ~406 tasks | 109 FR / 105 Use Case / 9 domain | Dựng lại WBS từ danh sách FR (`Các FR của hệ thống - Feature_Function Requirement.csv`) |
| Man-day | 860–900 man-days (5 người x 32 tuần) | Tính lại theo 109 FR + deadline mới 19/12/2026 | Re-estimate mỗi FR theo độ phức tạp (S/M/C) |
| Deadline | Tháng 11/2026 (ngầm định) | **19/12/2026** | Ghi rõ trong §1.1, trích `ba/00-overview.md` |

**Thêm 9 domain mới vào WBS** (Report 2 chưa nêu):
1. Media Package → Media Campaign (FR 3.5.1–3.5.10)
2. Task & Content Workflow (FR 3.6.1–3.6.35)
3. Publishing & Social (FR 3.8.1–3.8.16)
4. Subscription & Billing (FR 3.9.1–3.9.7)
5. Admin (FR 3.10.1–3.10.12)
6. AI Features (FR 3.7.1–3.7.12)
7. Authentication (FR 3.2.1–3.2.9)
8. Profile (FR 3.3.1–3.3.4)
9. Agency/Workspace (FR 3.4.1–3.4.21)

> ⚠️ **Chốt số FR trước khi dựng WBS.** BA ghi 109 FR, nhưng `docs/feature/` có 124 folder (thiếu `3-10-10`, vài FR chia nhỏ). Đếm lại FR chuẩn từ CSV, thống nhất 1 con số.

---

## 2. Mô hình nghiệp vụ — Report 2 KHÔNG đề cập (thêm mới)

Các khái niệm sau **bắt buộc** phải xuất hiện trong §1.1 hoặc overview, nếu không report 2 lạc so với SRS (Report 3):

| Khái niệm | Nội dung mới | Cách sửa |
|---|---|---|
| **Org 3 tầng** | Cũ `User → Workspace` (1 tầng). Mới `User → Agency → Workspace` | Thêm 1 đoạn + sơ đồ org vào §1.1. Nguồn `ba/01-organization-structure.md` |
| **Role theo Workspace** | Cũ RBAC 6 role cố định. Mới role gán theo Workspace (`OWNER/MANAGER/MEMBER`) | Sửa §4 Responsibility + mọi chỗ nhắc RBAC. Nguồn `ba/10-roles-permissions-matrix.md` |
| **Hợp đồng 3 tầng** | Media Package (mẫu) → Media Campaign (kế hoạch) → Task backlog | Thêm vào scope. Nguồn `ba/04-media-package-campaign.md` |
| **Task 3 loại** | Post / Livestream / Survey-Form, chung 1 Approval Sequence | Nguồn `ba/05-content-task-workflow.md` |
| **Client ngoài Agency** | Client = actor ngoài, profile tái sử dụng xuyên Agency | Nguồn `ba/02-authentication-profile.md` |
| **ThirdPartyCollaborator** | Đối tác báo/banner/TV, theo dõi thủ công | Nguồn `ba/07-publishing-social-collaborator.md` |

---

## 3. Risks (§1.3) — chỉnh số liệu lẻ + bổ sung

| # | Hiện tại | Sửa thành | Cách sửa |
|---|---|---|---|
| Risk #3 | OAuth token for **5 platforms** | **4 platforms** (Facebook, Instagram, TikTok, Threads) | Sửa số, thêm tên platform |
| Risk #1 | AI API: Groq, Stability AI, Google Veo | Cập nhật theo feature AI thực tế (caption, ambassador, image/video gen) — BA 06 không còn pin provider cũ | Bỏ tên provider cụ thể hoặc ghi chung "AI provider (caption/image/video)" |
| Risk #5 | Multi-tenancy leakage (workspace isolation) | Nâng thành **Agency/Workspace 3-tầng isolation** | Cập nhật mô tả |

**Thêm risk mới** (từ BA V2):
- PayOS payment failure (thanh toán thất bại, webhook)
- Subscription/Billing edge case (hủy, downgrade, credit AI)
- Đàm phán / Approval Sequence phức tạp — **task rủi ro cao nhất** theo `sprint-plan-v2-overview.md`

---

## 4. Training (§2.3) + Tech stack

| Mục | Hiện tại | Sửa thành | Cách sửa |
|---|---|---|---|
| React version | React 18 | **React 19** (web-dashboard đang dùng React 19) | Sửa ở §2.3 + bảng tech stack (nếu trích lại) |
| AI | Groq/Stability/Veo | Bỏ provider cũ | Đồng bộ với §1.3 |
| Thiếu training | — | Thêm: PayOS, subscription/billing, OAuth 4 platform, mô hình 3 tầng | Thêm hàng vào bảng Training |

---

## 5. Responsibility (§4) — thiếu người

- D/R/S/I matrix "5 members" nhưng chỉ ghi 4 assignee: **Trung, Phước, Tuấn, Ân**.
- **Thiếu Lộc** (AI Sub-lead).
- Cách sửa: thêm Lộc, lấy phân công chi tiết từ `sprint-plan-v2-overview.md` (mục "Ai làm gì, từng sprint").

---

## 6. Linh tinh

| Mục | Cách sửa |
|---|---|
| Date tiêu đề "August 2026" | Cập nhật Sept 2026 (BA V2 ngày 2026-09-14) |
| Table 1 Record of Changes trống | Điền sau khi áp dụng toàn bộ thay đổi trên |

---

## Thứ tự thực hiện

1. Chốt số FR chuẩn (đếm lại CSV vs `feature/`).
2. Dựng lại WBS theo 9 domain + 109 FR (S/M/C + man-day).
3. Viết lại phần mô hình org/RBAC (3 tầng, role theo Workspace).
4. Sửa risk, training, responsibility, date.
5. Điền Record of Changes.
