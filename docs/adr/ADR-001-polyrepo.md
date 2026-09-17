# ADR-001 — Polyrepo (nhiều repo riêng biệt)

**Status:** Accepted

## Context

BrandHub gồm 7 thành phần độc lập: `api-gateway`, `business-service`, `ai-service`, `publisher-service`, `web-dashboard`, `mobile-app`, `infrastructure`. Cần quyết định: 1 monorepo chứa tất cả, hay polyrepo (mỗi thành phần 1 GitHub repo riêng).

## Decision

Dùng **polyrepo** — 7 repo riêng biệt dưới cùng 1 GitHub Organization (`BrandHubOrganization`), quản lý chung qua `brandhub-infrastructure` (docs, docker-compose, scripts liên service).

## Consequences

**Tích cực:**
- Ngôn ngữ/stack khác nhau (Java Spring Boot, Python FastAPI, TypeScript React) tách CI/CD riêng, không phụ thuộc build tool chung.
- Team 5 người, mỗi người chủ yếu chạm 1-2 repo — giảm conflict PR, review scope rõ ràng theo service.
- Version độc lập từng service — deploy `publisher-service` không kéo theo rebuild `web-dashboard`.

**Tiêu cực:**
- Thay đổi cross-service (vd: đổi RabbitMQ message schema) cần PR đồng bộ ở 2 repo (`business-service` + `publisher-service`) — không atomic commit.
- Không có single source of truth cho dependency version giữa các service — `brandhub-infrastructure/docs/architecture/` đóng vai trò tài liệu điều phối thủ công.
- Local dev cần clone 7 repo, `docker-compose.apps.yml` build từ Dockerfile sibling repo (`../../brandhub-*`) — setup ban đầu phức tạp hơn monorepo.
