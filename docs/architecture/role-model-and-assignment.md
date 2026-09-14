# Role Model & Quy trình phân role

Tài liệu này định nghĩa **role là gì**, **phân biệt hai tầng role**, và **quy trình gán role** trong BrandHub.
Luồng kiểm tra quyền lúc request (gateway → business-service → `@RequireRole`) xem tại
[auth-role-check-flow.md](./auth-role-check-flow.md) — hai tài liệu bổ sung nhau, không trùng.

| | |
|---|---|
| Version | 1.0 |
| Ngày | 2026-09-11 |
| Nguồn sự thật | `brandhub-business-service` — đọc trực tiếp từ code, không suy đoán |

---

## 1. Nguyên tắc cốt lõi

BrandHub có **hai tầng role độc lập**, không thay thế nhau:

| Tầng | Tên | Phạm vi | Bảng DB | Giá trị |
|---|---|---|---|---|
| **Tầng 1** | `SystemRole` | Toàn hệ thống (platform-level) | `user_system_roles` | `ADMIN`, `USER` |
| **Tầng 2** | `MemberRole` | Trong **một** workspace cụ thể | `workspace_members` | `OWNER`, `MANAGER`, `CREATOR`, `CLIENT` |

**Ba điều bắt buộc hiểu đúng:**

1. **KHÔNG có role `GUEST`.** Người chưa đăng nhập không phải là một role — họ đơn giản là chưa có danh tính (request bị chặn ở tầng authentication, trả 401, không tới tầng authorization).
2. **Mọi user đã đăng nhập luôn có đúng một `SystemRole`**, mặc định là `USER`. Đăng ký tự do → `USER`. Không có trạng thái "đăng nhập nhưng không có system role".
3. **`MemberRole` chỉ tồn tại khi user đã join một workspace.** Cùng một user có thể là `OWNER` ở workspace A, `CREATOR` ở workspace B, và không là gì ở workspace C. `MemberRole` **không** phải thuộc tính của user — nó là thuộc tính của **cặp (user, workspace)**, lưu ở bảng `workspace_members`.

Hệ quả: khi nói "user này có quyền gì", câu hỏi đúng là **hai** câu — "system role là gì?" và "member role trong workspace đang thao tác là gì?". Một câu trả lời duy nhất luôn sai.

---

## 2. Tầng 1 — SystemRole

**Định nghĩa:** `com.brandhub.business.model.enums.SystemRole` — chỉ hai giá trị.

```java
public enum SystemRole {
    ADMIN, USER
}
```

| Role | Ý nghĩa | Quyền |
|---|---|---|
| `ADMIN` | Quản trị viên nền tảng, do team vận hành cấp (không tự đăng ký được) | **Bypass toàn bộ `@RequireRole`** — thấy và thao tác mọi workspace |
| `USER` | Mọi tài khoản đăng ký thông thường | Quyền trong một workspace do `MemberRole` quyết định, không phải `SystemRole` |

- **Lưu trữ:** bảng `user_system_roles`, quan hệ 1-1 với `users`. Repository: `UserSystemRoleRepository.findByUserId(UUID)`.
- **Mặc định khi đăng ký:** `USER`. Ghi tại `AuthServiceImpl` / `OAuthService` trong luồng register và social-login.
- **`USER` KHÔNG mang nghĩa "chỉ được làm việc cơ bản".** Nó chỉ có nghĩa "không phải platform admin". Một `USER` vẫn có thể là `OWNER` toàn quyền của workspace mình tạo.
- **`ADMIN` vẫn cần workspace context hợp lệ** để gọi các endpoint yêu cầu `workspaceId` trong JWT — bypass role check nhưng không bypass việc JWT phải có `workspaceId` claim để filter dữ liệu (giới hạn hiện tại, xem mục 7).

---

## 3. Tầng 2 — MemberRole

**Định nghĩa:** `com.brandhub.business.model.enums.MemberRole` — bốn giá trị, có thứ bậc quyền giảm dần.

```java
public enum MemberRole {
    OWNER, MANAGER, CREATOR, CLIENT
}
```

