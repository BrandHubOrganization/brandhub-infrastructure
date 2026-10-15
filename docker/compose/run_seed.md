# Seed PostgreSQL

```bash
docker compose --env-file .env -f shared/databases.yml -f shared/seed-postgres.yml up -d --build seed-postgres
```

# Seed Mongo

Run `seed-postgres` first: the Mongo seed reuses workspace and user IDs from Postgres.

```bash
docker compose --env-file .env -f shared/databases.yml -f shared/seed-mongo.yml up -d --build seed-mongo
```
