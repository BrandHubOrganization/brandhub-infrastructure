# Sprint 5 Report — Authentication, RBAC & Design System

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 5 |
| Timeline | Weeks 9–10 (Jul 15–28, 2026) |
| Phase | Phase 3 — Backend Core |
| Goal | Complete authentication system (register, login, OAuth, token refresh, logout), RBAC enforcement, and Design System foundation |
| Report date | 2026-08-02 |
| Reported by | Lê Trí Trung (Leader) |

> **AI Parallel:** AI Iteration 1 chạy đồng thời sprint này (Tuấn, Lộc). Hai thành viên này không có task trong Sprint 5 epics — báo cáo riêng trong AI Iteration 1 Report.

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | To Do | % Done |
|---|---|---|---|---|---|
| E12 — Authentication | 8 | 7 | 0 | 1 | 87.5% |
| E13 — User & Profile Management | 4 | 0 | 0 | 4 | 0% |
| E14 — Role-Based Access Control | 4 | 0 | 0 | 4 | 0% |
| E34 🔀 — Design System & Base Components | 5 | 4 | 1 | 0 | 80% |
| **Tổng** | **21** | **11** | **1** | **9** | **52%** |

> 🔀 E34 được dời từ Sprint 12 lên Sprint 5 sau rebalance (Lộc → AI Sub-lead, Phước nhận toàn bộ Frontend). E12 có 2 task phát sinh 🆕 (DA-E12-07 RS256 research, DA-E11-14 JPA models) không có trong plan gốc 6 task.

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done | In Review | To Do | Ghi chú |
|---|---|---|---|---|---|
| Trung (Leader) | 13 | 8 | 0 | 5 | Auth core (E12) hoàn chỉnh; RBAC + Profile + OAuth dời sang Sprint 6 |
| Phước (Publisher/Frontend) | 6 | 4 | 1 | 1 | Design System foundation hoàn chỉnh; Permission matrix blocked bởi RBAC |
| Ân (AI) | 2 | 0 | 0 | 2 | Blocked bởi RBAC + Workspace isolation chưa implement |
| Tuấn (AI) | — | — | — | — | AI Iteration 1 (không có task Sprint 5 epics) |
| Lộc (AI Sub-lead) | — | — | — | — | AI Iteration 1 (không có task Sprint 5 epics) |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File/Link | Tác giả | Chất lượng |
|---|---|---|---|
| Register API (bcrypt cost=12) | `brandhub-business-service/.../AuthController.java` | Trung | ⭐⭐⭐⭐⭐ |
| Login API (RS256 JWT + refresh cookie) | `brandhub-business-service/.../AuthController.java` | Trung | ⭐⭐⭐⭐⭐ |
| Refresh Token API (rolling rotation) | `brandhub-business-service/.../AuthController.java` | Trung | ⭐⭐⭐⭐⭐ |
| Logout API (Redis blacklist + cookie clear) | `brandhub-business-service/.../AuthController.java` | Trung | ⭐⭐⭐⭐⭐ |
| Forgot/Reset Password (OTP email flow) | `brandhub-business-service/.../AuthController.java` + `MailService.java` | Trung | ⭐⭐⭐⭐⭐ |
| RS256 Research & Decision | (trong code + config) | Trung | ⭐⭐⭐⭐ |
| JPA Models + Repositories (11 tables) | `brandhub-business-service/.../model/` + `repository/` | Trung | ⭐⭐⭐⭐⭐ |
| shadcn/ui + Tailwind + Design Tokens | `brandhub-web-dashboard/src/globals.css` + `tailwind.config.ts` | Phước | ⭐⭐⭐⭐⭐ |
| 13 Common Components (Button, Input, Modal, Toast, Table, Badge, Spinner, Dropdown, etc.) | `brandhub-web-dashboard/src/components/ui/` | Phước | ⭐⭐⭐⭐ |
| Layout Components (AuthGuard, Layout, Navbar, Sidebar, PageWrapper) | `brandhub-web-dashboard/src/components/layout/` | Phước | ⭐⭐⭐⭐⭐ |
| Axios Service Layer (interceptors + token refresh queue) | `brandhub-web-dashboard/src/services/api.ts` + `authService.ts` | Phước | ⭐⭐⭐⭐⭐ |
| Zustand authStore (persist) + 5 Auth Pages | `brandhub-web-dashboard/src/store/authStore.ts` + `pages/auth/` | Phước | ⭐⭐⭐⭐ |
| i18n Framework (en/vi) | `brandhub-web-dashboard/src/i18n/` | Phước | ⭐⭐⭐⭐ |
| Dark/Light Theme Provider | `brandhub-web-dashboard/src/components/theme/` | Phước | ⭐⭐⭐⭐ |

