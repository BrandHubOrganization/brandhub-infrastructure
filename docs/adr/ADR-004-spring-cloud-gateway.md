# ADR-004 — Spring Cloud Gateway làm API Gateway

**Status:** Accepted

## Context

Client (web-dashboard, mobile-app) cần 1 entry point duy nhất vào hệ thống thay vì gọi trực tiếp từng service (business-service:8081, ai-service:8082, publisher-service:8083). Cần chọn công nghệ gateway.

## Decision

Dùng **Spring Cloud Gateway** làm `api-gateway`, đảm nhận: verify chữ ký JWT (RS256, public key), check revoke qua Redis blacklist, rate limiting theo `X-User-Id`. Gateway forward nguyên request sau khi verify — **không** tự làm RBAC theo role (xem `docs/architecture/architecture.html` mục "Auth Role-Check Flow").

## Consequences

**Tích cực:**
- Cùng ngôn ngữ/ecosystem (Java/Spring) với `business-service`, `publisher-service` — team dễ maintain, tái sử dụng thư viện JWT chung.
- Tách rõ trách nhiệm: gateway chỉ verify chữ ký + rate limit (perimeter security), business-service tự re-verify JWT + query DB lấy role hiện tại (`RequireRoleAspect`) — tránh gateway phải biết nghiệp vụ RBAC 2 tầng (Agency-level + Workspace-level) phức tạp của V2.
- Route theo path-prefix wildcard (`/api/v1/**`) — thêm endpoint mới trong business-service tự động qua gateway, không cần sửa `application.yml` mỗi lần thêm API.

**Tiêu cực:**
- Gateway chỉ khai báo route cho `business-service` hiện tại — `ai-service`/`publisher-service` chưa có route riêng qua gateway (không public trực tiếp, chỉ nội bộ), cần bổ sung route khi có yêu cầu public endpoint cho 2 service này.
- Không phải service discovery động (Eureka/Consul) — thêm service mới phải sửa tay `application.yml`, không tự động phát hiện.
- RBAC 2 tầng V2 (Agency-level check tách biệt Workspace-level `@RequireRole`) đặt toàn bộ ở business-service — nếu sau này thêm service khác cần enforce Agency-level permission, phải duplicate logic hoặc factor ra shared library.
