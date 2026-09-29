# Seed PostgreSQL

```bash
docker compose --env-file .env -f dev/compose.yaml up -d --build seed-postgres
```

# Seed Mongo

```bash
docker compose --env-file .env -f dev/compose.yaml up -d --build seed-mongo
```
