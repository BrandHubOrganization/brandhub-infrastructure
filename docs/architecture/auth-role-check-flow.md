# Vì sao role-check nằm ở business-service, không phải api-gateway

Câu hỏi: "check role diễn ra ở business-service hay api-gateway?"

**Trả lời ngắn: ở `brandhub-business-service`. Gateway không check role.**

## Gateway làm gì

`brandhub-api-gateway` (Spring Cloud Gateway) chỉ làm 2 việc liên quan bảo mật:

1. **Verify JWT hợp lệ** — `JwtAuthFilterGatewayFilterFactory` check chữ ký RS256 + check token có bị revoke (Redis blacklist) không. Sai → 401, chặn ngay tại gateway.
2. **Rate limiting** — giới hạn số request theo `X-User-Id`.

Sau khi verify xong, gateway **inject 3 header** (`X-User-Id`, `X-User-Role`, `X-Workspace-Id`) rồi forward request tới business-service. Gateway **không** đọc giá trị `X-User-Role` để rẽ nhánh cho phép/từ chối gì cả — chỉ nhét vào header rồi đi tiếp.

## Vì sao gateway không (và không nên) check role

- **Gateway chỉ giữ public key** (`JWT_PUBLIC_KEY`), dùng để verify chữ ký. Private key (ký/issue token) chỉ business-service giữ. Gateway không có quyền/khả năng tạo hay xác thực sâu hơn chữ ký.
- **Gateway không có DB access** tới bảng `workspace_members` — không biết role *hiện tại* của user trong workspace đang thao tác. Nó chỉ biết role **tại thời điểm JWT được issue** (đóng gói trong claim), không phản ánh thay đổi role real-time (vd OWNER vừa demote CREATOR xuống VIEWER 1 giây trước — JWT cũ vẫn còn hạn, claim cũ vẫn ghi CREATOR).
- Role-based access control theo nghiệp vụ (`OWNER` mới được xoá member, `VIEWER` chỉ đọc...) là **domain logic**, thuộc về service hiểu nghiệp vụ đó — không phải trách nhiệm của lớp routing/perimeter.

## business-service làm gì

`JwtAuthenticationFilter` trong business-service **tự parse lại JWT từ đầu** (đọc thẳng header `Authorization`, không dùng header `X-User-*` gateway đã nhét) — verify độc lập, dựng `AuthenticatedUser` (id, workspaceId) từ claim.

`RequireRoleAspect` (mới build, xem docs/feature/rbac-middleware) sau đó:
1. Check `SystemRole` (ADMIN bypass hết).
2. Query trực tiếp `WorkspaceMemberRepository` theo `(workspaceId, userId)` hiện tại → lấy `MemberRole` **mới nhất từ DB**, không tin claim cũ trong JWT.
3. So với danh sách role cho phép trong `@RequireRole(...)` trên method — không đủ quyền → 403.

Đây là lý do role-check phải nằm ở business-service: **chỉ nơi có DB mới trả lời đúng "role hiện tại của user này là gì" tại đúng thời điểm request tới**, JWT claim chỉ là ảnh chụp lúc login/refresh.

## Sơ đồ luồng

```
Client
  │  Authorization: Bearer <JWT>
  ▼
api-gateway
  │  1. Verify chữ ký JWT (public key) + check revoke list
  │  2. Rate limit theo X-User-Id
  │  3. Inject X-User-Id / X-User-Role / X-Workspace-Id (chỉ để log/debug,
  │     KHÔNG dùng để quyết định cho phép/từ chối)
  │  4. Forward nguyên request
  ▼
business-service
  │  1. JwtAuthenticationFilter — tự parse lại JWT (độc lập với gateway)
  │  2. RequireRoleAspect — query DB lấy MemberRole hiện tại, so với @RequireRole
  │  3. 403 nếu không đủ quyền, ngược lại chạy tiếp method
  ▼
Response
```

## Lưu ý kỹ thuật (không phải bug cần fix ngay, nhưng nên biết)

README của `brandhub-api-gateway` mô tả "downstream service đọc header X-User-* trực tiếp, không re-verify JWT" — nhưng thực tế code business-service **re-verify JWT độc lập hoàn toàn**, bỏ qua header gateway gửi. Đây là chỗ doc và code đang lệch nhau (doc cũ chưa cập nhật theo code thật). Không ảnh hưởng tới RBAC middleware đang build — chỉ ghi nhận ở đây để nhóm biết, có thể cập nhật README gateway sau.