| Role | Định nghĩa nghiệp vụ | Nhóm quyền |
|---|---|---|
| `OWNER` | Chủ agency, người tạo workspace | Toàn quyền cấp cao nhất: workspace, billing, social accounts, member, settings. **Không trực tiếp thao tác content.** |
| `MANAGER` | Người được Owner giao vận hành workspace | Quản lý vận hành: member (invite/remove/gán role), settings, clients, analytics, reports. Cộng thêm giao tiếp khách hàng: content request, portal, calendar, library, approve. **Không tạo/sửa content, không xoá workspace.** |
| `CREATOR` | Người sản xuất nội dung | Editor, templates, hashtag, publish, AI studio. **Không quản member, không quản settings/billing.** |
| `CLIENT` | Khách hàng của agency | Xem và duyệt/từ chối **chỉ nội dung liên quan tới mình**. Không sửa, không tạo. |

### 3.1 Ranh giới quan trọng nhất: OWNER vs MANAGER

Hai role này gần nhau về quyền quản lý, khác nhau ở **quyền sở hữu**:

- `OWNER` = **sở hữu** workspace (tạo, xoá, billing, transfer). Là người cuối cùng chịu trách nhiệm.
- `MANAGER` = **vận hành** workspace (được OWNER giao). Làm được gần hết việc OWNER làm **trừ việc định đoạt sự tồn tại của workspace**.

Hệ quả code: các thao tác định đoạt như xoá workspace chỉ cho `OWNER`; các thao tác vận hành hàng ngày cho cả `OWNER` và `MANAGER` (pattern `@RequireRole({MemberRole.OWNER, MemberRole.MANAGER})`).

### 3.2 Bảo vệ OWNER cuối cùng

Hệ thống chặn việc làm workspace **mất hết OWNER** — khi đó không ai còn quyền định đoạt workspace, workspace trở thành mồ côi.

`WorkspaceServiceImpl.removeMember()` kiểm tra: nếu member bị xoá đang giữ `OWNER` **và** số OWNER active còn lại `<= 1` → ném `LAST_OWNER_CANNOT_BE_REMOVED`.

```java
if (member.getRole() == MemberRole.OWNER) {
    long ownerCount = workspaceMemberRepository
            .countByWorkspaceIdAndRoleAndIsActiveTrue(workspaceId, MemberRole.OWNER);
    if (ownerCount <= 1) {
        throw new BusinessException(ErrorCode.LAST_OWNER_CANNOT_BE_REMOVED);
    }
}
```

Điều này **không** áp dụng cho `MANAGER` / `CREATOR` / `CLIENT` — xoá họ không đe doạ tính toàn vẹn của workspace.

### 3.3 Đồng bộ enum bốn tầng

`MemberRole` phải khớp ở **bốn** nơi. Lệch một nơi = bug runtime (insert fail, hoặc FE hiển thị role không tồn tại):

| Tầng | Nơi | Ràng buộc |
|---|---|---|
| Java | `MemberRole.java` + `@Enumerated(EnumType.STRING)` trên `WorkspaceMember.role` | Nguồn sự thật |
| PostgreSQL | Native enum type `member_role` (`columnDefinition = "member_role"`) | Phải chứa đúng 4 giá trị |
| OpenAPI | `brandhub-business-service/docs/openapi.yaml` | FE/mobile generate type từ đây |
| TypeScript (FE) | `src/types/*.ts` trong `brandhub-web-dashboard` | Type union khớp hợp đồng |

**Migration khi đổi tên giá trị enum** (ví dụ đã làm khi bỏ `ACCOUNT` → gộp vào `MANAGER`):

```sql
ALTER TYPE member_role RENAME VALUE 'ACCOUNT' TO 'MANAGER';
```

Câu lệnh này **phải chạy độc lập, ngoài transaction block** — Postgres từ chối `RENAME VALUE` trong transaction. Nó tự cập nhật mọi row `workspace_members.role` đang mang giá trị cũ, nên không cần `UPDATE` riêng.

---

## 4. Quy trình phân role (role assignment)

Có **bốn** thời điểm role được gán. Mỗi thời điểm gán một loại role khác nhau — đây là chỗ dễ nhầm nhất.

### 4.1 Khi đăng ký tài khoản → gán `SystemRole`

Người dùng đăng ký (email/password hoặc OAuth social login). Hệ thống ghi `user_system_roles` với `systemRole = USER`.