**Tổng:** 14 deliverables | Auth core: 7 | Design System: 7

---

## 4. Deliverables chưa hoàn thành

| Task ID | Mô tả | Assignee | Lý do | Kế hoạch |
|---|---|---|---|---|
| DA-E12-06 | Google OAuth login | Trung | Auth core (E12-01→05) chiếm toàn bộ thời gian; OAuth cần Google Cloud Console setup + OAuth2 flow implementation | Sprint 6 Week 1 |
| DA-E13-01 | GET/PUT /users/me | Trung | Dời sang Sprint 6 do auth core scope lớn hơn estimate | Sprint 6 Week 1 |
| DA-E13-02 | Avatar upload to S3 | Trung | Phụ thuộc vào E13-01 (cần UserController trước) | Sprint 6 Week 2 |
| DA-E13-03 | Admin: GET /admin/users | Ân | Blocked by DA-E14-01 (@RequireRole) + DA-E14-02 (workspace isolation) chưa implement | Sprint 6 Week 1 |
| DA-E13-04 | Admin: Ban/Suspend user | Ân | Blocked by DA-E13-03 + DA-E14-01 | Sprint 6 Week 2 |
| DA-E14-01 | @RequireRole annotation | Trung | Auth core chiếm toàn bộ thời gian — **Critical path, blocks 5 tasks khác** | Sprint 6 Week 1 |
| DA-E14-02 | Workspace isolation filter | Trung | Phụ thuộc vào E14-01 | Sprint 6 Week 2 |
| DA-E14-03 | BRAND_CLIENT isolation | Trung | Phụ thuộc vào E14-01 + E14-02 | Sprint 6 Week 2 |
| DA-E14-04 | Permission matrix document | Phước | Blocked by DA-E14-01 (chưa biết role nào có quyền gì) | Sprint 6 Week 1 |
| DA-E34-05 (workspaceStore) | Zustand workspace store | Phước | Chưa có Workspace API (E15) | Sprint 6 |
| DA-E34-05 (notificationStore) | Zustand notification store | Phước | Chưa có Notification API (E19) | Sprint 8 |

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh

- **Auth core production-ready:** Trung implement đầy đủ Register/Login/Refresh/Logout/ForgotPassword/ResetPassword với RS256 JWT, rolling refresh token + theft detection, HttpOnly cookie, Redis blacklist, OTP email flow. Nhiều pattern bảo mật vượt yêu cầu gốc (plan chỉ nói "issue JWT", thực tế có rotation + theft detection + rate limiting).
- **Design System foundation toàn diện:** Phước setup shadcn/ui + Tailwind + design tokens, 13 common components, layout system responsive, Axios interceptors với token refresh queue, Zustand authStore + 5 auth pages, i18n, dark mode — tất cả trong 2 tuần. Token refresh queue pattern giải quyết race condition mà không cần thư viện ngoài.
- **E34 dời lên Sprint 5 là quyết định đúng:** Có component base sớm → code auth pages ngay trong Sprint 5 → test auth flow end-to-end. Tiết kiệm 7 sprint chờ đợi so với plan gốc (Sprint 12).
- **JPA models + repositories đầy đủ 11 tables:** Trung phát hiện thiếu prerequisite và tự thêm vào — unblock tất cả các task backend còn lại.

### 5.2 Vấn đề gặp phải

