# UC 06 — Publishing & Social (UC-83 → UC-89)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [07-publishing-social-collaborator.md](../07-publishing-social-collaborator.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`
> **Phạm vi platform:** Facebook, Instagram, TikTok, Threads — KHÔNG Zalo OA (loại khỏi scope).

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-83 | Connect/Disconnect Social Account | CLIENT | 3.8.1, 3.8.2 |
| UC-84 | View Post Dashboard | All roles (MEMBER) | 3.8.3 |
| UC-85 | View Post Detail & Comments | All roles (MEMBER) | 3.8.4, 3.8.5 |
| UC-86 | Preview, Schedule & Track Post Status | CREATOR/MANAGER | 3.8.6, 3.8.7, 3.8.8 |
| UC-87 | Publish to Facebook | System/CREATOR | 3.8.9, 3.8.10, 3.8.11 |
| UC-88 | Publish to Instagram | System/CREATOR | 3.8.12, 3.8.13, 3.8.14 |
| UC-89 | Publish to TikTok & Threads | System/CREATOR | 3.8.15, 3.8.16 |

---

## UC-83 — Connect/Disconnect Social Account

- **Actor(s):** CLIENT
- **Description:** Connect a social media account for automated posting; disconnect when needed.
- **Precondition:** Client is a Workspace member.
- **Main Flow:**
  1. CLIENT initiates OAuth connect flow for a platform (Facebook/Instagram/TikTok/Threads).
  2. System stores the access token, links the social account to the Workspace.
- **Alternate Flow:**
  - A1. CLIENT disconnects → system revokes/removes the stored token, logs the account out.

## UC-84 — View Post Dashboard

- **Actor(s):** All roles (MEMBER)
- **Description:** View the overview dashboard of successfully published posts across the Workspace.
- **Precondition:** At least one post published.
- **Main Flow:**
  1. User opens Post Dashboard.
  2. System displays aggregated stats of published posts.

## UC-85 — View Post Detail & Comments

- **Actor(s):** All roles (MEMBER)
- **Description:** View post details (reactions, shares) and the list of comments on that post.
- **Precondition:** Post has been published.
- **Main Flow:**
  1. User opens a specific post.
  2. System shows reaction/share counts (Track Detail) and the full comment list (Comment Detail List).

## UC-86 — Preview, Schedule & Track Post Status

- **Actor(s):** CREATOR/MANAGER
- **Description:** Preview post layout per platform, schedule posts, and track progress status (Pending/In Progress/Done/Fail).
- **Precondition:** Task (Post-type) has completed Approval Sequence.
- **Main Flow:**
  1. CREATOR/MANAGER previews how the post renders per target platform.
  2. Sets/adjusts the scheduled publish time on the posting calendar.
  3. System queues the post; status tracked through `PENDING → IN_PROGRESS → DONE/FAIL`.

## UC-87 — Publish to Facebook

- **Actor(s):** System/CREATOR
- **Description:** Push a Post, Story, or Reels to Facebook.
- **Precondition:** Post approved and scheduled (UC-86); Facebook account connected (UC-83).
- **Main Flow:**
  1. System dequeues the scheduled item at trigger time.
  2. Calls Facebook Graph API to publish as Post/Story/Reels per content type.
  3. Updates status to `DONE`.
- **Alternate Flow:**
  - A1. API call fails → status `FAIL`, retry/error surfaced on the dashboard.

## UC-88 — Publish to Instagram

- **Actor(s):** System/CREATOR
- **Description:** Push a Post, Reels, or Story to Instagram.
- **Precondition:** Post approved and scheduled; Instagram account connected.
- **Main Flow:**
  1. System dequeues the scheduled item.
  2. Calls Instagram API to publish as Post/Reels/Story.
  3. Updates status to `DONE`.
- **Alternate Flow:**
  - A1. API call fails → status `FAIL`.

## UC-89 — Publish to TikTok & Threads

- **Actor(s):** System/CREATOR
- **Description:** Push a short video to TikTok and a post to Threads.
- **Precondition:** Post approved and scheduled; target account connected.
- **Main Flow:**
  1. System dequeues the scheduled item.
  2. Calls TikTok Content API (video) or Threads API (post) accordingly.
  3. Updates status to `DONE`.
- **Alternate Flow:**
  - A1. API call fails → status `FAIL`.

---

## Ghi chú mở rộng — Third-party Collaborator (module mới, chưa có số FR chính thức)

Không thuộc 105 UC chính thức (chưa có FR number trong CSV gốc) — ghi nhận tại đây để không thất lạc khi cập nhật CSV:

- **Track Collaborator Status** (đề xuất) — Manager/Creator cập nhật thủ công trạng thái hợp tác với đối tác không có API (báo điện tử, banner, TV): `đã liên hệ → đang đàm phán → đã chốt → đã lên sóng`. Gắn với 1 Media Campaign/Task cụ thể. Không tự động hóa đăng bài lên các kênh này.
- Nguồn: [07-publishing-social-collaborator.md](../07-publishing-social-collaborator.md) §2. **[OPEN QUESTION]** — cần bổ sung số FR chính thức (đề xuất 3.8.17+ hoặc nhóm riêng 3.11) và thiết kế entity/DB schema khi cập nhật CSV gốc.
