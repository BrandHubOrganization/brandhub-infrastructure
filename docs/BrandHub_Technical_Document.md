# BrandHub — Technical Document (v1.0, V2 business model)

> DA-1159 (DA-E05-08). Tổng hợp toàn bộ artifact E05, dùng làm tài liệu tham khảo chính cho developer + nộp mentor.
> Cập nhật 2026-09-17 theo model V2: `Agency → Workspace → Media Package → Media Campaign → Task`.

## 1. System Overview

- **Product:** BrandHub — B2B SaaS, AI-powered multi-channel content production cho marketing agency.
- **6 role:** ADMIN, OWNER (Agency), MANAGER/CREATOR/CLIENT (theo Workspace, gán độc lập từng Workspace), GUEST.
- Xem chi tiết: [docs/ba/00-overview.md](ba/00-overview.md), [docs/ba/01-organization-structure.md](ba/01-organization-structure.md).
- Diagram tổng quan: [docs/architecture/architecture.html](architecture/architecture.html).

## 2. Service Boundaries

7 thành phần: `api-gateway`, `business-service`, `ai-service`, `publisher-service`, `web-dashboard`, `mobile-app`, `infrastructure`.

Chi tiết ownership/trách nhiệm từng service: [docs/service-boundaries.md](service-boundaries.md).

## 3. Database Design

- **PostgreSQL:** 23 bảng (Identity, Organization, Commerce, Collaborator, Billing) — business-service sở hữu duy nhất.
- **MongoDB:** 17 collection tổng cộng, chia 3 service (business 14, ai 2, publisher 1).
- **Redis:** JWT blacklist, rate limit, session cache — business-service sở hữu.
- **ChromaDB + S3:** ai-service sở hữu.

Chi tiết: [docs/architecture/db-ownership-diagram.html](architecture/db-ownership-diagram.html), schema đầy đủ: [docs/database/schema-v2/brandhub-dbml.dbml](database/schema-v2/brandhub-dbml.dbml).

## 4. API Contracts

- **business-service ↔ ai-service (REST, đồng bộ):** [docs/architecture/business-ai-rest-contract.md](architecture/business-ai-rest-contract.md).
- **business-service ↔ publisher-service (RabbitMQ, bất đồng bộ):** [docs/architecture/rabbitmq-publisher-contract.html](architecture/rabbitmq-publisher-contract.html).
- **RBAC 2 tầng (Agency-level + Workspace-level):** [docs/ba/10-roles-permissions-matrix.md](ba/10-roles-permissions-matrix.md).

## 5. Sequence Diagrams

4 luồng lõi (Content Creation, Approval Workflow, Auto-Publishing, OAuth Token Refresh): [docs/architecture/sequence-diagrams.md](architecture/sequence-diagrams.md).

## 6. AI Architecture

Internal design ai-service (router/service layer, ChromaDB schema, LLM routing): [docs/architecture/ai-service-architecture.md](architecture/ai-service-architecture.md).

## 7. Architecture Decision Records (ADR)

| ADR | Quyết định |
|---|---|
| [ADR-001](adr/ADR-001-polyrepo.md) | Polyrepo — 7 repo riêng biệt |
| [ADR-002](adr/ADR-002-database-split.md) | MongoDB + PostgreSQL split |
| [ADR-003](adr/ADR-003-rabbitmq.md) | RabbitMQ cho async publishing |
| [ADR-004](adr/ADR-004-spring-cloud-gateway.md) | Spring Cloud Gateway làm API Gateway |

## 8. Security Model

- JWT RS256, verify chữ ký tại gateway, re-verify + RBAC tại business-service (business-service là nguồn sự thật duy nhất cho role hiện tại, không tin claim JWT cũ).
- RBAC 2 tầng: Agency-level (chỉ `owner_id`, check riêng `@RequireAgencyOwner`) tách biệt Workspace-level (`MemberRole`, `@RequireRole`) — xem [docs/ba/10-roles-permissions-matrix.md](ba/10-roles-permissions-matrix.md) §1.1.
- OAuth token (Social Platform) mã hóa AES-256 trước khi gửi qua RabbitMQ tới publisher-service.
- Chi tiết flow: [docs/architecture/sequence-diagrams.md](architecture/sequence-diagrams.md) §4 (OAuth Token Refresh).

## 9. Deployment Architecture

- Docker Compose, 3 file tách rời: `docker-compose.infra.yml` (postgres/redis/rabbitmq/chromadb), `docker-compose.dev.yml` (overlay port cho dev), `docker-compose.apps.yml` (5 service app, build từ sibling repo).
- MongoDB dùng Atlas cloud, không self-host local.
- Chi tiết local run setup: [docs/architecture/architecture.html](architecture/architecture.html) mục "Local Run Setup".

## 10. Use Case Reference

105 Use Case đầy đủ, chia 8 domain: [docs/ba/use-cases/00-index.md](ba/use-cases/00-index.md).

## 11. Record of Changes

| Ngày | Thay đổi |
|---|---|
| 2026-09-17 | v1.0 — biên soạn đầy đủ theo model V2 (Agency→Workspace→Package→Campaign→Task), thay thế toàn bộ giả định V1 cũ trong `docs/plan/brandhub-master-plan.md` Epic E05 |