- **Ai gán:** hệ thống, tự động. Người dùng không chọn, không gửi lên.
- **Ai có thể gán `ADMIN`:** không ai qua API công khai. `ADMIN` chỉ được cấp qua thao tác vận hành trực tiếp trên DB.
- **Mã nguồn:** `AuthServiceImpl` (luồng register) và `OAuthService` (luồng first-time social login).

### 4.2 Khi tạo workspace → creator thành `OWNER`

`WorkspaceServiceImpl.createWorkspace()` tạo workspace, rồi **ngay lập tức** tạo một `WorkspaceMember` cho chính người tạo với role `OWNER`.

```java
WorkspaceMember owner = WorkspaceMember.builder()
        .workspaceId(workspace.getId())
        .userId(currentUser.getId())
        .role(MemberRole.OWNER)     // luôn OWNER, không lấy từ request
        .joinedAt(OffsetDateTime.now())
        .isActive(true)
        .build();
```

- **Điểm quan trọng:** role này **hardcode `OWNER`**, không đọc từ request body. Client không thể tự nhận `MANAGER` hay role khác khi tạo workspace. Đây là bất biến bảo mật — workspace luôn có đúng một người sở hữu ban đầu là người tạo nó.
- Không có endpoint "tạo workspace hộ người khác".

### 4.3 Khi mời member → gán role vào lời mời (chưa hiệu lực ngay)

OWNER/MANAGER gọi `POST /api/workspaces/{workspaceId}/invitations` với `InviteMemberRequest.role`.

`WorkspaceServiceImpl.inviteMember()`:

1. **Chặn nếu đã là member** → `ALREADY_IN_WORKSPACE`.
2. **Chặn nếu đã có lời mời PENDING chưa hết hạn** → `INVITATION_ALREADY_PENDING` (tránh spam nhiều lời mời cho cùng email).
3. Tạo `WorkspaceInvitation` với `role = request.role()`, `status = PENDING`, `expiresAt = now + INVITATION_EXPIRY_DAYS`, `token = UUID ngẫu nhiên`.
4. Gửi email chứa token cho người được mời.

**Trạng thái trung gian — quan trọng:** ở bước này role **chưa** được cấp. Người được mời **chưa phải member**, chưa có dòng nào trong `workspace_members`. Role nằm tạm ở `workspace_invitations.role` và chỉ có hiệu lực khi lời mời được accept.

**Role hợp lệ để mời:** `MANAGER`, `CREATOR`, `CLIENT`. **Không mời được `OWNER`** — OWNER chỉ hình thành qua tạo workspace (4.2) hoặc chuyển giao (chưa hỗ trợ). Điều này giữ bất biến "mỗi workspace có ít nhất một OWNER do con người chủ động tạo".

**Bảo vệ endpoint:** invitation endpoint yêu cầu `@RequireRole({MemberRole.OWNER, MemberRole.MANAGER})`. `CREATOR` và `CLIENT` **không mời được ai** — dù cả hai có gọi thẳng API, aspect chặn 403 trước khi vào service.

### 4.4 Khi accept lời mời → role chốt thành member

Người được mời click link trong email → FE gọi `POST /api/invitations/accept` với token.

`WorkspaceServiceImpl.acceptInvitation()`:

1. Tìm invitation theo token → không có → `INVALID_INVITATION`.
2. Kiểm tra `status == PENDING` **và** `expiresAt > now` → sai một trong hai → `INVALID_INVITATION`.
3. **Kiểm tra danh tính:** email của user đang đăng nhập phải khớp `invitation.invitedEmail` (so sánh `equalsIgnoreCase`) → lệch → `INVALID_INVITATION`. **Đây là chốt bảo mật:** token bị lộ cho người khác cũng vô dụng, vì phải đăng nhập **đúng tài khoản được mời** mới accept được.
4. Chặn nếu đã là member → `ALREADY_IN_WORKSPACE`.
5. Tạo `WorkspaceMember` với `role = invitation.getRole()` — **role copy nguyên từ invitation**, không lấy từ request accept.
6. Đánh dấu invitation `status = ACCEPTED`, ghi `acceptedAt`, `acceptedBy`.

**Từ bước này user mới thực sự có `MemberRole`.** Trước đó họ chỉ là người được mời.

### 4.5 Bảng tóm tắt bốn thời điểm

