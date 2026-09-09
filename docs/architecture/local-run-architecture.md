# Local run architecture

Ghi lại cách stack local thực sự lắp ráp, khác README gốc (README mô tả 1 file `docker-compose.yml` gộp — file này không tồn tại).

## Compose file split

`docker/` có 3 file compose độc lập, ghép bằng `-f`:

- `docker-compose.infra.yml` — hạ tầng nền: postgres, redis, rabbitmq, chromadb, neo4j. Không mở port ra host (trừ khi có overlay dev).
- `docker-compose.dev.yml` — overlay chỉ thêm `ports:` cho các service trên (để connect từ host) + thêm service `pgadmin`.
- `docker-compose.apps.yml` — 5 service ứng dụng: api-gateway, business-service, ai-service, publisher-service, web-dashboard. Build từ Dockerfile của từng repo sibling (`../../brandhub-*`).

`scripts/run-compose.bat`:
```
docker compose -f docker-compose.infra.yml -f docker-compose.dev.yml up -d          # mặc định
docker compose -f docker-compose.infra.yml -f docker-compose.apps.yml -f docker-compose.dev.yml up -d   # mode "full"
```

Lý do tách: dev thường không cần build lại 5 app image (chạy `mvn spring-boot:run`/`npm run dev` trực tiếp cho hot-reload), chỉ cần infra. `full` dùng khi cần test nguyên cụm Docker (staging-like).

## MongoDB không có trong compose

`business-service` có biến `MONGODB_URI`/`MONGODB_DATABASE` nhưng không có service `mongo` nào trong `docker-compose.infra.yml`. Kết luận: Mongo dùng cloud (Atlas), không self-host local. `scripts/init-mongo.js` tồn tại nhưng chạy tay nhắm vào cluster Atlas, không phải qua `docker-entrypoint-initdb.d`.

## Dependency chain khi lên full stack

```
postgres/redis/rabbitmq (healthy)
        │
        ▼
business-service ──▶ (Postgres, Redis, RabbitMQ, Mongo Atlas)
        │
        ▼
api-gateway ──▶ business-service + ai-service (qua HTTP nội bộ, chờ service_started)
        │
        ▼
web-dashboard (nginx, chỉ depends_on api-gateway, không chờ healthy — chỉ chờ container start)

ai-service ──▶ chromadb (chờ service_started, không healthy — Chroma healthcheck riêng nhưng không phải depends_on condition)
publisher-service ──▶ rabbitmq (healthy)
```

api-gateway là entrypoint duy nhất từ ngoài (port 8080) cho mọi client (web, mobile). business-service/ai-service/publisher-service không expose ra ngoài mạng thật trong production, nhưng compose local vẫn mở port host để debug trực tiếp (8081/8082/8083).

## Networking

Toàn bộ chung 1 bridge network `brandhub-network` (external name cố định, không prefix theo project) — cho phép service gọi nhau qua tên container (`http://business-service:8081`) bất kể compose file nào tạo ra network trước.

## Điểm khác biệt với README.md hiện tại

`brandhub-infrastructure/README.md` mô tả sai:
- Nói có 1 `docker-compose.yml` — thực tế 3 file (`infra`/`apps`/`dev`), xem trên.
- Nói `mongo` là container local — thực tế Atlas cloud, không có service.
- Bảng port/image trong README dùng version cũ (`postgres:16-alpine`, `rabbitmq:3.13`) — thực tế `docker-compose.infra.yml` dùng `postgres:17-alpine`, `rabbitmq:3.12-management-alpine`.

README chưa được cập nhật lại theo scope hiện tại — ghi nhận ở đây để không bị lẫn khi debug setup.
