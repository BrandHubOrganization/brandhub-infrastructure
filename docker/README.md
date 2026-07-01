# Docker Compose Quick Start

## 1. Tao file `.env`

PowerShell:

```powershell
Copy-Item .env.example .env
```

Bash:

```bash
cp .env.example .env
```

Sau do sua cac bien quan trong trong `.env`: `POSTGRES_PASSWORD`, `REDIS_PASSWORD`, `JWT_SECRET`, `AES_SECRET_KEY`, `INTERNAL_SERVICE_KEY`, `PGADMIN_DEFAULT_PASSWORD`.

## 2. Kiem tra config truoc khi chay

Infra core:

```bash
docker compose -p brandhub -f docker-compose.infra.yml config
```

Infra + dev tools:

```bash
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml config
```

Khong chay rieng `docker-compose.dev.yml` vi day chi la file override.

## 3. Chay docker

### Option 1: Chay bang file `.bat`

Windows nhanh gon:

```bat
./run-compose.bat
```

Chay full stack:

```bat
./run-compose.bat full
```

Script se tu check config truoc, sau do moi chay compose.

### Option 2: Chay tung lenh

Chay PostgreSQL + Redis:

```bash
docker compose -p brandhub -f docker-compose.infra.yml up -d
```

Chay kem pgAdmin va expose port local:

```bash
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml up -d
```

Kiem tra container:

```bash
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml ps
```

## 4. Dung docker

Dung container, giu data:

```bash
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml down
```

Xoa ca data volume:

```bash
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.dev.yml down -v
```

Can than voi `down -v` vi se xoa data local cua PostgreSQL, Redis va pgAdmin.

## 6. Guideline lien quan

- `guidelines/pgadmin-postgres-setup-guideline.md`