| # | Thời điểm | Gán role nào | Giá trị | Nguồn role | Ai trigger |
|---|---|---|---|---|---|
| 1 | Đăng ký tài khoản | `SystemRole` | `USER` | Hardcode | Hệ thống |
| 2 | Tạo workspace | `MemberRole` | `OWNER` | Hardcode | Người tạo workspace |
| 3 | Mời member | `MemberRole` (tạm, trong invitation) | `MANAGER`/`CREATOR`/`CLIENT` | Từ request, qua `InviteMemberRequest.role` | OWNER, MANAGER |
| 4 | Accept lời mời | `MemberRole` (chính thức, trong `workspace_members`) | Copy từ invitation | Copy từ bước 3 | Người được mời |

**Đọc bảng này theo chiều dọc:** bước 3 và 4 **phải** đi cùng nhau. Một role mời ở bước 3 không tự động thành quyền — nó chỉ trở thành quyền khi bước 4 hoàn tất. Đây là lý do có endpoint `listMyPendingInvitations` — user cần thấy lời mời đang chờ để biết mình "sắp" có role gì.

---

## 5. Thay đổi role sau khi đã là member

Sau khi là member, role có thể thay đổi qua hai đường:

| Thao tác | Endpoint | Điều kiện |
|---|---|---|
| Xoá member | `removeMember(workspaceId, memberId)` | `@RequireRole({OWNER, MANAGER})`; chặn nếu là OWNER cuối cùng |
| Mời lại với role khác | `inviteMember` | Chỉ khi chưa là member (đã là member → `ALREADY_IN_WORKSPACE`) |

**Giới hạn hiện tại:** chưa có endpoint đổi role **trực tiếp** cho member đang active. Muốn đổi `CREATOR` → `MANAGER`, phải xoá member rồi mời lại với role mới. `UpdateMemberRoleRequest` có tồn tại trong `openapi.yaml` và `inviteMember` dùng chung shape request, nhưng **chưa có** method service nào thực thi đổi role tại chỗ.

Điểm này quan trọng khi trả lời khách: role đang active là **bất biến qua API** cho tới khi có endpoint riêng — không có đường vòng nào từ client.

### 5.1 Xoá member = soft delete

`removeMember()` **không** xoá dòng khỏi DB — nó set `isActive = false`:

```java
member.setActive(false);
member.setUpdatedAt(OffsetDateTime.now());
```

**Vì sao:** giữ lịch sử audit (ai từng ở workspace nào, role gì, do ai mời) và tránh khoá ngoại gãy. Mọi truy vấn xác định role đều lọc `isActive = true`:

```java
workspaceMemberRepository.findByWorkspaceIdAndUserIdAndIsActiveTrue(workspaceId, userId)
```

Hệ quả: một user bị xoá khỏi workspace **ngay lập tức** mất quyền ở request kế tiếp — kể cả khi JWT cũ vẫn còn hạn — vì aspect query DB mỗi request chứ không tin claim trong JWT. Chi tiết xem [auth-role-check-flow.md](./auth-role-check-flow.md).

---

## 6. Truy vết một request: từ đăng nhập tới quyết định cho phép

Ví dụ cụ thể — `CREATOR` tên Bình thử xoá một member khỏi workspace.

```
1. Đăng nhập (đã làm trước đó)
   → JWT chứa: userId=Bình, systemRole=USER, workspaceId=W, exp=...

2. Bình gọi  DELETE /api/workspaces/W/members/{memberId}
   → Gateway verify chữ ký JWT → OK → forward

3. business-service: JwtAuthenticationFilter
   → Tự parse lại JWT → dựng AuthenticatedUser(id=Bình, workspaceId=W)

4. RequireRoleAspect.checkRole(@RequireRole({OWNER, MANAGER}))
   → a. Query user_system_roles WHERE userId=Bình  →  SystemRole.USER
        → KHÔNG phải ADMIN → không bypass, đi tiếp
   → b. Query workspace_members
        WHERE workspaceId=W AND userId=Bình AND isActive=true
        → tìm thấy, role = CREATOR
   → c. allowed = {OWNER, MANAGER}
        allowed.contains(CREATOR) → false
   → d. throw BusinessException(ErrorCode.FORBIDDEN)  → HTTP 403

5. Method removeMember() KHÔNG BAO GIỜ CHẠY.
```

