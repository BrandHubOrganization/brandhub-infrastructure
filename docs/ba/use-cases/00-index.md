# Use Cases — Danh Mục Tổng Hợp (141 Atomic Use Cases `UC-001` – `UC-141`)

> [<< Về Overview](../00-overview.md)
> Đồng bộ 1-đối-1 với **Baseline 141 Yêu cầu Chức năng Nguyên tử (`3.2.1` – `3.10.14`)** trong `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`.
> Tuân thủ tuyệt đối **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Theo 9 Miền Nghiệp Vụ (Domains)

| File Chi Tiết | Miền Nghiệp Vụ (SRS Section) | Dãy FR Chuẩn | Dãy Use Case Chuẩn | Số Lượng |
| :--- | :--- | :-: | :-: | :-: |
| [01-authentication-profile.md](01-authentication-profile.md) | `3.2 Authentication & Authorization`<br>`3.3 User & Client Profile` | `3.2.1` – `3.2.9`<br>`3.3.1` – `3.3.4` | `UC-001` – `UC-009`<br>`UC-010` – `UC-013` | **13** *(9 + 4)* |
| [02-agency-workspace.md](02-agency-workspace.md) | `3.4 Agency & Workspace` *(gồm Personal Studio)* | `3.4.1` – `3.4.26` | `UC-014` – `UC-039` | **26** |
| [03-media-package-campaign.md](03-media-package-campaign.md) | `3.5 Media Package & Media Campaign` | `3.5.1` – `3.5.13` | `UC-040` – `UC-052` | **13** |
| [04-content-task-workflow.md](04-content-task-workflow.md) | `3.6 Content & Workflow` *(8 loại Task & Sections)* | `3.6.1` – `3.6.35` | `UC-053` – `UC-087` | **35** |
| [05-ai-features.md](05-ai-features.md) | `3.7 AI Features` *(Trend, RAG, Studio, KOL)* | `3.7.1` – `3.7.19` | `UC-088` – `UC-106` | **19** |
| [06-publishing-social.md](06-publishing-social.md) | `3.8 Publishing & Social` *(FB, IG, TikTok, Threads)* | `3.8.1` – `3.8.15` | `UC-107` – `UC-121` | **15** |
| [07-subscription.md](07-subscription.md) | `3.9 Subscription & Billing` *(SePay & AI Credit)* | `3.9.1` – `3.9.6` | `UC-122` – `UC-127` | **6** |
| [08-admin-management.md](08-admin-management.md) | `3.10 Admin Functions` | `3.10.1` – `3.10.14` | `UC-128` – `UC-141` | **14** |
| **Tổng cộng** | **9 Miền Nghiệp Vụ Chuẩn** | **`3.2.1` – `3.10.14`** | **`UC-001` – `UC-141`** | **141** |

---

## 2. Phân Bổ Use Cases Theo 6 Vai Trò Hệ Thống Chuẩn (Canonical Actors)

| Role Chuẩn | Enum Code | Các Dãy Use Case Tham Gia |
| :--- | :--- | :--- |
| **`Guest`** | `GUEST` | `UC-001` – `UC-005` (Đăng ký, Đăng nhập, Google Login, Xác thực Email, Quên mật khẩu) + Xem công khai qua `ShareLink` (`/s/:token`) và điền khảo sát (`/public/surveys/:token`). |
| **`Owner`** | `OWNER` | `UC-004`, `UC-006` – `UC-012`, `UC-014` – `UC-039` (Toàn bộ Quản trị Agency, Workspace & Personal Studio), `UC-040`, `UC-041`, `UC-043`, `UC-045`, `UC-053`, `UC-054`, `UC-057`, `UC-062` – `UC-069`, `UC-071`, `UC-073`, `UC-078`, `UC-080` – `UC-087`, `UC-088` – `UC-099`, `UC-101` – `UC-106`, `UC-109` – `UC-111`, `UC-113`, `UC-122` – `UC-127` (Gói cước, Thanh toán SePay & Ví AI Credit). |
| **`Manager`** | `MANAGER` | `UC-004`, `UC-006` – `UC-013`, `UC-015`, `UC-016`, `UC-019`, `UC-020`, `UC-022`, `UC-023`, `UC-025`, `UC-027`, `UC-028`, `UC-030` – `UC-039`, `UC-041` – `UC-048`, `UC-050`, `UC-051`, `UC-053` – `UC-087` (Toàn bộ Công việc, Duyệt nội bộ & Tự duyệt 1 chạm ở chế độ `PERSONAL`), `UC-088` – `UC-099`, `UC-101` – `UC-122`, `UC-125`. |
| **`Creator`** | `CREATOR` | `UC-004`, `UC-006` – `UC-012`, `UC-015`, `UC-016`, `UC-019`, `UC-020`, `UC-022`, `UC-023`, `UC-025`, `UC-027`, `UC-036`, `UC-045`, `UC-053` – `UC-056`, `UC-058`, `UC-062` – `UC-065`, `UC-070` – `UC-082`, `UC-085` – `UC-091`, `UC-093` – `UC-099`, `UC-101`, `UC-102`, `UC-106`, `UC-109` – `UC-122`, `UC-125`. |
| **`Client`** | `CLIENT` | `UC-004`, `UC-006` – `UC-013`, `UC-022`, `UC-023`, `UC-025`, `UC-027`, `UC-036`, `UC-041`, `UC-042`, `UC-045`, `UC-047`, `UC-049` – `UC-054`, `UC-059` – `UC-064`, `UC-071`, `UC-073`, `UC-078`, `UC-086`, `UC-087`, `UC-107` – `UC-111`, `UC-113`, `UC-122`. |
| **`Admin`** | `ADMIN` | `UC-006` – `UC-008`, `UC-010`, `UC-011`, `UC-100` (`3.7.13 Crawl Schedule Config`), `UC-124` (`3.9.3 View Invoice History`), `UC-128` – `UC-141` (`3.10.1` – `3.10.14`). |
