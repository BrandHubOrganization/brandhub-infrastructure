# Docker Compose Run Scripts

Thư mục này chứa các script Windows `.bat` để chạy, dừng và dọn dẹp Docker Compose cho BrandHub.

> **Lưu ý chung:**
> - Các script dùng compose project name cố định là `brandhub`.
> - Chạy từ thư mục `brandhub-infrastructure/docker` (script tự `cd` về đây, không cần `cd` thủ công).

---

## 1. Chuẩn bị `.env`

Từ thư mục `brandhub-infrastructure/docker`:

```powershell
Copy-Item .env.example .env
```

Rồi mở `.env` để cập nhật password/secrets trước khi dùng chung.

> `run.bat` sẽ tự copy `.env.example` sang `.env` nếu chưa có file `.env`.

---

## 2. Chạy (run.bat)

Script: `run.bat`. Hỗ trợ 3 mode:

| Mode       | Lệnh                  | Nội dung                                                                                     |
| ---------- | --------------------- | -------------------------------------------------------------------------------------------- |
| `infra`    | `.\run\run.bat infra` | Databases + Cache/Broker + Dev: PostgreSQL, Redis, RabbitMQ, pgAdmin, RedisInsight           |
| `infra_ai` | `.\run\run.bat infra_ai` | AI Data + Databases + Cache/Broker + Dev: Neo4j, ChromaDB, PostgreSQL, Redis, RabbitMQ, pgAdmin, RedisInsight |
| `full`     | `.\run\run.bat full`  | Toàn bộ infra + dev tools + app services (thêm `docker-compose.apps.yml`)                    |

Chạy `run.bat` không tham số sẽ hiện menu chọn mode (1/2/3).

```powershell
.\run\run.bat            # menu chọn mode
.\run\run.bat infra
.\run\run.bat infra_ai
.\run\run.bat full
```

---

## 3. Dừng container, giữ volume (down-compose.bat)

Script: `down-compose.bat`. Dừng và xóa container + network của infra/dev, **giữ lại named volumes** (không xóa data database local).

```powershell
.\run\down-compose.bat           # chỉ dừng container, giữ volume
.\run\down-compose.bat cache     # dừng container + xóa thêm Docker build cache
```

Tham số `cache` chỉ thêm bước `docker builder prune -a -f`; named volumes luôn được giữ (không có `-v`).

---

## 4. Dọn dẹp BrandHub mạnh tay (clear.bat)

Chỉ dùng khi muốn xóa sạch Docker resources của BrandHub.

Từ thư mục `brandhub-infrastructure/docker`:

```powershell
.\run\end-game\clear.bat YES
```

Script chỉ target BrandHub resources:

- compose project `brandhub` (chạy `down -v --remove-orphans` cho infra/dev và apps);
- containers có label `com.docker.compose.project=brandhub`;
- containers tên `brandhub-*`;
- volumes tên có `brandhub`;
- networks tên/label `brandhub`;
- images tag `brandhub*` hoặc `brandhub/*`;
- Docker build cache.

Script có guard bắt buộc `YES` để tránh chạy nhầm.

> **Cảnh báo:** lệnh này xóa BrandHub named volumes, nên data Postgres/Redis/pgAdmin local của BrandHub sẽ mất.

---

## 5. Lệnh compose thủ công

Kiểm tra config:

```powershell
docker compose -p brandhub -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml config
docker compose -p brandhub -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml config
```

Chạy infra + dev:

```powershell
docker compose -p brandhub -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml up -d
```

Dừng container, giữ volume:

```powershell
docker compose -p brandhub -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml down
```

Dừng container, xóa volume:

```powershell
docker compose -p brandhub -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml down -v
```

---

## 6. Guideline liên quan

- `../guidelines/pgadmin-postgres-setup-guideline.md`
