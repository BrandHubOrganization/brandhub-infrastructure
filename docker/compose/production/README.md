# Production

Frontend is hosted separately on private S3 through CloudFront. This Compose stack runs Nginx, API gateway, business, AI, publisher, PostgreSQL, Redis, RabbitMQ, ChromaDB and Neo4j. MongoDB Atlas remains external. pgAdmin is available only in dev/dev-ai.

Only Nginx publishes host ports: 80 redirects to HTTPS, 443 proxies to api-gateway:8080. Internal services have no published host ports. Use an SSH tunnel or a separate administration workflow when database access is needed.

Before starting:

1. Configure ../.env with production credentials, MongoDB Atlas URI, frontend HTTPS URL and OAuth callback URLs.
2. Point the API domain DNS at the EC2 instance.
3. Obtain a valid certificate for that API domain and place fullchain.pem and privkey.pem in nginx/certs/. Copy actual PEM files, not symlinks to files outside this folder. Certificate files are ignored by Git.
4. Allow inbound 80/443 on EC2. Run run_production.bat from docker/ on Windows, or the direct Docker command below on EC2.

From docker/:

~~~sh
docker compose --env-file compose/.env -f compose/production/compose.yaml config --quiet
docker compose --env-file compose/.env -f compose/production/compose.yaml up -d --remove-orphans
~~~

The Windows runner checks for certificate files before startup. Compose config validation alone does not check TLS contents. After replacing renewed certificates, run the same Compose command with exec nginx nginx -t, then exec nginx nginx -s reload instead of up. Certificate issuance/renewal and frontend deployment are not automated here.

Applications still build from sibling repositories. ECR image publishing/pulling shown in the architecture requires a separate CI/CD configuration.

Existing brandhub project and volume names are preserved. Do not run this mode alongside dev/dev-ai on the same Docker host. Switching modes removes containers outside the selected mode but retains volumes.
