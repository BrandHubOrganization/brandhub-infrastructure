# Docker Compose Run Scripts

Thu muc nay chua cac script Windows `.bat` de chay, dung va don dep Docker Compose cho BrandHub.

> Luu y: cac script nay dung compose project name co dinh la `brandhub`.
> cd .\brandhub-infrastructure\docker\
---

## 1. Chuan bi `.env`

Chay tu thu muc `brandhub-infrastructure/docker`:

```powershell
Copy-Item .env.example .env
```

---

## 2. Chay infra + dev tools

Tu thu muc `brandhub-infrastructure/docker`:

```powershell
.\run\run-compose.bat
```

---

## 3. Chay full stack

Tu thu muc `brandhub-infrastructure/docker`:

```powershell
.\run\run-compose.bat full
```

Lenh nay se chay them app services tu `docker-compose.apps.yml`.

---

## 4. Dung container, giu volume

Tu thu muc `brandhub-infrastructure/docker`:

```powershell
.\run\down-compose.bat cache
```

Ket qua:

- xoa containers va network cua compose project;
- giu lai named volumes nhu `brandhub-postgres-data`, `brandhub-redis-data`, `brandhub-pgadmin-data`;
- khong xoa data database local.

---


## 5. Don dep BrandHub manh tay

Chi dung khi muon xoa sach Docker resources cua BrandHub.

Tu thu muc `brandhub-infrastructure/docker`:

```powershell
.\run\end-game\clear.bat YES
```

Script nay chi target BrandHub resources:

- compose project `brandhub`;
- containers co label `com.docker.compose.project=brandhub`;
- containers ten `brandhub-*`;
- volumes ten co `brandhub`;
- networks ten/label `brandhub`;
- images tag `brandhub*` hoac `brandhub/*`;
- Docker build cache.

Script co guard bat buoc `YES` de tranh chay nham.

Can than: lenh nay xoa BrandHub named volumes, nen data Postgres/Redis/pgAdmin local cua BrandHub se mat.

---

## 7. Lenh compose thu cong

Kiem tra config:

```powershell
docker compose -p brandhub -f docker-compose.infra.yml config
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml config
```

Chay infra + dev:

```powershell
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml up -d
```

Dung container, giu volume:

```powershell
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml down
```

Dung container, xoa volume:

```powershell
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml down -v
```

---

## 8. Guideline lien quan

- `../guidelines/pgadmin-postgres-setup-guideline.md`
