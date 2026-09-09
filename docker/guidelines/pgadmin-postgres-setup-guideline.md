# Guideline: pgAdmin PostgreSQL Setup

## 1. Mo pgAdmin

Chay Docker truoc:

```powershell
.\run-compose.bat
```

Mo pgAdmin:

```text
http://localhost:5050/browser/
```

Dang nhap bang gia tri trong `.env`:

```env
PGADMIN_DEFAULT_EMAIL=admin@brandhub.com
PGADMIN_DEFAULT_PASSWORD=<PGADMIN_DEFAULT_PASSWORD>
```

Neu dung gia tri mac dinh tu `.env.example`, email la:

```text
admin@brandhub.com
```

## 2. Register PostgreSQL Server

Trong pgAdmin:

1. Chon `Add New Server`.
2. Tab `General`:

```text
Name: BrandHub Local PostgreSQL
```

3. Tab `Connection`:

```text
Host name/address: postgres
Port: 5432
Maintenance database: brandhub
Username: brandhub
Password: <POSTGRES_PASSWORD>
Save password: On
```

Quan trong: trong pgAdmin phai dung host `postgres`, khong dung `localhost`.

Ly do: pgAdmin chay trong container. `localhost` ben trong pgAdmin la chinh container pgAdmin, khong phai container PostgreSQL.

## 3. Database Mac Dinh

Database mac dinh duoc tao boi `docker-compose.infra.databases.yml`:

```env
POSTGRES_DB=brandhub
POSTGRES_USER=brandhub
POSTGRES_PASSWORD=<POSTGRES_PASSWORD>
```

Sau khi register server thanh cong, vao:

```text
Servers > BrandHub Local PostgreSQL > Databases > brandhub
```

Neu thay database `brandhub`, khong can tao database moi.

## 4. Tao Database Thu Cong Neu Can

Chi tao thu cong khi:

- Da doi `POSTGRES_DB` trong `.env`.
- Volume PostgreSQL da co san tu lan chay cu.
- Init script khong tao database dung nhu mong muon.

Tao database trong pgAdmin:

1. Chuot phai `Databases`.
2. Chon `Create > Database`.
3. Dien:

```text
Database: brandhub
Owner: brandhub
```

4. Chon `Save`.

## 5. Luu Y Ve Init Script

File init script dang mount vao PostgreSQL:

```text
../scripts/init-postgres.sql
```

Script nay chi chay lan dau khi volume `brandhub-postgres-data` duoc tao.

Neu sua init script nhung database khong thay doi, do volume cu van con. Muon chay lai init script thi reset volume:

```powershell
docker compose -f docker-compose.infra.databases.yml -f docker-compose.infra.ai-data.yml -f docker-compose.infra.cache-broker.yml -f docker-compose.dev.yml down -v
.\run-compose.bat
```

Can than: `down -v` se xoa data local cua PostgreSQL, Redis va pgAdmin.

## 6. Ket Noi Tu May Host

Dung cho DBeaver/DataGrip/psql tren may Windows:

```text
Host: localhost
Port: 5432
Database: brandhub
Username: brandhub
Password: <POSTGRES_PASSWORD>
```

Khac voi pgAdmin:

- pgAdmin container -> PostgreSQL container: host `postgres`
- May host Windows -> PostgreSQL container: host `localhost`