- **RBAC toàn bộ bị dời sang Sprint 6:** E14 (4 tasks) + E13 (4 tasks) = 8 tasks dồn vào Sprint 6. Nguyên nhân: auth core (E12) scope lớn hơn estimate — 6 task gốc → 8 task thực tế (thêm RS256 research + JPA models). Đây là bottleneck nghiêm trọng: RBAC block ít nhất 5 task khác.
- **Dependency ordering sai trong plan:** Admin APIs (E13-03/04) được gán song song với RBAC (E14-01/02) → Ân không thể bắt đầu. Lãng phí 1 sprint cho Ân.
- **Google OAuth chưa implement:** Mới có model + enum scaffold. OAuth2 flow (Google token exchange, callback, user creation) cần thêm 3-4 ngày.
- **SecurityConfig đang `.anyRequest().permitAll()`:** Tất cả endpoint đều public — đây là rủi ro bảo mật nếu deploy production trước khi có RBAC.

### 5.3 Technical debt

- `SecurityConfig` cần enable `@EnableMethodSecurity` + `@PreAuthorize` ngay Sprint 6 Week 1.
- Gateway injects `X-User-Role`, `X-Workspace-Id` nhưng business-service chưa verify → nếu bypass gateway, role/workspace không được enforce.
- `workspaceStore` và `notificationStore` mới có type definitions, chưa có implementation.
- Thiếu ~8 common components (avatar, select, form, tabs, checkbox, switch, tooltip, textarea) — có sẵn trong `brandhub-UI-Design` reference repo, cần copy vào web-dashboard khi cần.

---

## 6. Blocked tasks & Dependencies

| Task bị block | Block bởi | Impact | Action |
|---|---|---|---|
| DA-E13-03, E13-04 (Admin APIs) | DA-E14-01 (@RequireRole) chưa xong | Ân không có task để làm trong Sprint 5 | E14-01 phải xong Sprint 6 Week 1 |
| DA-E14-04 (Permission matrix) | DA-E14-01 chưa xong | Không biết role nào có quyền gì để document | Làm ngay sau E14-01 |
| DA-E14-02 (Workspace isolation) | DA-E14-01 (cần annotation trước) | Workspace data không được isolate | Sprint 6 Week 2 |
| DA-E34-05 (workspaceStore) | E15 (Workspace APIs) chưa có | Frontend không có workspace state | Sprint 6 — sau E15-01 |
| DA-E12-06 (Google OAuth) | Auth core scope lớn | OAuth login chưa có | Sprint 6 Week 1 |

---

## 7. Individual highlights

- **Trung:** 8/13 Done. Auth core production-ready: Register/Login/Refresh/Logout/ForgotPassword/ResetPassword với RS256 JWT, rolling refresh token + theft detection, OTP email flow, Redis blacklist. Tự phát hiện và thêm 2 prerequisite task (RS256 research, 11 JPA models). RBAC bị delay do auth core scope lớn hơn estimate.

- **Phước:** 4/6 Done + 1 In Review. Design System foundation toàn diện trong 2 tuần: shadcn/ui + Tailwind + design tokens, 13 common components, layout system responsive, Axios interceptors với token refresh queue, Zustand authStore + 5 auth pages, i18n (en/vi), dark mode. Token refresh queue pattern tự implement — giải quyết race condition. E34 dời từ Sprint 12 → 5 giúp tiết kiệm 7 sprint chờ đợi.

- **Ân:** 0/2 Done — blocked bởi RBAC chưa implement. Hỗ trợ AI team research AI Iteration 1. Cần cải thiện dependency negotiation: thay vì chấp nhận blocked, nên đề xuất alternative (mock RBAC, làm task độc lập khác).

- **Tuấn:** AI Iteration 1 — không có task Sprint 5 epics. Báo cáo riêng trong AI Iteration 1 Report.

- **Lộc:** AI Iteration 1 (AI Sub-lead) — không có task Sprint 5 epics. Báo cáo riêng trong AI Iteration 1 Report.

---

## 8. Sprint Retrospective