**Điểm mấu chốt:** bước 4b query **DB hiện tại**, không đọc `systemRole`/role từ JWT. Nếu OWNER vừa demote Bình xuống `CLIENT` một giây trước, JWT cũ vẫn ghi `CREATOR` nhưng DB đã là `CLIENT` → hệ thống dùng `CLIENT`. **DB luôn thắng JWT.**

Chi tiết đầy đủ về mặt kiến trúc (vì sao gateway không check role, vì sao business-service phải re-verify JWT độc lập) xem [auth-role-check-flow.md](./auth-role-check-flow.md).

---

## 7. Bảng tra nhanh: khi nào nhận 403 nào

| Tình huống | Error code | HTTP |
|---|---|---|
| SystemRole `ADMIN` | *(không bao giờ 403 vì role — bypass)* | — |
| User không phải member active của workspace | `WORKSPACE_ACCESS_DENIED` | 403 |
| Là member nhưng role không nằm trong `@RequireRole` | `FORBIDDEN` | 403 |
| Thao tác đòi OWNER, nhưng user là MANAGER | `FORBIDDEN` | 403 |
| Xoá OWNER cuối cùng của workspace | `LAST_OWNER_CANNOT_BE_REMOVED` | 403 |
| Mời người đã là member | `ALREADY_IN_WORKSPACE` | 400 |
| Accept lời mời: token sai / hết hạn / không PENDING / sai email | `INVALID_INVITATION` | 400 |
| Chưa đăng nhập, hoặc JWT thiếu `workspaceId` | *(auth layer)* | 401 |

**Phân biệt 401 vs 403 — không được lẫn:**
- **401** = "tôi không biết bạn là ai" (chưa đăng nhập, token sai/hết hạn). Xử lý ở tầng authentication, **trước** khi tới role check.
- **403** = "tôi biết bạn là ai, nhưng bạn không được làm việc này". Xử lý ở `RequireRoleAspect`.

**`WORKSPACE_ACCESS_DENIED` vs `FORBIDDEN` — không được gộp:** hai lỗi này **cố tình** tách riêng. Không phải member → `WORKSPACE_ACCESS_DENIED`. Là member nhưng thiếu quyền → `FORBIDDEN`. Giữ tách biệt giúp debug nhanh (biết ngay là lỗi phân quyền workspace hay lỗi role) và cho phép FE hiển thị thông báo khác nhau.

**Nguyên tắc trả 403 thay vì 404:** khi user không có quyền tới một resource, API trả **403**, không phải 404. Trả 404 cho một resource mà user không được xem sẽ **rò rỉ thông tin** — kẻ tấn công phân biệt được "resource không tồn tại" (404) với "resource tồn tại nhưng tôi không có quyền" (403), từ đó dò ra sự tồn tại của dữ liệu. Luôn 403.

---

## 8. Quy tắc bắt buộc khi viết code đụng tới role

1. **Không hardcode tên role dạng chuỗi.** Luôn dùng enum `MemberRole.OWNER`, `SystemRole.ADMIN` — không viết `"OWNER"`, `"ACCOUNT"`. Chuỗi không được compiler kiểm tra; đổi tên enum sẽ không báo lỗi ở chỗ dùng chuỗi.
2. **Không tin role trong JWT cho mục đích authorization.** Luôn query DB. Claim chỉ là ảnh chụp lúc login.
3. **Mọi endpoint nghiệp vụ workspace-scoped phải có `@RequireRole`.** Thiếu annotation = endpoint mở cho mọi user đã đăng nhập.
4. **Không dùng `workspaceId` client gửi trong body/param để quyết định quyền.** Nguồn workspace hiện tại là `AuthenticatedUser.getWorkspaceId()` (từ JWT). `workspaceId` từ client chỉ dùng để chọn resource, không để override quyền — nếu resource không thuộc workspace của user → `WORKSPACE_ACCESS_DENIED`.
5. **Role không có trong `workspace_members` → 403, không 404.** Xem lý do ở mục 7.
6. **Đổi/tên lại giá trị enum phải cập nhật đủ 4 tầng** (mục 3.3) — Java, Postgres native enum, OpenAPI, TypeScript.
