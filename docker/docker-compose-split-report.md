# Docker Compose Split Report

## 1. Hien trang

File `docker-compose.yml` hien tai dang gom ca application services, infrastructure services va dev tooling trong mot file duy nhat.

### Nhom service hien co

| Nhom | Services | Vai tro |
|---|---|---|
| Application | `api-gateway`, `business-service`, `ai-service`, `publisher-service`, `web-dashboard` | Chay cac service cua BrandHub |
| Infrastructure | `postgres`, `redis`, `rabbitmq`, `chromadb` | Cung cap database, cache, message broker va vector database |
| Dev tooling | `pgadmin` | Cong cu quan tri PostgreSQL cho local development |

## 2. Danh gia

File compose hien tai khong sai ve mat ky thuat, nhung dang bi tron nhieu concern:

- Muon chay rieng infrastructure van phai doc va quan ly ca application services.
- `pgadmin` la cong cu dev, khong nen nam chung voi core infrastructure.
- Cac port database/message broker dang expose truc tiep ra host, phu hop local dev nhung khong phu hop moi truong gan production.
- Application services phu thuoc Dockerfile o cac repository khac, nen viec test infra co the bi anh huong boi loi build app.
- Comment trong file hien tai dang bi loi encoding tieng Viet, lam giam tinh de doc va maintain.

Ket luan: nen tach file compose theo muc dich su dung, khong chi tach de giam so dong.

## 3. De xuat cau truc moi

```text
docker/
  docker-compose.infra.yml          # postgres, redis, rabbitmq, chromadb
  docker-compose.apps.yml           # api-gateway, business, ai, publisher, web
  docker-compose.dev.yml            # pgadmin, infra exposed ports, local overrides
  .env.example
```

## 4. Vai tro tung file

### `docker-compose.infra.yml`

Chua cac service ha tang cot loi:

- `postgres`
- `redis`
- `rabbitmq`
- `chromadb`
- volumes dung chung
- network dung chung

File nay nen chay doc lap duoc bang:

```bash
docker compose -f docker-compose.infra.yml up -d
```

### `docker-compose.apps.yml`

Chua cac service ung dung:

- `api-gateway`
- `business-service`
- `ai-service`
- `publisher-service`
- `web-dashboard`

File nay nen phu thuoc vao infra va duoc chay cung infra khi can full stack:

```bash
docker compose -f docker-compose.infra.yml -f docker-compose.apps.yml up -d
```

### `docker-compose.dev.yml`

Chua cac thanh phan chi dung cho local development:

- `pgadmin`
- port expose ra host cho database/cache/message broker/vector database neu can debug
- cac override local nhu bind mount, profile dev, debug port

Chay local infrastructure development:

```bash
docker compose -f docker-compose.infra.yml -f docker-compose.dev.yml up -d
```

Chay full local stack:

```bash
docker compose -f docker-compose.infra.yml -f docker-compose.apps.yml -f docker-compose.dev.yml up -d
```

Luu y: port HTTP cua cac application services duoc dat trong `docker-compose.apps.yml` de file `docker-compose.dev.yml` van co the chay cung `docker-compose.infra.yml` ma khong can load app services.

## 5. Nguyen tac tach

- Core infra phai chay duoc doc lap, khong phu thuoc build app.
- Dev tooling khong nam trong file infra mac dinh.
- Port expose ra host nen dat trong `docker-compose.dev.yml`.
- Cac service app chi nen ket noi qua internal Docker network.
- Secrets va credentials dat trong `.env`, khong hardcode vao compose.
- Khong dung image tag `latest` cho service quan trong; nen pin version cu the.
- Giu chung mot network de cac file compose co the override va ket noi voi nhau.

## 6. Goi y mapping tu file hien tai

| Service hien tai | File moi nen chuyen vao | Ghi chu |
|---|---|---|
| `postgres` | `docker-compose.infra.yml` | Giu volume va init script |
| `redis` | `docker-compose.infra.yml` | Giu password qua `.env` |
| `rabbitmq` | `docker-compose.infra.yml` | Management port co the dua sang dev override |
| `chromadb` | `docker-compose.infra.yml` | Nen pin image version thay vi `latest` |
| `pgadmin` | `docker-compose.dev.yml` | Chi phuc vu local admin |
| `api-gateway` | `docker-compose.apps.yml` | Phu thuoc `redis`, `business-service`, `ai-service` |
| `business-service` | `docker-compose.apps.yml` | Phu thuoc `postgres`, `redis`, `rabbitmq` |
| `ai-service` | `docker-compose.apps.yml` | Phu thuoc `chromadb` |
| `publisher-service` | `docker-compose.apps.yml` | Phu thuoc `rabbitmq` |
| `web-dashboard` | `docker-compose.apps.yml` | Phu thuoc `api-gateway` |

## 7. Thu tu refactor de an toan

1. Tao `docker-compose.infra.yml` tu cac service `postgres`, `redis`, `rabbitmq`, `chromadb`.
2. Chay test infra doc lap va kiem tra healthcheck.
3. Tao `docker-compose.apps.yml` tu cac application services.
4. Tao `docker-compose.dev.yml` cho `pgadmin` va cac port expose local.
5. Cap nhat `.env.example` neu bien moi duoc tach/doi ten.
6. Cap nhat README hoac huong dan chay stack trong thu muc `docker`.
7. Giu `docker-compose.yml` cu trong mot commit rieng neu can backward compatibility, sau do xoa hoac thay bang file huong dan khi team da dong y.

## 8. Ket luan

Nen tach compose theo huong:

- `infra` de khoi dong ha tang cot loi nhanh va on dinh.
- `apps` de chay full service khi can integration test.
- `dev` de phuc vu local development va tooling.

Cach nay giup file compose de review hon, giam rui ro khi test rieng infrastructure, va gan hon voi cach van hanh thuc te cua du an microservices.