### 8.1 What went well?

- Auth core implementation chất lượng cao — vượt yêu cầu gốc về bảo mật (RS256, rolling refresh, theft detection, rate limiting).
- Design System foundation hoàn chỉnh — có thể build page mới nhanh chóng từ Sprint 6.
- Phát hiện và xử lý prerequisite work (RS256 research, JPA models) thay vì bỏ qua.
- E34 dời lên sớm → test auth flow end-to-end ngay trong Sprint 5.

### 8.2 What didn't go well?

- RBAC toàn bộ bị dời sang Sprint 6 — 8 tasks dồn cục (E13 4 tasks + E14 4 tasks).
- Ân không có task để làm do dependency ordering sai trong plan.
- Google OAuth bị bỏ lại dù là High priority.
- SecurityConfig vẫn `permitAll()` — rủi ro bảo mật.
- 3/3 member nộp report muộn (deadline 2026-07-28, nộp 2026-08-02).

### 8.3 Action items cho Sprint 6

| Action | Owner | Deadline |
|---|---|---|
| Implement @RequireRole + enable method security | Trung | Sprint 6 Week 1 — **Critical** |
| Implement workspace isolation filter | Trung | Sprint 6 Week 2 |
| Implement Google OAuth | Trung | Sprint 6 Week 1 |
| Implement GET/PUT /users/me + avatar upload | Trung | Sprint 6 Week 1-2 |
| Implement Admin list users + ban/suspend APIs | Ân | Sprint 6 Week 1-2 (ngay sau E14-01) |
| Write permission matrix document | Phước | Sprint 6 Week 1 (ngay sau E14-01) |
| Hoàn thành workspaceStore | Phước | Sprint 6 (sau E15-01) |
| Bổ sung các component thiếu (avatar, select, form, tabs) | Phước | Sprint 6 Week 1 |
| Tổ chức mid-sprint check-in | Trung | Sprint 6 Week 2 |
| Nộp report đúng deadline | All | Sprint 6 end |

---

## 9. Kế hoạch Sprint 6

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | DA-E14-01 @RequireRole annotation | Trung | **Block 5+ tasks — làm đầu tiên** |
| 🔴 Critical | DA-E14-02 Workspace isolation | Trung | Sau E14-01 |
| 🔴 Critical | DA-E14-03 BRAND_CLIENT isolation | Trung | Sau E14-02 |
| 🔴 Critical | DA-E12-06 Google OAuth | Trung | Carry over từ Sprint 5 |
| 🔴 Critical | DA-E15-01/02/03 Workspace APIs | Trung | Sprint 6 gốc |
| 🟡 High | DA-E13-01/02 Profile + Avatar | Trung | Carry over từ Sprint 5 |
| 🟡 High | DA-E13-03/04 Admin users | Ân | Sau E14-01 |
| 🟡 High | DA-E16-01/02/04 Client APIs | Trung | Sprint 6 gốc |
| 🟢 Medium | DA-E14-04 Permission matrix | Phước | Sau E14-01 |
| 🟢 Medium | DA-E34 bổ sung components | Phước | Xen kẽ |

> ⚠️ Sprint 6 có nguy cơ quá tải: 8 task carry over từ Sprint 5 + Sprint 6 gốc (E15, E16, E17). Cần prioritize ruthlessly — E14-01/02/03 và E15 là critical path.

---

## 10. Links & References

| Resource | Link |
|---|---|
| Jira Sprint 5 Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |
| GitHub — business-service | https://github.com/BrandHubOrganization/brandhub-business-service |
| GitHub — web-dashboard | https://github.com/BrandHubOrganization/brandhub-web-dashboard |
| GitHub — ai-service | https://github.com/BrandHubOrganization/brandhub-ai-service |
| GitHub — infrastructure | https://github.com/BrandHubOrganization/brandhub-infrastructure |
| Design reference (shadcn) | `brandhub-UI-Design/Uibrandhubs/src/app/components/ui/` |

---

*Deadline nộp: 2026-07-28 | Nộp muộn: 2026-08-02*
