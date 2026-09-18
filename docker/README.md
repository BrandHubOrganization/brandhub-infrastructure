# Docker environments

Run from this directory in PowerShell:

| Mode | Command | Services |
| --- | --- | --- |
| dev | .\run_dev.bat | PostgreSQL, Redis, RabbitMQ, pgAdmin 4 |
| dev-ai | .\run_dev_ai.bat | dev + ChromaDB |
| production | .\run_production.bat | PostgreSQL, Redis, RabbitMQ, ChromaDB, Neo4j, API gateway, business, AI, publisher, Nginx |

Each environment has a compose.yaml under compose/dev, compose/dev-ai, or compose/production. Shared definitions live in compose/shared and are loaded with Compose include. Docker Compose must support include and the !reset YAML tag; use a recent Docker Compose v2 or v5.

All runners use compose/.env, regardless of the caller's working directory. The existing .env is preserved. If missing, the runner copies compose/.env.example and exits so you can fill in credentials before starting.

Append config to validate without starting containers, or down to stop and remove containers while keeping named volumes:

~~~powershell
.\run_dev.bat config
.\run_dev_ai.bat down
.\run_production.bat config
~~~

These are alternative modes of the same brandhub project, with existing container, network, volume names and host ports preserved. Run one mode at a time. Starting another mode uses --remove-orphans to remove services outside that mode; volumes are retained. This is not isolation between local development and a live production deployment.

Production follows the S3/CloudFront frontend architecture: no frontend container or pgAdmin. Only Nginx publishes ports 80/443; backend and database ports stay internal. TLS certificates are required before startup. See [production setup](compose/production/README.md). MongoDB remains external via MONGODB_URI. PostgreSQL initialization SQL resolves to infrastructure/scripts/init-postgres-v2.sql and runs only on an empty database volume.

For direct CLI access from docker/:

~~~powershell
docker compose --env-file compose/.env -f compose/dev/compose.yaml ps
docker compose --env-file compose/.env -f compose/production/compose.yaml logs -f
~~~

Legacy run/run.bat aliases infra, infra_ai, full map to dev, dev-ai, production. run/down-compose.bat accepts the same modes (default dev); the old cache argument is no longer supported. run/end-game/clear.bat remains a destructive manual cleanup command, not part of normal startup/shutdown.

## Clean up BrandHub Docker resources

Run .\clear_brandhub.bat --dry-run to preview, then .\clear_brandhub.bat to delete. The script requires typing DELETE and permanently removes matching containers and volumes, networks, and BrandHub image tags. It matches BrandHub names or Compose project labels, including brandhub-dev and brandhub-ai. Shared upstream images and global build cache are retained. Resources still used by other containers are not force-removed. This affects all matching environments on the current Docker context, including production.

Cleanup also covers apps.yml services (api-gateway, business-service, ai-service, publisher-service), legacy brandhub-web-dashboard containers, their BrandHub-tagged images, and dangling images labeled with a BrandHub Compose project. apps.yml currently declares no app-specific volumes; shared BrandHub volumes and networks are already included. Source files are never deleted by cleanup.
